import os
import json
import asyncio
import websockets
import concurrent.futures
from websockets.exceptions import ConnectionClosedOK
from vosk import Model, SpkModel, KaldiRecognizer

from .config import audiowebsocket_config as conf
from .log import logging


def process_chunk(rec: KaldiRecognizer,
                  message: str or bytes):
    if message == '{"eof" : 1}':
        return rec.FinalResult(), True
    elif rec.AcceptWaveform(message):
        return rec.Result(), False
    else:
        return rec.PartialResult(), False


async def recognize(websocket, path):
    global model
    global spk_model
    global pool

    loop = asyncio.get_running_loop()
    rec = None
    phrase_list = None
    sample_rate = conf.sample_rate
    show_words = conf.show_words
    max_alternatives = conf.max_alternatives

    logging.info('Connection from %s', websocket.remote_address)

    try:
        while True:

            message = await websocket.recv()

            # Load configuration if provided
            if isinstance(message, str) and 'config' in message:
                jobj = json.loads(message)['config']
                logging.info("Config %s", jobj)
                if 'phrase_list' in jobj:
                    phrase_list = jobj['phrase_list']
                if 'sample_rate' in jobj:
                    sample_rate = float(jobj['sample_rate'])
                if 'words' in jobj:
                    show_words = bool(jobj['words'])
                if 'max_alternatives' in jobj:
                    max_alternatives = int(jobj['max_alternatives'])
                continue

            # Create the recognizer, word list is
            # temporary disabled since not every model supports it
            if not rec:
                if phrase_list:
                    rec = KaldiRecognizer(model, sample_rate,
                                          json.dumps(phrase_list,
                                                     ensure_ascii=False))
                else:
                    rec = KaldiRecognizer(model, sample_rate)
                rec.SetWords(show_words)
                rec.SetMaxAlternatives(max_alternatives)
                if spk_model:
                    rec.SetSpkModel(spk_model)

            response, stop = await loop.run_in_executor(pool,
                                                        process_chunk,
                                                        rec, message)
            await websocket.send(response)

            if stop:
                break

    except ConnectionClosedOK as err:
        logging.warning(err)


async def start():

    global model
    global spk_model
    global pool

    # Enable loging websockets
    logger = logging.getLogger('websockets')
    logger.setLevel(logging.INFO)
    # logger.addHandler(logging.StreamHandler())

    model = Model(conf.model_path)
    spk_model = SpkModel(conf.spk_model_path) if conf.spk_model_path else None

    pool = concurrent.futures.ThreadPoolExecutor((os.cpu_count() or 1))

    async with websockets.serve(recognize, conf.host, conf.port):
        await asyncio.Future()


def main():
    try:
        asyncio.run(start())
    except KeyboardInterrupt:
        pass


if __name__ == '__main__':
    main()
