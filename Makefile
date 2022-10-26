#===========================================================
#
# Общие настройки и переменные
VENV_NAME?=venv
VENV_BIN=${VENV_NAME}/bin
VENV_ACTIVATE=. ${VENV_BIN}/activate
PYTHON=${VENV_BIN}/python3
PIP=${VENV_BIN}/pip3
PYINSTALLER=${VENV_BIN}/pyinstaller
PYCODESTYLE=${VENV_BIN}/pycodestyle
PYFLAKES=${VENV_BIN}/pyflakes
#
export DOCKER=$(shell which docker)
export COMPOSE=$(shell which docker-compose)
export PWD_APP=$(shell pwd)
export USER_ID=$(shell id -u `whoami`)
#
#===========================================================
#

ifneq ("$(wildcard $(shell which timedatectl))","")
	export TIMEZONE=$(shell timedatectl status | awk '$$1 == "Time" && $$2 == "zone:" { print $$3 }')
endif

ENVIRONMENT=.env
ENVFILE=$(PWD_APP)/${ENVIRONMENT}
ifneq ("$(wildcard $(ENVFILE))","")
	
    include ${ENVFILE}
    export ENVFILE=$(PWD_APP)/${ENVIRONMENT}
endif

export MODEL_DIR=$(PWD_APP)/${VOSK_MODEL_DIR}

#
#===========================================================
#

# AUDIOWEBSOCKET
ifneq ("$(wildcard $(PWD_APP)/$(AUDIOWEBSOCKET)/$(MAKEFILE))","")
   include $(AUDIOWEBSOCKET)/$(MAKEFILE)
endif

# SAVECONFIG
ifneq ("$(wildcard $(PWD_APP)/$(SAVECONFIG)/$(MAKEFILE))","")
   include $(SAVECONFIG)/$(MAKEFILE)
endif

# AUDIOWEBSOCKET
ifneq ("$(wildcard $(PWD_APP)/$(MAKEFILE_DOCKER))","")
   include $(MAKEFILE_DOCKER)
endif

#
#===========================================================
#
