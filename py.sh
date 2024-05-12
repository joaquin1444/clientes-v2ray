#!/bin/bash

command -v bash >/dev/null 2>&1 || { echo >&2 ""; exit 1; }



trap '"; exit 1' STOP

if [ -t 1 ]; then
    : 
else
    echo ""
    exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' 
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
LIGHT_BLUE_CYAN='\033[38;2;0;212;255m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
MAGENTA='\033[0;35m'
TEAL='\033[0;36m'
GREY='\033[0;37m'

# Colores HTML para el banner
declare -A html_colors
html_colors=(
    [1]="red"
    [2]="green"
    [3]="blue"
    [4]="yellow"
    [5]="purple"
    [6]="cyan"
    [7]="magenta"
    [8]="teal"  
    [9]="grey"
)

INSTALL_DIR="/etc/python"
SCRIPT_NAME="PDirect-80.py"

change_banner() {
    clear
    echo -e "${BLUE}Seleccione el color para el nuevo mini banner:${NC}"
    echo -e "${RED}[${NC}${LIGHT_BLUE}1${NC}${RED}]${NC} ${RED}Red${NC}"
    echo -e "${RED}[${NC}${LIGHT_BLUE}2${NC}${RED}]${NC} ${GREEN}Green${NC}"
    echo -e "${RED}[${NC}${LIGHT_BLUE}3${NC}${RED}]${NC} ${BLUE}Blue${NC}"
    echo -e "${RED}[${NC}${LIGHT_BLUE}4${NC}${RED}]${NC} ${YELLOW}Yellow${NC}"
    echo -e "${RED}[${NC}${LIGHT_BLUE}5${NC}${RED}]${NC} ${PURPLE}Purple${NC}"
    echo -e "${RED}[${NC}${LIGHT_BLUE}6${NC}${RED}]${NC} ${CYAN}Cyan${NC}"
    echo -e "${RED}[${NC}${LIGHT_BLUE}7${NC}${RED}]${NC} ${MAGENTA}Magenta${NC}"
    echo -e "${RED}[${NC}${LIGHT_BLUE}8${NC}${RED}]${NC} ${TEAL}Teal${NC}"
    echo -e "${RED}[${NC}${LIGHT_BLUE}9${NC}${RED}]${NC} ${GREY}Grey${NC}"

    read -p "Seleccione una opción de color (1-9): " color_choice

    if [[ ! ${html_colors[$color_choice]+_} ]]; then
        echo -e "${RED}Opción no válida. Por favor seleccione un número válido.${NC}"
        return
    fi

    selected_color=${html_colors[$color_choice]}

    echo -e "${BLUE}Ingrese el texto para el nuevo mini banner:${NC}"
    read mini_banner
    if [[ -z "$mini_banner" ]]; then
        echo -e "${RED}No se ingresó texto para el banner. Cancelando operación.${NC}"
        return
    fi

    sed -i "s/<font color=\"[^\"]*\">[^<]*<\/font>/<font color=\"$selected_color\">$mini_banner<\/font>/" $INSTALL_DIR/$SCRIPT_NAME

    echo -e "${GREEN}Banner actualizado a: $mini_banner en color $selected_color${NC}"
    restart_script
}
install_script() {
    clear
    echo -e "${GREEN}Instalando Python Script...${NC}"
    mkdir -p $INSTALL_DIR
    cat << EOF > $INSTALL_DIR/$SCRIPT_NAME
import socket, threading, thread, select, signal, sys, time, getopt

# Listen
LISTENING_ADDR = '0.0.0.0'
if sys.argv[1:]:
  LISTENING_PORT = sys.argv[1]
else:
  LISTENING_PORT = '80' 
#Pass
PASS = ''

# CONST
BUFLEN = 4096 * 4
TIMEOUT = 60
DEFAULT_HOST = '127.0.0.1:22'
RESPONSE = 'HTTP/1.1 101 200 <font color="#0046ff">${mini_banner}</font>\r\nContent-length: 0\r\n\r\nHTTP/1.1 200 OK\r\n\r\n'
#RESPONSE = 'HTTP/1.1 200 Hello_World!\r\nContent-length: 0\r\n\r\nHTTP/1.1 200 Connection established\r\n\r\n'  # lint:ok

class Server(threading.Thread):
    def __init__(self, host, port):
        threading.Thread.__init__(self)
        self.running = False
        self.host = host
        self.port = port
        self.threads = []
        self.threadsLock = threading.Lock()
        self.logLock = threading.Lock()

    def run(self):
        self.soc = socket.socket(socket.AF_INET)
        self.soc.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.soc.settimeout(2)
        intport = int(self.port)
        self.soc.bind((self.host, intport))
        self.soc.listen(0)
        self.running = True

        try:
            while self.running:
                try:
                    c, addr = self.soc.accept()
                    c.setblocking(1)
                except socket.timeout:
                    continue

                conn = ConnectionHandler(c, self, addr)
                conn.start()
                self.addConn(conn)
        finally:
            self.running = False
            self.soc.close()

    def printLog(self, log):
        self.logLock.acquire()
        print log
        self.logLock.release()

    def addConn(self, conn):
        try:
            self.threadsLock.acquire()
            if self.running:
                self.threads.append(conn)
        finally:
            self.threadsLock.release()

    def removeConn(self, conn):
        try:
            self.threadsLock.acquire()
            self.threads.remove(conn)
        finally:
            self.threadsLock.release()

    def close(self):
        try:
            self.running = False
            self.threadsLock.acquire()

            threads = list(self.threads)
            for c in threads:
                c.close()
        finally:
            self.threadsLock.release()


class ConnectionHandler(threading.Thread):
    def __init__(self, socClient, server, addr):
        threading.Thread.__init__(self)
        self.clientClosed = False
        self.targetClosed = True
        self.client = socClient
        self.client_buffer = ''
        self.server = server
        self.log = 'Connection: ' + str(addr)

    def close(self):
        try:
            if not self.clientClosed:
                self.client.shutdown(socket.SHUT_RDWR)
                self.client.close()
        except:
            pass
        finally:
            self.clientClosed = True

        try:
            if not self.targetClosed:
                self.target.shutdown(socket.SHUT_RDWR)
                self.target.close()
        except:
            pass
        finally:
            self.targetClosed = True

    def run(self):
        try:
            self.client_buffer = self.client.recv(BUFLEN)

            hostPort = self.findHeader(self.client_buffer, 'X-Real-Host')

            if hostPort == '':
                hostPort = DEFAULT_HOST

            split = self.findHeader(self.client_buffer, 'X-Split')

            if split != '':
                self.client.recv(BUFLEN)

            if hostPort != '':
                passwd = self.findHeader(self.client_buffer, 'X-Pass')
				
                if len(PASS) != 0 and passwd == PASS:
                    self.method_CONNECT(hostPort)
                elif len(PASS) != 0 and passwd != PASS:
                    self.client.send('HTTP/1.1 400 WrongPass!\r\n\r\n')
                elif hostPort.startswith('127.0.0.1') or hostPort.startswith('localhost'):
                    self.method_CONNECT(hostPort)
                else:
                    self.client.send('HTTP/1.1 403 Forbidden!\r\n\r\n')
            else:
                print '- No X-Real-Host!'
                self.client.send('HTTP/1.1 400 NoXRealHost!\r\n\r\n')

        except Exception as e:
            self.log += ' - error: ' + e.strerror
            self.server.printLog(self.log)
	    pass
        finally:
            self.close()
            self.server.removeConn(self)

    def findHeader(self, head, header):
        aux = head.find(header + ': ')

        if aux == -1:
            return ''

        aux = head.find(':', aux)
        head = head[aux+2:]
        aux = head.find('\r\n')

        if aux == -1:
            return ''

        return head[:aux];

    def connect_target(self, host):
        i = host.find(':')
        if i != -1:
            port = int(host[i+1:])
            host = host[:i]
        else:
            if self.method=='CONNECT':
                port = 110
            else:
                port = sys.argv[1]

        (soc_family, soc_type, proto, _, address) = socket.getaddrinfo(host, port)[0]

        self.target = socket.socket(soc_family, soc_type, proto)
        self.targetClosed = False
        self.target.connect(address)

    def method_CONNECT(self, path):
        self.log += ' - CONNECT ' + path

        self.connect_target(path)
        self.client.sendall(RESPONSE)
        self.client_buffer = ''

        self.server.printLog(self.log)
        self.doCONNECT()

    def doCONNECT(self):
        socs = [self.client, self.target]
        count = 0
        error = False
        while True:
            count += 1
            (recv, _, err) = select.select(socs, [], socs, 3)
            if err:
                error = True
            if recv:
                for in_ in recv:
		    try:
                        data = in_.recv(BUFLEN)
                        if data:
			    if in_ is self.target:
				self.client.send(data)
                            else:
                                while data:
                                    byte = self.target.send(data)
                                    data = data[byte:]

                            count = 0
			else:
			    break
		    except:
                        error = True
                        break
            if count == TIMEOUT:
                error = True
            if error:
                break


def print_usage():
    print 'Usage: proxy.py -p <port>'
    print '       proxy.py -b <bindAddr> -p <port>'
    print '       proxy.py -b 0.0.0.0 -p 80'

def parse_args(argv):
    global LISTENING_ADDR
    global LISTENING_PORT
    
    try:
        opts, args = getopt.getopt(argv,"hb:p:",["bind=","port="])
    except getopt.GetoptError:
        print_usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print_usage()
            sys.exit()
        elif opt in ("-b", "--bind"):
            LISTENING_ADDR = arg
        elif opt in ("-p", "--port"):
            LISTENING_PORT = int(arg)


def main(host=LISTENING_ADDR, port=LISTENING_PORT):
    print "\n:-------PythonProxy-------:\n"
    print "Listening addr: " + LISTENING_ADDR
    print "Listening port: " + str(LISTENING_PORT) + "\n"
    print ":-------------------------:\n"
    server = Server(LISTENING_ADDR, LISTENING_PORT)
    server.start()
    while True:
        try:
            time.sleep(2)
        except KeyboardInterrupt:
            print 'Stopping...'
            server.close()
            break

 #######    parse_args(sys.argv[1:])
if __name__ == '__main__':
    main()


EOF

    echo -e "${BLUE}Script instalado en $INSTALL_DIR/$SCRIPT_NAME${NC}"
    sleep 1
    change_port1
    change_default_host_port
    change_banner
    sleep 1

}


