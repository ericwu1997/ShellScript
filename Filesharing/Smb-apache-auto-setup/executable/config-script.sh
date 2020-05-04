# prerequisite
# Apache - 
#   - SELinux disabled, firewall setup for httpd 
#   iptables -F (use with caution)
# NFS & Samba (reference https://www.tecmint.com/setup-samba-file-sharing-for-linux-windows-clients/)
#   setsebool -P samba_export_all_ro=1 samba_export_all_rw=1
#   getsebool –a | grep samba_export
#   semanage fcontext –at samba_share_t "/${MOUNTDIR}(/.*)?"
#   restorecon /finance
#   firewall-cmd --permanent --add-service=samba
#   firewall-cmd --reload 

labs=("Lab 2 setup (Basic Apache)" "Lab 3 setup (NFS & SAMBA)")
clear
for i in ${!labs[@]}; do
    printf "$i)..... ${labs[$i]}\n"
done
printf 'Press number for choice, then Return\n'
read -p " > " ltr
case ${ltr} in
[0])
    # Fedora need to disable firewall iptables -F
    # And /etc/selinux/config SELINUX=disabled
    clear

    config="lab-2-setup.config"
    if [ ! -f "${config}" ]; then
        printf "lab-2-setup.config not found, create new one...\n"
        touch lab-2-setup.config
        read -p "username: `echo $'\n> '`" name rest
        echo "username=$name" >> lab-2-setup.config
        read -p "password: `echo $'\n> '`" passwd rest
        echo "password=$passwd" >> lab-2-setup.config
    fi
    printf "0\n\nq" | ./install-script.sh # ----------------------------- install required package from install-script.sh

    source lab-2-setup.config     # ------------------------------------- get user config

    clear

    printf "Step 1)\n" # ------------------------------------------------ step 1) setup apache service
    printf "starting apache...\n"
    systemctl start httpd.service 
    systemctl enable httpd.service

    printf "\nStep 2)\n" # ---------------------------------------------- step 2) allow userdir
    sed -i '17 s/^./#/' /etc/httpd/conf.d/userdir.conf 
    sed -i '24 s/#//g' /etc/httpd/conf.d/userdir.conf
    printf "allow using UserDir\n"

    printf "\nStep 3)\n" # ---------------------------------------------- step 3) config user and home dir
    if [ `grep -c "^$username:" /etc/passwd` == 0 ]; then
        printf "creating user ${username}\n"
        useradd ${username} 
        printf "${password}\n${password}" | passwd ${username}
    else
        printf "user ${username} detected\n"
    fi

    if [ ! -d "/home/${username}/public_html" ]; then
        printf "creating 'public_html' folder for ${username}\n"
        mkdir /home/${username}/public_html
    else
        printf "public_html folder exist under user $username's home directory\n"
    fi
    printf "creating /home/$username/public_html/index.html ...\n"
    echo "A00961904 Eric Wu" >/home/${username}/public_html/index.html
    chmod -R 777 /home/${username}/ 

    printf "\nStep 4)\n" # ---------------------------------------------- step 4) adding password access
    if [ ! -d "/var/www/html/passwords" ]; then 
        printf "creating 'passwords' folder\n"
        mkdir /var/www/html/passwords
    else
        printf "folder /var/www/html/passowrds exist\n"
    fi
    printf "creating password auth file: /var/www/html/passwords/${username}-auth...\n"
    chmod 755 /var/www/html/passwords
    cd /var/www/html/passwords
    htpasswd -b -c /var/www/html/passwords/${username}-auth ${username} ${password}

    printf "\nStep 5)\n" # ---------------------------------------------- step 5) change userdir.conf allow access
    printf "/etc/httpd/conf.d/userdir.conf modified to allow external password access\n"
    sed -i '/<Directory/,/<\/Directory>/d' /etc/httpd/conf.d/userdir.conf;

    cat >> /etc/httpd/conf.d/userdir.conf << 'q'
<Directory /home/USERNAME>
AllowOverride None
AuthUserFile /var/www/html/passwords/USERNAME-auth
AuthGroupFile /dev/null
AuthName test
AuthType Basic
<Limit GET>
    require valid-user
    order deny,allow
    deny from all
    allow from all
