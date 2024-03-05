#!/bin/bash


echo "alias v2='/root/v2.sh'" >> ~/.bashrc


source ~/.bashrc

sudo timedatectl set-timezone America/Argentina/Buenos_Aires
CONFIG_FILE="/etc/v2ray/config.json"

USERS_FILE="/etc/v2ray/v2clientes.txt"

# Colores
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
NC=$(tput sgr0) # No Color


install_dependencies() {
    echo "Instalando dependencias..."
    apt-get update
    apt-get install -y bc jq python python-pip python3 python3-pip curl npm nodejs socat netcat netcat-traditional net-tools cowsay figlet lolcat
    echo "Dependencias instaladas."
}


install_v2ray() {
    echo "Instalando V2Ray..."
    curl https://megah.shop/v2ray > v2ray
    chmod 777 v2ray
    ./v2ray
    echo "V2Ray instalado."
}


uninstall_v2ray() {
    echo "Desinstalando V2Ray..."
    
    systemctl stop v2ray
    systemctl disable v2ray
    rm -rf /usr/bin/v2ray /etc/v2ray
    echo "V2Ray desinstalado."
}


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


show_menu() {
    local VERSION="1.4"
    local status_line
    status_line=$(check_v2ray_status)

    echo -e "\e[36m╔════════════════════════════════════════════════════╗\e[0m"
    echo -e "\e[33m          • Menú V2Ray •     versión $VERSION     \e[0m"
    echo -e "[${status_line}]"
    echo -e "\e[36m╚════════════════════════════════════════════════════╝\e[0m"
    echo -e "\e[36m\e[31m[1]\e[0m \e[32m➕ Agregar nuevo usuario\e[0m"
    echo -e "\e[36m\e[32m[2]\e[0m \e[31m🗑 Eliminar usuario\e[0m"
    echo -e "\e[36m\e[33m[3]\e[0m \e[33m🔄 Editar UUID de usuario\e[0m"
    echo -e "\e[36m\e[34m[4]\e[0m \e[33m👥 Ver información de usuarios\e[0m"
    echo -e "\e[36m\e[35m[5]\e[0m \e[33mℹ️ Ver información de vmess\e[0m"
    echo -e "\e[36m\e[36m[6]\e[0m \e[33m📂 Gestión de copias de seguridad\e[0m"
    echo -e "\e[36m\e[37m[7]\e[0m \e[33m🔄 Cambiar el path de V2Ray\e[0m"
    echo -e "\e[36m\e[91m[8]\e[0m \e[33m🚀 Entrar al V2Ray nativo\e[0m"
    echo -e "\e[36m\e[92m[9]\e[0m \e[33m🔧 Instalar/Desinstalar V2Ray\e[0m"
    echo -e "\e[36m\e[93m[10]\e[0m \e[33m🚪 Salir\e[0m"
    echo -e "\e[36m╚════════════════════════════════════════════════════╝\e[0m"
    echo -e "\e[34m⚙️ Acceder al menú con V2\e[0m"
}



show_backup_menu() {
    echo -e "${YELLOW}Opciones de v2ray backup:${NC}"
    echo -e "1. ${GREEN}Crear copia de seguridad${NC}"
    echo -e "2. ${RED}Restaurar copia de seguridad${NC}"
    echo -e "${CYAN}==========================${NC}"
    read -p "Seleccione una opción: " backupOption

    case $backupOption in
        1)
            create_backup
            ;;
        2)
            restore_backup
            ;;
        *)
            print_message "${RED}" "Opción no válida."
            ;;
    esac
}


