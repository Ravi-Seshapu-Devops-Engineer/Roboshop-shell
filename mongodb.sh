#!/bin bash

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
    echo e "$G $2 is Success $N" | tee -a $LOGS_FILE
  fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "copying mongo repo"

dnf install mongodb-org -y & >>$LOGS_FILE
validate $? "Installing monfodb sever"

systemctl enable mongod &>>$LOGS_FILE
validate $? "mongodb enable"

systemctl start mongod
validate $? "mongodb start"

systemctl status mongod

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "Allowing remote connections"

systemctl restart mongod &>>$LOGS_FILE
validate $? "restart mongodb"
