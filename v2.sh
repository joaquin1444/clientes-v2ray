#!/bin/bash


echo "alias v2='/root/v2.sh'" >> ~/.bashrc

source ~/.bashrc


CONFIG_FILE="/etc/v2ray/config.json"
USERS_FILE="/etc/v2ray/v2clientes.txt"



RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
NC=$(tput sgr0)
print_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}
check_v2ray_status() {
    if systemctl is-active --quiet v2ray; then
        echo -e "${YELLOW}V2Ray está ${GREEN}activo${NC}"
    else
        echo -e "${YELLOW}V2Ray está ${RED}desactivado${NC}"
    fi
}
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
NC=$(tput sgr0)
BG_BLACK=$(tput setab 0)
show_menu() {
    local VERSION="2.1"
    clear
    echo -e "\e[36m╔════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[33m ••••••••••• Menú V2Ray ••••••••••• (versión) \e[35m$VERSION\e[33m     \e[0m"
    
    menu_info  
    echo -e "\e[36m╚════════════════════════════════════════════════════╝\e[0m"
    echo -e "\e[36m\e[31m[1]\e[0m \e[32m➕ AGREGAR NUEVO USUARIO \e[0m"
    echo -e "\e[36m\e[32m[2]\e[0m \e[31m🗑 ELIMINAR USUARIO \e[0m"
    echo -e "\e[36m\e[33m[3]\e[0m \e[33m🔄 EDITAR UUID DE USUARIO \e[0m"
    echo -e "\e[36m\e[34m[4]\e[0m \e[33m👥 VER INFORMACIÓN DE USUARIOS \e[0m"
    echo -e "\e[36m\e[35m[5]\e[0m \e[33m🔍 VER VMESS \e[0m"
    echo -e "\e[36m\e[35m[6]\e[0m \e[33m🚮 ELIMINAR EXPIRADOS \e[0m"
    echo -e "\e[36m\e[35m[7]\e[0m \e[33m🟢 VER CONECTADOS \e[0m"
    echo -e "\e[36m\e[36m[8]\e[0m \e[33m📂 GESTIÓN DE COPIAS DE SEGURIDAD \e[0m"
    echo -e "\e[36m\e[91m[9]\e[0m \e[33m🚀 ENTRAR AL V2RAY NATIVO \e[0m"
    echo -e "\e[36m\e[92m[10]\e[0m \e[33m🔧 CONFIGURAR V2RAY \e[0m"
    echo -e "\e[36m\e[93m[11]\e[0m \e[33m🚪 SALIR \e[0m"
    echo -e "\e[36m╚════════════════════════════════════════════════════╝\e[0m"
    echo -e "\e[34m⚙️ Acceder al menú con V2 \e[0m"
}
get_and_save_public_ip() {
    curl -s --max-time 5 https://api.ipify.org > ip.txt
}
get_saved_public_ip() {
    cat ip.txt
}
get_os_info() {
    if [[ "$(grep -c "Ubuntu" /etc/issue.net)" = "1" ]]; then
        echo "Ubuntu $(cut -d' ' -f2 /etc/issue.net)"
    elif [[ "$(grep -c "Debian" /etc/issue.net)" = "1" ]]; then
        echo "Debian $(cut -d' ' -f3 /etc/issue.net)"
    else
        echo "$(cut -d' ' -f1 /etc/issue.net)"
    fi
}


if [ ! -f "ip.txt" ]; then
    get_and_save_public_ip
fi

menu_info() {
    public_ip=$(get_saved_public_ip)
    local status_line
    status_line=$(check_v2ray_status)
    os_info=$(get_os_info)
    _usor=$(printf '%-8s' "$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')")
    _ram=$(printf ' %-8s' "$(free -h | grep -i mem | awk {'print $2'})")
    _ram2=$(printf ' %-8s' "$(free -h | grep -i mem | awk {'print $4'})")
    _system=$(printf '%-9s' "$os_info")
    _core=$(printf '%-8s' "$(grep -c cpu[0-9] /proc/stat)")
    _usop=$(top -bn1 | sed -rn '3s/[^0-9]* ([0-9\.]+) .*/\1/p;4s/.*, ([0-9]+) .*/\1/p' | tr '\n' ' ')
    modelo1=$(printf '%-11s' "$(lscpu | grep Arch | sed 's/\s\+/,/g' | cut -d , -f2)")
    mb=$(printf '%-8s' "$(free -h | grep Mem | sed 's/\s\+/,/g' | cut -d , -f6)")
    _hora=$(printf '%(%H:%M:%S)T')
    _hoje=$(date +'%d/%m/%Y')
    echo -e "\033[1;37m SO \033[1;31m: \033[1;32m$_system \033[1;37mTIEMPO\033[1;31m: \033[1;32m$_hora"
    echo -e "\033[1;37m RAM\e[31m: \033[1;32m$_ram \033[1;37mUSADA\033[1;31m: \033[1;32m$mb\033[1;37m LIBRE\033[1;31m: \033[1;32m$_ram2"
    echo -e "[${status_line}] \033[1;37mIP\033[1;31m:\033[1;32m $public_ip"
}
show_backup_menu() {
    clear
    print_separator
    echo -e "${YELLOW}Opciones de v2ray backup:${NC}"
    echo -e "1. ${GREEN}Crear copia de seguridad${NC}"
    echo -e "2. ${RED}Restaurar copia de seguridad${NC}"
    echo -e "3. Volver al menú principal"
    print_separator
    read -p "Seleccione una opción: " backupOption

    case $backupOption in
        1)
            create_backup
            ;;
        2)
            restore_backup
            ;;
        3)
            main_menu  
            ;;
        *)
            print_message "${RED}" "Opción no válida."
            ;;
    esac
}



