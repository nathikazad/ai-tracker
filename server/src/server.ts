// import express, { Request, Response, NextFunction } from 'express';
// import fs from 'fs';
// import path from 'path';
// import Busboy from 'busboy';

// const app = express();
// const PORT = process.env.PORT || 5001

// interface File {
//     fieldname: string;
//     filename: string;
//     encoding: string;
//     mimetype: string;
//     path: string;
// }

// declare module 'express-serve-static-core' {
//     interface Request {
//         files?: File[];
//         // body?: any;
//     }
// }

// app.get('/', (req, res) => {
//     res.send('Express + TypeScript Server');
// });


// // Middleware to handle multipart/form-data
// app.use((req: Request, res: Response, next: NextFunction) => {
//     if (req.method === 'POST' && req.headers['content-type']?.startsWith('multipart/form-data')) {
//         const bb = Busboy({ headers: req.headers });
//         req.files = [];
//         req.body = {};

//         bb.on('file', (fieldname: string, file: NodeJS.ReadableStream, info: { filename: string; encoding: string; mimetype: string }) => {
//             const { filename, encoding, mimetype } = info;
//             const saveTo = path.join(__dirname, 'uploads', path.basename(filename));
//             file.pipe(fs.createWriteStream(saveTo));
//             file.on('end', () => {
//                 req.files?.push({
//                     fieldname,
//                     filename,
//                     encoding,
//                     mimetype,
//                     path: saveTo
//                 });
//             });
//         });

//         bb.on('field', (fieldname: string, val: any) => {
//             console.log(`Field [${fieldname}]: value: ${val}`);
//             if (req.body) req.body[fieldname] = val;
//         });

//         bb.on('finish', () => {
//             console.log('Done parsing form!');
//             next();
//         });

//         req.pipe(bb);
//     } else {
//         next();
//     }
// });

// // Define a POST endpoint to handle the form submission
// app.post('/post', (req: Request, res: Response) => {
//     console.log('Files:', req.files); // Files that were uploaded
//     console.log('Body:', req.body); // Other fields in the form
//     res.status(200).send('Files and data received successfully.');
// });

// // Start the server
// app.listen(PORT, () => {
//     console.log(`Server running on http://localhost:${PORT}`);
// });


import express, { Express, Request, Response } from 'express';
import {config} from "./config";

const app: Express = express();

app.get('/', (req: Request, res: Response) => {
    res.send('Code with Rico. Ready to run on Heroku.');
});

app.listen(config.server.port, () => {
    return console.log(`[server]: Server is running on ${config.server.port}`);
});