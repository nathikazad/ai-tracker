
import express, { Express, Request, Response, NextFunction } from 'express';
import { config } from "./config";
import path from 'path';
import { convertAudioToText } from './helper/audio';

import { authorize, convertAppleJWTtoHasuraJWT } from './resources/authorization';
import { parseUserRequest } from './resources/logic';
import { getUserLanguage } from './resources/user';
import { processMovement, setNameForLocation } from './helper/location';
const app: Express = express();

app.use(express.static(path.join(__dirname, '../public')));
app.use(express.json());


app.post('/parseUserRequestFromAudio', async (req: Request, res: Response, next: NextFunction) => {
    console.log(`inside parseUserRequestFromAudio`)
    try {
        const userId = authorize(req); 
        console.log(`userId: ${userId}`)

        let userLanguage = await getUserLanguage(userId)
        convertAudioToText(req, res, userLanguage, next, async (text: string) => {
            try {
                parseUserRequest(text.replace(/"/g, '').trim(), userId); 
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

app.post('/updateMovement', async (req: Request, res: Response) => {
    try {
        const userId = authorize(req); 
        try {
            console.log(`🏃🏽🏃🏽🏃🏽🏃🏽🏃🏽🏃🏽🏃🏽 ${userId} ${req.body?.eventType}`)
            // console.log(req.body)
            processMovement(userId, req.body); 
            // console.log("success")
            res.status(200).json({
                status: "success",
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

app.post('/createLocation', async (req: Request, res: Response) => {
    try {
        const userId = authorize(req); 
        try {
            console.log(`Set location ${userId} ${req.body?.eventType}`)
            console.log(req.body)
            setNameForLocation(userId, req.body?.lon, req.body?.lat, req.body?.name);
            // console.log("success")
            res.status(200).json({
                status: "success",
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
        let jwt = await convertAppleJWTtoHasuraJWT(req.body.appleKey, req.body.username, req.body.language)
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