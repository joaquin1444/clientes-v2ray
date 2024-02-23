#!/bin/bash

CLIENTES_FILE="clientes.txt"

mostrar_banner() {
    echo -e "\e[1;35m*************************************************************\e[0m"
    echo -e "\e[1;35m*                    BIENVENIDO A CLIENTES                   *\e[0m"
    echo -e "\e[1;35m*                        by joaquin                          *\e[0m"
    echo -e "\e[1;35m*************************************************************\e[0m"
}

mostrar_menu() {
    echo -e "\e[1;33m************************************************************\e[0m"
    echo -e "\e[1;33m* 1. Agregar cliente\e[0m"
    echo -e "\e[1;33m* 2. Mostrar clientes\e[0m"
    echo -e "\e[1;33m* 3. Editar clientes\e[0m"
    echo -e "\e[1;33m* 4. Borrar cliente\e[0m"
    echo -e "\e[1;33m* 5. Salir\e[0m"
    echo -e "\e[1;33m************************************************************\e[0m"
}

agregar_cliente() {
    echo -e "\e[1;34m*************************************************************\e[0m"
    echo -e "\e[1;34m* Ingrese el nombre del cliente:\e[0m"
    read nombre

    echo -e "\e[1;34m* Ingrese la cantidad de días:\e[0m"
    read dias

    echo -e "\e[1;34m* Ingrese el HWID:\e[0m"
    read hwid

    echo -e "\e[1;34m* Ingrese el UUID:\e[0m"
    read uuid

    fecha_inicio=$(date "+%Y-%m-%d")
    fecha_expiracion=$(date -d "+${dias} days" "+%Y-%m-%d")

    # Numerar clientes
    num_clientes=$(awk 'END {print NR}' "${CLIENTES_FILE}")
    num_cliente=$((num_clientes + 1))

    echo "${num_cliente}:${nombre}:${dias}:${hwid}:${uuid}:${fecha_inicio}:${fecha_expiracion}" >> "${CLIENTES_FILE}"

    echo -e "\e[1;32m* Cliente agregado correctamente.\e[0m"
    echo -e "\e[1;34m*************************************************************\e[0m"
}

mostrar_clientes() {
    echo -e "\e[1;36m*************************************************************\e[0m"
    echo -e "\e[1;36m* No | Nombre | Días | HWID | UUID | Inicio | Expiración | Días Restantes *\e[0m"
    echo -e "\e[1;36m* ------------------------------------------------------------------- *\e[0m"
    hoy=$(date "+%s")

    while IFS=':' read -r num_cliente nombre dias hwid uuid fecha_inicio fecha_expiracion; do
        fecha_expiracion_s=$(date -d "${fecha_expiracion}" "+%s")
        dias_desde_inicio=$(( (hoy - $(date -d "${fecha_inicio}" "+%s")) / 86400 ))
        dias_restantes=$(( (fecha_expiracion_s - hoy) / 86400 ))
        echo -e "\e[1m* ${num_cliente}\e[0m | \e[1m${nombre}\e[0m | \e[1m${dias}\e[0m | \e[1m${hwid}\e[0m | \e[1m${uuid}\e[0m | \e[1m${fecha_inicio}\e[0m | \e[1m${fecha_expiracion}\e[0m | \e[1m${dias_restantes}\e[0m"
        echo -e "\e[1;36m* ------------------------------------------------------------------- *\e[0m"
    done < "${CLIENTES_FILE}"

    echo -e "\e[1;36m*************************************************************\e[0m"
}

editar_clientes() {
    mostrar_clientes
    echo -e "\e[1;34m* Ingrese el número del cliente que desea editar:\e[0m"
    read num_cliente_editar

    # Buscar el cliente con el número seleccionado
    cliente=$(grep "^${num_cliente_editar}:" "${CLIENTES_FILE}")

    if [ -z "$cliente" ]; then
        echo -e "\e[1;31m* Cliente no encontrado.\e[0m"
        return
    fi

    echo -e "\e[1;34m* Cliente seleccionado:\e[0m"
    echo -e "\e[1m$cliente\e[0m"

    # Obtener la información actual del cliente
    IFS=':' read -r num_cliente_old nombre_old dias_old hwid_old uuid_old fecha_inicio_old fecha_expiracion_old <<< "$cliente"

    # Menú de edición
    echo -e "\e[1;34m* Seleccione la información a editar:\e[0m"
    echo -e "\e[1;33m* 1. Cambiar HWID\e[0m"
    echo -e "\e[1;33m* 2. Cambiar UUID\e[0m"
    echo -e "\e[1;33m* 3. Cambiar nombre\e[0m"
    echo -e "\e[1;33m* 4. Cambiar días\e[0m"
    echo -e "\e[1;33m* 5. Volver al menú principal\e[0m"
    echo -e "\e[1;33m* ------------------------------------------------------------------- *\e[0m"

    read opcion_edicion
    case $opcion_edicion in
        1) editar_hwid ;;
        2) editar_uuid ;;
        3) editar_nombre ;;
        4) editar_dias ;;
        5) ;;
        *) echo -e "\e[1;31m* Opción no válida.\e[0m"; editar_clientes ;;
    esac
}

