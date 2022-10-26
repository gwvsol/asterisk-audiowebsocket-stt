######################################################################
##
## STAGE 1
##

FROM audiowebsocket-base:latest
LABEL maintainer="Mikhail Fedorov" email="jwvsol@yandex.ru"
LABEL version="latest"

######################################################################
##
## STAGE 2: This is the final image => vosk-api and audiowebsocket
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
# Установка зависимостей и приложения
RUN set -eux \
    && ln -snf /usr/share/zoneinfo/$TIMEZONE \
        /etc/localtime && echo $TIMEZONE > /etc/timezone \
    && dnf update -y \
    && dnf install -y make zip unzip tzdata ncurses \
    && mkdir -p ${APP_DIR}/${VOSK_API_DIR}

# # Устанавливаем локаль RU.UTF-8
# ENV LANG ru_RU.UTF-8
# ENV LANGUAGE ru_RU.UTF-8
# ENV LC_ALL ru_RU.UTF-8

# Копируем релиз в Docker
ADD release/${APPS}-*.zip ${APP_DIR}

COPY --from=0 /src/vosk-api ${APP_DIR}/${VOSK_API_DIR}

RUN chown -Rf $APPS:$APPS $APP_DIR

# Рабочая дирректория $APP_DIR
WORKDIR $APP_DIR

RUN unzip ${APPS}-*.zip \
    && rm *.zip \
    && chown -Rf $APPS:$APPS $APP_DIR

# Устанавливаем зависимости
RUN \
    ls -la \
    && make install-dependents \
    && dnf clean all \
    && rm -rf /root/.cache

# Не привилигированный пользователь
USER $APPS

RUN \
    make install-apps \
#    && make install-vosk-model
#    && rm -fr .env
    && rm -rf $HOME/.cache

ENV PATH=${PATH}:${APP_DIR}

# Открываем порты
EXPOSE 3700

# Что стартуем при запуске Docker
ENTRYPOINT ["run.sh"]
