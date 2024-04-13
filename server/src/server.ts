
import express, { Express, Request, Response, NextFunction } from 'express';
import { config } from "./config";
import path from 'path';
import { convertAudioToText } from './helper/receiveFile';

import { authorize, convertAppleJWTtoHasuraJWT } from './resources/authorization';
import { parseUserRequest } from './resources/logic';
import { isSpanish } from './helper/language';
const app: Express = express();

app.use(express.static(path.join(__dirname, '../public')));
app.use(express.json());

// app.post('/parseUserRequest', convertAudioToInteraction);


app.post('/parseUserRequestFromAudio', async (req: Request, res: Response, next: NextFunction) => {
    console.log(`inside parseUserRequestFromAudio`)
    try {
        const userId = authorize(req); 
        console.log(`userId: ${userId}`)
        convertAudioToText(req, res, next, async (text: string) => {
            try {
                console.log(`pre translation text: ${text}`);
                text = (await isSpanish(text)) || text;
                console.log(`post translation text: ${text}`);
                await parseUserRequest(text, userId); 
                res.status(200).json({
                    status: "success",
                    text: text
                });
                return; // This ensures that the control ends here after sending the response
            } catch (parseError) {
                console.error('Parsing error:', parseError);
                res.status(500).json({ error: 'Error processing text' });
                return; // Prevent further execution in case of an error
            }
        });
    } catch (authError) {
        console.error('Authentication error:', authError);
        res.status(401).json({ error: 'Unauthorized: ' + authError });
    }
});

app.post('/parseUserRequestFromText', async (req: Request, res: Response) => {
    try {
        const userId = authorize(req); 
        const text = req.body["text"]    
        try {
            parseUserRequest(text, userId); 
            res.status(200).json({
                status: "success",
                text: text
            });
        } catch (parseError) {
            console.error('Parsing error:', parseError);
            res.status(500).json({ error: 'Error processing text' });
        }
    } catch (authError) {
        console.error('Authentication error:', authError);
        res.status(401).json({ error: 'Unauthorized: ' + authError });
    }
});



app.post('/hasuraJWT', async (req, res) => {
    try {
        let jwt = await convertAppleJWTtoHasuraJWT(req.body.appleKey)
        res.status(200).json({
            status: "success",
            jwt: jwt
        });
    } catch (error) {
        console.error('hasuraJWT:', error);
        res.status(401).json({ error: error });
    }
    
});

app.listen(config.server.port, () => {
    return console.log(`[server]: Server is running on ${config.server.port}`);
});