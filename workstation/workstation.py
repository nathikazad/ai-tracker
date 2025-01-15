import websockets
import asyncio
import json
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class WorkstationClient:
    def __init__(self, uri):
        self.uri = uri
        self.websocket = None
        self.is_running = True

    async def connect(self):
        while self.is_running:
            try:
                async with websockets.connect(self.uri) as websocket:
                    self.websocket = websocket
                    logger.info("Connected to server")

                    # Send connect message
                    connect_message = {
                        "type": "connect",
                        "connectionType": "workstation"
                    }
                    await websocket.send(json.dumps(connect_message))
                    logger.info("Sent connect message")

                    # Handle messages
                    while True:
                        message = await websocket.recv()
                        await self.handle_message(websocket, message)

            except websockets.exceptions.ConnectionClosed:
                logger.info("Connection lost. Reconnecting in 1 second...")
            except Exception as e:
                logger.error(f"Error: {e}")
            
            await asyncio.sleep(1)  # Wait before reconnecting

    async def handle_message(self, websocket, message):
        try:
            data = json.loads(message)
            logger.info(f"Received message: {data}")

            # If it's a client message, send a response
            if "clientId" in data:
                response = {
                    "type": "message",
                    "clientId": data["clientId"],
                    "content": f"Hey {data['clientId']}, I got your message."
                }
                await websocket.send(json.dumps(response))
                logger.info(f"Sent response to client {data['clientId']}")

        except json.JSONDecodeError:
            logger.error(f"Failed to parse message: {message}")
        except Exception as e:
            logger.error(f"Error handling message: {e}")

async def main():
    # Connect to your Heroku server
    uri = "wss://ai-tracker-server-613e3dd103bb.herokuapp.com/websocket"
    client = WorkstationClient(uri)
    await client.connect()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Shutting down...")