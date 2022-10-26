#===========================================================
# ################## Установка приложения ##################
#===========================================================

# Установка AUDIOWEBSOCKET SAVECONFIG
.PHONY: install-saveconf
install-saveconf: ${SAVECONFIG} install
	@printf "\033[0m"
	@printf "\033[33m"
	@echo "======================== Install AUDIOWEBSOCKET SAVECONFIG ========================="
	@${PIP} install pip wheel -U
	@${PIP} install --editable ${SAVECONFIG}
	@echo "====================== Install AUDIOWEBSOCKET SAVECONFIG OK! ======================="
	@printf "\033[0m"

#===========================================================
# ############## Запуск приложения локально ################
#===========================================================

# Запуск SAVECONFIG - создание файла настроек для AUDIOWEBSOCKET
.PHONY: run-saveconf
run-saveconf: ${SETUP_SAVECONFIG} venv
	@printf "\033[0m"
	@printf "\033[33m"
	@echo "============================ AUDIOWEBSOCKET SAVECONFIG ============================="
	@${VENV_BIN}/${SAVECONFIG}
	@echo "========================== AUDIOWEBSOCKET SAVECONFIG OK ============================"
	@printf "\033[0m"

