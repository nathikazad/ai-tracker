import { getHasura } from "../config";
import { todos_constraint, todos_update_column, ValueTypes } from "../generated/graphql-zeus";

export async function generateTodosFromGoals(user_id?: number | null) {
    const chain = getHasura();
    const user_filter: ValueTypes['Int_comparison_exp'] = {
        _eq: user_id ?? undefined
    };
    let response = await chain.query({
        goals: [{
            where: { _and: [{ user_id: user_filter }, { status: { _eq: "active" } }] },
        }, {
            id: true,
            name: true,
            frequency: [{}, true],
            status: true,
            user_id: true,
            user: {
                timezone: true
            },
            todo: {
                updated: true
            }
        }]
    });
    const goalsList: Goal[] = response.goals.map((goal): Goal => {
        return {
            id: goal.id,
            user_id: goal.user_id,
            name: goal.name,
            status: goal.status,
            frequency: goal.frequency,
            last_todo_updated: goal.todo?.updated,
            user_timezone: goal.user?.timezone ?? 'America/Los_Angeles'
        };
    });

    generateTodos(goalsList);
    async function generateTodos(goalsList: Goal[]) {
        console.log("checking if time to generate todo for goal");
        goalsList.forEach(async (goal: Goal) => {
            // Check if it's time for a new todo based on the goal's frequency
            let checkIfTime = checkIfTimeForNewTodo(goal)
            console.log(`time for ${goal.name}? ${checkIfTime}`)
            if (goal.last_todo_updated === null || checkIfTime) {
                let response = await chain.mutation({
                    insert_todos_one: [{
                        object: {
                            name: goal.name,
                            goal_id: goal.id,
                            user_id: goal.user_id,
                            current_count: 0,
                            status: "todo",
                            updated: new Date().toISOString()
                        },
                        on_conflict: {
                            constraint: todos_constraint.todo_goal_id_user_id_key,
                            update_columns: [todos_update_column.status, todos_update_column.current_count, todos_update_column.updated]
                        }
                    }, {
                        id: true
                    }]
                });
                console.log(response);
            }
        });
    }

    function checkIfTimeForNewTodo(goal: Goal): boolean {
        const now = new Date(new Date().toLocaleString("en-US", { timeZone: goal.user_timezone }));
        const today = new Date(now);
        today.setHours(0, 0, 0, 0); // Set 'today' to midnight in user's timezone
    
        const lastMutationDate = new Date(goal.last_todo_updated || 0);
        const lastMutationDay = new Date(new Date(lastMutationDate).toLocaleString("en-US", { timeZone: goal.user_timezone }));
        lastMutationDay.setHours(0, 0, 0, 0); // Set 'lastMutationDay' to midnight in user's timezone
    
        const isNewDaySinceLastMutation = today > lastMutationDay;
        if (!isNewDaySinceLastMutation) return false; // If not a new day since last mutation, exit early
    
        switch (goal.frequency.type) {
            case 'periodic': {
                // Assuming 'period' is in days and we simply check if the required number of days have passed
                const periodInMilliseconds = (goal.frequency.period || 1) * 24 * 60 * 60 * 1000;
                return now.getTime() - lastMutationDay.getTime() >= periodInMilliseconds;
            }
            case 'weekly': {
                const todayDayName = today.toLocaleDateString('en-US', { timeZone: goal.user_timezone, weekday: 'long' }).toLowerCase();
                const weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
                const isWeekday = weekdays.includes(todayDayName);
                const isWeekend = todayDayName === 'saturday' || todayDayName === 'sunday';
    
                // Special handling for "weekdays" and "weekends"
                if (goal.frequency.daysOfWeek?.includes('weekdays') && isWeekday) return true;
                if (goal.frequency.daysOfWeek?.includes('weekends') && isWeekend) return true;
    
                // Check for specific days
                const dayMatch = goal.frequency.daysOfWeek?.some(day => {
                    const dayLower = day.toLowerCase();
                    return (dayLower === todayDayName) ||
                           (dayLower === 'weekdays' && isWeekday) ||
                           (dayLower === 'weekends' && isWeekend);
                });
    
                return !!dayMatch;
            }
            default: {
                // Handle any other frequency types or lack thereof
                return false;
            }
        }
    }
}



export interface Frequency {
    type: 'weekly' | 'periodic';
    daysOfWeek?: string[]; // For 'weekly' type schedules
    timesPerDay: number;
    preferredHours?: string[];
    duration?: string; // Optional, for schedules that specify a duration
    period?: number; // Optional, for 'periodic' type schedules
}


export interface Goal {
    id: number;
    name: string;
    status: string;
    frequency: Frequency;
    last_todo_updated: string;
    user_timezone: string
    user_id: number
}

// {
//     "type": "weekly",
//     "days": ["weekdays"],
//     "timesPerDay": 1,
//     "preferredHours": ["20:00"],
//     "duration": "1:00"
// }

// {
//     "type": "weekly",
//     "days": ["monday", "wednesday", "friday"],
//     "timesPerDay": 1,
//     "preferredHours": ["08:00"]
// }

// {
//     "type": "periodic",
//     "period": 1,
//     "timesPerDay": 5,
//     "preferredHours": [
//         "05:00", "01:00", "04:00", "06:00", "08:00"
//     ]
// }