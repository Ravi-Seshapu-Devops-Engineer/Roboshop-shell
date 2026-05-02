#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/Roboshop-shell"
LOGS_FILE="/var/log/Roboshop-shell/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
  echo -e "$R run the script with root user access $N" | tee -a $LOGS_FILE
  exit 1
fi

mkdir -p $LOGS_FOLDER

validate(){
  if [ $1 -ne 0 ]; then
    echo -e "$R $2 is failed $N" | tee -a $LOGS_FILE
    exit 1
  else
    echo -e "$G $2 is Success $N" | tee -a $LOGS_FILE
  fi
}

dnf module disable redis -y &>>$LOGS_FILE
dnf module enable redis:7 -y &>>$LOGS_FILE
validate $? "Redis module disabled and module 7 enabled"

dnf install redis -y &>>$LOGS_FILE
validate $? "reis installation"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>>$LOGS_FILE
validate $? "Allowing remote access"

systemctl enable redis &>>$LOGS_FILE
systemctl start redis &>>$LOGS_FILE
validate $? " enabling and starting redis"