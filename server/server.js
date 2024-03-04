"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const busboy_1 = __importDefault(require("busboy"));
const app = (0, express_1.default)();
const PORT = 3000;
// Middleware to handle multipart/form-data
app.use((req, res, next) => {
    var _a;
    if (req.method === 'POST' && ((_a = req.headers['content-type']) === null || _a === void 0 ? void 0 : _a.startsWith('multipart/form-data'))) {
        const bb = (0, busboy_1.default)({ headers: req.headers });
        req.files = [];
        req.body = {};
        bb.on('file', (fieldname, file, info) => {
            const { filename, encoding, mimetype } = info;
            const saveTo = path_1.default.join(__dirname, 'uploads', path_1.default.basename(filename));
            file.pipe(fs_1.default.createWriteStream(saveTo));
            file.on('end', () => {
                var _a;
                (_a = req.files) === null || _a === void 0 ? void 0 : _a.push({
                    fieldname,
                    filename,
                    encoding,
                    mimetype,
                    path: saveTo
                });
            });
        });
        bb.on('field', (fieldname, val) => {
            console.log(`Field [${fieldname}]: value: ${val}`);
            if (req.body)
                req.body[fieldname] = val;
        });
        bb.on('finish', () => {
            console.log('Done parsing form!');
            next();
        });
        req.pipe(bb);
    }
    else {
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