</Limit>
</Directory>
q
    sed -i "s/USERNAME/$username/g" /etc/httpd/conf.d/userdir.conf
    printf "\nDone)\n" # ------------------------------------------------ Done 
    printf "http://`ifconfig | awk '/inet /{print substr($2,1)}' | head -1`/~$username\n"
    
    systemctl stop httpd.service
    systemctl start httpd.service
    ;;
[1])
    clear

    config="lab-3-setup.config"
    if [ ! -f "${config}" ]; then
        printf "lab-3-setup.config not found, create new one...\n"
        touch lab-3-setup.config
        read -p "username: `echo $'\n> '`" name rest
        echo "username=$name" >> lab-3-setup.config
        read -p "password: `echo $'\n> '`" passwd rest
        echo "password=$passwd" >> lab-3-setup.config
        read -p "mountdir: `echo $'\n> '`" dir rest
        echo "mountdir=$dir" >> lab-3-setup.config
        read -p "mapping label: `echo $'\n> '`" label rest
        echo "mappinglabel=$label" >> lab-3-setup.config
        read -p "ip range: `echo $'\n> '`" range rest
        echo "iprange=$range" >> lab-3-setup.config
    fi
    printf "1\n\n2\n\nq" | ./install-script.sh

    source lab-3-setup.config

    clear
    printf "\nStep 1)\n" # ------------------------------------------------ step 1) configure NFS
    if [ `grep -c "^$username:" /etc/passwd` == 0 ]; then
        printf "creating user ${username}\n"
        useradd ${username} 
    else
        printf "user ${username} detected\n"
    fi
    printf "${password}\n${password}" | passwd $username

    if [ ! -d "${mountdir}" ]; then
        printf "creating folder $mountdir...\n"
        mkdir $mountdir
    fi
    printf "change permission of file system $mountdir to 777\n"
    chmod -R 777 $mountdir
    printf "test file foo.txt created under user's home directory\n"
    echo "A00961904 Eric Wu" > $mountdir/foo.txt

    printf "\nStep 2)\n" # ------------------------------------------------ step 2) create an entry in the NFS
    
    if [ -f "/etc/exports" ]; then
        printf "overwriting existing /etc/exports...\n"
    else
        printf "creating /etc/exports...\n"
    fi
    echo "$mountdir $iprange(rw,no_root_squash)" > /etc/exports
    # ---(a)-------(b)------(c)(d)---------------------
    # (a) directory to be shared
    # (b) systems that are permitted to access to share 
    # (c) rw = read and write access to file
    # (d) if client is root, then server access is always root

    printf "\nStep 3)\n" # ------------------------------------------------ step 3) start & enable NFS
    printf "starting NFS...\n"
    systemctl enable nfs-server.service
    systemctl start nfs-server

    printf "\nStep 4)\n" # ------------------------------------------------ step 4) make file system available
    printf "make file system available\n"
    exportfs -v

    printf "\nStep 5)\n" # ------------------------------------------------ step 5) modify samba configuration
    printf "modify samba configuration\n"
    cat > /etc/samba/smb.conf << 'q'
[global]
    workgroup = CST323
    server string = Samba Server
    security = user
[MAPPINGLABLE]
    comment = Win32 Share
    path = MOUNTDIR
    public = yes
    writable = yes
    printable = no
q
    mountdir=$(sed 's/\//\\\//g' <<< $mountdir)
    sed -i "s/MAPPINGLABLE/$mappinglabel/g" /etc/samba/smb.conf
    sed -i "s/MOUNTDIR/${mountdir}/g" /etc/samba/smb.conf

    printf "\nStep 6)\n" # ------------------------------------------------ step 6) setup security
    printf "setup samba security\n"
    printf "${password}\n${password}" | smbpasswd -a $username

    printf "\nStep 7)\n" # ------------------------------------------------ step 7) restart samba
    printf "restarting samba...\n"
    systemctl enable smb.service
    systemctl stop smb
    systemctl start smb

    printf "\nDone)\n" # -------------------------------------------------- Done 
    ;;
[Qq])
    exit
    ;;
*)
    echo Unrecognized choice: ${ltr}
    ;;
esac
