import express, { Express, Request, Response } from 'express';
import { config } from "./config";
import { deleteInteraction, getInteractions, getMatchingInteractions, insertInteraction } from './resources/interactions';
import path from 'path';
import { deleteEvent, getEvents } from './resources/events';
import { convertMessageToEvent } from './resources/ai';
import { getPrompt, loadPromptApi, savePrompt  } from './resources/prompt';
import { convertAudioToInteraction } from './helper/receiveFile';

const app: Express = express();

app.use(express.static(path.join(__dirname, '../public')));
app.use(express.json());

loadPromptApi(app)
app.post('/convertAudioToInteraction', convertAudioToInteraction);

app.get('/test', (req, res) => {
    res.send('Express + TypeScript Server');
});

app.get('/dodge', (req: Request, res: Response) => {
    let content = "Dodge this"
    insertInteraction(1, content).then((id) => {
        res.status(200).send({ id:  id});
    })
    getMatchingInteractions(1, content).then((matches) => {
        res.status(200).send(matches);
    })
    
});

app.post('/convertMessageToEvent', async (req, res) => {
    console.log(req.body.time, ": ", req.body.query);
    let prompt = getPrompt()
    
    if(config.testing)
        savePrompt({prompt}); 

    // const gql = await convertMessageToEvent(prompt, req.body.query, req.body.time)
    await insertInteraction(1, req.body.query);
    res.json({
        // gql
    });
});

app.post('/getgql', async (req, res) => {
    console.log(req.body.time, ": ", req.body.query);
    savePrompt({prompt: req.body.prompt});
    let gql = await convertMessageToEvent(req.body.prompt, req.body.query, req.body.time, true)
    res.json({
        gql
    });
});




app.get('/getevents', async (req, res) => {    
    let events = await getEvents({ user_id: 1 });
    res.json(JSON.parse(JSON.stringify(events)));
    
});

app.get('/getInteractions', async (req, res) => {    
    let interactions = await getInteractions({ user_id: 1 });
    res.json(JSON.parse(JSON.stringify(interactions)));
    
});

app.delete('/interaction/:id', (req, res) => {
    const { id } = req.params;
    deleteInteraction(parseInt(id))
        .then(response => res.json(response))
        .catch(error => {
            console.error('Failed to delete event:', error);
            res.status(500).json({ success: false, message: 'Failed to delete event.' });
        });
});


app.delete('/event/:id', (req, res) => {
    const { id } = req.params;
    deleteEvent(parseInt(id))
        .then(response => res.json(response))
        .catch(error => {
            console.error('Failed to delete event:', error);
            res.status(500).json({ success: false, message: 'Failed to delete event.' });
        });
});


app.listen(config.server.port, () => {
    return console.log(`[server]: Server is running on ${config.server.port}`);
});