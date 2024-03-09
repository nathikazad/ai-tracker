import { makeFetchRequest } from './utils.js';

// Refactored fetchEvents to use the makeFetchRequest function
export function fetchEvents() {
    makeFetchRequest('getevents', 'GET')
        .then(events => loadEvents(events));
}


function loadEvents(events) {
    const tableBody = document.getElementById('response-table').getElementsByTagName('tbody')[0];
    tableBody.innerHTML = ''; // Clear existing rows
    // Assuming data is an array of objects with properties matching the table columns
    events.forEach(event => {
        const newRow = tableBody.insertRow();
        console.log(event);
        insertCellWithDeleteButton(newRow, event.id, event);
        insertCell(newRow, event.event_type_object.parent_tree)
        insertCell(newRow, dateToString(event.start_time))
        insertCell(newRow, dateToString(event.end_time))
        insertCell(newRow, JSON.stringify(event.metadata))
        insertCell(newRow, event.status)
    });
}

function insertCell(newRow, data) {
    const newCell = newRow.insertCell();
    const newText = document.createTextNode(data);
    newCell.appendChild(newText);
}

function dateToString(utcTime) {
    if (!utcTime)
        return ""
    console.log(utcTime);

    const date = new Date(utcTime + 'Z'); // Add 'Z' to indicate UTC time
    const userLocalTime = date.toLocaleString('en-US', { timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone });

    return userLocalTime;
}

function tagsToString(tags) {
    return tags.map(tag => tag.tag.name).join(',');
}

function insertCellWithDeleteButton(newRow, data, event) {
    const newCell = newRow.insertCell();
    const newText = document.createTextNode(data);
    newCell.appendChild(newText);

    // Create a delete button
    const deleteButton = document.createElement('button');
    deleteButton.textContent = 'Delete';
    deleteButton.onclick = function () {
        deleteEvent(event.id); // Call delete API function
    };
    newCell.appendChild(deleteButton);
}

function deleteEvent(eventId) {
    // Implement the API call to delete the event using the eventId
    console.log('Deleting event with ID:', eventId);
    // Example fetch call
    fetch('event/' + eventId, { method: 'DELETE' })
        .then(response => response.json())
        .then(data => {
            console.log('Delete successful', data);
            fetchEvents()
        })
        .catch((error) => {
            console.error('Error:', error);
        });
}