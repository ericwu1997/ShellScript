source config.sh

options=(
    firewall-host-setup
    client-setup
    firewall-update
    iptables-list
    firewall-internal-test
    firewall-external-test
)

function flush_firewall() {
    iptables -F
    iptables -X
    iptables -t nat -F
}

function flush_route_table() {
    ip route flush table main
}

function flush_firewall_prompt() {
    while :; do # Flush out existing firewall
        echo "Flush existing firewall? [y/n]"
        read -p " > " ltr
        case ${ltr} in
        n)
            break
            ;;
        y | "")
            flush_firewall
            break
            ;;
        *)
            echo "Please enter a valid choice, default [y]"
            ;;
        esac
    done
}

function flush_route_table_prompt() {
    while :; do # Flush out existisng routing table
        echo "Flush existing routing table? [y/n]"
        read -p " > " ltr
        case ${ltr} in
        n)
            break
            ;;
        y | "")
            ip route flush table main
            break
            ;;
        *)
            echo "Please enter a valid choice, default [y]"
            ;;
        esac
    done
}

function firewall_host_setup() {
    clear
    echo "Setting up firewall host..."
    flush_route_table_prompt
    flush_firewall_prompt

    clear
    echo "1) Enable forwarding  :1"
    echo "1" >/proc/sys/net/ipv4/ip_forward

    echo "nameserver $NAMESERVER" >$NAMESERVER_CONFIG_PATH
    echo "2) Nameserver         :$NAMESERVER"

    echo "3) LOCAL GATEWAY      :$LOCALNET_GATEWAY"
    echo "   LOCALNET           :$LOCALNET"
    ifconfig $LOCALNET_NIC down
    ifconfig $LOCALNET_NIC $LOCALNET_GATEWAY broadcast $LOCAL_BCAST netmask $LOCAL_NETMASK
    route del -net $LOCALNET gw 0.0.0.0 netmask $LOCAL_NETMASK dev $LOCALNET_NIC

    echo "4) Internet gateway   :$INTERNET_GATEWAY"
    echo "   Internet IP        :$INTERNET_IP"
    echo "   Internet           :$INTERNET_NET"
    ifconfig $INTERNET_NIC $INTERNET_IP up
    ip route add $INTERNET_NET dev $INTERNET_NIC
    route add -net $LOCALNET netmask $LOCAL_NETMASK gw $LOCALNET_GATEWAY
    route add default gw $INTERNET_GATEWAY

    echo "5) PREROUTING         :$INTERNET_IP --> $CLIENT_IP (DNAT)"
    echo "   POSTROUTING        :$CLIENT_IP --> $INTERNET_IP (SNAT)"
    iptables -t nat -A PREROUTING -i $INTERNET_NIC -d $INTERNET_IP -j DNAT --to-destination $CLIENT_IP
    iptables -t nat -A PREROUTING -i $INTERNET_NIC -d $CLIENT_IP -j DNAT --to-destination $INTERNET_IP
    iptables -t nat -A POSTROUTING -o $INTERNET_NIC -j SNAT --to-source $INTERNET_IP

    echo "6) Bring up firewall  :./firewall.sh"
    ./firewall.sh

    echo ""
    route -n
    echo ""
}

function internal_host_setup() {
    # client configuration
    clear
    echo "Setting up internal host..."
    flush_route_table_prompt
    flush_firewall_prompt

    clear
    echo "nameserver $NAMESERVER" >$NAMESERVER_CONFIG_PATH
    echo "1) Nameserver         :$NAMESERVER"
    ifconfig $CLIENT_NIC down
    ifconfig $CLIENT_NIC $CLIENT_IP broadcast $LOCAL_BCAST netmask $LOCAL_NETMASK
    route add default gw $LOCALNET_GATEWAY

    echo "2) Internet gateway   :$LOCALNET_GATEWAY"
    echo "   Internet IP        :$CLIENT_IP"
    echo "   Internet           :$LOCALNET"

    echo ""
    route -n
    echo ""
}

function firewall_update() {
    clear
    ./firewall.sh
    echo "TCP inbound 	: $TCP_INBOUND_ALLOWED"
    echo "TCP outbound	: $TCP_OUTBOUND_ALLOWED"
    echo "UDP inbound 	: $UDP_INBOUND_ALLOWED"
    echo "UDP outbound	: $UDP_OUTBOUND_ALLOWED"
    echo "ICMP inbound	: $ICMP_INBOUND_ALLOWED"
    echo "ICMP outbound	: $ICMP_OUTBOUND_ALLOWED"

    echo ""
    echo "TCP blocked	: $TCP_BLOCK"
    echo "UDP blocked	: $UDP_BLOCK"
    echo "Block all       : $BLOCK_ALL"
    echo "Firewall updated!"
}

function iptables_list() {
    clear
    iptables -L -v
}

function automatic_test_run() {
    clear
    echo "Running firewall test, please wait..."
    ./firewall-test.sh $1
    while :; do # Flush out existisng routing table
        echo "Test completed, Would you like to view it now? [y/n]"
        read -p " > " ltr
        case ${ltr} in
        y | "")
            vim $OUTPUT_FILE
            break
            ;;
        n)
            echo "To view test reulst later, check $OUTPUT_FILE"
            break
            ;;
        *)
            echo "Please enter a valid choice, default [n]"
            ;;
        esac
    done
}

# command-line menu display
clear
while true; do
    echo "8006 Assignment 2"
    for i in "${!options[@]}"; do
        printf "$i) ${options[$i]}\n"
    done
    printf "q) quit\n"
    read -p " > " ltr rest
    case ${ltr} in
    [0])
        firewall_host_setup
        exit
        ;;
    [1])
        internal_host_setup
        exit
        ;;
    [2])
        firewall_update
        exit
        ;;
    [3])
        iptables_list
        exit
        ;;
    [4])
        automatic_test_run -internal
        exit
        ;;
    [5])
        automatic_test_run -external
        exit
        ;;
    [Qq])
        exit
        ;;
    *)
        clear
        echo "Unrecognized choice: ${ltr}"
        ;;
    esac
done
