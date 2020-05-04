if [ "$#" -ne 2 ]; then
    echo "Usage: ./aes-decrypt passphrase file-to-decrypt"
else
    # decrypt file with aes using passphrase
    openssl enc -nosalt -aes-256-cbc -pass pass:$1 -d -in $2 -out ${2%.*} -pbkdf2
fi