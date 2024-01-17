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

echo "started installing golang"

dnf install golang -y

id roboshop

if [ $? -ne 0]
then
    useradd roboshop
    VALIDATE $? "user added"
else
    echo "roboshop user already exists"

mkdir -p /app &>> $LOGFILE

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOGFILE

VALIDATE $? "downloading dispatch file"

cd /app 

unzip -u /tmp/dispatch.zip

go mod init dispatch

go get 

go build

cp /home/centos/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service

systemctl daemon-reload

systemctl enable dispatch 

systemctl start dispatch