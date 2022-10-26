#===========================================================
# Установка зависимостей
.PHONY: install
install:
	@printf "\033[0m"
	@printf "\033[32m"
	@echo "================================= Install VENV ================================"
	@[ -d $(VENV_NAME) ] || python3 -m $(VENV_NAME) $(VENV_NAME)
	@${PIP} install pip wheel -U
	@printf "\033[36m"
	@echo "============================== Install VENV OK! ==============================="
	@printf "\033[0m"

# Установка зависимостей для проверки кода
.PHONY: install-dev
install-dev: ${AUDIOWEBSOCKET_DEPENDENTS_DEV}
	@printf "\033[0m"
	@printf "\033[32m"
	@echo "================================= Install DEV ================================="
	@[ -d $(VENV_NAME) ] || python3.8 -m $(VENV_NAME) $(VENV_NAME)
	@${PIP} install pip wheel -U
	@${PIP} install -r ${AUDIOWEBSOCKET_DEPENDENTS_DEV}
	@printf "\033[36m"
	@echo "============================== Install DEV OK! ================================"
	@printf "\033[0m"

# Активация виртуального окружения
.PHONY: venv
venv: ${VENV_NAME}/bin/activate
$(VENV_NAME)/bin/activate: ${SETUP}
	@[ -d $(VENV_NAME) ] || python3 -m $(VENV_NAME) $(VENV_NAME)
	@${PIP} install pip wheel -U
	@${PIP} install -e .
	@${VENV_ACTIVATE}

# Удаление виртуального окружения
.PHONY: uninstall
uninstall:
	@printf "\033[0m"
	@printf "\033[31m"
	@echo "================================== UNINSTALL ===================================="
	@make clean
	@rm -fr ${VENV_NAME}
	@printf "\033[36m"
	@echo "================================ UNINSTALL OK! =================================="
	@printf "\033[0m"

#===========================================================
# Создание релиза приложения
.PHONY: release
release: clean ${AUDIOWEBSOCKET} ${SAVECONFIG} ${DOCKERFILE} ${COMPOSE_FILE} ${MAKEFILE} \
			   ${README} ${KALDI_APP_INSTALL} ${RUN_SCRIPT} ${AUDIOWEBSOCKET_CLI} ${ENVIRONMENT}
	@printf "\033[0m"
	@printf "\033[34m"
	@echo "============================= CREATE RELEASE SRC ================================"
	@make clean
	@zip -r ${RELEASE}/${AUDIOWEBSOCKET}-$(shell date '+%Y-%m-%d-%H-%M-%S').zip ${KALDI_APP_INSTALL} \
	${AUDIOWEBSOCKET} ${SAVECONFIG} ${DOCKERFILE} ${COMPOSE_FILE} ${MAKEFILE} ${README} \
	${KALDI_APP_INSTALL} ${RUN_SCRIPT} ${AUDIOWEBSOCKET_CLI} ${ENVIRONMENT}
	@printf "\033[32m"
	@echo "============================= CREATE RELEASE SRC OK! ============================"
	@printf "\033[0m"


#===========================================================
# Проверка кода
.PHONY: check
check: ${PYCODESTYLE} ${PYFLAKES} ${AUDIOWEBSOCKET} ${AUDIOWEBSOCKET_CLI} ${SAVECONFIG}
	@printf "\033[0m"
	@printf "\033[31m"
	@echo "=============================== CHECK SRC CODE =================================="
	@${PYCODESTYLE} ${AUDIOWEBSOCKET} ${AUDIOWEBSOCKET_CLI} ${SAVECONFIG}
	@${PYFLAKES} ${AUDIOWEBSOCKET} ${AUDIOWEBSOCKET_CLI} ${SAVECONFIG}
	@printf "\033[32m"
	@echo "============================= CHECK SRC CODE OK ================================="
	@printf "\033[0m"

#===========================================================
# Очистка мусора
.PHONY: clean
clean:
	@printf "\033[0m"
	@printf "\033[33m"
	@echo "===================================== CLEAN ====================================="
	@[ -d $(RELEASE) ] || mkdir ${RELEASE}
	@[ -d $(ARCHIVE) ] || mkdir ${ARCHIVE}
	@find . '(' -path ./archive -o -path ./venv ')' -prune -o '(' -name '*.tar.xz' -o -name '*.zip' ')' -type f -exec mv -v -t "$(ARCHIVE)" {} +
	@find . '(' -path ./archive -o -path ./venv ')' -prune -o '(' -name '*.egg-info' -o -name '.eggs' -o -name '*~' -o -name '__pycache__' ')' -exec rm -fr {} +
	@find . '(' -path ./archive -o -path ./venv ')' -prune -o '(' -name '*.pyc' -o -name '*.pyo' -o -name '*.spec' ')' -type f -exec rm {} +
	@printf "\033[36m"
	@echo "=================================== CLEAN OK! ==================================="
	@printf "\033[0m"

#===========================================================
# ################## Установка приложения ##################
#===========================================================
# Определение переменных для установки и запуска AUDIOWEBSOCKET
SETUP=${SETUP_AUDIOWEBSOCKET}
# Установка приложения AUDIOWEBSOCKET
.PHONY: install-audiowebsocket
install-audiowebsocket: ${AUDIOWEBSOCKET_DEPENDENCES} install
	@printf "\033[0m"
	@printf "\033[33m"
	@echo "============================ INSTALL AUDIOWEBSOCKET ============================="
	@${PIP} install pip wheel -U
	@${PIP} install --editable ${AUDIOWEBSOCKET}
	@echo "========================== INSTALL AUDIOWEBSOCKET OK! ==========================="
	@printf "\033[0m"


