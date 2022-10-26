#!/bin/bash
system=$(awk -F= '$1 == "ID" { gsub(/"/, "", $NF); print($NF) }' /etc/*release)

PWD_APP=$(pwd)


update() {
# Обновление системы
echo "################################### UPDATE SYSTEM ####################################"
if [[ "$system" = "fedora" ]] || [[ "$system" = "centos" ]]; then
    dnf update -y
elif [[ "$system" = "debian" ]]; then
    apt-get update && apt-get upgrade -y
fi
    

if [[ $? -ne 0 ]]; then
    echo "################################ ERROR UPDATE SYSTEM #################################"
    exit 1
else
    echo "################################# UPDATE SYSTEM OK! ##################################"
fi
}


dependents() {
echo "################################# INSTALL DEPENDENTS #################################"
if [[ "$system" = "fedora" ]] || [[ "$system" = "centos" ]]; then
# Установка зависимостей fedora 35
    dnf install -y make ncurses automake jq gcc gcc-c++ kernel-devel git zip unzip tzdata \
                curl lame lame-libs opus opus-tools opus-devel flac flac-libs which \
                wget bzip2 xz cmake zlib zlib-devel automake autoconf libtool \
                libatomic pkgconf-pkg-config ca-certificates speech-dispatcher \
                speech-dispatcher-devel python3-lxml python3-scons python3-setuptools \
                python3-wheel
elif [[ "$system" = "debian" ]]; then
    apt-get install -y --no-install-recommends build-essential git make unzip tzdata \
        curl libspeechd-dev lame opus-tools flac wget bzip2 xz-utils g++ cmake \
        zlib1g-dev automake autoconf libtool pkg-config ca-certificates jq \
        python3 python3-dev python3-pip python3-venv python3-setuptools \
        python3-wheel python3-websockets python3-cffi \
    && pip3 install scons lxml setuptools wheel
fi

if [[ $? -ne 0 ]]; then
    echo "############################## ERROR INSTALL DEPENDENTS ##############################"
    exit 1
else
    echo "############################### INSTALL DEPENDENTS OK! ###############################"
fi
}


build-kaldi() {
# Сборка kaldi
echo "#################################### BUILD KALDI #####################################"
cd ${PWD_APP}
git clone -b vosk --single-branch ${KALDI_GIT} ${KALDI_DIR} \
    && cd ${KALDI_DIR}/tools \
    && sed -i 's:status=0:exit 0:g' extras/check_dependencies.sh \
    && sed -i 's:--enable-ngram-fsts:--enable-ngram-fsts --disable-bin:g' Makefile \
    && make -j $(nproc) openfst cub \
    && if [ "x${KALDI_MKL}" != "x1" ] ; then \
          extras/install_openblas_clapack.sh; \
       else \
          extras/install_mkl.sh; \
       fi \
    && cd ${PWD_APP} \
    && cd ${KALDI_DIR}/src \
    && if [ "x${KALDI_MKL}" != "x1" ] ; then \
          ./configure --mathlib=OPENBLAS_CLAPACK --shared; \
       else \
          ./configure --mathlib=MKL --shared; \
       fi \
    && sed -i 's:-msse -msse2:-msse -msse2:g' kaldi.mk \
    && sed -i 's: -O1 : -O3 :g' kaldi.mk \
    && make -j $(nproc) online2 lm rnnlm

if [[ $? -ne 0 ]]; then
    echo "################################# ERROR BUILD KALDI ##################################"
    exit 1
else
    echo "################################## BUILD KALDI OK! ###################################"
fi
}

remove-kaldi(){
# Удаление kaldi
echo "################################## REMOVE KALDI ######################################"
cd ${PWD_APP}
rm -fr ${KALDI_DIR}

if [[ $? -ne 0 ]]; then
    echo "############################### ERROR REMOVE KALDI ###############################"
    exit 1
else
    echo "################################## REMOVE KALDI OK! ##################################"
fi
}


build-vosk-api() {
# Сборка vosk-api
echo "################################### BUILD VOSK-API ###################################"
cd ${PWD_APP}
git clone ${VOSKAPI_GIT} ${VOSKAPI_DIR} \
    && cd ${VOSKAPI_DIR} \
    && rm -fr android c csharp go ios java nodejs travis webjs \
    && cd src \
    && KALDI_MKL=${KALDI_MKL} KALDI_ROOT=${PWD_APP}/${KALDI_DIR} make -j $(nproc) \
    && rm -f *.o

if [[ $? -ne 0 ]]; then
    echo "################################ ERROR BUILD VOSK-API ################################"
    exit 1
else
    echo "################################# BUILD VOSK-API OK! #################################"
fi
}


remove-vosk-api(){
# Удаление vosk-api
echo "################################## REMOVE VOSK-API ###################################"
cd ${PWD_APP}
rm -fr ${VOSKAPI_DIR}

if [[ $? -ne 0 ]]; then
    echo "############################### ERROR REMOVE VOSK-API ################################"
    exit 1
else
    echo "################################ REMOVE VOSK-API OK! #################################"
fi
}


install-apps() {
# Установка vosk-api
echo "################################## INSTALL VOSK-API ##################################"

cd ${PWD_APP}
make install-audiowebsocket

cd ${VOSKAPI_DIR}/python \
    && ${PWD_APP}/venv/bin/python3 ./setup.py install

if [[ $? -ne 0 ]]; then
    echo "################################ ERROR BUILD VOSK-API ################################"
    exit 1
else
    echo "################################# BUILD VOSK-API OK! #################################"
fi
}

uninstall-apps(){
# Деинсталяция vosk-api
echo "################################# UNINSTALL VOSK-API #################################"

cd ${PWD_APP}
make uninstall && cd ${PWD_APP} && rm -fr kaldi vosk-api

if [[ $? -ne 0 ]]; then
    echo "############################## ERROR UNINSTALL VOSK-API ##############################"
    exit 1
else
    echo "############################### UNINSTALL VOSK-API OK! ###############################"
fi
}

install-vosk-model() {
# Установка vosk-model
echo "################################# INSTALL VOSK-MODEL #################################"

cd ${PWD_APP}
if ! [ -e ${VOSK_MODEL_DIR} ]; then
    mkdir ${VOSK_MODEL_DIR}
else
    rm -fr ${VOSK_MODEL_DIR}/*
fi

if [ -e vosk-model-ru-${VOSK_MODEL_RU_VERSION} ]; then
    rm -fr vosk-model-ru-${VOSK_MODEL_RU_VERSION}
fi

if ! [ -f vosk-model-ru-${VOSK_MODEL_RU_VERSION}.zip ]; then
    wget -v ${VOSK_MODEL_URL}
else
   unzip vosk-model-ru-${VOSK_MODEL_RU_VERSION}.zip \
   && mv vosk-model-ru-${VOSK_MODEL_RU_VERSION}/* ${VOSK_MODEL_DIR} \
   && rm -rf ${VOSK_MODEL_DIR}/extra \
   && mv vosk-model-ru-${VOSK_MODEL_RU_VERSION}.zip ${VOSK_MODEL_DIR} \
   && rm -fr vosk-model-ru-${VOSK_MODEL_RU_VERSION}
#   && rm -fr vosk-model-ru-${VOSK_MODEL_RU_VERSION}.zip
fi

if [[ $? -ne 0 ]]; then
    echo "############################### ERROR BUILD VOSK-MODEL ###############################"
    exit 1
else
    echo "################################ BUILD VOSK-MODEL OK! ################################"
fi
}


uninstall-vosk-model(){
# Деинсталяция vosk-model
echo "################################ UNINSTALL VOSK-MODEL ################################"

cd ${PWD_APP}
rm -rf ${VOSK_MODEL_DIR}

if [[ $? -ne 0 ]]; then
    echo "############################# ERROR UNINSTALL VOSK-MODEL #############################"
    exit 1
else
    echo "############################## UNINSTALL VOSK-MODEL OK! ##############################"
fi
}


build-apps() {
# Установка и сборка приложения
    build-kaldi
    build-vosk-api
    install-apps
    install-vosk-model
}


case $1 in
    "--update" )
          update # Обновление системы
          ;;
    "--dependents" )
          dependents # Установка зависимостей
          ;;
    "--build-apps" )
          build-apps $2 $3 # Установка и сборка приложения
          ;;
    "--build-kaldi" )
          build-kaldi # Сборка kaldi
          ;;
    "--remove-kaldi" )
          remove-kaldi # Удаление kaldi
          ;;
    "--build-vosk-api" )
          build-vosk-api # Сборка vosk-api
          ;;
    "--remove-vosk-api" )
          remove-vosk-api # Удаление vosk-api
          ;;
    "--install-apps" )
          install-apps # Установка vosk-api и приложения audiowebsocket
          ;;
    "--uninstall-apps" )
          uninstall-apps # Деинсталяция vosk-api и приложения audiowebsocket
          ;;
    "--install-vosk-model" )
          install-vosk-model # Установка vosk-model
          ;;
    "--uninstall-vosk-model" )
          uninstall-vosk-model # Деинсталяция vosk-model
          ;;
    "--help" )
          echo "######################################## HELP ########################################"
          echo " $0 --update             | Установка обновлений системы"
          echo " $0 --dependents         | Установка зависимостей"
          echo " $0 --build              | Установка и сборка приложения"
          echo " $0 --build-kaldi        | Сборка kaldi"
          echo " $0 --remove-kaldi       | Удаление kaldi"
          echo " $0 --build-vosk-api     | Сборка vosk-api"
          echo " $0 --remove-vosk-api    | Удаление vosk-api"
          echo " $0 --install-apps       | Установка vosk-api и приложения audiowebsocket"
          echo " $0 --uninstall-apps     | Деинсталяция vosk-api и приложения audiowebsocket"
          echo " $0 --help               | Справка по работе со скриптом"
          echo "######################################################################################"
          ;;
     *)
          echo "######################################################################################"
          echo " HELP по работе со скриптом $0 --help"
          echo "######################################################################################"
          ;;
esac
