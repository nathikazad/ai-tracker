import { getHasura } from "../config";
import { todo_constraint } from "../generated/graphql-zeus";

export async function generateTodosFromGoals(user_id: number) {
    const chain = getHasura();
    let goals = await chain.query({
        goal: [{
            where: { _and: [{ user_id: { _eq: user_id } }, { status: { _eq: "active" } }] },
        }, {
            id: true,
            name: true,
            period: true,
            last_todo_mutated: true,
            target_number: true
        }]
    });
    goals.goal.forEach(async (goal: any) => {
        console.log(goal.name);
        if (goal.last_todo_mutated === null || checkIfTimeForNewTodo()) {
            let response = await chain.mutation({
                insert_todo_one: [{
                    object: {
                        name: goal.name,
                        goal_id: goal.id,
                        user_id: user_id,
                        target_count: goal.target_number,
                        current_count: 0
                    },
                    on_conflict: {
                        constraint: todo_constraint.todo_goal_id_user_id_key,
                        update_columns: []
                    }
                }, {
                    id: true
                }],
                update_goal_by_pk: [{
                    pk_columns: { id: goal.id },
                    _set: {
                        last_todo_mutated: new Date().toISOString()
                    }
                }, {
                    id: true
                }]

            })
            console.log(response);
        }

        function checkIfTimeForNewTodo(): boolean {
            return new Date().getTime() - new Date(goal.last_todo_mutated).getTime() > ((goal.period * 24 - 2) * (60 * 60 * 1000));
        }
    });
}
