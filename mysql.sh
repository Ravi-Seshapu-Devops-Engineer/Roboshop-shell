#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/Roboshop-shell"
LOGS_FILE="/var/log/Roboshop-shell/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.seshapudevops.online

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

dnf install mysql-server -y &>>$LOGS_FILE
validate $? "installation of mysql server is "

systemctl enable mysqld &>>$LOGS_FILE
systemctl start mysqld  &>>$LOGS_FILE
validate $? "Enablinh mysqld and starting mysqld is "

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGS_FILE
validate $? "secure installation is "