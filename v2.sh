#!/bin/bash



echo "alias v2='/root/v2.sh'" >> ~/.bashrc


source ~/.bashrc

CONFIG_FILE="/etc/v2ray/config.json"

USERS_FILE="/etc/v2ray/v2clientes.txt"

# Colores
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
NC=$(tput sgr0) # No Color



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






# Colores
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
NC=$(tput sgr0)  # No Color
BG_BLACK=$(tput setab 0)  # Background color black

show_menu() {
    clear
    local VERSION="1.8"
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
    echo -e "\e[36m\e[35m[5]\e[0m \e[33m🚮 eliminar expirados\e[0m"
    echo -e "\e[36m\e[36m[6]\e[0m \e[33m📂 Gestión de copias de seguridad\e[0m"
    echo -e "\e[36m\e[91m[7]\e[0m \e[33m🚀 Entrar al V2Ray nativo\e[0m"
    echo -e "\e[36m\e[92m[8]\e[0m \e[33m🔧 configurar v2ray\e[0m"
    echo -e "\e[36m\e[93m[9]\e[0m \e[33m🚪 Salir\e[0m"
    echo -e "\e[36m╚════════════════════════════════════════════════════╝\e[0m"
    echo -e "\e[34m⚙️ Acceder al menú con V2\e[0m"
}









