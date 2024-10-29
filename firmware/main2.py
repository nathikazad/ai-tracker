# chat.py

import asyncio
from nrf.scripts.transcribe import BLEAudioTranscriber
from openai import OpenAI
import os
from typing import List, Dict
from rp2040.scripts.cmdmp3Transfer import send_file
import tempfile
from pathlib import Path

# Initialize OpenAI client
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

class ConversationManager:
    def __init__(self, max_history: int = 10):
        self.messages: List[Dict[str, str]] = [
            {"role": "system", "content": "You are a helpful assistant having a conversation. Keep your responses concise and natural."}
        ]
        self.max_history = max_history
        self._lock = asyncio.Lock()

    def add_message(self, role: str, content: str):
        self.messages.append({"role": role, "content": content})
        # Keep only the system message plus last max_history messages
        if len(self.messages) > self.max_history + 1:
            self.messages = [self.messages[0]] + self.messages[-(self.max_history):]
    
    async def text_to_speech(self, text: str) -> None:
        """Convert text to speech using OpenAI API and play it."""
        try:
            # Create temporary directory if it doesn't exist
            temp_dir = Path(tempfile.gettempdir()) / "tts_responses"
            temp_dir.mkdir(exist_ok=True)
            
            # Generate temporary file path
            temp_file = temp_dir / f"response.mp3"
            
            # Get speech data from OpenAI
            response = await asyncio.get_event_loop().run_in_executor(
                None,
                lambda: client.audio.speech.create(
                    model="tts-1",
                    voice="alloy",
                    input=text
                )
            )
            
            # Stream the response content to file
            with open(temp_file, 'wb') as f:
                response_iterator = response.iter_bytes()
                for chunk in response_iterator:
                    f.write(chunk)

            return str(temp_file)
        except Exception as e:
            print(f"Error in text to speech: {e}")

    async def get_gpt_response(self, text: str) -> str:
        """Get response from GPT-3 and convert it to speech."""
        async with self._lock:
            try:
                self.add_message("user", text)
                
                response = await asyncio.get_event_loop().run_in_executor(
                    None,
                    lambda: client.chat.completions.create(
                        model="gpt-3.5-turbo",
                        messages=self.messages
                    )
                )
                
                assistant_response = response.choices[0].message.content
                print(f"Assistant response: {assistant_response}")
                self.add_message("assistant", assistant_response)
                
                # Convert response to speech
                path = await self.text_to_speech(assistant_response)
                print(f"Sending file: {path}")
                await send_file(path)
                
                return assistant_response
                
            except Exception as e:
                return f"Error getting GPT response: {e}"

async def main():
    # Initialize conversation manager
    conversation = ConversationManager()

    async def on_transcription(text: str):
        """Async callback function to receive transcribed text"""
        print(f"\nTranscribed text: {text}")
        
        # Only send to GPT if the text is not just a period
        if text.strip() != ".":
            await conversation.get_gpt_response(text)
            # print(f"GPT Response: {gpt_response}")

    # Create transcriber instance
    transcriber = BLEAudioTranscriber()
    
    # Set up callback
    transcriber.set_transcription_callback(on_transcription)
    
    # Start listening
    await transcriber.start()
    
    # Keep running until you want to stop
    try:
        await asyncio.sleep(float('inf'))
    except KeyboardInterrupt:
        await transcriber.stop()

if __name__ == "__main__":
    asyncio.run(main())