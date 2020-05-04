if [ "$#" -ne 2 ]; then
    echo "Usage: ./aes-encrypt passphrase file-to-encrypt"
else
    # encrypt file with aes using passphrase
    openssl enc -nosalt -aes-256-cbc -pass pass:$1 -p -in $2 -out $2.enc -pbkdf2
fi