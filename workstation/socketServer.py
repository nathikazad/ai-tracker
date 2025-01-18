import websockets
import asyncio
import json
import logging
import base64
import os
import datetime
import zmq
from collections import deque
from wavAssembler import combine_wav_files
from adpcm import save_wav_file

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
zmq_port = 5555

context = zmq.Context()
socket = context.socket(zmq.REQ)
socket.connect(f"tcp://localhost:{zmq_port}")

class WorkstationClient:
    def __init__(self, uri):
        self.uri = uri
        self.websocket = None
        self.is_running = True
        self.processing = False
        self.queue = deque()
        self.processing_task = None
        self.processed = 0

    async def connect(self):
        while self.is_running:
            try:
                async with websockets.connect(self.uri) as websocket:
                    self.websocket = websocket
                    logger.info("Connected to server")

                    connect_message = {
                        "type": "connect",
                        "connectionType": "workstation"
                    }
                    await websocket.send(json.dumps(connect_message))
                    logger.info("Sent connect message")

                    self.processing_task = asyncio.create_task(self.process_queue())

                    while True:
                        message = await websocket.recv()
                        await self.handle_message(websocket, message)

            except websockets.exceptions.ConnectionClosed:
                logger.info("Connection lost. Reconnecting in 1 second...")
            except Exception as e:
                logger.error(f"Error: {e}")
            
            if self.processing_task:
                self.processing_task.cancel()
            await asyncio.sleep(1)

    async def process_queue(self):
        while True:
            try:
                if not self.processing and self.queue:
                    self.processing = True
                    current_task = self.queue.popleft()
                    folder_name, client_id = current_task
                    
                    try:
                        full_path = os.path.join("Files", folder_name)
                        combine_wav_files(full_path, "out.wav")
                        message = {
                            'file_name': f"../../socketClient/{full_path}/out.wav",
                        }
                        
                        socket.send_pyobj(message)
                        process_response = socket.recv_string()
                        logger.info(f"Processed folder {folder_name}: {process_response}")
                        with open(f"{full_path}/out/transcript.txt", "rb") as f:
                            response_data = base64.b64encode(f.read()).decode()
                        
                        # Send processing result through websocket
                        response = {
                            # "type": "processing_complete",
                            "type": "file_response",
                            "clientId": client_id,
                            "filepath": f"{folder_name}/transcript.txt",
                            "content": response_data
                            # "result": process_response
                        }
                        await self.websocket.send(json.dumps(response))
                        
                    except Exception as e:
                        logger.error(f"Error processing folder {full_path}: {e}")
                        # Send error message through websocket
                        error_response = {
                            "type": "processing_error",
                            "clientId": client_id,
                            "filepath": folder_name,
                            "error": str(e)
                        }
                        await self.websocket.send(json.dumps(error_response))
                    finally:
                        self.processing = False
                        self.processed = self.processed + 1
                        print(f"{self.processed} complete 😛")
                
                await asyncio.sleep(0.1)
                
            except Exception as e:
                logger.error(f"Error in queue processor: {e}")
                await asyncio.sleep(1)

    async def handle_message(self, websocket, message):
        try:
            data = json.loads(message)
            logger.info(f"Received message")
            
            if data.get("type") == "file":
                await self.handle_file(websocket, data)
            elif "clientId" in data:
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
            adpcm_path = data["filepath"]
            content = data["content"]
            folder_name = os.path.dirname(adpcm_path)
            # Create the Files directory structure
            full_path = os.path.join("Files", adpcm_path)
            os.makedirs(os.path.dirname(full_path), exist_ok=True)
            
            # Save the received file
            file_data = base64.b64decode(content)
            wav_path = full_path.replace("adpcm", "wav")
            save_wav_file(wav_path, file_data)
            # with open(full_path, "wb") as f:
            #     f.write(file_data)
            
            logger.info(f"File saved: {full_path}")

            # Add to processing queue with client_id
            # Check if file is already in queue or processed
            if any(task[0] == folder_name for task in self.queue):
                logger.info(f"Folder {folder_name} is already queued or processed")
                return
            else:
                logger.info(f"Folder {folder_name} is queued")
                self.queue.append((folder_name, client_id))
            
            # Send queued confirmation
            response = {
                "type": "file_received",
                "clientId": client_id,
                "filepath": adpcm_path.replace("adpcm", "wav"),
                "message": "File received and queued for processing"
            }
            await websocket.send(json.dumps(response))
            
        except Exception as e:
            logger.error(f"Error handling file: {e}")
            error_response = {
                "type": "file_error",
                "clientId": client_id,
                "filepath": adpcm_path.replace("adpcm", "wav"),
                "error": str(e)
            }
            await websocket.send(json.dumps(error_response))

async def main():
    uri = "wss://ai-tracker-server-613e3dd103bb.herokuapp.com/websocket"
    client = WorkstationClient(uri)
    await client.connect()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Shutting down...")