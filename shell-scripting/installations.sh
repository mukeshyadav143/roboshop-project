#checking the root access

user_id=$(id -u)

if [ $user_id -eq 0 ]; then 
    echo "proceeding installations wih root access"
else 
    echo "please proceed wih root access"
exit 1
fi

dnf install mysql -y

if [ $? -eq 0 ]; then
    echo "mysql isntallation is success"
else 
    echo "mysql installation is failure"
exit 1
fi