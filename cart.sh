#!/bin/bash

ID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)

LOGFILE="/tmp/$0-$TIMESTAMP.log"

R="\e[31m" #RED
G="\e[32m" #GREEN
Y="\e[33m" #YELLOW
N="\e[0m"  #NO COLOR

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

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

dnf module disable nodejs -y  &>> $LOGFILE

VALIDATE $? "disabling current nodejs modules"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enabling nodejs:18"

echo "started installing nodejs $TIMESTAMP" &>> $LOGFILE

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "installing nodejs"



id roboshop

if [ $? -ne 0 ]
then
    echo "user roboshop not exists"
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "adding user roboshop" 
else
    echo "user already exits"
fi

mkdir -p /app &>> $LOGFILE

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip

cd /app

unzip -0 /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "unzipping cart"

npm install &>> $LOGFILE

VALIDATE $? "installing packages"

cp -u /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon-reload automatically reload new config"

systemctl enable cart &>> $LOGFILE

VALIDATE $? "enabling services on boot"

systemctl start cart &>> $LOGFILE

VALIDATE $? "starts services immediately"