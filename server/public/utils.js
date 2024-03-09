export function makeFetchRequest(url, method, body = null) {
    // Create the initial request configuration
    const config = {
        method: method,
        headers: {
            'Content-Type': 'application/json',
        },
    };

    // Conditionally add the body to the request configuration if method is not GET
    if (method !== 'GET' && body !== null) {
        config.body = JSON.stringify(body);
    }

    return fetch(url, config)
        .then(response => response.json())
        .catch(error => console.error('Error:', error));
}

export function getTime() {
    const now = new Date();

    // Get the time zone offset in minutes, then convert it to hours and minutes
    const timeZoneOffset = now.getTimezoneOffset();
    const offsetSign = timeZoneOffset > 0 ? "-" : "+"; // Invert sign because the offset is reversed
    const offsetHours = String(Math.floor(Math.abs(timeZoneOffset) / 60)).padStart(2, '0');
    const offsetMinutes = String(Math.abs(timeZoneOffset) % 60).padStart(2, '0');

    // Format the current date and time
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0'); // getMonth() is zero-based
    const day = String(now.getDate()).padStart(2, '0');
    const hours = String(now.getHours() % 12 || 12).padStart(2, '0'); // Convert 24h to 12h format
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');
    const ampm = now.getHours() >= 12 ? 'PM' : 'AM';

    // Construct the formatted date and time string with time zone offset
    const formattedDateTimeWithTimeZone = `${year}-${month}-${day}, ${hours}:${minutes}:${seconds} ${ampm} ${offsetSign}${offsetHours}:${offsetMinutes}`;

    return formattedDateTimeWithTimeZone;
}