# Установка AUDIOWEBSOCKET ALL
.PHONY: install-all
install-all: install-apps install-dev install-saveconf run-saveconf

#===========================================================
# ############## Запуск приложения локально ################
#===========================================================

# Запуск приложения AUDIOWEBSOCKET
.PHONY: run-audiowebsocket
run-audiowebsocket: ${SETUP_AUDIOWEBSOCKET} venv
	@echo "============================== RUN AUDIOWEBSOCKET ==============================="
#	@${VENV_BIN}/${AUDIOWEBSOCKET}
#	@${PYTHON} -m ${AUDIOWEBSOCKET}
	@${PYTHON} ${AUDIOWEBSOCKET_CLI}


#===========================================================
# ############### Архивирование приложения #################
#===========================================================

.PHONY: tar-audiowebsocket
tar-audiowebsocket: ${AUDIOWEBSOCKET}
	@printf "\033[0m"
	@printf "\033[32m"
	@echo "============================= TAR AUDIOWEBSOCKET ================================"
	@make clean
	@tar -cvJf ${RELEASE}/${AUDIOWEBSOCKET}-$(shell date '+%Y-%m-%d-%H-%M-%S').tar.xz ${AUDIOWEBSOCKET}
	@printf "\033[36m"
	@echo "============================ TAR AUDIOWEBSOCKET OK! ============================="
	@printf "\033[0m"


#===========================================================
# ############## Сборка, установка, настройка ##############
#===========================================================
# Обновление системы
.PHONY: update-system
update-system:
	@$(PWD_APP)/$(KALDI_APP_INSTALL) --update

# Установка зависимостей
.PHONY: install-dependents
install-dependents: update-system
	@$(PWD_APP)/$(KALDI_APP_INSTALL) --dependents

# Установка и сборка приложения
.PHONY: build-apps
build-apps:
	@$(PWD_APP)/$(KALDI_APP_INSTALL) --build-apps

# Сборка kaldi
.PHONY: build-kaldi
build-kaldi:
	@$(PWD_APP)/$(KALDI_APP_INSTALL) --build-kaldi

# Удаление kaldi
.PHONY: remove-kaldi
remove-kaldi:
	@$(PWD_APP)/$(KALDI_APP_INSTALL) --remove-kaldi

# Сборка vosk-api
.PHONY: build-vosk-api
build-vosk-api:
	@$(PWD_APP)/$(KALDI_APP_INSTALL) --build-vosk-api

# Удаление vosk-api
.PHONY: remove-vosk-api
remove-vosk-api:
	@$(PWD_APP)/$(KALDI_APP_INSTALL) --remove-vosk-api

# Установка install-apps
.PHONY: install-apps
install-apps:
	@$(PWD_APP)/$(KALDI_APP_INSTALL) --install-apps

# Деинсталяция vosk-api
.PHONY: uninstall-apps
uninstall-apps:
	@$(PWD_APP)/$(KALDI_APP_INSTALL) --uninstall-apps

# Установка vosk-model
.PHONY: install-vosk-model
install-vosk-model:
	@$(PWD_APP)/$(KALDI_APP_INSTALL) --install-vosk-model

# Деинсталяция vosk-model
.PHONY: uninstall-vosk-model
uninstall-vosk-model:
	@$(PWD_APP)/$(KALDI_APP_INSTALL) --uninstall-vosk-model


#===========================================================
# ########## Cборка/Запуск приложения в Docker #############
#===========================================================

# Сборка AUDIOWEBSOCKET
.PHONY: build-docker-base
build-docker-base: ${DOCKER} ${DOCKERFILE_BASE}
	@${DOCKER} build \
	--file $(PWD_APP)/${DOCKERFILE_BASE} \
	--build-arg TIMEZONE=${TIMEZONE} \
	--build-arg USER_ID=${USER_ID} \
	--build-arg GROUP_ID=${USER_ID} \
	--tag ${AUDIOWEBSOCKET}-base:${RELEASE_IMAGE} ./

# Сборка AUDIOWEBSOCKET
.PHONY: build-docker-audiowebsocket
build-docker-audiowebsocket: ${DOCKER} ${DOCKERFILE}
	@make release
	@${DOCKER} build \
	--file $(PWD_APP)/${DOCKERFILE} \
	--build-arg TIMEZONE=${TIMEZONE} \
	--build-arg USER_ID=${USER_ID} \
	--build-arg GROUP_ID=${USER_ID} \
	--tag ${AUDIOWEBSOCKET}:${RELEASE_IMAGE} ./

# Cтарт AUDIOWEBSOCKET
.PHONY: start-docker-audiowebsocket
start-docker-audiowebsocket: ${DOCKER} ${DOCKERFILE}
	@[ `${DOCKER} ps | grep ${AUDIOWEBSOCKET} | wc -l` -eq 1 ] || \
	${DOCKER} run \
	--name ${AUDIOWEBSOCKET} \
	--rm \
	--volume ${AUDIOWEBSOCKET_CONFIG}:/src/${AUDIOWEBSOCKET_CONFIG} \
	--volume ${AUDIOWEBSOCKET_VOSK_MODEL_DIR}:/src/${AUDIOWEBSOCKET_VOSK_MODEL_DIR} \
	--publish ${AUDIOWEBSOCKET_PORT}:${AUDIOWEBSOCKET_PORT} \
	--detach ${AUDIOWEBSOCKET}:${RELEASE_IMAGE} \
	--restart=always