change_default_host_port() {
    clear
    echo -e "${YELLOW}INGRESE EL PUERTO PARA DIRIGIR PYTHON:${NC}"
    read new_port
    sed -i "s/DEFAULT_HOST =.*/DEFAULT_HOST = '127.0.0.1:${new_port}'/" $INSTALL_DIR/$SCRIPT_NAME
    echo -e "${YELLOW}PUERTO ACTUALIZADO A: ${new_port}${NC}"
}

kill_port() {
    clear
    echo -e "${YELLOW}PUERTOS PYTHON ACTIVOS :${NC}"
    lsof -i -P -n | grep "^python.*LISTEN" | awk '{print $9}' | cut -d: -f2 | sort -u

    echo -e "${YELLOW}INGRESE EL PUERTO QUE DESEA CERRAR O PRESIONE ENTER PARA VOLVER ATRÁS:${NC}"
    read port

    if [ -z "$port" ]; then
        return
    fi

    pid=$(lsof -t -i:$port)
    if [ -n "$pid" ]; then
        echo -e "${YELLOW}CERRANDO PUERTO ${port}...${NC}"
        kill $pid
        echo -e "${YELLOW}PUERTO ${port} CERRADO.${NC}"
    else
        echo -e "${RED}EL PUERTO ${port} NO ESTÁ EN USO O NO ES UN PUERTO PYTHON ACTIVO.${NC}"
    fi
}

