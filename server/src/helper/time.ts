export function toDate(dateString: string): Date {
    dateString = dateString.split('.')[0];  
    dateString = dateString.split('+')[0];  
    dateString += dateString.endsWith('Z') ? '' : 'Z';
    return new Date(dateString);
}
export function toPST(dateString: string | undefined): string {
    if (!dateString) {
        return 'N/A';
    }
    const date = toDate(dateString);
    const pstDate = date.toLocaleString('en-US', {
        timeZone: 'America/Los_Angeles',
        hour12: true,
        month: '2-digit',
        day: '2-digit',
        hour: 'numeric',
        minute: '2-digit',
        second: '2-digit'
    });
    return pstDate;
}

export function getCostTimeInSeconds(start: string, end: string): number {
    const startTime = toDate(start);
    const endTime = toDate(end);
    return Math.floor((endTime.getTime() - startTime.getTime()) / 1000);
}

export function differnceInMinutes(timestampone: string, timestamptwo: string): string {
    let difference_start = Math.abs(new Date(timestampone).getTime() - new Date(timestamptwo).getTime()) / 1000
    return secondsToHHMM(difference_start)
}

export function addHoursToTimestamp(timestamp: string, hours: number): string {
    if (!timestamp) {
        undefined
    }
    const date = toDate(timestamp!);
    date.setHours(date.getHours() + hours);
    return date.toISOString();
}

export function secondsToHHMM(seconds: number): string {
    const hours: number = Math.floor(seconds / 3600);
    const remainingSecondsAfterHours: number = seconds % 3600;
    const minutes: number = Math.floor(remainingSecondsAfterHours / 60);
    // const remainingSeconds: number = remainingSecondsAfterHours % 60;

    const formattedHours: string = String(hours).padStart(2, '0');
    const formattedMinutes: string = String(minutes).padStart(2, '0');
    // const formattedSeconds: string = String(remainingSeconds).padStart(2, '0');

    return `${formattedHours}:${formattedMinutes}`;
}


export function getStartOfDay(timestamp: string): string {
    let date = new Date(timestamp);
    date.setUTCHours(0, 0, 0, 0);
    return date.toISOString();
}

export function addHours(date: Date, hours: number): Date {
    return new Date(date.getTime() + hours * 60 * 60 * 1000)
}
