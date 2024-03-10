import * as fs from 'fs';
import * as path from 'path';
import{ Express } from 'express';
import { complete } from '../third/openai';


export function loadPromptApi(app:Express) {
    app.get('/getprompt', async (req, res) => {    
        let prompt = await getPrompt();
        res.json({
            prompt
        });
    });

    app.post('/savePrompt', async (req, res) => {
        savePrompt({prompt: req.body.prompt});
        res.json({
            status: "success"
        });
    });

    app.post('/modifyPrompt', async (req, res) => {
        const newPrompt = await modifyPrompt({ oldPrompt: req.body.prompt, instruction: req.body.query })
        res.json({
            newPrompt
        });
    });
}



const directoryPath: string = './prompts';

function getMaxVersionNumber(files: string[]): number {
    return files
        .map(file => parseInt(file.match(/\d+/)?.[0] ?? '0', 10))
        .reduce((max, curr) => Math.max(max, curr), 0);
}

function readLatestPrompt(maxVersionNumber: number): string {
    if (maxVersionNumber === 0) {
        return '';
    }
    const latestFilePath = path.join(directoryPath, `v${maxVersionNumber}`);
    try {
        return fs.readFileSync(latestFilePath, 'utf8');
    } catch (error) {
        console.error('Error reading latest file:', error);
        return '';
    }
}

export function savePrompt({ prompt }: { prompt: string }): void {
    try {
        const files = fs.readdirSync(directoryPath);
        const maxVersionNumber = getMaxVersionNumber(files);
        const latestPrompt = readLatestPrompt(maxVersionNumber);

        if (prompt === latestPrompt) {
            console.log('The new prompt matches the latest version. Skipping save.');
            return;
        }

        const nextVersionNumber = maxVersionNumber + 1;
        const filePath = path.join(directoryPath, `v${nextVersionNumber}`);
        fs.writeFileSync(filePath, prompt);
        console.log('File has been saved.');
    } catch (error) {
        console.error('Error writing file:', error);
    }
}

export function getPrompt(): string {
    try {
        const files = fs.readdirSync(directoryPath);
        if (files.length === 0) {
            console.log('No files found.');
            return "";
        }
        const maxVersionNumber = getMaxVersionNumber(files);
        const latestFilePath = path.join(directoryPath, `v${maxVersionNumber}`);
        const data: string = fs.readFileSync(latestFilePath, { encoding: 'utf8' });
        return data;
    } catch (error) {
        console.error('Error reading file:', error);
        return "";
    }
}

export async function modifyPrompt({ oldPrompt, instruction }: { oldPrompt: string; instruction: string; }) {

    let prompt = instruction
    prompt += "for the prompt below enclosed in square brackets\n"
    prompt += `[${oldPrompt}]`
    console.log(prompt);
    let newPrompt = await complete(prompt)
    console.log();
    console.log(newPrompt);
    return newPrompt
}