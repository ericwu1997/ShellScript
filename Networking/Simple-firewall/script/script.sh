clear
# FLUSH INPUT OUTPUT FORWARD chain
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD
iptables -F ALL
iptables -F WWW
iptables -F SSH
iptables -F OTHERS

# set default polices to DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# User defined chain: ALL
iptables -N ALL
iptables -I INPUT -j ALL
iptables -I OUTPUT -j ALL
iptables -I FORWARD -j ALL

# Drop all incoming packets from reserved port 0 as well as outbound traffic to port 0.
iptables -A ALL -p tcp --sport 0 -j DROP
iptables -A ALL -p tcp --dport 0 -j DROP
iptables -A ALL -p udp --sport 0 -j DROP
iptables -A ALL -p udp --dport 0 -j DROP

# Direct the rest of the traffic to corresponding chain (none www and ssh goes to OTHERS)
# -> WWW
iptables -A ALL -p tcp -m multiport --sports 80,443 -m state --state ESTABLISHED -j WWW
iptables -A ALL -p tcp -m multiport --dports 80,443 -m state --state NEW,ESTABLISHED -j WWW
# -> SSH
iptables -A ALL -p tcp --sport 22 -m state --state ESTABLISHED -j SSH
iptables -A ALL -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j SSH
# -> OTHERS
iptables -A ALL -j OTHERS

# User defined chain: WWW
iptables -N WWW
# Drop inbound traffic to port 80 (http) from source ports less than 1024.
iptables -A WWW -p tcp -s 0/0 --sport 0:1023 -d 0/0 --dport 80 -j DROP
# Accept the rest
iptables -A WWW -j ACCEPT

# User defined chain: SSH
iptables -N SSH
iptables -A SSH -j ACCEPT

# User defined chain: OTHERS
iptables -N OTHERS
# Allow inbound DNS
iptables -A OTHERS -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT
iptables -A OTHERS -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OTHERS -p tcp --sport 53 -m state --state ESTABLISHED -j ACCEPT
iptables -A OTHERS -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
# Allow inbound DHCP
iptables -A OTHERS -p udp --dport 67:68 --sport 67:68 -j ACCEPT
iptables -A OTHERS -j DROP

echo "Table updated!"
