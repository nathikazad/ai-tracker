import express, { Express, Request, Response, NextFunction } from 'express';
import { config } from "./config";
import path from 'path';
import { convertAudioToText } from './helper/audio';
import { createServer } from 'http';
import { WebSocketServer, WebSocket } from 'ws';
import { ConnectionManager } from './socketManager';
import { authorize, convertAppleJWTtoHasuraJWT, deleteUser } from './resources/authorization';
import { parseUserRequest } from './resources/logic';
import { getUserLanguage } from './resources/user';
// import { processMovement, setNameForLocation } from './helper/location';
import { uploadSleep } from './helper/sleep';
import { addUserMovement, saveLocation } from './resources/location/location2';
import { log } from 'console';
import { notifyOtherMembers } from './helper/notification';

const app: Express = express();

const server = createServer(app);

// Create WebSocket server
const wss = new WebSocketServer({ server });
const wsManager = new ConnectionManager();

// Set up WebSocket connection handling
wss.on('connection', (ws: WebSocket) => {
    wsManager.handleConnection(ws);
});

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

// "chat_id": 1,
// "id": 75,
// "member_id": 1,
// "payload": {
//     "message": "Test"
// },
// "time": "2024-08-21T21:50:28.361207+00:00"
app.post('/notifyParticipants', async (req, res) => {
    if (req.headers['secret_key'] != "iloveyareni") {
        console.log("Incorrect key")
        res.status(401).json({ error: "Incorrect key" });
        return
    }
    let message = req.body.event.data.new
    notifyOtherMembers(message.chat_id, message.member_id, message.payload.message)
    res.status(200).json({
        status: "success"
    });
});

app.get('/ping', (req, res) => {
    res.send('pong');
});

server.listen(config.server.port, () => {
    return console.log(`[server]: Server is running on ${config.server.port}`);
});