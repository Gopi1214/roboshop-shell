    #!/bin/bash

    #installing mongodb, I was checking wether user has root access or not.

    ID=$(id -u)

    #date and time when this script was executed.

    TIMESTAMP=$(date +%F-%H-%M-%S)

    #writing the logs of commands to logfile

    LOGFILE="/tmp/$0-$TIMESTAMP.log"
        
    #adding colours
    R="\e[31m" #RED
    G="\e[32m" #GREEN
    Y="\e[33m" #YELLOW
    N="\e[0m"  #NO COLOR

    echo "sript started executing at $TIMESTAMP" &>> $LOGFILE

    #validate function to check weather the bash command was success or failed.

    VALIDATE(){
        if [ $1 -ne 0 ]
        then 
            echo -e "$2 was ... $R FAILED $N"
            exit 1
        else
            echo -e "$2 was ... $G SUCCESS $N"
        fi
        }

    if [ $ID -ne 0 ]
    then 
        echo -e "$R ERROR::$N user has no root acces, not allowed to execute below commands"
        exit 1
    else
        echo -e "user has $G root $N access"
    fi

    cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

    VALIDATE $? "copied mongodb repo"

    echo -e "$G installing mongodb $N"

    dnf install mongodb-org -y &>> $LOGFILE

    VALIDATE $? "installed mongodb"

    systemctl enable mongod &>> $LOGFILE

    VALIDATE $? "enabled mongodb"

    systemctl start mongod &>> $LOGFILE

    VALIDATE $? "started mongodb"

    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

    VALIDATE $? "Remote access to MongoDB"
    
    systemctl restart mongod &>> $LOGFILE

    VALIDATE $? "restarted mongodb"

