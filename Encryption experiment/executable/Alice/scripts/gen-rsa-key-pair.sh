if [ "$#" -ne 3 ]; then
    echo "Usage: ./gen-rsa-key-par passphrase private-key-name public-key-name"
else
    # generate private key
    openssl genrsa -aes128 -passout pass:$1 -out $2 1024
    # generate public key
    openssl rsa -in $2 -passin pass:$1 -pubout -out $3
fi