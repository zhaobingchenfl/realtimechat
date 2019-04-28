#!/usr/bin/env sh

mkdir -p beanstalk/app
cp beanstalk/Dockerrun.aws.json beanstalk/app/
cd beanstalk/app

eb init -p docker zchen-eb-docker
eb deploy ZchenEbDocker-env -region us-east-2