add_user() {
    clear
    print_separator
    print_message "${CYAN}" "AGREGAR NUEVO USUARIO"

    read -p "$(echo -e "${YELLOW}INGRESE EL NOMBRE DEL NUEVO USUARIO:${NC} ")" userName
    if grep -q "| $userName |" "$USERS_FILE"; then
        print_message "${RED}" "YA EXISTE UN USUARIO CON EL MISMO NOMBRE. POR FAVOR, ELIJA OTRO NOMBRE."
        read -p "PRESIONE ENTER PARA REGRESAR AL MENÚ PRINCIPAL" enterKey
        clear
        return 1
    fi
    print_separator
    read -p "$(echo -e "${YELLOW}INGRESE LA DURACIÓN EN DÍAS PARA EL NUEVO USUARIO:${NC} ")" days

    if ! [[ "$days" =~ ^[0-9]+$ ]]; then
        print_message "${RED}" "LA DURACIÓN DEBE SER UN NÚMERO."
        read -p "PRESIONE ENTER PARA REGRESAR AL MENÚ PRINCIPAL" enterKey
        clear
        return 1
    fi
    print_separator
    read -p "$(echo -e "${YELLOW}¿DESEA INGRESAR UN UUID PERSONALIZADO? (SÍ: S, NO: CUALQUIER TECLA):${NC} ")" customUuidChoice

    if [[ "${customUuidChoice,,}" == "s" ]]; then
        read -p "$(echo -e "${YELLOW}INGRESE EL UUID PERSONALIZADO PARA EL NUEVO USUARIO (FORMATO: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX):${NC} ")" userId

        if ! [[ "$userId" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
            print_message "${RED}" "FORMATO DE UUID NO VÁLIDO. DEBE SER XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
            read -p "PRESIONE ENTER PARA REGRESAR AL MENÚ PRINCIPAL" enterKey
            clear
            return 1
        fi

        if grep -q "$userId" "$USERS_FILE"; then
            print_message "${RED}" "ADVERTENCIA: YA EXISTE UN USUARIO CON EL MISMO UUID. ELIMINANDO EL USUARIO EXISTENTE..."
            delete_user_by_uuid "$userId"
        fi
    else
        userId=$(uuidgen)
    fi
    alterId=0
    expiration_date=$(date -d "+$days days" +%Y-%m-%d)
    print_separator
    print_message "${CYAN}" "UUID DEL NUEVO USUARIO: ${GREEN}$userId${NC}"
    print_message "${YELLOW}" "FECHA DE EXPIRACIÓN: ${GREEN}$expiration_date${NC}"

    userJson="{\"alterId\": $alterId, \"id\": \"$userId\", \"email\": \"$userName\", \"expiration\": $(date -d "$expiration_date" +%s)}"

    jq ".inbounds[0].settings.clients += [$userJson]" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    
    echo "$userId | $userName | $expiration_date" >> "$USERS_FILE"

    systemctl restart v2ray
    print_message "${GREEN}" "USUARIO AGREGADO EXITOSAMENTE."
    print_separator
    
    print_message "${CYAN}" "VMESS DEL NUEVO USUARIO:"
    ps="$userName"
    id="$userId"
    aid="$alterId"
    add=$(jq -r '.inbounds[0].domain // (.inbounds[0].listen | split(":")[0])' "$CONFIG_FILE")
    port=$(jq '.inbounds[0].port' "$CONFIG_FILE")
    net=$(jq -r '.inbounds[0].streamSettings.network' "$CONFIG_FILE")
    path=$(jq -r '.inbounds[0].streamSettings.wsSettings.path // empty' "$CONFIG_FILE")
    host=$(jq -r '.inbounds[0].streamSettings.wsSettings.headers.Host // empty' "$CONFIG_FILE")

    
    tls_active=$(jq '.inbounds[0].streamSettings | has("security")' "$CONFIG_FILE")
    if [[ "$tls_active" == "true" ]]; then
        tls="open"
    else
        tls="close"
    fi

    var="{\"v\":\"2\",\"ps\":\"$ps\",\"add\":\"$add\",\"port\":$port,\"aid\":$aid,\"type\":\"none\",\"net\":\"$net\",\"path\":\"$path\",\"host\":\"$host\",\"id\":\"$id\",\"tls\":\"$tls\"}"
    print_message "${GREEN}" "vmess://$(echo "$var" | jq -r '.|@base64')"

    print_separator
    read -p "PRESIONE ENTER PARA REGRESAR AL MENÚ PRINCIPAL" enterKey
}










delete_user() {
    clear
    print_message "${CYAN}" "⚠️ ADVERTENCIA: LOS USUARIOS EXPIRADOS SE RECOMIENDA ELIMINARLOS MANUALMENTE CON EL ID ⚠️ "
    show_registered_user

    read -p "INGRESE EL ID DEL USUARIO QUE DESEA ELIMINAR (O PRESIONE ENTER PARA CANCELAR): " userId

    if [ -z "$userId" ]; then
        print_message "${YELLOW}" "NO SE SELECCIONÓ NINGÚN ID. VOLVIENDO AL MENÚ PRINCIPAL."
        return
    fi

    jq ".inbounds[0].settings.clients = (.inbounds[0].settings.clients | map(select(.id != \"$userId\")))" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    sed -i "/$userId/d" "$USERS_FILE"
    print_message "${RED}" "USUARIO CON ID $userId ELIMINADO."
    systemctl restart v2ray
    read -p "PRESIONE ENTER PARA REGRESAR AL MENÚ PRINCIPAL" enterKey
}
delete_users_by_uuid() {
    local userId=$1

    
    jq ".inbounds[0].settings.clients = (.inbounds[0].settings.clients | map(select(.id != \"$userId\")))" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    
    sed -i "/$userId/d" "$USERS_FILE"

    
    systemctl restart v2ray
    echo -e "\033[33mUSUARIOS CON UUID $userId ELIMINADOS.\033[0m"
    read -p "PRESIONE ENTER PARA REGRESAR AL MENÚ PRINCIPAL" enterKey

}
delete_user_by_uuid() {
    local userId=$1

    
    jq ".inbounds[0].settings.clients = (.inbounds[0].settings.clients | map(select(.id != \"$userId\")))" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    
    sed -i "/$userId/d" "$USERS_FILE"

    
    systemctl restart v2ray
    echo -e "\033[33mUSUARIO CON UUID $userId ELIMINADO.\033[0m"
    read -p "PRESIONE ENTER PARA REGRESAR AL MENÚ PRINCIPAL" enterKey
}
edit_user_uuid() {
    show_registered_user
    read -p "INGRESE EL ID DEL USUARIO QUE DESEA EDITAR (O PRESIONE ENTER PARA CANCELAR): " userId

    if [ -z "$userId" ]; then
        print_message "${YELLOW}" "NO SE SELECCIONÓ NINGÚN ID. VOLVIENDO AL MENÚ PRINCIPAL."
        read -p "PRESIONE ENTER PARA REGRESAR AL MENÚ PRINCIPAL" enterKey
        return
    fi

    
    oldUserData=$(grep "$userId" /etc/v2ray/v2clientes.txt)

    
    sed -i "/$userId/d" "$USERS_FILE"

    read -p "INGRESE EL NUEVO UUID PARA EL USUARIO CON ID $userId: " newUuid

    if [[ ! "$newUuid" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
    print_message "${RED}" "FORMATO DE UUID NO VÁLIDO. DEBE SER XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
    read -p "PRESIONE ENTER PARA REGRESAR AL MENÚ PRINCIPAL" enterKey
    return
fi

    
    oldName=$(echo "$oldUserData" | awk -F "|" '{print $2}')

    read -p "INGRESE EL NUEVO NOMBRE PARA EL USUARIO CON ID $userId (O PRESIONE ENTER PARA CONSERVAR EL NOMBRE $oldName): " newName

newName=$(echo $newName | xargs)  

if [ -z "$newName" ]; then
    newName=$(echo "$oldName" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
fi

    read -p "INGRESE EL NÚMERO DE DÍAS PARA LA FECHA DE EXPIRACIÓN (O PRESIONE ENTER PARA CONSERVAR LA FECHA DEL USUARIO ANTERIOR): " expiryDays

    if [ -z "$expiryDays" ]; then
        oldDate=$(echo "$oldUserData" | awk -F "|" '{print $3}' | xargs)
        newDate=$oldDate
    else
        newDate=$(date -d "+$expiryDays days" "+%Y-%m-%d")
    fi

    
    sleep 2
    sed -i "/$userId/d" /etc/v2ray/v2clientes.txt

    
    echo "$newUuid | $newName | $newDate" >> /etc/v2ray/v2clientes.txt

    
    jq ".inbounds[0].settings.clients = (.inbounds[0].settings.clients | map(if .id == \"$userId\" then .id = \"$newUuid\" | .email = \"$newName\" else . end))" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    
    systemctl restart v2ray

    print_message "${GREEN}" "UUID DEL USUARIO CON ID $userId EDITADO EXITOSAMENTE."
    read -p "PRESIONE ENTER PARA REGRESAR AL MENÚ PRINCIPAL" enterKey
return
}
create_backup() {
    clear
    print_separator
    read -p "INGRESE EL NOMBRE DEL ARCHIVO DE RESPALDO: " backupFileName
    backupFilePath="/root/$backupFileName"  
    cp $CONFIG_FILE "$backupFilePath"_config.json
    cp $USERS_FILE "$backupFilePath"_v2clientes.txt
    print_message "${GREEN}" "COPIA DE SEGURIDAD CREADA EN: $backupFilePath"
    print_separator
    read -p "PRESIONE ENTER PARA CONTINUAR"
}
show_backups() {
    print_separator
    clear
    echo -e "\e[1m\e[34mBACKUPS DISPONIBLES:\e[0m"
    
    for backupFile in /root/*_config.json; do
        
        backupName=$(basename "$backupFile" _config.json)
        
        
        backupDateTime=$(date -r "$backupFile" "+%Y-%m-%d %H:%M:%S")
        
        
        echo -e "\e[1m\e[32mNombre:\e[0m $backupName"
        echo -e "\e[1m\e[32mFecha y hora:\e[0m $backupDateTime"
        print_separator
    done
}
show_registered_user() {
    echo -e "\e[97;40m$(clear)"
echo -e "\e[97;40mInformación de Usuarios:"
echo -e "\e[97;40m=========================================================="
echo -e "\e[97;40mUUID                                 Nombre      Días"
echo -e "\e[97;40m=========================================================="

    current_time=$(date +%s)

    contador_activos=0
    contador_expirados=0

    while IFS='|' read -r uuid nombre fecha_expiracion || [[ -n "$uuid" ]]; do
        expiracion_timestamp=$(date -d "$fecha_expiracion" +%s)
        dias_restantes=$(( (expiracion_timestamp - current_time + 86399) / 86400 ))

        if [ "$current_time" -ge "$expiracion_timestamp" ]; then
    color="\e[31m"  
    ((contador_expirados++))
    printf "%b%-37s %-10s [%s]\n" "$color" "$uuid" "$nombre" "Expirado"
else
    color="\e[32m"  
    ((contador_activos++))
    printf "%b%-37s %-10s [%s]\n" "$color" "$uuid" "$nombre" "$dias_restantes"
fi
    
done < <(sort -k3.1,3.10 /etc/v2ray/v2clientes.txt)
    echo -e "\e[34m==========================================================\e[0m"
    echo -e "\e[97;40mUsuarios activos: [\e[32m${contador_activos}\e[0m\e[97;40m]"
    echo -e "\e[97;40mUsuarios expirados: [\e[31m${contador_expirados}\e[0m\e[97;40m]"
}
show_registered_users() {
    tput sgr0  
    echo -e "\e[97;40m$(clear)"
    echo -e "\e[97;40mInformación de Usuarios:"
    echo -e "\e[97;40m=========================================================="
    echo -e "\e[97;40mUUID                                 Nombre      Días"
    echo -e "\e[97;40m=========================================================="

    current_time=$(date +%s)

    contador_activos=0
    contador_expirados=0

    while IFS='|' read -r uuid nombre fecha_expiracion || [[ -n "$uuid" ]]; do
        expiracion_timestamp=$(date -d "$fecha_expiracion" +%s)
        dias_restantes=$(( (expiracion_timestamp - current_time + 86399) / 86400 ))

        if [ "$current_time" -ge "$expiracion_timestamp" ]; then
            color="\e[31m"  
            ((contador_expirados++))
        else
            color="\e[32m"  
            ((contador_activos++))
        fi

        printf "%b%-37s %-10s [%s]\n\e[97;40m" "$color" "$uuid" "$nombre" "$dias_restantes"
    done < <(sort -k3.1,3.10 /etc/v2ray/v2clientes.txt)

    echo -e "\e[34m==========================================================\e[0m"
    echo -e "\e[97;40mUsuarios activos: [\e[32m${contador_activos}\e[0m\e[97;40m]"
    echo -e "\e[97;40mUsuarios expirados: [\e[31m${contador_expirados}\e[0m\e[97;40m]"
    read -p "Presione Enter para regresar al menú principal" enterKey
    tput sgr0  
}


show_vmess_by_id() {
    clear
    print_separator
    print_message "${CYAN}" "Mostrar VMess por ID"

    # Mostrar la lista de usuarios VMess registrados
    show_registered_user

    read -p "$(echo -e "${YELLOW}Ingrese el ID del usuario VMess que desea ver:${NC} ")" vmess_id

    
    vmess_index=$(jq -r '.inbounds[0].settings.clients | map(.id == "'"$vmess_id"'") | index(true)' "$CONFIG_FILE")

    if [[ "$vmess_index" = "null" ]]; then
        print_message "${RED}" "No se encontró ningún usuario VMess con el ID especificado."
        read -p "Presione Enter para regresar al menú principal" enterKey
        return
    fi

    ps=$(jq -r .inbounds[0].settings.clients[$vmess_index].email "$CONFIG_FILE")
    id=$(jq -r .inbounds[0].settings.clients[$vmess_index].id "$CONFIG_FILE")
    aid=$(jq .inbounds[0].settings.clients[$vmess_index].alterId "$CONFIG_FILE")
    add=$(jq -r '.inbounds[0].domain // (.inbounds[0].listen | split(":")[0])' "$CONFIG_FILE") && [[ $add = null ]] && add=$(wget -qO- ipv4.icanhazip.com)
    port=$(jq '.inbounds[0].port' "$CONFIG_FILE")
    tls=$(jq -r '.inbounds[0].streamSettings.security // "none"' "$CONFIG_FILE")
    host=$(jq -r '.inbounds[0].streamSettings.wsSettings.headers.Host // empty' "$CONFIG_FILE")
    path=$(jq -r '.inbounds[0].streamSettings.wsSettings.path // empty' "$CONFIG_FILE")
    net=$(jq -r '.inbounds[0].streamSettings.network' "$CONFIG_FILE")

    var="{\"v\":\"2\",\"ps\":\"$ps\",\"add\":\"$add\",\"port\":$port,\"aid\":$aid,\"type\":\"none\",\"net\":\"$net\",\"path\":\"$path\",\"host\":\"$host\",\"id\":\"$id\",\"tls\":\"$tls\"}"
    print_message "${GREEN}" "vmess://$(echo "$var" | jq -r '.|@base64')"

    read -p "Presione Enter para regresar al menú principal" enterKey
}

conexion() {
    clear
    CGHlog='/var/log/v2ray/access.log'
    [[ $log0 -le 1 ]] && {
        v2ray restart &> /dev/null
        v2ray clean &> /dev/null && let log0++ && clear 
    }
    echo ""
    
    echo -ne '\033[0;34mCargando [\033[0m'
    for i in {1..10}
    do
        echo -ne '\033[0;32m###\033[0m'
        sleep 0.4
    done
    echo -e '\033[0;34m] completo\033[0m'
    sleep 0.3
    clear && clear
    users=$(jq -r '.inbounds[0].settings.clients[] | .email' /etc/v2ray/config.json)
    v2rayports=$(jq -r '.inbounds[0].port' /etc/v2ray/config.json)
    
    
    activos=$(grep -c "accepted" ${CGHlog})
    
    n=1
    echo -e "\033[1;97;41m     PUERTO ACTIVO : $v2rayports    ACTIVOS:  $activos \033[0m"
    echo -e "\033[1;97;41m N) | USER  |   CONEXIONES \033[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    for U in $users
    do
        CConT=$(grep -c "accepted.*email: $U" ${CGHlog})
        [[ $CConT = 0 ]] && continue
        printf "\033[0;32m%-5s | %-10s | %-10s\033[0m\n" "$n)" "$U" "$CConT"
        let n++
    done
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[0mPRESIONE CUALQUIER TECLA PARA CONTINUAR..."
    read -n 1 -s -r
    v2ray clean > /dev/null 2>&1
}

interface="eth0"


v2ray_port="80"


get_traffic() {
    vnstat -i "$interface" --json | jq ".interfaces[0].traffic.total.rx+ .interfaces[0].traffic.total.tx"
}

get_connections() {
    netstat -anp | grep ":$v2ray_port " | grep ESTABLISHED | wc -l
}
restore_backup() {
    show_backups
    read -p "Ingrese el nombre del archivo de respaldo a restaurar: " backupFileName
    
    if [[ -f "/root/${backupFileName}_config.json" ]]; then
        cp "/root/${backupFileName}_config.json" $CONFIG_FILE
        cp "/root/${backupFileName}_v2clientes.txt" $USERS_FILE
        print_message "${GREEN}" "Copia de seguridad '$backupFileName' restaurada."
        read -p "Presione Enter para regresar al menú principal" enterKey
return
        # Restart V2Ray
        systemctl restart v2ray
    else
        print_message "${RED}" "Error: El archivo de respaldo '$backupFileName' no existe."
        read -p "Presione Enter para regresar al menú principal" enterKey
return
    fi
}
install_ini() {
    sudo apt-get install software-properties-common -y
    sudo add-apt-repository universe
    sudo apt update -y
    sudo apt upgrade -y
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
    [[ $(dpkg --get-selections|grep -w "python3"|head -1) ]] && ESTATUS=`echo -e "\e[3;32mINSTALADO\e[0m"` &>/dev/null
    echo -e "\033[97m  # apt-get install python3.............. $ESTATUS "
    # python3-pip
    [[ $(dpkg --get-selections|grep -w "python3-pip"|head -1) ]] || sudo apt-get install python3-pip -y &>/dev/null
    [[ $(dpkg --get-selections|grep -w "python3-pip"|head -1) ]] || ESTATUS=`echo -e "\033[91mFALLO DE INSTALACION"` &>/dev/null
    [[ $(dpkg --get-selections|grep -w "python3-pip"|head -1) ]] && ESTATUS=`echo -e "\e[3;32mINSTALADO\e[0m"` &>/dev/null
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
install_v2ray() {
    install_ini

    
    download_and_move_v2ctl() {
        echo "Descargando v2ctl desde GitHub..."
        curl -o v2ctl.zip -sSL https://raw.githubusercontent.com/joaquin1444/clientes-v2ray/main/v2ctl.zip

        
        unzip -o -q v2ctl.zip -d /usr/bin/v2ray/

        if [ $? -eq 0 ]; then
            
            
            chmod +x /usr/bin/v2ray/v2ctl
        else
            echo " "
        fi
        rm v2ctl.zip
    }

    
    curl -sL https://multi.netlify.app/v2ray.sh | bash
    
    
    cat <<EOF > /etc/systemd/system/v2ray.service
[Unit]
Description=V2Ray Service
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/v2ray/v2ray run -c /etc/v2ray/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    config="/etc/v2ray/config.json"
    tmp_config="/etc/v2ray/tmp.json"
    if [ -e "$config" ]; then
        jq 'del(.inbounds[].streamSettings.kcpSettings)' < "$config" >> "$tmp_config"
    fi

    download_and_move_v2ctl

    systemctl daemon-reload &>/dev/null
    systemctl start v2ray &>/dev/null
    systemctl enable v2ray &>/dev/null
    systemctl restart v2ray.service

    echo "V2Ray instalado con éxito."
    echo "Presiona Enter para continuar" && read enter
}
entrar_v2ray_original() {
    
    systemctl start v2ray

    
    v2ray

    print_message "${CYAN}" "Has entrado al menú nativo de V2Ray."
}
archivo="/etc/v2ray/v2clientes.txt"


cp "$archivo" "$archivo.bak"

cambiar_formatos_y_eliminar_dias() {
    while IFS=' | ' read -r id nombre dias fecha; do
        
        if [[ $fecha =~ ^[0-9]{2}-[0-9]{2}-[0-9]{2}$ ]]; then
            
            dia=${fecha:0:2}
            mes=${fecha:3:2}
            ano="20${fecha:6:2}"
            fecha_nueva="$ano-$mes-$dia"
            
            
            sed -i "s/$id | $nombre | $dias | $fecha/$id | $nombre | $fecha_nueva/" "$archivo"
        fi
    done < "$archivo"
}
restart_v2ray() {
    systemctl restart v2ray
}
cambiar_path() {
    clear
    printf "\e[1;35mEntrando en la función cambiar_path...\e[0m\n"

    while true; do
        printf "\e[1;33mSELECCIONA UNA OPCIÓN:\e[0m\n"
        printf "\e[36m1. \e[32mCAMBIAR EL NUEVO PATH\e[0m\n"
        printf "\e[36m2. \e[31mVOLVER AL MENÚ PRINCIPAL\e[0m\n"
        printf "\e[36mOPCIÓN: \e[0m"
        read opcion

        case $opcion in
            1)
                printf "\e[1;32mSELECCIONASTE CAMBIAR EL PATH...\e[0m\n"
                printf "\e[36mINTRODUCE EL NUEVO PATH: \e[0m"
                read nuevo_path
                printf "\e[1;32mMODIFICANDO EL PATH A $nuevo_path EN EL ARCHIVO DE CONFIGURACIÓN...\e[0m\n"

                if ! command -v jq &> /dev/null; then
                    printf "\e[91mERROR: 'jq' NO ESTÁ INSTALADO. INSTÁLALO PARA CONTINUAR.\e[0m\n"
                    return
                fi

                if [ ! -f "$CONFIG_FILE" ]; then
                    printf "\e[91mERROR: EL ARCHIVO DE CONFIGURACIÓN '$CONFIG_FILE' NO EXISTE.\e[0m\n"
                    return
                fi

                jq --arg nuevo_path "$nuevo_path" '.inbounds[0].streamSettings.wsSettings.path = $nuevo_path' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

                if [ $? -eq 0 ]; then
                    printf "\e[33mEL PATH HA SIDO CAMBIADO A $nuevo_path.\e[0m\n"
                    systemctl restart v2ray
                    printf "\e[36mPRESIONA ENTER PARA REGRESAR AL MENÚ PRINCIPAL\e[0m"
                    read enterKey
                    return
                else
                    printf "\e[91mERROR AL MODIFICAR EL ARCHIVO DE CONFIGURACIÓN CON jq.\e[0m\n"
                    printf "\e[36mPRESIONA ENTER PARA REGRESAR AL MENÚ PRINCIPAL\e[0m"
                    read enterKey
                    return
                fi
                ;;
            2)
                printf "\e[1;31mSELECCIONASTE VOLVER AL MENÚ PRINCIPAL...\e[0m\n"
                return
                ;;
            *)
                printf "\e[91mOPCIÓN INVÁLIDA. POR FAVOR, SELECCIONA UNA OPCIÓN VÁLIDA.\e[0m\n"
                ;;
        esac
    done
}
configurar_temporizador() {
    while true; do
        clear
        print_separator
        echo -e "${CYAN}Selecciona el intervalo de tiempo:${NC}"
        echo -e "1. ${GREEN}5 minutos${NC}"
        echo -e "2. ${GREEN}30 minutos${NC}"
        echo -e "3. ${GREEN}1 hora${NC}"
        echo -e "4. ${RED}Desactivar temporizador${NC}"
        echo -e "5. ${YELLOW}Salir${NC}"
        print_separator

        read -p "Selecciona una opción (1-5): " opcion

        case $opcion in
            1)
                configurar_temporizador_con_intervalo "5:00"
                ;;
            2)
                configurar_temporizador_con_intervalo "30:00"
                ;;
            3)
                configurar_temporizador_con_intervalo "59:00"
                ;;
            4)
                desactivar_temporizador
                ;;
            5)
                echo "Volviendo al menú principal..."
                return  
                ;;
            "")
                echo "Volviendo al menú principal..."
                return  
                ;;
            *)
                echo -e "${RED}Opción no válida. Por favor, selecciona una opción válida.${NC}"
                ;;
        esac

        read -p "Presiona Enter para continuar..."
    done
}


eliminar_expirados() {
    python3 <<EOF
import json
import time

def eliminar_usuarios_expirados(config_path, usuarios_path):
    # Definir función para imprimir un separador
    def print_separator():
        print("\033[1;34m============================================================\033[0m")

    # Cargar la configuración de V2Ray
    with open(config_path, 'r') as config_file:
        config = json.load(config_file)

    # Cargar la lista de usuarios desde v2clientes.txt
    with open(usuarios_path, 'r') as usuarios_file:
        usuarios = [line.strip().split(' | ') for line in usuarios_file]

    # Obtener la fecha actual en formato de época
    current_date = int(time.time())

    usuarios_eliminados = []

    # Iterar sobre la lista de usuarios y eliminar los expirados
    usuarios_actualizados = []
    for usuario in usuarios:
        uuid, username, expiration_date = usuario
        expiration_epoch = int(time.mktime(time.strptime(expiration_date, '%Y-%m-%d')))

        if expiration_epoch > current_date:
            # Si el usuario no ha expirado, agregarlo a la lista actualizada
            usuarios_actualizados.append(usuario)
        else:
            # Imprimir información de depuración
            print_separator()
            print(f"\033[1;31mEliminando usuario expirado:\033[0m\n  \033[1;34mUUID:\033[0m {uuid}\n  \033[1;34mUsuario:\033[0m {username}\n  \033[1;34mFecha de expiración:\033[0m {expiration_date}")

            # Agregar el usuario eliminado a la lista
            usuarios_eliminados.append(username)

            # Eliminar el usuario del archivo config.json
            config['inbounds'][0]['settings']['clients'] = [client for client in config['inbounds'][0]['settings']['clients'] if client['id'] != uuid]

    # Guardar la configuración modificada en config.json
    with open(config_path, 'w') as config_file:
        json.dump(config, config_file, indent=2)

    # Guardar la lista de usuarios actualizada en v2clientes.txt
    with open(usuarios_path, 'w') as usuarios_file:
        for usuario in usuarios_actualizados:
            usuarios_file.write(' | '.join(usuario) + '\n')

    if usuarios_eliminados:
        print(f"\033[1;32mUsuarios expirados eliminados:\033[0m {', '.join(usuarios_eliminados)}")
    else:
        print("\033[1;33mNo se encontraron usuarios expirados para eliminar.\033[0m")

if __name__ == "__main__":
    config_path = "/etc/v2ray/config.json"
    usuarios_path = "/etc/v2ray/v2clientes.txt"
    eliminar_usuarios_expirados(config_path, usuarios_path)
EOF

    # Definir la función print_separator
    print_separator() {
        echo -e "\e[1;34m============================================================\e[0m"
    }

    # Esperar a que el usuario presione Enter para continuar
    read -p $'\e[1;36mPresiona Enter para continuar...\e[0m'
}


print_separator() {
    echo -e "\e[1;34m============================================================\e[0m"
}

addres_ip() {
    config="/etc/v2ray/config.json"
    temp="/tmp/temp_v2ray_config.json"

    add=$(jq -r '.inbounds[] | select(.domain != null) | .domain' "$config")
    _add=""

    print_separator
    echo -e "\e[1;33mCONFIGURACIÓN DE ADDRES V2RAY\e[0m"
    print_separator

    while [[ -z $_add || $_add == '' ]]; do
        echo -e "\e[1;34mNueva ADDRES\e[0m"
        read -p "Ingrese la nuevo addres (presione Enter para cancelar): " _add
        if [[ -z "$_add" ]]; then
            echo -e "\e[1;31mCancelado.\e[0m"
            return
        elif [[ "$_add" != *.* ]]; then
            echo -e "\e[1;31mFormato no válido.\e[0m"
            unset _add
        fi
    done

    mv "$config" "$temp"
    jq --arg a "$_add" '.inbounds[] += {"domain":$a}' < "$temp" >> "$config"
    chmod 777 "$config"
    rm "$temp"
     print_separator
    echo -e "\e[1;33mSu addres ha sido cambiada a: \e[1;32m$_add\e[0m"
    print_separator
    systemctl restart v2ray

    read -p "Presione Enter para volver atrás..."
}





cache_ram() {
    clear
echo -e "${GREEN}REFRESCANDO CACHE Y RAM ${NC}"
  (
    VE="\033[1;33m" && MA="\033[1;31m" && DE="\033[1;32m"

    while [[ ! -e /tmp/abc ]]; do
      A+="#"
      echo -e "${VE}[${MA}${A}${VE}]" >&2
      sleep 0.3s
      tput cuu1 && tput dl1
    done

    echo -e "${VE}[${MA}${A}${VE}] - ${DE}[100%]" >&2
    rm /tmp/abc
    ) &
  sudo echo 3 > /proc/sys/vm/drop_caches &>/dev/null
  sleep 1s
  sysctl -w vm.drop_caches=3 &>/dev/null
  apt-get autoclean -y &>/dev/null
  sleep 1s
  apt-get clean -y &>/dev/null
  rm /tmp/* &>/dev/null
  touch /tmp/abc
  sleep 0.5s
  echo -e "${DE}CACHE/RAM LIMPIADA CON ÉXITO!"

  if [[ ! -z $(crontab -l|grep -w "vm.drop_caches=3") ]]; then
    while :
    do
    echo -ne "${VE} QUITAR TAREA PROGRAMADA [S/N]: " && read t_ram
    tput cuu1 && tput dl1
    case $t_ram in
      s|S) crontab -l > /root/cron && sed -i '/vm.drop_caches=3/ d' /root/cron && crontab /root/cron && rm /root/cron
           echo -e "${VE} TAREA AUTOMÁTICA REMOVIDA!" && sleep 2
           return 1;;
      n|N)return 1;;
      *)echo -e "${VE} Selecciona S para si, N para no" && sleep 2 && tput cuu1 && tput dl1;;
    esac
    done
  fi 

  echo -ne "${VE}DESEA PROGRAMAR UNA TAREA AUTOMÁTICA [S/N]: "
  read c_ram
  if [[ $c_ram = @(s|S|y|Y) ]]; then
    tput cuu1 && tput dl1
    echo -ne "${VE} PERIODO DE EJECUCIÓN DE LA TAREA [1-12HS]: "
    read ram_c
    if [[ $ram_c =~ $numero ]]; then
      crontab -l > /root/cron
      echo "0 */$ram_c * * * sudo sysctl -w vm.drop_caches=3 > /dev/null 2>&1" >> /root/cron
      echo "0 */$ram_c * * * systemctl restart v2ray > /dev/null 2>&1" >> /root/cron
      crontab /root/cron
      rm /root/cron
      tput cuu1 && tput dl1
      echo -e "${VE} TAREA AUTOMÁTICA PROGRAMADA CADA: ${DE}${ram_c}HS" && sleep 2
    else
      tput cuu1 && tput dl1
      echo -e "${MA} INGRESE SOLO NÚMEROS ENTRE 1 Y 12"
      sleep 2
    fi
  fi
  return 1
}







protocolv2ray () {
    echo -e "\e[1mESCOGER OPCIÓN 3 Y PONER EL DOMINIO DE NUESTRA IP:\e[0m"
    print_separator
    v2ray stream
    print_separator
    echo -e "\e[1mENTER PARA CONTINUAR\e[0m" && read enter
    ${SCPinst}/v2ray.sh
}
tls () {
    echo -e "\e[1mACTIVAR O DESACTIVAR TLS:\e[0m"
    print_separator
    v2ray tls
    print_separator
    echo -e "\e[1mENTER PARA CONTINUAR\e[0m" && read enter
    ${SCPinst}/v2ray.sh
}
portv () {
    echo -e "\e[1mCAMBIAR PUERTO V2RAY:\e[0m"
    print_separator
    v2ray port
    print_separator
    echo -e "\e[1mENTER PARA CONTINUAR\e[0m" && read enter
    ${SCPinst}/v2ray.sh
}
stats () {
    echo -e "\e[1mESTADÍSTICAS DE CONSUMO:\e[0m"
    v2ray stats
    echo -e "\e[1mENTER PARA CONTINUAR\e[0m" && read enter
    ${SCPinst}/v2ray.sh
}


show_speedtest_menu() {
    clear
    echo -e "\e[1;32m===== SpeedTest Menu =====\e[0m"
    echo -e "1. \e[34mEJECUTAR SPEEDTEST \e[0m"
    echo -e "2. \e[31mSALIR AL MENÚ PRINCIPAL \e[0m"
    echo -e "\e[1;32m==========================\e[0m"
}
run_speedtest_menu() {
    while true; do
        show_speedtest_menu
        read -p "Ingrese su elección: " choice_speedtest
        case $choice_speedtest in
            1)
                echo -e "\e[1;33mEJECUTANDO SPEEDTEST \e[0m"
                speedtest-cli --share
                ;;
            2)
                echo "VOLVIENDO AL MENÚ PRINCIPAL."
                break
                ;;
            *)
                echo "OPCIÓN INVÁLIDA. POR FAVOR, SELECCIONE UNA OPCIÓN VÁLIDA."
                ;;
        esac
    done
}

while true; do
    show_menu
    read -p "Seleccione una opción: " opcion

    case $opcion in
        1)
            add_user
            ;;
        2)
            delete_user
            ;;
        3)
            edit_user_uuid
            ;;
        4)
            show_registered_users
            
            ;;
        5)
            show_vmess_by_id
            ;;
        6)
            eliminar_expirados
            ;;
        7)
            conexion
            ;;
        8)
            show_backup_menu
            ;;
        9)
            entrar_v2ray_original
            ;;
        10)
            while true; do
    clear
    echo -e "${CYAN}===== CONFIGURAR V2RAY =====${NC}"
    print_separator
    echo -e "[1] ${GREEN}INSTALAR V2RAY ${NC}"
    echo -e "[2] ${RED}DESINSTALAR V2RAY ${NC}"

    optimize_status="[${RED}off${NC}]"
    if crontab -l | grep -q "vm.drop_caches=3"; then
        optimize_status="[${GREEN}on${NC}]"
    fi

    echo -e "[3] ${YELLOW} OPTIMIZAR VPS AUT. ${optimize_status} ${NC}"
    echo -e "[4] ${GREEN}CAMBIAR EL PATH DE V2RAY ${NC}"
    echo -e "[5] ${GREEN}CAMBIAR PROTOCOLO ${NC}"
    echo -e "[6] ${GREEN}ACTIVAR TLS ${NC}"
    echo -e "[7] ${GREEN}CAMBIAR PUERTO ${NC}"
    echo -e "[8] ${GREEN}CAMBIAR IP ${NC}"
    echo -e "[9] ${GREEN}VER DATOS CONSUMIDOS ${NC}"
    echo -e "[10] ${GREEN}SPEEDTEST ${NC}"
    echo -e "[11] ${YELLOW}VOLVER AL MENÚ PRINCIPAL ${NC}"
