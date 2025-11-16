#checking the root access

user_id=$(id -u)

if [ $user_id -eq 0 ]; then 
    echo "proceeding installations wih root access"
exit 1
else 
    echo "please proceed wih root access"
exit 1
fi

dnf install mysql -y

if [ $? -eq 0 ]; then
    echo "mysql isntallation is success"
exit 1
else 
    echo "mysql installation is failure because of "0" code"
exit 1
fi