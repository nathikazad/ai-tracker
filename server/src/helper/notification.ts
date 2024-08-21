import apn from 'apn';
import fs from 'fs';
import path from 'path';
import { config, getHasura } from '../config';

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



export async function notifyOtherMembers(id: number, senderMemberId: number, message: string): Promise<any> {
  let chain = getHasura();
  let resp = await chain.query({
    group_chat_by_pk: [
      {
        id: id
      }, {
        name: true,
        members: [{}, {
          id: true,
          chat_id: true,
          user: {
            apns_token: true,
            name: true
          }
        }]
      }
    ]
  });
  let sender = resp.group_chat_by_pk?.members.find(m => m.id == senderMemberId);
  let otherMembers = resp.group_chat_by_pk?.members.filter(m => m.id != senderMemberId);

  const apnsSender = new ApnsNotificationSender();
  const notification = new apn.Notification();

  notification.alert = {
    title: `${resp.group_chat_by_pk?.name}`,
    body: `${sender?.user.name} ${message}` 
  };
  notification.topic = 'com.snow.aspire';
  // notify other members
  otherMembers?.forEach(m => {
    if (m.user.apns_token) {
      try {
        apnsSender.sendNotification(m.user.apns_token, notification);
      } catch (error) {
        console.error('Failed to send notification:', error);
      } finally {
        apnsSender.shutdown();
      }
    }
  });
  return resp.group_chat_by_pk
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