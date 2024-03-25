#!/bin/bash
clear

# Definir colores en formato RGB
YELLOW='\033[38;2;255;255;0m'
CYAN='\033[38;2;0;255;255m'
NC='\033[0m' # No Color

echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}                                                                              ${YELLOW}║${NC}"
echo -e "${YELLOW}║${NC}           ${YELLOW}BIENVENIDO AL SCRIPT${NC}                                               ${YELLOW}║${NC}"
echo -e "${YELLOW}║${NC}           ${YELLOW}MENU V2RAY VERSION 2.2${NC}                                              ${YELLOW}║${NC}"
echo -e "${YELLOW}║${NC}                                                                               ${YELLOW}║${NC}"
echo -e "${YELLOW}║${NC} DESARROLLADO POR:                                                              ${YELLOW}║${NC}"
echo -e "${YELLOW}║${NC}                     JOAQUÍN                                                   ${YELLOW}║${NC}"
echo -e "${YELLOW}║${NC}           TELEGRAM: ${CYAN}T.ME/joaquinH2${NC}                                             ${YELLOW}║${NC}"
echo -e "${YELLOW}║${NC}                                                                                  ${YELLOW}║${NC}"
echo -e "${YELLOW}║${NC} ${left_spaces}${CYAN}Recomendado para Ubuntu 20.04${NC}            ${YELLOW}║${NC}"
echo -e "${YELLOW}║${NC}                                                                                  ${YELLOW}║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"

sleep 1
install_ini() {
    sudo apt-get install software-properties-common -y
    sudo add-apt-repository universe
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install shc -y
    pip install speedtest-cli
    clear
     echo -e "$BARRA"
    echo -e "\033[92m        -- INSTALANDO PAQUETES NECESARIOS -- "
    echo -e "$BARRA"
    # bc
    [[ $(dpkg --get-selections|grep -w "bc"|head -1) ]] || sudo apt-get install bc -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "bc"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "bc"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install bc................... $ESTATUS "
    # jq
    [[ $(dpkg --get-selections|grep -w "jq"|head -1) ]] || sudo apt-get install jq -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "jq"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "jq"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install jq................... $ESTATUS "
    # python
    [[ $(dpkg --get-selections|grep -w "python"|head -1) ]] || sudo apt-get install python -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "python"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "python"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install python............... $ESTATUS "
    # python-pip
    [[ $(dpkg --get-selections|grep -w "python-pip"|head -1) ]] || sudo apt-get install python-pip -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "python-pip"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "python-pip"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install python-pip........... $ESTATUS "
    # python3
    [[ $(dpkg --get-selections|grep -w "python3"|head -1) ]] || sudo apt-get install python3 -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "python3"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "python3"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install python3.............. $ESTATUS "
    # python3-pip
    [[ $(dpkg --get-selections|grep -w "python3-pip"|head -1) ]] || sudo apt-get install python3-pip -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "python3-pip"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "python3-pip"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install python3-pip.......... $ESTATUS "
    # curl
    [[ $(dpkg --get-selections|grep -w "curl"|head -1) ]] || sudo apt-get install curl -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "curl"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "curl"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install curl................. $ESTATUS "
    # npm
    [[ $(dpkg --get-selections|grep -w "npm"|head -1) ]] || sudo apt-get install npm -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "npm"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "npm"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install npm.................. $ESTATUS "
    # nodejs
    [[ $(dpkg --get-selections|grep -w "nodejs"|head -1) ]] || sudo apt-get install nodejs -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "nodejs"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "nodejs"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install nodejs............... $ESTATUS "
    # socat
    [[ $(dpkg --get-selections|grep -w "socat"|head -1) ]] || sudo apt-get install socat -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "socat"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "socat"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install socat................ $ESTATUS "
    # netcat
    [[ $(dpkg --get-selections|grep -w "netcat"|head -1) ]] || sudo apt-get install netcat -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "netcat"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "netcat"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install netcat............... $ESTATUS "
    # netcat-traditional
    [[ $(dpkg --get-selections|grep -w "netcat-traditional"|head -1) ]] || sudo apt-get install netcat-traditional -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "netcat-traditional"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "netcat-traditional"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install netcat-traditional... $ESTATUS "
    # net-tools
    [[ $(dpkg --get-selections|grep -w "net-tools"|head -1) ]] || sudo apt-get install net-tools -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "net-tools"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "net-tools"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install net-tools............ $ESTATUS "
    # cowsay
    [[ $(dpkg --get-selections|grep -w "cowsay"|head -1) ]] || sudo apt-get install cowsay -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "cowsay"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "cowsay"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install cowsay............... $ESTATUS "
    # figlet
    [[ $(dpkg --get-selections|grep -w "figlet"|head -1) ]] || sudo apt-get install figlet -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "figlet"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "figlet"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install figlet............... $ESTATUS "
    # lolcat
    sudo apt-get install lolcat -y &>/dev/null
    sudo gem install lolcat &>/dev/null
    [[ $(dpkg --get-selections|grep -w "lolcat"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "lolcat"|head -1) ]] && ESTATUS=`echo -e "\033[92mINSTALADO"` &>/dev/null
    echo -e "\033[97m  # apt-get install lolcat............... $ESTATUS "

    echo -e "$BARRA"
    echo -e "\033[92m La instalacion de paquetes necesarios a finalizado"
    echo -e "$BARRA"
    echo -e "\033[97m Si la instalacion de paquetes tiene fallas"
    echo -ne "\033[97m Puede intentar de nuevo [s/n]: "
    read inst
    [[ $inst = @(s|S|y|Y) ]] && install_ini
}
install_ini

# Descarga y ejecuta el script v2.sh
wget --no-cache https://raw.githubusercontent.com/joaquin1444/clientes-v2ray/main/v2.sh
if [ $? -eq 0 ]; then
    chmod +x v2.sh
    sudo bash -c 'echo "alias v2='/root/v2.sh'" >> ~/.bashrc'
    source ~/.bashrc
    /root/v2.sh
else
    echo "Error: No se pudo descargar el script v2.sh"
fi

# Eliminar el instalador
