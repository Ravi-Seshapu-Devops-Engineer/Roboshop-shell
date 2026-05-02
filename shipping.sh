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

dnf install maven -y &>>$LOGS_FILE
validate $? "Installation of maven"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
  useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
  validate $? "user creation"
else
  echo -e "roboshop user aready exists $Y skipping $N"
fi

mkdir -p /app &>>$LOGS_FILE
validate $? "app directory creation"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOGS_FILE
validate $? "Downloading the code"

cd /app &>>$LOGS_FILE
validate $? "directory changed to app"

rm -rf /app/* &>>$LOGS_FILE
validate $? "Removing the existing code"

unzip /tmp/shipping.zip &>>$LOGS_FILE
validate $? "Unzipping the code"

cd /app 
mvn clean package
validate $? "Installing and building Shipping"

mv target/shipping-1.0.jar shipping.jar
validate $? "moving the jar file to shipping.jar"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOGS_FILE
validate $? "creating systemctl service"

systemctl daemon-reload &>>$LOGS_FILE
validate $? "deamon reload"


dnf install mysql -y &>>$LOGS_FILE
validate $? "installation of Mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then

    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOGS_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOGS_FILE
    validate $? "Loaded data into MySQL"
else
    echo -e "data is already loaded ... $Y SKIPPING $N"
fi

systemctl enable shipping &>>$LOGS_FILE
validate $? "enabling shipping"

systemctl start shipping &>>$LOGS_FILE
validate $? "cart shipping"