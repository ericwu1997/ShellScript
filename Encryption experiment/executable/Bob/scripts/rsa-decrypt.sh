if [ "$#" -ne 2 ]; then
    echo "Usage: ./rsa-encrypt rsa-key file-to-encrypt"
else
    # dencrypt file with rsa key
    openssl rsautl -decrypt -inkey $1 -in $2 -out ${2%.*} 
fi