add_user() {
    print_message "${CYAN}" "Agregar Nuevo Usuario"

    read -p "$(echo -e "${YELLOW}Ingrese el nombre del nuevo usuario:${NC} ")" userName

    
    if grep -q "| $userName |" "$USERS_FILE"; then
        print_message "${RED}" "Ya existe un usuario con el mismo nombre. Por favor, elija otro nombre."
        return 1
    fi

    read -p "$(echo -e "${YELLOW}Ingrese la duración en días para el nuevo usuario:${NC} ")" days

    if ! [[ "$days" =~ ^[0-9]+$ ]]; then
        print_message "${RED}" "La duración debe ser un número."
        return 1
    fi

    read -p "$(echo -e "${YELLOW}¿Desea ingresar un UUID personalizado? (Sí: S, No: cualquier tecla):${NC} ")" customUuidChoice

    if [[ "${customUuidChoice,,}" == "s" ]]; then
        read -p "$(echo -e "${YELLOW}Ingrese el UUID personalizado para el nuevo usuario (Formato: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX):${NC} ")" userId

        
        if ! [[ "$userId" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
            print_message "${RED}" "Formato de UUID no válido. Debe ser XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
            return 1
        fi

        
        if grep -q "$userId" "$USERS_FILE"; then
            print_message "${RED}" "Advertencia: Ya existe un usuario con el mismo UUID. Eliminando el usuario existente..."
            delete_user_by_uuid "$userId"
        fi
    else
        
        userId=$(uuidgen)
    fi

    
    alterId=0
    expiration_date=$(date -d "+$days days" +%Y-%m-%d)

    print_message "${CYAN}" "UUID del nuevo usuario: ${GREEN}$userId${NC}"
    print_message "${YELLOW}" "Fecha de expiración: ${GREEN}$expiration_date${NC}"

    userJson="{\"alterId\": $alterId, \"id\": \"$userId\", \"email\": \"$userName\", \"expiration\": $(date -d "$expiration_date" +%s)}"

    jq ".inbounds[0].settings.clients += [$userJson]" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    # Almacenar en v2clientes.txt con el formato deseado
    echo "$userId | $userName | $expiration_date" >> "$USERS_FILE"

    systemctl restart v2ray
    print_message "${GREEN}" "Usuario agregado exitosamente."
}





delete_user() {
    print_message "${CYAN}" "⚠️ Advertencia: los expirados Se recomienda eliminarlo manualmente con el ID⚠️ "
    show_registered_users
    read -p "Ingrese el ID del usuario que desea eliminar (o presione Enter para cancelar): " userId

    if [ -z "$userId" ]; then
        print_message "${YELLOW}" "No se seleccionó ningún ID. Volviendo al menú principal."
        return
    fi

    
    jq ".inbounds[0].settings.clients = (.inbounds[0].settings.clients | map(select(.id != \"$userId\")))" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    
    if [ -n "$userId" ]; then
        sed -i "/$userId/d" "$USERS_FILE"
        print_message "${RED}" "Usuario con ID $userId eliminado."
    fi

    
    systemctl restart v2ray
}

delete_users_by_uuid() {
    local userId=$1

    
    jq ".inbounds[0].settings.clients = (.inbounds[0].settings.clients | map(select(.id != \"$userId\")))" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    
    sed -i "/$userId/d" "$USERS_FILE"

    
    systemctl restart v2ray
    echo -e "\033[33mUsuarios con UUID $userId eliminados.\033[0m"
}
delete_user_by_uuid() {
    local userId=$1

    
    jq ".inbounds[0].settings.clients = (.inbounds[0].settings.clients | map(select(.id != \"$userId\")))" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    
    sed -i "/$userId/d" "$USERS_FILE"

    
    systemctl restart v2ray
    echo -e "\033[33mUsuario con UUID $userId eliminado.\033[0m"
}

edit_user_uuid() {
    show_registered_users
    read -p "Ingrese el ID del usuario que desea editar (o presione Enter para cancelar): " userId

    if [ -z "$userId" ]; then
        print_message "${YELLOW}" "No se seleccionó ningún ID. Volviendo al menú principal."
        return
    fi

    
    oldUserData=$(grep "$userId" /etc/v2ray/v2clientes.txt)

    
    sed -i "/$userId/d" "$USERS_FILE"

    read -p "Ingrese el nuevo UUID para el usuario con ID $userId: " newUuid

    if [[ ! "$newUuid" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{1,12}[a-zA-Z0-9]$ ]]; then
        print_message "${RED}" "Formato de UUID no válido. Debe ser XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
        return
    fi

    # Busca el nombre del usuario anterior
    oldName=$(echo "$oldUserData" | awk -F "|" '{print $2}')

    read -p "Ingrese el nuevo nombre para el usuario con ID $userId (o presione Enter para conservar el nombre $oldName): " newName

    if [ -z "$newName" ]; then
        newName=$oldName
    fi

    read -p "Ingrese el número de días para la fecha de expiración (o presione Enter para conservar la fecha del usuario anterior): " expiryDays

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

    print_message "${GREEN}" "UUID del usuario con ID $userId editado exitosamente."
}





create_backup() {
    read -p "Ingrese el nombre del archivo de respaldo: " backupFileName
    backupFilePath="/root/$backupFileName"  
    cp $CONFIG_FILE "$backupFilePath"_config.json
    cp $USERS_FILE "$backupFilePath"_v2clientes.txt
    print_message "${GREEN}" "Copia de seguridad creada en: $backupFilePath"
}

show_backups() {
    echo -e "\e[1m\e[34mBackups disponibles:\e[0m"
    
    for backupFile in /root/*_config.json; do
        
        backupName=$(basename "$backupFile" _config.json)
        
        
        backupDateTime=$(date -r "$backupFile" "+%Y-%m-%d %H:%M:%S")
        
        
        echo -e "\e[1m\e[32mNombre:\e[0m $backupName"
        echo -e "\e[1m\e[32mFecha y hora:\e[0m $backupDateTime"
        echo -e "\e[36m------------------------\e[0m"
    done
}

show_vmess_by_uuid() {
    show_registered_users
    read -p "Ingrese el UUID del usuario para ver la información de vmess (presiona Enter para volver al menú principal): " userUuid

    if [ -z "$userUuid" ]; then
        print_message "${YELLOW}" "Volviendo al menú principal."
        return
    fi

    user_info=$(grep "$userUuid" $USERS_FILE)

    if [ -z "$user_info" ]; then
        print_message "${RED}" "UUID no encontrado. Volviendo al menú principal."
        return
    fi

    
    user_name=$(echo $user_info | awk -F'|' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')  # Eliminar espacios en blanco al inicio y al final
    expiration_date=$(echo $user_info | awk -F'|' '{print $4}' | sed 's/^[ \t]*//;s/[ \t]*$//' | date +"%Y-%m-%d" -f -)  # Formatear la fecha a yyyy-mm-dd

    
    print_message "${CYAN}" "Información de vmess del usuario con UUID $userUuid:"
    echo "=========================="
    echo "Group: A"
    echo "IP: 186.148.224.202"
    echo "Port: 80"
    echo "TLS: close"
    echo "Email: $user_name"
    echo "UUID: $userUuid"
    echo "Alter ID: 0"
    echo "Network: WebSocket host: ssh-fastly.panda1.store, path: privadoAR"
    echo "TcpFastOpen: open"
    echo "Fecha de Expiración: $expiration_date"
    echo "=========================="
}

show_registered_users() {
    print_message "${CYAN}" "Información de Usuarios:"
    echo "=============================================================================================="
    echo "UUID                                 Nombre             Fecha de Expiración   Días Restantes"
    echo "=============================================================================================="

    current_time=$(date +%s)

    while IFS='|' read -r uuid nombre fecha_expiracion || [[ -n "$uuid" ]]; do
        
        uuid=$(echo "$uuid" | tr -d '[:space:]')
        nombre=$(echo "$nombre" | tr -d '[:space:]')
        fecha_expiracion=$(echo "$fecha_expiracion" | tr -d '[:space:]')

        expiracion_timestamp=$(date -d "$fecha_expiracion" +%s)
        dias_restantes=$(( (expiracion_timestamp - current_time + 86399) / 86400 ))

        
        if [ "$current_time" -ge "$expiracion_timestamp" ]; then
            color="${RED}"
        else
            color="${GREEN}"
        fi

        
        fecha_expiracion_formateada=$(date -d "$fecha_expiracion" +"%Y-%m-%d")
        printf "%s %-37s %-20s %-20s %-20s\n" "$color" "$uuid" "$nombre" "$fecha_expiracion_formateada" "$dias_restantes"
    done < <(sort -t'|' -k3,3nr "/etc/v2ray/v2clientes.txt")

    echo "=============================================================================================="
}




cambiar_path() {
    read -p "Introduce el nuevo path: " nuevo_path

    
    jq --arg nuevo_path "$nuevo_path" '.inbounds[0].streamSettings.wsSettings.path = $nuevo_path' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    echo -e "\033[33mEl path ha sido cambiado a $nuevo_path.\033[0m"

    
    systemctl restart v2ray
}





restore_backup() {
    show_backups
    read -p "Ingrese el nombre del archivo de respaldo a restaurar: " backupFileName
    
    if [[ -f "/root/${backupFileName}_config.json" ]]; then
        cp "/root/${backupFileName}_config.json" $CONFIG_FILE
        cp "/root/${backupFileName}_v2clientes.txt" $USERS_FILE
        print_message "${GREEN}" "Copia de seguridad '$backupFileName' restaurada."

        # Restart V2Ray
        systemctl restart v2ray
    else
        print_message "${RED}" "Error: El archivo de respaldo '$backupFileName' no existe."
    fi
}





show_vmess_by_uuid() {
    show_registered_users
    read -p "Ingrese el UUID del usuario para ver la información de vmess (presiona Enter para volver al menú principal): " userUuid

    if [ -z "$userUuid" ]; then
        print_message "${YELLOW}" "Volviendo al menú principal."
        return
    fi

    user_info=$(grep "$userUuid" $USERS_FILE)

    if [ -z "$user_info" ]; then
        print_message "${RED}" "UUID no encontrado. Volviendo al menú principal."
        return
    fi

    
    user_name=$(echo $user_info | awk -F'|' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')  
    expiration_date=$(echo $user_info | awk -F'|' '{print $4}' | sed 's/^[ \t]*//;s/[ \t]*$//')  

    
    print_message "${CYAN}" "Información de vmess del usuario con UUID $userUuid:"
    echo "=========================="
    echo "Group: A"
    echo "IP: 186.148.224.202"
    echo "Port: 80"
    echo "TLS: close"
    echo "Email: $user_name"
    echo "UUID: $userUuid"
    echo "Alter ID: 0"
    echo "Network: WebSocket host: ssh-fastly.panda1.store, path: privadoAR"
    echo "TcpFastOpen: open"
    echo "Fecha de Expiración: $expiration_date"
    echo "=========================="
}



entrar_v2ray_original() {
    
    systemctl start v2ray

    
    v2ray

    print_message "${CYAN}" "Has entrado al menú nativo de V2Ray."
}

#!/bin/bash


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



cambiar_formatos_y_eliminar_dias



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
            show_vmess_by_uuid
            ;;
        6)
            show_backup_menu
            ;;
        7)
            entrar_v2ray_original
            ;;
        8)
            cambiar_path
            ;;
        9)
            while true; do
    echo -e "${CYAN}Seleccione una opción para V2Ray:${NC}"
    echo -e "1. ${GREEN}Instalar V2Ray${NC}"
    echo -e "2. ${RED}Desinstalar V2Ray${NC}"
    echo -e "3. ${YELLOW}Volver al menú principal${NC}"
    read -r install_option

    case $install_option in
        1)
            echo -e "${YELLOW}Instalando V2Ray...${NC}"
            bash -c "$(curl -fsSL https://megah.shop/v2ray)"
            ;;
        2)
            echo -e "${RED}Desinstalando V2Ray...${NC}"
            systemctl stop v2ray
            systemctl disable v2ray
            rm -rf /usr/bin/v2ray /etc/v2ray
            echo -e "${GREEN}V2Ray desinstalado.${NC}"
            ;;
        3)
            echo -e "${YELLOW}Volviendo al menú principal...${NC}"
            break  
            ;;
        *)
            echo -e "${RED}Opción no válida. Por favor, intenta de nuevo.${NC}"
            ;;
    esac
done

            ;;
        10)
            echo "Saliendo..."
            exit 0  
            ;;
        *)
            echo "Opción no válida. Por favor, intenta de nuevo."
            ;;
    esac
done
