import express, { Express, Request, Response } from 'express';
import { config } from "./config";
import { getMatchingInteractions, insertInteraction } from './resources/interactions';

const app: Express = express();


app.get('/test', (req, res) => {
    res.send('Express + TypeScript Server');
});

app.get('/', (req: Request, res: Response) => {
    let content = "Dodge this"
    insertInteraction(1, content).then((id) => {
        res.status(200).send({ id:  id});
    })
    getMatchingInteractions(1, content).then((matches) => {
        res.status(200).send(matches);
    })
    
});

app.listen(config.server.port, () => {
    return console.log(`[server]: Server is running on ${config.server.port}`);
});