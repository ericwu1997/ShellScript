source config.sh

iptables -F
iptables -X
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

iptables -N TCP_TRAFFIC
iptables -N UDP_TRAFFIC
iptables -N ICMP_TRAFFIC

# DHCP
iptables -A INPUT -p udp --dport 67:68 --sport 67:68 -j ACCEPT

# DNS
# iptables -A INPUT -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT
# iptables -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT

# Block 
iptables -A FORWARD -d $CLIENT_IP -s $LOCALNET/$LOCAL_NETMASK -j DROP


# Bock external traffic to all unpermitted ports 
for ports in $BLOCK_ALL
{
	iptables -A FORWARD -p tcp -m multiport --dport $ports -j DROP
	iptables -A FORWARD -p udp -m multiport --dport $ports -j DROP
}

# Split traffic to TCP, UDP and ICMP
iptables -A FORWARD -p tcp -j TCP_TRAFFIC
iptables -A FORWARD -p udp -j UDP_TRAFFIC
iptables -A FORWARD -p icmp -j ICMP_TRAFFIC

# TCP_TRAFFIC rules
if [ ! -z $TCP_BLOCK ]
then
	iptables -A TCP_TRAFFIC -p tcp -m multiport --dports $TCP_BLOCK -j DROP 
fi
iptables -A TCP_TRAFFIC -d $CLIENT_IP -p tcp -m multiport --sports $TCP_INBOUND_ALLOWED -m state --state ESTABLISHED -j ACCEPT
iptables -A TCP_TRAFFIC -s $CLIENT_IP -p tcp -m multiport --dports $TCP_OUTBOUND_ALLOWED -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A TCP_TRAFFIC -d $CLIENT_IP -p tcp -m multiport --dports $TCP_INBOUND_ALLOWED -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A TCP_TRAFFIC -s $CLIENT_IP -p tcp -m multiport --sports $TCP_OUTBOUND_ALLOWED -m state --state ESTABLISHED -j ACCEPT
iptables -A TCP_TRAFFIC -j DROP

# UDP_TRAFFIC rules
if [ ! -z $UDP_BLOCK ]
then
	iptables -A UDP_TRAFFIC -p udp -m multiport --dports $UDP_BLOCK -j DROP 
fi
iptables -A UDP_TRAFFIC -d $CLIENT_IP -p udp -m multiport --dports $UDP_INBOUND_ALLOWED -j ACCEPT
iptables -A UDP_TRAFFIC -s $CLIENT_IP -p udp -m multiport --dports $UDP_OUTBOUND_ALLOWED -j ACCEPT
iptables -A UDP_TRAFFIC -j DROP   

# ICMP_TRAFFIC rules
for port in "${ICMP_INBOUND_ALLOWED[@]}"
{
	iptables -A ICMP_TRAFFIC -d $CLIENT_IP -p icmp --icmp-type $port -m state --state NEW,ESTABLISHED -j ACCEPT
}
for port in "${ICMP_OUTBOUND_ALLOWED[@]}"
{
	iptables -A ICMP_TRAFFIC -s $CLIENT_IP -p icmp --icmp-type $port -m state --state NEW,ESTABLISHED -j ACCEPT
}
iptables -A ICMP_TRAFFIC -j DROP

# Block high ports
for port in $HIGHPORT_RANGE
{
    iptables -A FORWARD -d $CLIENT_IP -p tcp -m multiport --dports $port -j DROP
    iptables -A FORWARD -d $CLIENT_IP -p udp -m multiport --dports $port -j DROP
}

