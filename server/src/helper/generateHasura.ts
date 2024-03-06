
import { checkHasuraCreds, config } from "./../config";
import { exec } from 'child_process';




checkHasuraCreds()

const command: string = `zeus ${config.graphqlUrl}/v1/graphql ./src/generated --node --typescript --header='x-hasura-admin-secret:${config.hasuraAdminSecret}' --graphql=./src/generated`;

exec(command, (error, stdout, stderr) => {
    if (error) {
        console.error(`exec error: ${error}`);
        return;
    }
    console.log(`stdout: ${stdout}`);
    if (stderr) console.error(`stderr: ${stderr}`);
});