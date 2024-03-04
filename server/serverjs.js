const express = require('express');
const fs = require('fs');
const path = require('path');
const busboy = require('busboy'); // Ensure Busboy is installed

const app = express();
const PORT = 3000;

// Middleware to handle multipart/form-data
app.use((req, res, next) => {
    if (req.method === 'POST' && req.headers['content-type'].startsWith('multipart/form-data')) {
        const bb = busboy({ headers: req.headers });
        req.files = []; // To store file info

        bb.on('file', (fieldname, file, info) => {
            const filename = info.filename; // Correct way to access the filename
            const saveTo = path.join(__dirname, 'uploads', path.basename(filename));
            file.pipe(fs.createWriteStream(saveTo));
            file.on('end', () => {
                req.files.push({
                    fieldname,
                    filename,
                    encoding: info.encoding,
                    mimetype: info.mimetype,
                    path: saveTo
                });
            });
        });
        

        bb.on('field', (fieldname, val) => {
            console.log(`Field [${fieldname}]: value: ${val}`);
            req.body = req.body || {};
            req.body[fieldname] = val;
        });

        bb.on('finish', () => {
            console.log('Done parsing form!');
            next();
        });

        req.pipe(bb);
    } else {
        next();
    }
});

// Define a POST endpoint to handle the form submission
app.post('/post', (req, res) => {
    console.log('Files:', req.files); // Files that were uploaded
    console.log('Body:', req.body); // Other fields in the form
    res.status(200).send('Files and data received successfully.');
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
