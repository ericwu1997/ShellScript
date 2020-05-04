# installation script

package=(
   httpd # apache
   nfs-utils # NFS
   samba # SAMBA
)
while true; do
   clear
   for i in "${!package[@]}"; do
      printf "$i)..... ${package[$i]}\n"
   done
   printf "${#package[@]})..... other\n"
   printf "q)..... quit\n"
   printf 'Press number for choice, then Return\n'
   read -p " > " ltr rest
   case ${ltr} in
   [0-2])
      printf "installing ${package[${ltr}]}...\n"
      dnf install -y ${package[${ltr}]}
      ;;
   [3])
      printf "enter name of the package you would like to install\n"
      read -p " > " name
      printf "installing ${name}...\n"
      dnf install -y ${name}
      ;;
   [Qq])
      exit
      ;;
   *)
      echo Unrecognized choice: ${ltr}
      ;;
   esac
   echo
   echo -n ' Press Enter to continue.....'
   read rest
done
