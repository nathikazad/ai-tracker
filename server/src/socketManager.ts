import { WebSocketServer, WebSocket } from 'ws';
type ConnectionType = 'client' | 'workstation';

interface ConnectMessage {
    type: 'connect';
    connectionType: ConnectionType;
    clientId?: string;
}

// Connection Manager for WebSocket
export class ConnectionManager {
    private workstation: WebSocket | null = null;
    private clients = new Map<string, WebSocket>();

    handleConnection(ws: WebSocket) {
        const connectTimeout = setTimeout(() => {
            ws.close();
        }, 5000);

        ws.once('message', (message: string) => {
            try {
                const data = JSON.parse(message) as ConnectMessage;
                if (data.type !== 'connect') {
                    ws.close();
                    return;
                }

                clearTimeout(connectTimeout);

                if (data.connectionType === 'workstation') {
                    this.handleWorkstationConnection(ws);
                } else if (data.connectionType === 'client' && data.clientId) {
                    this.handleClientConnection(ws, data.clientId);
                } else {
                    ws.close();
                }
            } catch (error) {
                console.error('Error handling connect message:', error);
                ws.close();
            }
        });
    }

    private handleWorkstationConnection(ws: WebSocket) {
        if (this.workstation) {
            ws.close();
            return;
        }

        this.workstation = ws;
        console.log('Workstation connected');

        this.clients.forEach(clientWs => {
            clientWs.send(JSON.stringify({
                type: 'system',
                message: 'Workstation connected'
            }));
        });

        ws.on('message', (message: string) => {
            try {
                const data = JSON.parse(message);
                if (!data.clientId) {
                    console.error('Workstation message missing clientId');
                    return;
                }

                const clientWs = this.clients.get(data.clientId);
                if (clientWs) {
                    clientWs.send(JSON.stringify(data));
                }
            } catch (error) {
                console.error('Error handling workstation message:', error);
            }
        });

        ws.on('close', () => {
            this.workstation = null;
            console.log('Workstation disconnected');
            
            this.clients.forEach(clientWs => {
                clientWs.send(JSON.stringify({
                    type: 'system',
                    message: 'Workstation disconnected'
                }));
            });
        });
    }

    private handleClientConnection(ws: WebSocket, clientId: string) {
        const existingClient = this.clients.get(clientId);
        if (existingClient) {
            existingClient.close();
        }

        this.clients.set(clientId, ws);
        console.log(`Client connected: ${clientId}`);

        ws.on('message', (message: string) => {
            try {
                const data = JSON.parse(message);
                if (!this.workstation) {
                    ws.send(JSON.stringify({
                        type: 'system',
                        message: 'Workstation not connected',
                        clientId
                    }));
                    return;
                }

                const forwardMessage = {
                    ...data,
                    clientId
                };
                this.workstation.send(JSON.stringify(forwardMessage));
            } catch (error) {
                console.error('Error handling client message:', error);
            }
        });

        ws.on('close', () => {
            this.clients.delete(clientId);
            console.log(`Client disconnected: ${clientId}`);
            
            if (this.workstation) {
                this.workstation.send(JSON.stringify({
                    type: 'system',
                    message: 'Client disconnected',
                    clientId
                }));
            }
        });
    }
}