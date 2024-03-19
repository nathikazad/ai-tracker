import { Request, Response, NextFunction } from 'express';
import fs from 'fs';
import path from 'path';
import Busboy from 'busboy';
import { speechToText } from '../third/openai';



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
        var text: string | undefined;
        var speechToTextPromise: Promise<any> | undefined;

        bb.on('file', (fieldname: string, file: NodeJS.ReadableStream, info: { filename: string; encoding: string; mimetype: string }) => {
            const { filename, encoding, mimetype } = info;
            const uploadDir = path.join(__dirname, 'uploads');
            if (!fs.existsSync(uploadDir)) {
                fs.mkdirSync(uploadDir);
            }
            const saveTo = path.join(uploadDir, path.basename(filename));
            file.pipe(fs.createWriteStream(saveTo));
            file.on('end', () => {
                const newFile = {
                    fieldname,
                    filename,
                    encoding,
                    mimetype,
                    path: saveTo
                };
                
                if (req.files) {
                    req.files!.push(newFile);
                    speechToTextPromise = speechToText(newFile.path).then((value) => {
                        text = value.text;
                    });
                }
                
            });
        });

        bb.on('field', (fieldname: string, val: any) => {
            if (req.body) req.body[fieldname] = val;
        });

        bb.on('finish', () => {
            if (speechToTextPromise) {
                speechToTextPromise.then(() => {
                    res.status(200).send(text);
                    next();
                });
            } else {
                next();
            }
        });

        req.pipe(bb);
    } else {
        next();
    }
}