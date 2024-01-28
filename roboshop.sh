#!/bin/bash

AMI=ami-0f3c7d07486cad139
SG_ID=sg-04bb94f5d828fa09d
INSTANCES=(mongodb, mysql, redis, rabbitmq, shipping, payment, user, cart, catalogue, dispatch, web)

for i in "${INSTANCES[@]}"
do
    echo "instance is: $i"
    if [ $i == "mongodb" ] || [ $i == "shipping" ] || [ $i == "mysql" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    aws ec2 run-instances --image-id ami-0f3c7d07486cad139 --count 1 --instance-type $INSTANCE_TYPE --security-group-ids $sg-04bb94f5d828fa09d
done

