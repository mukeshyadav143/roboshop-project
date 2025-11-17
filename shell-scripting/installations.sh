#checking the root access

user_id=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
E="\e[0m"

if [ $user_id -eq 0 ]; then 
    echo -e "${G} proceeding installations wih root access ${E}"
else 
    echo -e "please proceed with ${R} root access ${E}"
    exit 1
fi

dnf install mysql -y

if [ $? -eq 0 ]; then
    echo -e "mysql isntallation ${G} is success ${E}"
else 
    echo -e "mysql installation is ${R} failure ${E}"
    exit 1
fi

