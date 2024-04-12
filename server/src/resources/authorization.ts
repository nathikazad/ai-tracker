
import * as jwt from 'jsonwebtoken';
import * as jwksRsa from 'jwks-rsa';
import { Request } from 'express';

import { config, getHasura } from '../config';


interface HasuraJWTClaims extends jwt.JwtPayload {
    "iat": number,
    "https://hasura.io/jwt/claims": {
        "x-hasura-default-role": string;
        "x-hasura-allowed-roles": string[];
        "x-hasura-user-id": string;
    };
}

function getKey(header: jwt.JwtHeader, callback: jwt.SigningKeyCallback): void {
    const client = new jwksRsa.JwksClient({
        jwksUri: 'https://appleid.apple.com/auth/keys',
    });

    client.getSigningKey(header.kid, function (err, key) {
        if (err) {
            callback(err, undefined);
            return;
        }
        if (key && typeof key.getPublicKey === 'function') {
            var signingKey = key.getPublicKey();
            callback(null, signingKey);
        } else {
            callback(new Error('Could not retrieve signing key'), undefined);
        }
    });
}

export function verifyAppleJwt(token: string): Promise<jwt.JwtPayload | undefined> {
    return new Promise((resolve, reject) => {
        jwt.verify(token, getKey, { algorithms: ['RS256'] }, function (err, decoded) {
            if (err) {
                reject(err);
            } else {
                resolve(decoded as jwt.JwtPayload);
            }
        });
    });
}

export async function convertAppleJWTtoHasuraJWT(appleJWT: string) {
    const decoded =  await verifyAppleJwt(appleJWT)
    console.log("apple jwt")
    console.log(decoded)
    const userId = await getHasuraUserId(decoded);
    const token = generateJWT(userId);
    return token;
}

function generateJWT(userId: number) {
    const privateKey: string = config.hasuraPrivateKey!; 
    const payload: HasuraJWTClaims = {
        "iat": Math.floor(Date.now() / 1000),
        "https://hasura.io/jwt/claims": {
            "x-hasura-default-role": "user",
            "x-hasura-allowed-roles": ["user"],
            "x-hasura-user-id": userId.toString(),
        }
    };

    const expiresIn = Math.floor(Date.now() / 1000) + (24 * 60 * 60); // Current time + 1 day
    const signOptions: jwt.SignOptions = {
        algorithm: 'RS256',
        expiresIn: expiresIn
    };
    const token = jwt.sign(payload, privateKey, signOptions);
    return token;
}

async function getHasuraUserId(decoded: jwt.JwtPayload | undefined) {
    let chain = getHasura();
    let resp = await chain.query({
        users: [{
            where: {
                apple_id: {
                    _eq: decoded!.sub
                }
            }
        }, {
            id: true
        }]
    });
    if (resp.users.length >= 1) 
        return resp.users[0].id;
    
    let resp2 = await chain.mutation({
            insert_users_one: [{
                object: {
                    apple_id: decoded!.sub
                }
            }, {
                id: true
            }]
        });
    return resp2.insert_users_one!.id;
}


export function authorize(req: Request): number {
    console.log(`authorization header: ${req.headers.authorization}`)
    let token =  req.headers.authorization?.split(' ')[1]; 
    if (!token) {
        throw new Error('No authorizaiton provided')
    }
    const privateKey: string = config.hasuraPrivateKey!; 
    // try {
        const decoded = jwt.verify(token, privateKey) as HasuraJWTClaims;
        console.log(`decoded`)
        console.log(decoded)
        const hasuraJWTClaims = decoded as HasuraJWTClaims;
        console.log("hasuraJWTClaims")
        console.log(hasuraJWTClaims)
        return parseInt(hasuraJWTClaims['https://hasura.io/jwt/claims']['x-hasura-user-id']);
    // } catch (error) {
    //     throw new Error('Invalid or expired JWT');
    // }
}

