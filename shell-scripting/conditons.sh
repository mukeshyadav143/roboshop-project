number1=$1
number2=$2

if [ $number1 -eq $number2 ]; then
    echo "$number1 is equal to $number2"
elif [ $number1 -ne $number2 ]; then
    echo "$number1 is not at all equal to $number2"
# else
#     echo "$number1 is not equal to $number2"
fi


echo "please enter the number:"
read NUMBER

if [ $(($NUMBER % 2)) -eq 0 ]; then
    echo "given $NUMBER IS EVEN"
else
    echo "given $NUMBER IS ODD"
fi