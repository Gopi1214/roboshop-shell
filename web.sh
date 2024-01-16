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

    dnf install nginx -y &>> $LOGFILE

    VALIDATE $? "installed nginx"

    systemctl enable nginx &>> $LOGFILE

    VALIDATE $? "enable nginx"

    systemctl start nginx &>> $LOGFILE

    VALIDATE $? "start nginx"

    rm -rf /usr/share/nginx/html/* &>> $LOGFILE

    VALIDATE $? "removing old files"

    curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

    VALIDATE $? "installing web application"

    cd /usr/share/nginx/html &>> $LOGFILE

    VALIDATE $? "moving nginx to html directory"

    unzip /tmp/web.zip &>> $LOGFILE

    VALIDATE $? "unzipping web app"

    cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf  &>> $LOGFILE

    VALIDATE $? "copied roboshop reverse proxy config"

    systemctl restart nginx &>> $LOGFILE

    VALIDATE $? "restarted nginx"

