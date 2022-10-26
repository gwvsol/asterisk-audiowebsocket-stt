import logging


log_format = '%(asctime)s.%(msecs)d|%(levelname)s\
|%(module)s.%(funcName)s:%(lineno)d %(message)s'

date_format = '%Y-%m-%d %H:%M:%S'

log_level = logging.INFO

logging.basicConfig(level=log_level,
                    format=log_format,
                    datefmt=date_format)
