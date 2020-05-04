# install sqlite3
dnf install sqlite -y

# create a sqlite database to store passwd failed entries
sqlite3 passwd-attempt.db "CREATE TABLE FAILED_LIST (
	IP CHAR(16) PRIMARY KEY NOT NULL,
	FAILED_ATTEMPT INT NOT NULL
);" 2>/dev/null

# add user define chain for managing block rules
iptables -F PASSWD_FAILED 2>/dev/null
iptables -N PASSWD_FAILED 2>/dev/null
iptables -A PASSWD_FAILED -j RETURN
iptables -C INPUT -j PASSWD_FAILED 2>/dev/null
if [ $? -eq 1 ] 
	then
	iptables -I INPUT -j PASSWD_FAILED
fi


