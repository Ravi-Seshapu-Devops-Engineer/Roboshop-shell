#!/bin/bash

AMI_ID=ami-0220d79f3f480ecf5
SG_ID=sg-0ff061d19a895a55d
DOMAIN_NAME=seshapudevops.online

for instance in $@
do
  INSTANCE_ID=(  aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --security-group-ids $SG_ID \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
  --query 'Instances[0].InstanceId' \
  --output text)

  if [ $instance == "frontend" ]; then
    IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[].Instances[].PublicIpAddress" \
    --output text)
    RECORD_NAME="$DOMAIN_NAME"
  else
    IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[].Instances[].PrivateIpAddress" \
    --output text)
    RECORD_NAME="$instance.$DOMAIN_NAME"
  fi
  echo "IP_Address: $IP"
  
done