print_separator
    read -r main_option

                case $main_option in
                    1) 
read -p "¿Desea instalar V2Ray? (s/n, Enter para cancelar): " answer
if [ "$answer" = "s" ]; then
    install_v2ray
elif [ "$answer" = "n" ]; then
    echo "La instalación de V2Ray ha sido cancelada."
else
    echo "Volviendo atrás"
fi
                        ;;
                    2) 
                        echo -e "\033[33m¿Estás seguro de que deseas desinstalar V2Ray? (y/n)\033[0m"
read -n 1 -r confirmacion
if [ "$confirmacion" = "y" ] || [ "$confirmacion" = "Y" ]; then
    echo -e "\nDesinstalando V2Ray..."
    sudo systemctl stop v2ray
    sudo systemctl disable v2ray
    sudo rm -f /etc/systemd/system/v2ray.service
    sudo rm -rf /usr/bin/v2ray /etc/v2ray
    echo -e "\033[32mV2Ray se ha desinstalado correctamente.\033[0m"
    echo -e "Presiona Enter para salir..."
    read -s -n 1
else
    echo -e "\nOperación de desinstalación cancelada. Volviendo al menú principal..."
    echo -e "Presiona Enter para salir..."
    read -s -n 1
fi
                        ;;
                    3) 
                        cache_ram
                        ;;
                    4)
                        cambiar_path
                        ;;
                    5)
                        protocolv2ray
                        ;;
                    6)
                        tls
                        ;;
                    7)
                        portv
                        ;;
                    8)
                        addres_ip
                        ;;
                    9)
    stats
    ;;
    10)
    while true; do
        show_speedtest_menu
        read -p "Ingrese su elección: " choice
        case $choice in
            1)
                echo -e "\e[1;33mEJECUTANDO SPEEDTEST\e[0m"
                echo "ESPERE MIENTRAS SE CARGAN LOS RESULTADOS:"
                speedtest-cli --simple --share > speedtest_results.txt 2>/dev/null &
                speedtest_pid=$!

                echo -ne '\033[0;34mCargando [\033[0m'
                while ps -p $speedtest_pid > /dev/null; do
                    echo -ne '\033[0;32m#\033[0m'
                    sleep 0.8
                done
                echo -e '\033[0;34m] completo\033[0m'

                speedtest_results=$(cat speedtest_results.txt)

                echo ""
                print_separator
                echo -e "\e[1;32m$speedtest_results\e[0m" 
                print_separator

                rm speedtest_results.txt

                echo -e "\n\e[1;33mPRESIONE ENTER PARA VOLVER AL MENÚ PRINCIPAL...\e[0m"
                read -s -r
                ;;
            2)
                echo "Volviendo al menú principal."
                break
                ;;
            *)
                echo -e "${RED}Opción no válida${NC}"
                ;;
        esac
    done
    ;;
11)
                        echo "Volviendo al menú principal."
                        break  
                        ;;
                    *)
                        echo -e "${RED}Opción no válida${NC}"
                        ;;
                esac
            done 
                ;;
            11)
                echo "Saliendo..."
                exit 0  
                ;;
            *)
                echo -e "${RED}Opción no válida${NC}"
                ;;
        esac
    done
