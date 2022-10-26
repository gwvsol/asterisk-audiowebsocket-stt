class AudioWebSocketError(Exception):
    """ Обработка исключений AudioSocketError """
    def __init__(self, *args):
        self.args = [a for a in args]


class ConfigError(AudioWebSocketError):
    """ Обработка исключений ConfigError """
    pass
