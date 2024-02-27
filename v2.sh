#!/bin/bash

# Agrega el alias al archivo .bashrc
echo "alias v2='/root/v2.sh'" >> ~/.bashrc


source ~/.bashrc


CONFIG_FILE="/etc/v2ray/config.json"
USERS_FILE="/etc/v2ray/v2clientes.txt"

# Colores
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
NC=$(tput sgr0) 
VERSION="1.1"

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
    local status_line
    local VERSION="1.1"

    status_line=$(check_v2ray_status)

    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}          • V2Ray MENU •       version $VERSION     ${NC}"
    echo -e "[${status_line}]"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo -e "1. ${GREEN}➕ Agregar nuevo usuario${NC}"
    echo -e "2. ${RED}🗑 Eliminar usuario${NC}"
    echo -e "3. ${YELLOW}👥 Ver información de usuarios${NC}"
    echo -e "4. ${YELLOW}ℹ️ Ver información de vmess${NC}"
    echo -e "5. ${YELLOW}📂 Gestión de copias de seguridad${NC}"
    echo -e "6. ${YELLOW}🔄 Cambiar el path de V2Ray${NC}"
    echo -e "7. ${YELLOW}🚀 Entrar al V2Ray nativo${NC}"
    echo -e "8. ${YELLOW}🔧 Instalar/Desinstalar V2Ray${NC}"
    echo -e "9. ${YELLOW}🚪 Salir${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo -e "${BLUE}⚙️ Acceder al menú con V2${NC}"  
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
    read -p "Ingrese el nombre del nuevo usuario: " userName
    read -p "Ingrese la duración en días para el nuevo usuario: " days

    
    if ! [[ "$days" =~ ^[0-9]+$ ]]; then
        echo -e "\033[31mLa duración debe ser un número.\033[0m"
        return 1
    fi

    
    echo -e "\033[36mFormato aceptado para el UUID personalizado: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX\033[0m"
    
    read -p "¿Desea ingresar un UUID personalizado? (Sí: S, No: cualquier tecla): " customUUIDOption

    if [ "$customUUIDOption" == "S" ] || [ "$customUUIDOption" == "s" ]; then
        read -p "Ingrese el UUID personalizado: " customUUID

        
        if [[ ! $customUUID =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
            echo -e "\033[31mEl UUID personalizado no tiene el formato correcto.\033[0m"
            return 1
        else
            userId=$customUUID
        fi
    else
        userId=$(uuidgen)  
    fi

    alterId=0  
    expiration_date=$(date -d "+$days days" +%s)  

    
    echo -e "\033[36mUUID del nuevo usuario: \033[32m$userId\033[0m"
    echo -e "\033[33mFecha de expiración: \033[32m$(date -d "@$expiration_date" +"%d-%m-%y")\033[0m"

    
    if grep -q "$userId" "$USERS_FILE"; then
        echo -e "\033[31mYa existe un usuario con el mismo UUID. Eliminando el usuario existente...\033[0m"
        delete_user_by_uuid "$userId"
    fi

    
    userJson="{\"alterId\": $alterId, \"id\": \"$userId\", \"email\": \"$userName\", \"expiration\": $expiration_date}"

    
    jq ".inbounds[0].settings.clients += [$userJson]" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    
    echo "$userId | $userName | $days | $(date -d "@$expiration_date" +"%d-%m-%y")" >> "$USERS_FILE"

    
    systemctl restart v2ray
    echo -e "\033[32mUsuario agregado exitosamente.\033[0m"
}


delete_user_by_uuid() {
    local userId=$1

    
    jq ".inbounds[0].settings.clients = (.inbounds[0].settings.clients | map(select(.id != \"$userId\")))" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    
    sed -i "/$userId/d" "$USERS_FILE"

    
    systemctl restart v2ray
    echo -e "\033[33mUsuario con UUID $userId eliminado.\033[0m"
}


delete_users_by_uuid() {
    local userId=$1

    
    jq ".inbounds[0].settings.clients = (.inbounds[0].settings.clients | map(select(.id != \"$userId\")))" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    
    sed -i "/$userId/d" "$USERS_FILE"

    
    systemctl restart v2ray
    echo -e "\033[33mUsuarios con UUID $userId eliminados.\033[0m"
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
create_backup() {
    read -p "Ingrese el nombre del archivo de respaldo: " backupFileName
    cp $CONFIG_FILE "$backupFileName"_config.json
    cp $USERS_FILE "$backupFileName"_v2clientes.txt
    print_message "${GREEN}" "Copia de seguridad creada."
}

 

restore_backup() {
    read -p "Ingrese el nombre del archivo de respaldo: " backupFileName

    
    if [ ! -e "${backupFileName}_config.json" ] || [ ! -e "${backupFileName}_v2clientes.txt" ]; then
        print_message "${RED}" "Error: El archivo de respaldo no existe."
        return 1
    fi

    
    cp "${backupFileName}_config.json" "$CONFIG_FILE"
    cp "${backupFileName}_v2clientes.txt" "$USERS_FILE"

    
    if [ $? -eq 0 ]; then
        print_message "${GREEN}" "Copia de seguridad restaurada correctamente."
        
        
        systemctl restart v2ray  
        

        print_message "${GREEN}" "Servicio V2Ray reiniciado."
    else
        print_message "${RED}" "Error al restaurar la copia de seguridad."
    fi
}


show_registered_users() {
    print_message "${CYAN}" "Información de Usuarios:"
    echo "================================================================================================="
    echo "UUID                                 Nombre                                Días   Fecha de Expiración"
    echo "================================================================================================="

    while IFS='|' read -r uuid nombre dias fecha_expiracion || [[ -n "$uuid" ]]; do
        if [ "$dias" -ge 0 ]; then
            color="${GREEN}"  
        else
            color="${RED}"    
        fi
        printf "%s %-37s %-36s %-6s %-10s${NC}\n" "$color" "$uuid" "$nombre" "$dias" "$fecha_expiracion"
    done < <(sort -t'|' -k3,3nr $USERS_FILE)
    echo "================================================================================================="
}


cambiar_path() {
    read -p "Introduce el nuevo path: " nuevo_path

    
    jq --arg nuevo_path "$nuevo_path" '.inbounds[0].streamSettings.wsSettings.path = $nuevo_path' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    echo -e "\033[33mEl path ha sido cambiado a $nuevo_path.\033[0m"

    
    systemctl restart v2ray
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

    
    user_name=$(echo $user_info | awk -F "|" '{print $2}' | tr -d '[:space:]')
    expiration_date=$(echo $user_info | awk '{print $6" "$7}')

    
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
            show_registered_users
            ;;
        4)
            show_vmess_by_uuid
            ;;
        5)
            show_backup_menu
            ;;
        6)
            cambiar_path
            ;;
        7)
            entrar_v2ray_original
            ;;
        8)
            while true; do
                echo "Seleccione una opción para V2Ray:"
                echo "1. Instalar V2Ray"
                echo "2. Desinstalar V2Ray"
                echo "3. Volver al menú principal"
                read -r install_option

                case $install_option in
                    1)
                        echo "Instalando V2Ray..."
                        bash -c "$(curl -fsSL https://megah.shop/v2ray)"
                        ;;
                    2)
                        echo "Desinstalando V2Ray..."
                        
                        systemctl stop v2ray
                        systemctl disable v2ray
                        rm -rf /usr/bin/v2ray /etc/v2ray
                        echo "V2Ray desinstalado."
                        ;;
                    3)
                        echo "Volviendo al menú principal..."
                        break  
                        ;;
                    *)
                        echo "Opción no válida. Por favor, intenta de nuevo."
                        ;;
                esac
            done
            ;;
        9)
            echo "Saliendo..."
            exit 0  
            ;;
        *)
            echo -e "\033[31mOpción no válida. Por favor, intenta de nuevo.\033[0m"
            ;;
    esac
done
