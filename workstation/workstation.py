import websockets
import asyncio
import json
import logging
import base64
import os
import datetime

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
            logger.info(f"Received message")#: {data}")
            
            if data.get("type") == "file":
                # Handle incoming file
                await self.handle_file(websocket, data)
            elif "clientId" in data:
                # Handle regular messages as before
                response = {
                    "type": "message",
                    "clientId": data["clientId"],
                    "content": f"Hey {data['clientId']}, I got your message."
                }
                await websocket.send(json.dumps(response))
                
        except json.JSONDecodeError:
            logger.error(f"Failed to parse message: {message}")
        except Exception as e:
            logger.error(f"Error handling message: {e}")

    async def handle_file(self, websocket, data):
        try:
            client_id = data["clientId"]
            filepath = data["filepath"]
            content = data["content"]
            
            # Create the Files directory structure
            full_path = os.path.join("Files", filepath)
            #full_path = os.path.join("Files", client_id, filepath) for when multiple clients
            os.makedirs(os.path.dirname(full_path), exist_ok=True)
            
            # Save the received file
            file_data = base64.b64decode(content)
            with open(full_path, "wb") as f:
                f.write(file_data)
            
            logger.info(f"File saved: {full_path}")
            
            # Create and send response file
            folder_name = os.path.dirname(filepath)
            response_path = os.path.join(folder_name, "response.txt")
            response_full_path = os.path.join("Files", response_path)
            
            # Create response content (you can modify this as needed)
            response_content = f"Processed file: {filepath}\nTimestamp: {datetime.datetime.now()}"
            
            # Save response file
            os.makedirs(os.path.dirname(response_full_path), exist_ok=True)
            with open(response_full_path, "w") as f:
                f.write(response_content)
            
            # Read and encode response file
            with open(response_full_path, "rb") as f:
                response_data = base64.b64encode(f.read()).decode()
            
            # Send response file
            response = {
                "type": "file_response",
                "clientId": client_id,
                "filepath": response_path,
                "content": response_data
            }
            await websocket.send(json.dumps(response))
            logger.info(f"Sent response file: {response_path}")
            
        except Exception as e:
            logger.error(f"Error handling file: {e}")

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