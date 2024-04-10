#!/bin/bash
clear

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
NC=$(tput sgr0) # No Color
BG_BLACK=$(tput setab 0)

echo -e "${CYAN}${BG_BLACK}╔═════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BG_BLACK}║${NC}                                                 ${CYAN}${BG_BLACK}║${NC}"
echo -e "${CYAN}${BG_BLACK}║${NC}           ${CYAN}BIENVENIDO AL SCRIPT${NC}                  ${CYAN}${BG_BLACK}║${NC}"
echo -e "${CYAN}${BG_BLACK}║${NC}           ${CYAN}MENU V2RAY VERSION 2.8${NC}                ${CYAN}${BG_BLACK}║${NC}"
echo -e "${CYAN}${BG_BLACK}║${NC}                                                 ${CYAN}${BG_BLACK}║${NC}"
echo -e "${CYAN}${BG_BLACK}║${NC} DESARROLLADO POR:                               ${CYAN}${BG_BLACK}║${NC}"
echo -e "${CYAN}${BG_BLACK}║${NC}                     JOAQUÍN                     ${CYAN}${BG_BLACK}║${NC}"
echo -e "${CYAN}${BG_BLACK}║${NC}           TELEGRAM: ${YELLOW}t.me/joaquinH2${NC}              ${CYAN}${BG_BLACK}║${NC}"
echo -e "${CYAN}${BG_BLACK}║${NC}                                                 ${CYAN}${BG_BLACK}║${NC}"
echo -e "${CYAN}${BG_BLACK}║${NC} ${YELLOW}Recomendado para Ubuntu 20.04${NC}                   ${CYAN}${BG_BLACK}║${NC}"
echo -e "${CYAN}${BG_BLACK}║${NC}                                                 ${CYAN}${BG_BLACK}║${NC}"
echo -e "${CYAN}${BG_BLACK}╚═════════════════════════════════════════════════╝${NC}"

sleep 1
install_ini() {
    sudo apt-get install software-properties-common -y
    sudo add-apt-repository universe
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install shc -y
    pip install speedtest-cli
    echo "0 0 * * * /ruta/al/comando_a_ejecutar" | sudo crontab -
    clear
     echo -e "$BARRA"
    echo -e "\033[92m -- INSTALANDO PAQUETES NECESARIOS -- \033[0m"
    echo -e "\033[92mESTO PUEDE TARDAR UN POCO ESPERAR HASTA EL FINAL.\033[0m"
    
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



if [ -f /usr/bin/v2.sh ]; then
    sudo rm /usr/bin/v2.sh
fi

unalias v2 > /dev/null 2>&1

wget --no-cache -O /usr/bin/v2.sh https://raw.githubusercontent.com/joaquin1444/clientes-v2ray/main/v2.sh > /dev/null 2>&1
if [ $? -eq 0 ]; then
    sudo chmod +x /usr/bin/v2.sh
    
    echo "alias v2='/usr/bin/v2.sh'" | sudo tee -a ~/.bashrc > /dev/null
    
    /usr/bin/v2.sh
else
    echo "Error: No se pudo descargar el script v2.sh"
fi
