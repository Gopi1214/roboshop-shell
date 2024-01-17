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
    exit 1 #you can give other than 0
else
    echo -e "You are root user"
fi # fi means reverse of if, indicating condition end

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
    echo -e "user already exits $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "creating app directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip

VALIDATE $? "downloading cart application"

cd /app

unzip -o /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "unzipping cart"

npm install &>> $LOGFILE

VALIDATE $? "installing packages"

#use absolute path, because cart.service exists there
cp -u /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service

VALIDATE $? "copying cart service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon-reload automatically reload new config"

systemctl enable cart &>> $LOGFILE

VALIDATE $? "enabling services on boot"

systemctl start cart &>> $LOGFILE

VALIDATE $? "starts services immediately"