show_backup_menu() {
    clear
    echo -e "${YELLOW}Opciones de v2ray backup:${NC}"
    echo -e "1. ${GREEN}Crear copia de seguridad${NC}"
    echo -e "2. ${RED}Restaurar copia de seguridad${NC}"
    echo -e "3. Volver al menú principal"
    echo -e "${CYAN}==========================${NC}"
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
    print_message "${CYAN}" "Agregar Nuevo Usuario"

    read -p "$(echo -e "${YELLOW}Ingrese el nombre del nuevo usuario:${NC} ")" userName

    
    if grep -q "| $userName |" "$USERS_FILE"; then
    print_message "${RED}" "Ya existe un usuario con el mismo nombre. Por favor, elija otro nombre."
    read -p "Presione Enter para regresar al menú principal" enterKey
    clear
    return 1
fi

    read -p "$(echo -e "${YELLOW}Ingrese la duración en días para el nuevo usuario:${NC} ")" days

if ! [[ "$days" =~ ^[0-9]+$ ]]; then
    print_message "${RED}" "La duración debe ser un número."
    read -p "Presione Enter para regresar al menú principal" enterKey
    clear
    return 1
fi

    read -p "$(echo -e "${YELLOW}¿Desea ingresar un UUID personalizado? (Sí: S, No: cualquier tecla):${NC} ")" customUuidChoice

    if [[ "${customUuidChoice,,}" == "s" ]]; then
        read -p "$(echo -e "${YELLOW}Ingrese el UUID personalizado para el nuevo usuario (Formato: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX):${NC} ")" userId

        
        if ! [[ "$userId" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
    print_message "${RED}" "Formato de UUID no válido. Debe ser XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
    read -p "Presione Enter para regresar al menú principal" enterKey
    clear
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
read -p "Presione Enter para regresar al menú principal" enterKey
}





delete_user() {
    clear
    print_message "${CYAN}" "⚠️ Advertencia: los usuarios expirados se recomienda eliminarlos manualmente con el ID ⚠️ "
    show_registered_user

    read -p "Ingrese el ID del usuario que desea eliminar (o presione Enter para cancelar): " userId

    if [ -z "$userId" ]; then
        print_message "${YELLOW}" "No se seleccionó ningún ID. Volviendo al menú principal."
        return
    fi

    jq ".inbounds[0].settings.clients = (.inbounds[0].settings.clients | map(select(.id != \"$userId\")))" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    sed -i "/$userId/d" "$USERS_FILE"
    print_message "${RED}" "Usuario con ID $userId eliminado."
    systemctl restart v2ray
    read -p "Presione Enter para regresar al menú principal" enterKey
}

delete_users_by_uuid() {
    local userId=$1

    
    jq ".inbounds[0].settings.clients = (.inbounds[0].settings.clients | map(select(.id != \"$userId\")))" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    
    sed -i "/$userId/d" "$USERS_FILE"

    
    systemctl restart v2ray
    echo -e "\033[33mUsuarios con UUID $userId eliminados.\033[0m"
    read -p "Presione Enter para regresar al menú principal" enterKey

}
delete_user_by_uuid() {
    local userId=$1

    
    jq ".inbounds[0].settings.clients = (.inbounds[0].settings.clients | map(select(.id != \"$userId\")))" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

    
    sed -i "/$userId/d" "$USERS_FILE"

    
    systemctl restart v2ray
    echo -e "\033[33mUsuario con UUID $userId eliminado.\033[0m"
    read -p "Presione Enter para regresar al menú principal" enterKey
}

edit_user_uuid() {
    show_registered_user
    read -p "Ingrese el ID del usuario que desea editar (o presione Enter para cancelar): " userId

    if [ -z "$userId" ]; then
        print_message "${YELLOW}" "No se seleccionó ningún ID. Volviendo al menú principal."
        read -p "Presione Enter para regresar al menú principal" enterKey
        return
    fi

    
    oldUserData=$(grep "$userId" /etc/v2ray/v2clientes.txt)

    
    sed -i "/$userId/d" "$USERS_FILE"

    read -p "Ingrese el nuevo UUID para el usuario con ID $userId: " newUuid

    if [[ ! "$newUuid" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
    print_message "${RED}" "Formato de UUID no válido. Debe ser XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX."
    read -p "Presione Enter para regresar al menú principal" enterKey
    return
fi

    
    oldName=$(echo "$oldUserData" | awk -F "|" '{print $2}')

    read -p "Ingrese el nuevo nombre para el usuario con ID $userId (o presione Enter para conservar el nombre $oldName): " newName

newName=$(echo $newName | xargs)  

if [ -z "$newName" ]; then
    newName=$(echo "$oldName" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
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
    read -p "Presione Enter para regresar al menú principal" enterKey
return
}




create_backup() {
    clear
    read -p "Ingrese el nombre del archivo de respaldo: " backupFileName
    backupFilePath="/root/$backupFileName"  
    cp $CONFIG_FILE "$backupFilePath"_config.json
    cp $USERS_FILE "$backupFilePath"_v2clientes.txt
    print_message "${GREEN}" "Copia de seguridad creada en: $backupFilePath"
    read -p "Presione Enter para continuar"
}

show_backups() {
    clear
    echo -e "\e[1m\e[34mBackups disponibles:\e[0m"
    
    for backupFile in /root/*_config.json; do
        
        backupName=$(basename "$backupFile" _config.json)
        
        
        backupDateTime=$(date -r "$backupFile" "+%Y-%m-%d %H:%M:%S")
        
        
        echo -e "\e[1m\e[32mNombre:\e[0m $backupName"
        echo -e "\e[1m\e[32mFecha y hora:\e[0m $backupDateTime"
        echo -e "\e[36m------------------------\e[0m"
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
    color="\e[31m"  # Rojo
    ((contador_expirados++))
    printf "%b%-37s %-10s [%s]\n" "$color" "$uuid" "$nombre" "Expirado"
else
    color="\e[32m"  # Verde
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
            color="\e[31m"  # Rojo
            ((contador_expirados++))
        else
            color="\e[32m"  # Verde
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
    echo "Entrando en la función cambiar_path..."

    while true; do
        read -p "Selecciona una opción:
1. Cambiar el nuevo path
2. Volver al menú principal
Opción: " opcion

        case $opcion in
            1)
                echo "Seleccionaste cambiar el path..."
                read -p "Introduce el nuevo path: " nuevo_path
                echo "Modificando el path a $nuevo_path en el archivo de configuración..."

                
                if ! command -v jq &> /dev/null; then
                    echo "Error: 'jq' no está instalado. Instálalo para continuar."
                    return
                fi

                
                if [ ! -f "$CONFIG_FILE" ]; then
                    echo "Error: El archivo de configuración '$CONFIG_FILE' no existe."
                    return
                fi

                
                jq --arg nuevo_path "$nuevo_path" '.inbounds[0].streamSettings.wsSettings.path = $nuevo_path' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

                
                if [ $? -eq 0 ]; then
                    echo -e "\033[33mEl path ha sido cambiado a $nuevo_path.\033[0m"
                    systemctl restart v2ray
                    read -p "Presiona Enter para regresar al menú principal" enterKey
                    return
                else
                    echo "Error al modificar el archivo de configuración con jq."
                    read -p "Presiona Enter para regresar al menú principal" enterKey
                    return
                fi
                ;;
            2)
                echo "Seleccionaste volver al menú principal..."
                return
                ;;
            *)
                echo "Opción inválida. Por favor, selecciona una opción válida."
                ;;
        esac
    done
}


configurar_temporizador() {
    while true; do
        clear
        echo -e "${CYAN}-----------------------------------------${NC}"
        echo -e "${CYAN}Selecciona el intervalo de tiempo:${NC}"
        echo -e "1. ${GREEN}5 minutos${NC}"
        echo -e "2. ${GREEN}30 minutos${NC}"
        echo -e "3. ${GREEN}1 hora${NC}"
        echo -e "4. ${RED}Desactivar temporizador${NC}"
        echo -e "5. ${YELLOW}Salir${NC}"
        echo -e "${CYAN}-----------------------------------------${NC}"

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

    
    read -p $'\e[1;36mPresiona Enter para continuar...\e[0m'
}


change_v2ray_address() {
    
        echo "próximamente."
    read -p "Presiona Enter para continuar..."
}



configurar_temporizador_con_intervalo() {
    intervalo=$1
    timer_unit="[Timer]\nOnCalendar=*-*-* *:00/$intervalo\nPersistent=true\nUnit=reiniciador.service\n"

    echo -e "$timer_unit" | sudo tee /etc/systemd/system/temporizador.timer > /dev/null
    sudo systemctl daemon-reload
    sudo systemctl restart temporizador.timer

    echo "Configuración completa."
}

desactivar_temporizador() {
    sudo systemctl stop temporizador.timer
    sudo systemctl disable temporizador.timer
    echo "Temporizador desactivado."
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
            eliminar_expirados
            ;;
        6)
            show_backup_menu
            ;;
        7)
            entrar_v2ray_original
            ;;
        8)
            while true; do
    clear
    echo -e "${CYAN}Seleccione una opción para V2Ray:${NC}"
    echo -e "1. ${GREEN}Instalar V2Ray${NC}"
    echo -e "2. ${RED}Desinstalar V2Ray${NC}"
    
    
    if systemctl is-active --quiet temporizador.timer; then
        optimize_status="[${GREEN}on${NC}]"
    else
        optimize_status="[${RED}off${NC}]"
    fi

    echo -e "3. ${YELLOW}Reiniciar V2Ray Aut. ${optimize_status}${NC}"
    echo -e "4. ${GREEN}Cambiar el path de V2Ray${NC}"
    echo -e "5. ${GREEN}cambiar address${NC}"
    echo -e "6. ${YELLOW}Volver al menú principal${NC}"

    read -r main_option

                case $main_option in
                    1) 
                        echo -e "\033[33m¿Estás seguro de que quieres instalar V2Ray? (y/n):\033[0m \c"
read confirm_install

if [ "$confirm_install" = "y" ] || [ "$confirm_install" = "Y" ]; then
    echo -e "\nDesinstalando la versión anterior de V2Ray (si existe)..."
    
    systemctl stop v2ray

    
    bash <(curl -sL https://install.direct/uninstall.sh)

    
    rm -rf /etc/v2ray /usr/bin/v2ray /var/log/v2ray

    echo -e "\nInstalando dependencias..."
    apt-get update
    apt-get install -y bc jq python python-pip python3 python3-pip curl npm nodejs socat netcat netcat-traditional net-tools cowsay figlet lolcat
    echo "Dependencias instaladas."

    echo -e "\nDescargando e instalando la nueva versión de V2Ray..."
    
    bash <(curl -sL https://raw.githubusercontent.com/joaquin1444/clientes-v2ray/main/install%20v2ray)

   
    if systemctl is-active --quiet v2ray; then
        echo -e "\033[32mV2Ray se ha instalado correctamente.\033[0m"
    else
        echo -e "\033[31m¡La instalación de V2Ray ha fallado!\033[0m"
    fi
    read -p "Presiona Enter para salir..."
else
    echo -e "\nOperación de instalación cancelada. Volviendo al menú principal..."
    read -p "Presiona Enter para salir..."
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
                        configurar_temporizador
                        ;;
                    4)
                        cambiar_path
                        ;;
                    5)
                        change_v2ray_address
                        ;;
                    6)
                        echo "Volviendo al menú principal..."
                        break  
                        ;;
                    *)
                        echo -e "${RED}Opción no válida${NC}"
                        ;;
                esac
            done
            ;;
        9)
            echo "Saliendo..."
            exit 0  
            ;;
        *)
            echo "Opción no válida. Por favor, intenta de nuevo."
            ;;
    esac
done
