#!/usr/bin/env sh

mkdir -p beanstalk/app
cp beanstalk/Dockerrun.aws.json beanstalk/app/
cd beanstalk/app

set -x
sudo usermod -a -G ec2-user jenkins

export PATH=$PATH:/home/ec2-user/.local/bin

echo $PATH
echo $PWD

eb init -p docker zchen-eb-docker
eb deploy ZchenEbDocker-env --region us-east-2

