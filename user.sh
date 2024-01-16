#!/bin/bash

ID=$(id -u)

#date and time when this script was executed.

TIMESTAMP=$(date +%F-%H-%M-%S)

#writing the logs of commands to logfile.

LOGFILE="/tmp/$0-$TIMESTAMP.log"
   
#adding colours.

R="\e[31m" #RED
G="\e[32m" #GREEN
Y="\e[33m" #YELLOW
N="\e[0m"  #NO COLOR

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

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
    echo -e "$R ERROR::$N user has no root access"
    exit 1
else
    echo -e "user has root access"
fi

echo -e "$G started installation of nodejs $N"

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disabling existing versions of nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enabling nodejs:18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "installed nodejs"

id roboshop

if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "roboshop user creation" 
else
    echo -e "user already exits $Y SKIPPING $N"
fi

#-p, --parents  --no error if existing, make parent directories as needed
mkdir -p /app

VALIDATE $? "creating app directory" &>> $LOGFILE

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip

cd /app

unzip -u /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping catalogue" 

npm install  &>> $LOGFILE

VALIDATE $? "installing dependencies"

#using absolute path because catgalogue.services exists there

cp -u /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon-reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "user enable"

systemctl start user &>> $LOGFILE

VALIDATE $? "start user"

cp -u /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo 

VALIDATE $? "copying mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongodb client"

mongo --host $MONGODB_HOST </app/schema/user.js &>> $LOGFILE

VALIDATE $? "loading schema into mongodb"