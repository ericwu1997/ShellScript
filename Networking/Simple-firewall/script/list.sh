# Show INPUT OUTPUT FORWARD table
clear
iptables -L INPUT -v -x
echo ""
iptables -L FORWARD -v -n -x
echo ""
iptables -L OUTPUT -v -n -x
echo ""
iptables -L ALL -v -n -x
echo ""
iptables -L WWW -v -n -x
echo ""
iptables -L SSH -v -n -x
echo ""
iptables -L OTHERS -v -n -x
echo ""
iptables -Z