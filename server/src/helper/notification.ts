import apn from 'apn';
import fs from 'fs';
import path from 'path';
import { config } from '../config';

export class ApnsNotificationSender {
    private provider: apn.Provider;

    constructor() {
        try {
            createApnsKeyFile(config.apnsKey!, 'apns.p8');
        } catch (error) {
            console.error('Failed to create APNs key file:', error);
        }
        const options: apn.ProviderOptions = {
            token: {
                key: 'apns.p8',
                keyId: 'S38YKJK244',
                teamId: 'F2W45BF2AV',
            },
            production: false // Set to true for production environment
        };
        this.provider = new apn.Provider(options);
    }

    async sendNotification(deviceToken: string, payload: apn.Notification): Promise<apn.Responses> {
        try {
            const result = await this.provider.send(payload, deviceToken);
            console.log('Notification sent successfully', result);
            return result;
        } catch (error) {
            console.error('Error sending notification:', error);
            throw error;
        }
    }

    shutdown() {
        this.provider.shutdown();
    }
}

function formatPrivateKey(key: string): string {
    const header = '-----BEGIN PRIVATE KEY-----';
    const footer = '-----END PRIVATE KEY-----';
    const content = key.replace(/\s/g, '');
    const formattedContent = content.match(/.{1,64}/g)?.join('\n') || '';
    return `${header}\n${formattedContent}\n${footer}`;
  }
  
  function createApnsKeyFile(keyContent: string, fileName: string): void {
    try {
      // Check if file already exists
      try {
        fs.accessSync(fileName);
        console.log(`File ${fileName} already exists. Skipping creation.`);
        return;
      } catch (error) {
        // File doesn't exist, proceed with creation
      }
  
      // Ensure the directory exists
      const directory = path.dirname(fileName);
      fs.mkdirSync(directory, { recursive: true });
  
      // Format the key
      const formattedKey = formatPrivateKey(keyContent);
  
      // Write the file
      fs.writeFileSync(fileName, formattedKey, 'utf8');
      console.log(`File ${fileName} has been created successfully.`);
    } catch (error) {
      console.error('Error creating APNs key file:', error);
      throw error;
    }
  }

// Usage

// async function main() {

//     const sender = new ApnsNotificationSender();

//     const deviceToken = 'a3a83883236bcb6141fdcaf85da0f8f9687b6ecb6a33a7fe4d6348c7734aa397';
//     const notification = new apn.Notification();

//     notification.alert = {
//         title: 'Hello',
//         body: 'This is a test notification'
//     };
//     notification.topic = 'com.snow.aspire';

//     try {
//         await sender.sendNotification(deviceToken, notification);
//     } catch (error) {
//         console.error('Failed to send notification:', error);
//     } finally {
//         sender.shutdown();
//     }
// }

// main();