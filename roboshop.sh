#!/bin/bash
AMI=ami-0f3c7d07486cad139
SG_ID=sg-04bb94f5d828fa09d
INSTANCES=("mongodb" "mysql" "redis" "rabbitmq" "shipping" "payment" "user" "cart" "catalogue" "dispatch")
DOMAIN_NAME="pjdevops.online"
ZONE_ID=Z08780431GOB4T1TR5RPR

for i in "${INSTANCES[@]}"
do
    #echo "instance is: $i"
    if [ $i == "mongodb" ] || [ $i == "shipping" ] || [ $i == "mysql" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI --count 1 --instance-type $INSTANCE_TYPE  --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query "Instances[0].PrivateIpAddress" --output text)
#echo "instance is ip_address: $IP_ADDRESS"
echo "$i: $IP_ADDRESS"

#creating route53 records make sure delete old type A records
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{ 
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }'
done

