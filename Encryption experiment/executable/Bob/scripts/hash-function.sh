if [ "$#" -ne 2 ]; then
    echo "Usage: ./hash-function hash-key file"
else
    # hash rsa key
    cat $2 | openssl dgst -sha256 -hmac $1 > $2.hashed
fi