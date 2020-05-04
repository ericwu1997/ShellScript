In this setup, we are assuming both Alice and Bob knows the following in advance
hash algorithm  : SHA-256
hash salt       : NSmxLLZsWps=
hash key        : "carly"

the hash salt was generate with the following command
openssl rand -base64 8

Each "script" folder in both "Alice" and "Bob" consists of same 
bash scripts. The scripts are:

aes-decrypt.sh 
    Takes 2 argument. AES passphrase and file to decrypt. This script is used
    to decrypt files encrypt with AES

aes-encrypt.sh
    Takes 2 argument. AES passphrase and file to encrypt. This script is used
    to encrypt files with AES

gen-rsa-key-pair.sh
    Takes 3 argument. passphrase for private key, private key name, public key name.
    This script is used for generate RSA key pairs

hash-function.sh
    Takes 2 arugment. Hash key (string value, for example "carly"), file to hash.
    This script is used to hash file using SHA-256

rsa-decrypt.sh
    Takes 2 arugment. Private key, file to decrypt. This script is used to decrypt
    file encrypt with RSA. Additional passphrase might be needed if the passphrase
    option was used to create the RSA keys.

rsa-encrypt.sh
    Takes 2 arugment. PUblic key, file to encrypt. This script is used to encrypt
    file with.