editar_hwid() {
    echo -e "\e[1;34m* Ingrese el nuevo HWID:\e[0m"
    read hwid_new

    # Actualizar el HWID del cliente en el archivo
    sed -i "s/^${num_cliente_editar}:${nombre_old}:${dias_old}:${hwid_old}:${uuid_old}:${fecha_inicio_old}:${fecha_expiracion_old}/\
${num_cliente_editar}:${nombre_old}:${dias_old}:${hwid_new}:${uuid_old}:${fecha_inicio_old}:${fecha_expiracion_old}/" "${CLIENTES_FILE}"

    echo -e "\e[1;32m* HWID editado correctamente.\e[0m"
    editar_clientes
}

editar_uuid() {
    echo -e "\e[1;34m* Ingrese el nuevo UUID:\e[0m"
    read uuid_new

    # Actualizar el UUID del cliente en el archivo
    sed -i "s/^${num_cliente_editar}:${nombre_old}:${dias_old}:${hwid_old}:${uuid_old}:${fecha_inicio_old}:${fecha_expiracion_old}/\
${num_cliente_editar}:${nombre_old}:${dias_old}:${hwid_old}:${uuid_new}:${fecha_inicio_old}:${fecha_expiracion_old}/" "${CLIENTES_FILE}"

    echo -e "\e[1;32m* UUID editado correctamente.\e[0m"
    editar_clientes
}

editar_nombre() {
    echo -e "\e[1;34m* Ingrese el nuevo nombre:\e[0m"
    read nombre_new

    # Actualizar el nombre del cliente en el archivo
    sed -i "s/^${num_cliente_editar}:${nombre_old}:${dias_old}:${hwid_old}:${uuid_old}:${fecha_inicio_old}:${fecha_expiracion_old}/\
${num_cliente_editar}:${nombre_new}:${dias_old}:${hwid_old}:${uuid_old}:${fecha_inicio_old}:${fecha_expiracion_old}/" "${CLIENTES_FILE}"

    echo -e "\e[1;32m* Nombre editado correctamente.\e[0m"
    editar_clientes
}

editar_dias() {
    echo -e "\e[1;34m* Ingrese la nueva cantidad de días (actual: $dias_old):\e[0m"
    read dias_new

    fecha_expiracion_new=$(date -d "+${dias_new} days" "+%Y-%m-%d")

    # Actualizar la cantidad de días del cliente en el archivo
    sed -i "s/^${num_cliente_editar}:${nombre_old}:${dias_old}:${hwid_old}:${uuid_old}:${fecha_inicio_old}:${fecha_expiracion_old}/\
${num_cliente_editar}:${nombre_old}:${dias_new}:${hwid_old}:${uuid_old}:${fecha_inicio_old}:${fecha_expiracion_new}/" "${CLIENTES_FILE}"

    echo -e "\e[1;32m* Días editados correctamente.\e[0m"
    editar_clientes
}

borrar_cliente() {
    mostrar_clientes
    echo -e "\e[1;34m* Ingrese el número del cliente que desea borrar:\e[0m"
    read num_cliente_borrar

    # Borrar el cliente con el número seleccionado
    sed -i "/^${num_cliente_borrar}:/d" "${CLIENTES_FILE}"

    echo -e "\e[1;32m* Cliente borrado correctamente.\e[0m"
    echo -e "\e[1;34m*************************************************************\e[0m"
}

mostrar_banner

while true; do
    mostrar_menu

    read opcion
    case $opcion in
        1) agregar_cliente ;;
        2) mostrar_clientes ;;
        3) editar_clientes ;;
        4) borrar_cliente ;;
        5) echo -e "\e[1;31m* Saliendo.\e[0m"; break ;;
        *) echo -e "\e[1;31m* Opción no válida.\e[0m" ;;
    esac
done
