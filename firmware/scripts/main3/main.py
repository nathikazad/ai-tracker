# main.py
import asyncio
from openai import OpenAI
import os
from ble import BLEManager
from transcribe import AudioTranscriber
from playback import AudioPlayer
from util import log
class ChatManager:
    def __init__(self, max_history: int = 10):
        self.messages = [
            {"role": "system", "content": "Your name is Maximus, you are a helpful assistant having a conversation. Keep your responses concise and natural."}
        ]
        self.max_history = max_history
        self._lock = asyncio.Lock()
        self.client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
        self.ble_manager = BLEManager()
        self.transcriber = AudioTranscriber(self.ble_manager)
        self.player = AudioPlayer(self.ble_manager)

    def add_message(self, role: str, content: str):
        self.messages.append({"role": role, "content": content})
        if len(self.messages) > self.max_history + 1:
            self.messages = [self.messages[0]] + self.messages[-(self.max_history):]

    async def text_to_speech(self, text: str) -> str:
        """Convert text to speech using OpenAI API."""
        try:
            response = await asyncio.get_event_loop().run_in_executor(
                None,
                lambda: self.client.audio.speech.create(
                    model="tts-1",
                    voice="alloy",
                    input=text
                )
            )
            return response
        except Exception as e:
            print(f"Error in text to speech: {e}")
            return None

    async def handle_transcription(self, text: str):
        """Handle transcribed text and generate response."""
        if text.strip() == ".":
            return

        log(f"Transcribed text: {text}")
        async with self._lock:
            try:
                self.add_message("user", text)
                
                response = await asyncio.get_event_loop().run_in_executor(
                    None,
                    lambda: self.client.chat.completions.create(
                        model="gpt-3.5-turbo",
                        messages=self.messages
                    )
                )
                
                assistant_response = response.choices[0].message.content
                log(f"Assistant response: {assistant_response}")
                self.add_message("assistant", assistant_response)
                log("Text to speech start")
                # Convert to speech and play
                speech_response = await self.text_to_speech(assistant_response)
                log("Text to speech finish")
                if speech_response:
                    log("Play audio start")
                    await self.player.play_audio(speech_response)
                    log("Play audio finish")
                
            except Exception as e:
                print(f"Error in chat handling: {e}")

    async def start(self):
        """Start the chat system."""
        await self.ble_manager.connect()
        self.transcriber.set_transcription_callback(self.handle_transcription)
        await self.transcriber.start()

    async def stop(self):
        """Stop the chat system."""
        await self.transcriber.stop()
        await self.ble_manager.disconnect()

async def main():
    chat_manager = ChatManager()
    try:
        await chat_manager.start()
        await asyncio.sleep(float('inf'))
    except KeyboardInterrupt:
        await chat_manager.stop()

if __name__ == "__main__":
    asyncio.run(main())

