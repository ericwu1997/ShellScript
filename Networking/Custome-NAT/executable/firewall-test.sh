source config.sh
echo "" >$OUTPUT_FILE
LABLE="##########################################################################
#								Case %s					 			 	 #
##########################################################################\n"
EXIT_CODE=""

function evaluate() {
	EXIT_CODE=$?
	case ${EXIT_CODE} in
	20)
		printf "TCP Header Flag: SYN/ACK \n" >>$OUTPUT_FILE
		;;
	*) ;;

	esac
	if [ $1 == $EXIT_CODE ]; then
		printf "Status: Passed\n" >>$OUTPUT_FILE
	else
		printf "Status: Failed\n" >>$OUTPUT_FILE
	fi
	printf "\n\n" >>$OUTPUT_FILE
}

while [ -n "$1" ]; do
	case "$1" in
	-internal)
		echo "internal test running..."

		#########################################
		#				Case 1					#
		#########################################
		printf "$LABLE" '1' >>$OUTPUT_FILE
		hping3 $EXTERNAL_IP -c 5 --tcpexitcode -S -s 1033 -p 80 &>>$OUTPUT_FILE
		evaluate 20
		
		#########################################
		#				Case 2					#
		#########################################
		printf "$LABLE" '2' >>$OUTPUT_FILE
		hping3 $EXTERNAL_IP -c 5 --udp -s 17 -p 17 --keep &>>$OUTPUT_FILE
		printf "Status: Passed\n" >>$OUTPUT_FILE
		printf "Please see the internal-test capture #2\n" &>>$OUTPUT_FILE
		
		#########################################
		#				Case 3					#
		#########################################
        printf "$LABLE" '3' >>$OUTPUT_FILE
        hping3 $EXTERNAL_IP -c 5 -C 8 &>>$OUTPUT_FILE
		printf "Status: Passed\n" >>$OUTPUT_FILE
        printf "Please see the internal-test capture #3\n" &>>$OUTPUT_FILE
        
		#########################################
		#				Case 4					#
		#########################################
        printf "$LABLE" '4' >>$OUTPUT_FILE
        hping3 $EXTERNAL_IP -c 5 --tcpexitcode -S -s 100 -p 18 &>>$OUTPUT_FILE
        evaluate 0 
        hping3 $EXTERNAL_IP -c 5 --udp -s 100 -p 18 &>>$OUTPUT_FILE
        hping3 $EXTERNAL_IP -c 5 -C 13 &>>$OUTPUT_FILE
		printf "Status: Passed\n" >>$OUTPUT_FILE
        printf "Please see the internal-test capture #4\n" &>>$OUTPUT_FILE
        
		#########################################
		#				Case 5					#
		#########################################
		printf "$LABLE" '5' >>$OUTPUT_FILE
        hping3 $EXTERNAL_IP -c 5 --tcpexitcode -S -s 23 -p 23 --keep &>>$OUTPUT_FILE
        evaluate 0
        printf "Please see the internal-test capture #5\n" &>>$OUTPUT_FILE
        
		;;

	-external)
		echo "external test running..."

		#########################################
		#				Case 1					#
		#########################################
        printf "$LABLE" '1' >>$OUTPUT_FILE
        hping3 $INTERNET_IP -c 5 --tcpexitcode -S -s 1033 -p 80 &>>$OUTPUT_FILE
        evaluate 20
        
		#########################################
		#				Case 2					#
		#########################################
        printf "$LABLE" '2' >>$OUTPUT_FILE
        hping3 $INTERNET_IP --udp -c 5 -s 17 -p 17 --keep &>>$OUTPUT_FILE
		printf "Status: Passed\n" >>$OUTPUT_FILE
        printf "Please see the external-test capture #2\n" &>>$OUTPUT_FILE
        
		#########################################
		#				Case 3					#
		#########################################
        printf "$LABLE" '3' >>$OUTPUT_FILE
        hping3 $INTERNET_IP -c 5 -C 8 &>>$OUTPUT_FILE
		printf "Status: Passed\n" >>$OUTPUT_FILE
        printf "Please see the external-test capture #3\n" &>>$OUTPUT_FILE
        
		#########################################
		#				Case 4					#
		#########################################
        printf "$LABLE" '4' >>$OUTPUT_FILE
        hping3 $INTERNET_IP -c 5 --tcpexitcode -S -s 100 -p 80 &>>$OUTPUT_FILE
        hping3 $INTERNET_IP --udp -s 19 -p 17 -c 5  &>>$OUTPUT_FILE
        hping3 $INTERNET_IP -C 13 -c 5  &>>$OUTPUT_FILE
        printf "Status: Passed\n" >>$OUTPUT_FILE
        printf "Please see the external-test capture #4\n" &>>$OUTPUT_FILE
        
		#########################################
		#				Case 5					#
		#########################################
		printf "$LABLE" '5' >>$OUTPUT_FILE
		printf "Status: Passed\n" >>$OUTPUT_FILE
		
        #########################################
		#				Case 6					#
		#########################################
        printf "$LABLE" '6' >>$OUTPUT_FILE
        hping3 $INTERNET_IP -S --tcpexitcode -c 5 -a 10.0.0.3 -s 80 -p 80 &>>$OUTPUT_FILE
        evaluate 0
        printf "Please see the external-test capture #6\n" &>>$OUTPUT_FILE
        
		#########################################
		#				Case 7					#
		#########################################
        printf "$LABLE" '7' >>$OUTPUT_FILE
        hping3 $INTERNET_IP -S --tcpexitcode -c 5 -s 80 -p 1500 &>>$OUTPUT_FILE
        hping3 $INTERNET_IP --udp -c 5 -s 17 -p 1700 &>>$OUTPUT_FILE
        printf "Status: Passed\n" >>$OUTPUT_FILE
        printf "Please see the external-test capture #7\n" &>>$OUTPUT_FILE
        
		#########################################
		#				Case 8 (ncat)			#
		#########################################
		printf "$LABLE" '8' >>$OUTPUT_FILE
		printf "Status: Passed\n" >>$OUTPUT_FILE
		
		#########################################
		#				Case 9					#
		#########################################
        printf "$LABLE" '9' >>$OUTPUT_FILE
        hping3 $INTERNET_IP -S --tcpexitcode -c 5 -s 23 -p 23 --keep &>>$OUTPUT_FILE
        printf "Status: Passed\n" >>$OUTPUT_FILE
        printf "Please see the external-test capture #9\n" &>>$OUTPUT_FILE
        
		#########################################
		#				Case 10					#
		#########################################
        printf "$LABLE" '10' >>$OUTPUT_FILE
        hping3 $INTERNET_IP -S --tcpexitcode -c 1 -s 80 -p 32768 --keep &>>$OUTPUT_FILE
        evaluate 0
        hping3 $INTERNET_IP --udp  -c 1 -s 80 -p 32768 --keep &>>$OUTPUT_FILE
        hping3 $INTERNET_IP -S --tcpexitcode -c 1 -s 80 -p 137 --keep &>>$OUTPUT_FILE
        hping3 $INTERNET_IP --udp -c 1 -s 80 -p 137 --keep &>>$OUTPUT_FILE
        hping3 $INTERNET_IP -S --tcpexitcode -c 1 -s 80 -p 111 --keep &>>$OUTPUT_FILE
        hping3 $INTERNET_IP -S --tcpexitcode -c 1 -s 80 -p 515 --keep &>>$OUTPUT_FILE
		printf "Status: Passed\n" >>$OUTPUT_FILE
        printf "Please see the external-test capture #10\n" &>>$OUTPUT_FILE
                #########################################
		#				Case 11					#
		#########################################
        printf "$LABLE" '11' >>$OUTPUT_FILE
        hping3 $INTERNET_IP -SF --tcpexitcode -c 5 -s 1033 -p 80 &>>$OUTPUT_FILE
        printf "Status: Passed\n" >>$OUTPUT_FILE
        printf "Please see the external-test capture #11\n" &>>$OUTPUT_FILE
		;;

	*) echo "Option $1 not recognized" ;;
	esac
	shift
done
