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

dnf module disable nodejs -y &>>$LOGS_FILE
validate $? "disabling existing nodejs" 

dnf module enable nodejs:20 -y &>>$LOGS_FILE
validate $? "enabling nodejs 20 version" 

dnf install nodejs -y &>>$LOGS_FILE
validate $? "installing nodejs"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
  useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
  validate $? "user creation"
else
  echo -e "roboshop user aready exists $Y skipping $N"
fi

mkdir -p /app &>>$LOGS_FILE
validate $? "app directory creation"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOGS_FILE
validate $? "Downloading the code"

cd /app &>>$LOGS_FILE
validate $? "directory changed to app"

rm -rf /app/* &>>$LOGS_FILE
validate $? "Removing the existing code"

unzip /tmp/user.zip &>>$LOGS_FILE
validate $? "Unzipping the code"

npm install &>>$LOGS_FILE
validate $? "installing node package manager"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>>$LOGS_FILE
validate $? "creating systemctl service"

systemctl daemon-reload &>>$LOGS_FILE
validate $? "deamon reload"

systemctl enable user &>>$LOGS_FILE
validate $? "enabling user"

systemctl start user &>>$LOGS_FILE
validate $? "user started"


