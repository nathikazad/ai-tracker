import { Request, Response, NextFunction } from 'express';
import fs from 'fs';
import path from 'path';
import Busboy from 'busboy';
import OpenAI from 'openai';

import { config } from "./../config";

const openai = new OpenAI({
  apiKey: config.openApiKey, // This is the default and can be omitted
});
// const app: Express = express();

interface File {
    fieldname: string;
    filename: string;
    encoding: string;
    mimetype: string;
    path: string;
}

// Extend the Request interface to include the files and body property
declare module 'express-serve-static-core' {
    interface Request {
        files?: File[];
    }
}

// // Middleware to handle multipart/form-data
export function convertAudioToInteraction(req: Request, res: Response, next: NextFunction) {
    if (req.method === 'POST' && req.headers['content-type']?.startsWith('multipart/form-data')) {
        const bb = Busboy({ headers: req.headers });
        req.files = []; // Ensure files is initialized
        req.body = {};

        bb.on('file', (fieldname: string, file: NodeJS.ReadableStream, info: { filename: string; encoding: string; mimetype: string }) => {
            const { filename, encoding, mimetype } = info;
            const saveTo = path.join(__dirname, 'uploads', path.basename(filename));
            file.pipe(fs.createWriteStream(saveTo));
            file.on('end', () => {
                const newFile = {
                    fieldname,
                    filename,
                    encoding,
                    mimetype,
                    path: saveTo
                };
                req.files?.push(newFile);
                if (req.files) {
                    openai.audio.transcriptions.create({
                        file: fs.createReadStream(newFile.path),
                        model: "whisper-1" 
                    }).then((value) => {
                        console.log(value.text)
                    });
                }
            });
        });

        bb.on('field', (fieldname: string, val: any) => {
            if (req.body) req.body[fieldname] = val;
        });

        bb.on('finish', () => {
            next();
        });

        req.pipe(bb);
    } else {
        next();
    }
}