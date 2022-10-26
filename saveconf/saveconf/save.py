from os import getenv
from pathlib import Path
from configparser import ConfigParser


class ConfigError(Exception):
    pass


config = ConfigParser()

BASE_PATH = Path(__file__).parent.parent.parent

# =====================================================
#
#

AUDIOWEBSOCKET_NAME = getenv('AUDIOWEBSOCKET', default=None)
if AUDIOWEBSOCKET_NAME is None:
    raise ConfigError('AUDIOWEBSOCKET ERROR in env')
#
AUDIOWEBSOCKET_PORT = getenv('AUDIOWEBSOCKET_PORT', default=None)
if AUDIOWEBSOCKET_PORT.isdigit():
    AUDIOWEBSOCKET_PORT = int(AUDIOWEBSOCKET_PORT)
else:
    raise ConfigError('AUDIOWEBSOCKET_PORT ERROR in env')
#
AUDIOWEBSOCKET_VOSK_MODEL_DIR = getenv(
    'AUDIOWEBSOCKET_VOSK_MODEL_DIR', default=None)
if AUDIOWEBSOCKET_VOSK_MODEL_DIR is None:
    raise ConfigError('AUDIOWEBSOCKET_VOSK_MODEL_DIR ERROR in env')
#
AUDIOWEBSOCKET_VOSK_SPK_MODEL_PATH = getenv(
    'AUDIOWEBSOCKET_VOSK_SPK_MODEL_PATH', default=None)
#
config['audiowebsocket'] = {
    'AUDIOWEBSOCKET_PORT': AUDIOWEBSOCKET_PORT,
    'AUDIOWEBSOCKET_VOSK_MODEL_DIR': AUDIOWEBSOCKET_VOSK_MODEL_DIR}

if AUDIOWEBSOCKET_VOSK_SPK_MODEL_PATH:
    config['audiowebsocket']['AUDIOWEBSOCKET_VOSK_SPK_MODEL_PATH'] =\
         AUDIOWEBSOCKET_VOSK_SPK_MODEL_PATH
#
# =====================================================
#


def main():
    """ Сохраняем настройки в файл """
    AUDIOWEBSOCKET_PATH = BASE_PATH/f'{AUDIOWEBSOCKET_NAME}.conf'
    with open(AUDIOWEBSOCKET_PATH.as_posix(), 'w') as configfile:
        config.write(configfile)

    print(f"save conf => {AUDIOWEBSOCKET_PATH.as_posix()}")


# =====================================================