change_port1() {
    clear
    echo -e "${YELLOW}Ingrese el nuevo puerto:${NC}"
    read new_port
    sed -i "s/LISTENING_PORT =.*/LISTENING_PORT = sys.argv[1] if sys.argv[1:] else '${new_port}'/" $INSTALL_DIR/$SCRIPT_NAME
    echo -e "${YELLOW}Puerto actualizado a: ${new_port}${NC}"
    PORT=$new_port
}


change_port() {
    clear
    echo -e "${BLUE}Ingrese el nuevo puerto:${NC}"
    read new_port
    sed -i "s/LISTENING_PORT =.*/LISTENING_PORT = sys.argv[1] if sys.argv[1:] else '${new_port}'/" $INSTALL_DIR/$SCRIPT_NAME
    echo -e "${GREEN}Puerto actualizado a: ${new_port}${NC}"
    PORT=$new_port  
    restart_script
}



restart_script() {
    echo -e "${YELLOW}Reiniciando el script Python para aplicar los cambios...${NC}"
    
    pkill -f $SCRIPT_NAME
    
    sleep 2
    
    screen -dmS python_session python $INSTALL_DIR/$SCRIPT_NAME
    echo -e "${GREEN}Proceso de Python reiniciado en una nueva sesión de screen.${NC}"
}

main_menu() {
    
    while true; do
    clear
        echo -e "\n${BLUE}========= PERSONAL PYTHON MENU  =========${NC}"
        echo -e "${RED}=======================================${NC}\n"
        echo -e "${RED}[${NC}${LIGHT_BLUE}01${NC}${RED}]${NC} ${LIGHT_BLUE}Instalar Python Script ${NC}"
        echo -e "${RED}[${NC}${LIGHT_BLUE}02${NC}${RED}]${NC} ${LIGHT_BLUE}Cambiar Banner ${NC}"
        echo -e "${RED}[${NC}${LIGHT_BLUE}03${NC}${RED}]${NC} ${LIGHT_BLUE}Cambiar Puerto ${NC}"
        echo -e "${RED}[${NC}${LIGHT_BLUE}04${NC}${RED}]${NC} ${LIGHT_BLUE}QUITAR PUERTO ACTIVO ${NC}"
        echo -e "${RED}[${NC}${LIGHT_BLUE}05${NC}${RED}]${NC} ${RED}Salir ${NC}"
        echo -e "${RED}=======================================${NC}\n"
        
        read -p "Seleccione una opción: " option
        case $option in
            1)
                install_script
                ;;
            2)
                change_banner
                ;;
            3)
                change_port
                ;;
            4)
                kill_port
                ;;
            5)
                echo -e "${RED}Saliendo...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opción no válida, por favor intente nuevamente.${NC}"
                ;;
        esac
    done
}

main_menu
