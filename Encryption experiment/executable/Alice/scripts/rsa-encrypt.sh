if [ "$#" -ne 2 ]; then
    echo "Usage: ./rsa-encrypt rsa-key file-to-encrypt"
else
    # encrypt file with rsa key
    openssl rsautl -encrypt -inkey $1 -pubin -in $2 -out $2.enc
fi