#!/bin/bash
source assign3.conf

# track the log file for new entry
tail -n0 -f $LOG_FILE_LOCATION | while read line; 
do 
	IP=$(echo "$line" | grep "Failed password" | awk '{print $11}');

	if [ ! -z "$IP" ]
		then
			sqlite3 passwd-attempt.db "INSERT INTO FAILED_LIST (IP, FAILED_ATTEMPT) \
			VALUES (\"${IP}\", 1) \
			ON CONFLICT(IP) \
			DO UPDATE SET FAILED_ATTEMPT=FAILED_ATTEMPT+1;"

			COUNT=$(sqlite3 -separator ' ' passwd-attempt.db "SELECT * FROM FAILED_LIST WHERE IP == \"${IP}\";" |
			awk '{print $2}')

			if [ $COUNT -ge $MAX_FAILED_ATTEMPT ]
				then 
					sqlite3 passwd-attempt.db "DELETE FROM FAILED_LIST WHERE IP == \"${IP}\";"
					iptables -C PASSWD_FAILED -s $IP -j DROP 2>/dev/null
					if [ $? -eq 1 ]
						then
							iptables -I PASSWD_FAILED -s $IP -j DROP
							DELAY=$(date +%S)
							echo "Start Time:" >> timestamp-log.txt
							echo "$(date +%H:%M:%S)" >> timestamp-log.txt
							echo "End Time:" >> timestamp-log.txt
							echo "sleep $DELAY ; iptables -D PASSWD_FAILED -s $IP -j DROP ; date +%H:%M:%S >> timestamp-log.txt" | at now +$BLOCK_DURATION_MIN minutes > /dev/null 2>&1
					fi
			fi
	fi
done &

# get pid of last command and create a stop script
echo "kill -9 '$!' | echo 'service stopped'" > stop-script.sh

echo "service started"
