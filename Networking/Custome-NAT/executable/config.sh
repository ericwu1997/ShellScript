##########################################################
#		Firewall host and internal host setup			 #
##########################################################
# nameserver info
NAMESERVER="142.232.76.191"
NAMESERVER_CONFIG_PATH="/etc/resolv.conf"

# Firewall host info
INTERNET_NIC="eno1"
INTERNET_IP="192.168.0.11"
INTERNET_GATEWAY="192.168.0.100"
INTERNET_NET="192.168.0.0/24"

LOCALNET_NIC="enp2s0"
LOCALNET_GATEWAY="10.0.0.1"
LOCALNET="10.0.0.0"
LOCAL_BCAST="10.0.0.255"
LOCAL_NETMASK="255.255.255.0"

# Client info
CLIENT_NIC="enp2s0"
CLIENT_IP="10.0.0.2"
CLIENT_NETMASK="255.255.255.0"

EXTERNAL_IP="192.168.0.5"
##########################################################
#					Firewall params						 #
########################################################## 
TCP_INBOUND_ALLOWED="80,443:447"
TCP_OUTBOUND_ALLOWED="80,443:447"

UDP_INBOUND_ALLOWED="53,17"
UDP_OUTBOUND_ALLOWED="53,17"

ICMP_INBOUND_ALLOWED=( "0" "8" )
ICMP_OUTBOUND_ALLOWED=( "0" "8" )

TCP_BLOCK="23,111,515"
UDP_BLOCK=""
BLOCK_ALL="32768:32775 137:139"

HIGHPORT_RANGE="1024:65535"
##########################################################
#				Automatic test params					 #
########################################################## 
OUTPUT_FILE="internal-test-result.txt"
