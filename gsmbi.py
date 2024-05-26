#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from gtts import gTTS
import os
import subprocess
from tempfile import NamedTemporaryFile


text_to_convert = input("Enter the text you want to convert to speech: ")


output_filename_base = input("Enter the desired output file name (without extension): ")


while True:
    lang_choice = input("Do you want the speech in [E]nglish or [S]panish? - ").lower()
    if lang_choice in ['e', 's']:
        break
    print("Please answer with 'E' for English or 'S' for Spanish.")


lang = 'en' if lang_choice == 'e' else 'es'


output_folder_ul = "/var/lib/asterisk/sounds"


os.makedirs(output_folder_ul, exist_ok=True)


output_filename_ul = os.path.join(output_folder_ul, "{}.ul".format(output_filename_base))


with NamedTemporaryFile(suffix=".wav", delete=False) as temp_wav:
    temp_wav_filename = temp_wav.name


tts = gTTS(text=text_to_convert, lang=lang)
tts.save(temp_wav_filename)


command = [
    'ffmpeg', '-i', temp_wav_filename, '-ar', '8000', '-ac', '1', '-f', 'mulaw', output_filename_ul
]

try:
    subprocess.run(command, check=True)
    # If conversion is successful, delete the temporary WAV file
    os.remove(temp_wav_filename)
    print("The speech has been saved as {} and the temporary WAV file has been deleted.".format(output_filename_ul))
except subprocess.CalledProcessError as e:
    print("An error occurred during the conversion process: {}".format(e))
    # Clean up the temporary WAV file in case of an error
    if os.path.exists(temp_wav_filename):
        os.remove(temp_wav_filename)
