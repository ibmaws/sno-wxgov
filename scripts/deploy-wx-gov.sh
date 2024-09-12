#!/bin/bash


SHORT=curl:,cuser:,cpass:,h
LONG=cluster-url:,cluster-username:,cluster-password:,help
OPTS=$(getopt -a -n wx-gov --options $SHORT --longoptions $LONG -- "$@")

eval set -- "$OPTS"

while :
do
  case "$1" in
    -curl | --cluster-url )
      CLUSTER_URL="$2"
      shift 2
      ;;
    -cuser | --cluster-username )
      CLUSTER_USERNAME="$2"
      shift 2
      ;;
    -cpass | --cluster-password )
      CLUSTER_PASSWORD="$2"
      shift 2
      ;;
    -h | --help)
      "This is a deployment for watsonx governance script"
      exit 2
      ;;
    --)
      shift;
      break
      ;;
    *)
      echo "Invalid option: $1"
      ;;
  esac
done

curl -v https://icr.io
mkdir -p ibm-cp4d
wget https://github.com/IBM/cpd-cli/releases/download/v14.0.2/cpd-cli-linux-EE-14.0.2.tgz -O cpd-cli-linux-EE-14.0.2.tgz
tar -xz -C ~/ibm-cp4d --strip-components=1 -f cpd-cli-linux-EE-14.0.2.tgz

export PATH=/home/ec2-user/ibm-cp4d:$PATH
cpd-cli manage restart-container
cpd-cli manage login-to-ocp --username=$CLUSTER_USERNAME --password=$CLUSTER_PASSWORD --server=$CLUSTER_URL
