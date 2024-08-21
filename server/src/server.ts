import apn from 'apn';
import express, { Express, Request, Response, NextFunction } from 'express';
import { config } from "./config";
import path from 'path';
import { convertAudioToText } from './helper/audio';

import { authorize, convertAppleJWTtoHasuraJWT, deleteUser, getHasuraUserDeviceToken } from './resources/authorization';
import { parseUserRequest } from './resources/logic';
import { getUserLanguage } from './resources/user';
// import { processMovement, setNameForLocation } from './helper/location';
import { uploadSleep } from './helper/sleep';
import { addUserMovement, saveLocation } from './resources/location/location2';
import { log } from 'console';
import { ApnsNotificationSender } from './helper/notification';
const app: Express = express();

app.use(express.static(path.join(__dirname, '../public')));
app.use(express.json());


app.post('/parseUserRequestFromAudio', async (req: Request, res: Response, next: NextFunction) => {
    console.log(`inside parseUserRequestFromAudio`)
    console.log(req.headers.parse)
    console.log(req.headers.parenteventid)
    try {
        const userId = authorize(req);
        console.log(`userId: ${userId}`)

        let userLanguage = await getUserLanguage(userId)
        convertAudioToText(req, res, userLanguage, next, async (text: string) => {
            try {
                console.log(`final text2: ${text}`);
                if (req.headers.parse) {
                    console.log(`parsing text: ${text}`)
                    let parentEventId = req.headers.parenteventid ? parseInt(req.headers.parenteventid as string) : undefined;
                    parseUserRequest(text.replace(/"/g, '').trim(), userId, parentEventId);
                }
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
        const parentEventId = req.body["parentEventId"] ? parseInt(req.body["parentEventId"] as string) : undefined;
        console.log(parentEventId)
        try {
            await parseUserRequest(text, userId, parentEventId);
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


app.post('/updateLocation', async (req: Request, res: Response) => {
    try {
        const userId = authorize(req);
        try {
            console.log(`🦵🏻🦵🏻🦵🏻🦵🏻 ${userId} ${req.body}`)
            console.log(req.body)
            await addUserMovement(userId, req.body.locations, req.body.fromBackground || false);
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

app.post('/uploadSleep', async (req: Request, res: Response) => {
    try {
        const userId = authorize(req);
        try {
            console.log(`uploadSleep ${userId}`)
            console.log(JSON.stringify(req.body.sleepData))
            uploadSleep(userId, req.body.sleepData);
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
            console.log(`Set location ${userId} ${req.body}`)
            let id = await saveLocation(userId, { lat: req.body!.lat, lon: req.body!.lon }, req.body!.name)
            // console.log("success")
            res.status(200).json({
                status: "success",
                id: id
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

app.post('/deleteUser', async (req, res) => {
    try {
        const userId = authorize(req);
        let jwt = await deleteUser(userId)
        res.status(200).json({
            status: "success",
            jwt: jwt
        });
    } catch (error) {
        console.error('deleting user:', error);
        res.status(401).json({ error: error });
    }
});

app.post('/notifyParticipants', async (req, res) => {
    let deviceToken = await getHasuraUserDeviceToken(1)
    if (deviceToken) {
        const sender = new ApnsNotificationSender();
        const notification = new apn.Notification();

        notification.alert = {
            title: 'Hello',
            body: 'This is a test notification'
        };
        notification.topic = 'com.snow.aspire';

        try {
            await sender.sendNotification(deviceToken, notification);
        } catch (error) {
            console.error('Failed to send notification:', error);
        } finally {
            sender.shutdown();
        }
    }
});

app.get('/ping', (req, res) => {
    res.send('pong');
});

app.listen(config.server.port, () => {
    return console.log(`[server]: Server is running on ${config.server.port}`);
});