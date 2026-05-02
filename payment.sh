#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/Roboshop-shell"
LOGS_FILE="/var/log/Roboshop-shell/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.seshapudevops.online


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

dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
validate $? "Installation of python"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
  useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
  validate $? "user creation"
else
  echo -e "roboshop user aready exists $Y skipping $N"
fi

mkdir -p /app &>>$LOGS_FILE
validate $? "app directory creation"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOGS_FILE
validate $? "Downloading the code"

cd /app &>>$LOGS_FILE
validate $? "directory changed to app"

rm -rf /app/* &>>$LOGS_FILE
validate $? "Removing the existing code"

unzip /tmp/payment.zip &>>$LOGS_FILE
validate $? "Unzipping the code"

pip3 install -r requirements.txt
validate $? "Installing "

cp $SCRIPT_DIR/payment.service vim /etc/systemd/system/payment.service &>>$LOGS_FILE
validate $? "creating systemctl service"

systemctl daemon-reload &>>$LOGS_FILE
validate $? "deamon reload"

systemctl enable payment &>>$LOGS_FILE
systemctl start payment &>>$LOGS_FILE
validate $? "enabling payment and starting "