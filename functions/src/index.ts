// src/index.ts
import { HttpFunction } from '@google-cloud/functions-framework/build/src/functions';
import { printHelloWorld } from './lib/helloWorld';

export const helloWorld: HttpFunction = (req, res) => {
  res.send(printHelloWorld());
};
