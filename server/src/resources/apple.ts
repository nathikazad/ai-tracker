
import * as jwt from 'jsonwebtoken';
import * as jwksRsa from 'jwks-rsa';;

import { config, getHasura } from '../config';

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
    const userId = await getHasuraUserId(decoded);
    const token = generateJWT(userId);
    return token;
}

function generateJWT(userId: number) {
    const privateKey = config.hasuraPrivateKey?.replace(/\\n/g, '\n') || '';
    const payload = {
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
        user: [{
            where: {
                apple_id: {
                    _eq: decoded!.sub
                }
            }
        }, {
            id: true
        }]
    });
    if (resp.user.length >= 1) 
        return resp.user[0].id;
    
    let resp2 = await chain.mutation({
            insert_user_one: [{
                object: {
                    apple_id: decoded!.sub
                }
            }, {
                id: true
            }]
        });
    return resp2.insert_user_one!.id;
}
