
import { makeFetchRequest, getTime } from './utils.js';
import { fetchEvents } from './events.js';

// Initial load functions
window.onload = function () {
    fetchEvents();
    loadPrompt();
};

function loadPrompt() {
    makeFetchRequest('getprompt', 'GET')
        .then(data => updatePromptValue(data.prompt));
}

document.getElementById('submit-btn').addEventListener('click', function () {
    const prompt = document.getElementById('prompt').value;
    const query = document.getElementById('query').value;

    makeFetchRequest('convertMessageToEvent', 'POST', { prompt, query, time: getTime() })
        .then(response => {
            showGql(response.gql);
            fetchEvents(); // Assuming fetchEvents is defined elsewhere and does not require modification.
        });
});

document.getElementById('get-gql-btn').addEventListener('click', function () {
    const prompt = document.getElementById('prompt').value;
    const query = document.getElementById('query').value;

    makeFetchRequest('getgql', 'POST', { prompt, query, time: getTime() })
        .then(response => {
            showGql(response.gql);
        });
});

function showGql(gql) {
    // Format the server response for display
    const gqlArea = document.getElementById('gql-area');
    gqlArea.style.display = 'block';
    document.getElementById('copyBtn').style.display = 'block';
    gqlArea.textContent = gql.trim(); 
    // Copy to clipboard functionality
    document.getElementById('copyBtn').addEventListener('click', function() {
        const textarea = document.getElementById('response');
        textarea.select();
        document.execCommand('copy');
        
        // Optional: Show a message that the text was copied.
        alert('Copied to clipboard!');
    });
}

// Function to update the textarea's value
function updatePromptValue(newValue) {
    document.getElementById('prompt').value = newValue;
}

// Event listener for the modify button
document.getElementById('modify-btn').addEventListener('click', function () {
    const prompt = document.getElementById('prompt').value;
    const query = document.getElementById('query').value;

    makeFetchRequest('modifyPrompt', 'POST', { prompt, query })
        .then(data => updatePromptValue(data.newPrompt));
});

// Event listener for the save button
document.getElementById('save-btn').addEventListener('click', function () {
    const prompt = document.getElementById('prompt').value;

    makeFetchRequest('savePrompt', 'POST', { prompt })
        .then(data => console.log(data));
});

// Event listener for the reload button
document.getElementById('reload-btn').addEventListener('click', function () {
    makeFetchRequest('getprompt', 'GET')
        .then(data => updatePromptValue(data.prompt));
});