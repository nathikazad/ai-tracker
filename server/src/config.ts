import dotenv from 'dotenv';

dotenv.config();

const PORT = process.env.PORT || 3000;

export const config = {
    server: {
        port: PORT,
    },
    openApiKey: process.env.OPENAI_API_KEY,
    graphqlUrl: process.env.GRAPHQL_URL,
    hasuraAdminSecret: process.env.HASURA_ADMIN_SECRET
};

import { Chain } from "./generated/graphql-zeus";

export function getHasura() {
    checkHasuraCreds()
    return Chain(getFullHasuraUrl(), {
        headers: {
            "x-hasura-admin-secret": config.hasuraAdminSecret!
        }
    });
}

export function getFullHasuraUrl() {
    return `${config.graphqlUrl!}/v1/graphql`
}

export function checkHasuraCreds() {
    if (!config.graphqlUrl || !config.hasuraAdminSecret) {
        console.error('Environment variables GRAPHQL_URL or HASURA_ADMIN_SECRET are not set.');
        process.exit(1);
    }
}