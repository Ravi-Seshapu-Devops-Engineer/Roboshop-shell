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

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOGS_FILE
validate $? "Downloading the code"

cd /app &>>$LOGS_FILE
validate $? "directory changed to app"

rm -rf /app/* &>>$LOGS_FILE
validate $? "Removing the existing code"

unzip /tmp/cart.zip &>>$LOGS_FILE
validate $? "Unzipping the code"

npm install &>>$LOGS_FILE
validate $? "installing node package manager"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service &>>$LOGS_FILE
validate $? "creating systemctl service"

systemctl daemon-reload &>>$LOGS_FILE
validate $? "deamon reload"

systemctl enable cart &>>$LOGS_FILE
validate $? "enabling cart"

systemctl start cart &>>$LOGS_FILE
validate $? "cart started"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOGS_FILE

INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("cart")')

if [ $INDEX -le 0 ]; then
  mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOGS_FILE
  validate $? "Loading products"
else
  echo -e "Products already loaded $Y skipping $N"
fi

systemctl restart cart
validate $? "cart restart"

systemctl status cart

netstat -lntp