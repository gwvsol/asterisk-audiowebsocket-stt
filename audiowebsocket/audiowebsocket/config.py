import sys
from shutil import copy
from pathlib import Path
from configparser import ConfigParser

from .exception import ConfigError
from .log import logging as log

# =====================================================
#
base_dir = Path(__file__).parent.parent
conf_path = base_dir.parent
config_file = 'audiowebsocket.conf'

if conf_path.as_posix() in sys.executable:
    config = base_dir.parent/config_file
else:
    config = Path(sys.executable).parent
    config = config/config_file
    if not config.exists():
        confbase = base_dir/config_file
        log.info(f'confbase => {confbase.as_posix()}')
        log.info(f'config => {config.as_posix()}')
        copy(src=confbase.as_posix(), dst=config.as_posix())

conf = ConfigParser()
conf.read(config)

# =====================================================
#
_audiowebsocket = conf['audiowebsocket']
audiowebsocket_port = _audiowebsocket.getint('audiowebsocket_port')
audiowebsocket_vosk_model_dir = _audiowebsocket.get(
    'audiowebsocket_vosk_model_dir')
audiowebsocket_vosk_spk_model_path = _audiowebsocket.get(
    'audiowebsocket_vosk_spk_model_path')

if audiowebsocket_vosk_model_dir is None:
    raise ConfigError('VOSK_MODEL_DIR ERROR in env')

vosk_model_path = conf_path/audiowebsocket_vosk_model_dir

if not vosk_model_path.exists():
    raise ConfigError('VOSK_MODEL_DIR ERROR in system')
vosk_model_path = vosk_model_path.as_posix()

vosk_spk_model_path = audiowebsocket_vosk_spk_model_path
if audiowebsocket_vosk_spk_model_path:
    vosk_spk_model_path = conf_path/audiowebsocket_vosk_spk_model_path
    if vosk_spk_model_path.exists():
        vosk_spk_model_path = vosk_spk_model_path.as_posix()


class AudioWebSocketConfig:
    """ Настройки для AudioWebSocket """
    host: str = '0.0.0.0'
    port: int = audiowebsocket_port
    model_path: str = vosk_model_path
    spk_model_path: str = vosk_spk_model_path
    sample_rate: int = 8000
    show_words: bool = True
    max_alternatives: int = 0


audiowebsocket_config = AudioWebSocketConfig()

# =====================================================
