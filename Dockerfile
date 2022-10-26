######################################################################
##
## STAGE 1: Build kaldi and vosk-api
##

# Какой используем образ
FROM audiowebsocket-base:latest
LABEL maintainer="Mikhail Fedorov" email="jwvsol@yandex.ru"
LABEL version="latest"

# Устанавливаем переменные окружения
ARG TIMEZONE
ENV TIMEZONE=${TIMEZONE:-Europe/Moscow}
ARG USER_ID
ENV USER_ID ${USER_ID:-1000}
ARG GROUP_ID
ENV GROUP_ID ${GROUP_ID:-1000}
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

######################################################################
##
## STAGE 2: This is the final image => vosk-api and audiosocket
##

# Какой используем образ
FROM fedora:36
LABEL maintainer="Mikhail Fedorov" email="jwvsol@yandex.ru"
LABEL version="latest"

# Устанавливаем переменные окружения
ARG TIMEZONE
ENV TIMEZONE=${TIMEZONE:-Europe/Moscow}
ARG USER_ID
ENV USER_ID=${USER_ID:-1000}
ARG GROUP_ID
ENV GROUP_ID=${GROUP_ID:-1000}

ENV VOSK_API_DIR=vosk-api

# Используется в некоторых случаях если не возможно собрать образ
#ENV HTTP_PROXY="http://192.168.93.1:3128"
#ENV HTTPS_PROXY="https://192.168.93.1:3128"

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Переменная оболочки 
ENV SHELL=/bin/bash

# Имя релиза приложения
ENV APPS=audiowebsocket

# Директория для запуска сервиса
ENV APP_DIR=/src

# Создаем не привилигированного пользователя
RUN groupadd --gid ${GROUP_ID} $APPS \
  && useradd --uid ${USER_ID} --gid $APPS --shell $SHELL --create-home $APPS

# Начальные настроки
RUN set -eux \
    && ln -snf /usr/share/zoneinfo/$TIMEZONE \
        /etc/localtime && echo $TIMEZONE > /etc/timezone \
    && dnf update -y \
    && dnf install -y make zip unzip tzdata ncurses

# # Устанавливаем локаль RU.UTF-8
# ENV LANG ru_RU.UTF-8
# ENV LANGUAGE ru_RU.UTF-8
# ENV LC_ALL ru_RU.UTF-8

# Установка зависимостей и приложения
RUN set -eux \
    && mkdir -p ${APP_DIR}/${VOSK_API_DIR} \
    && mkdir -p ${APP_DIR}/${APPS}

COPY --from=0 /src/vosk-api ${APP_DIR}/${VOSK_API_DIR}
COPY --from=0 /src/audiowebsocket ${APP_DIR}/${APPS}
COPY --from=0 /src/.env ${APP_DIR}
COPY --from=0 /src/audiowebsocket-cli.py ${APP_DIR}
COPY --from=0 /src/Makefile ${APP_DIR}
COPY --from=0 /src/install-kaldi.sh ${APP_DIR}
COPY --from=0 /src/run.sh ${APP_DIR}

RUN chown -Rf $APPS:$APPS $APP_DIR

# Рабочая дирректория $APP_DIR
WORKDIR $APP_DIR

# Устанавливаем зависимости
RUN \
    ls -la \
    && make install-dependents \
    && dnf clean all \
    && rm -rf /root/.cache/pip \
    && rm -rf /var/lib/apt/lists/*

# Не привилигированный пользователь
USER $APPS
# Рабочая дирректория $APP_DIR
WORKDIR $APP_DIR

RUN \
    make install-apps \
#    && make install-vosk-model
    && rm -fr .env \
    && rm -rf $HOME/.cache


# Открываем порты
EXPOSE 3700

# Что стартуем при запуске Docker
ENTRYPOINT ["run.sh"]
