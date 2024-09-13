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

echo $PATH
export installer_workspace=$(pwd)/installer-files
export cpd_cli_version=14.0.2
export PATH=$installer_workspace/cpd-cli-linux-SE-$cpd_cli_version:$PATH

echo "script to deploy wx gov starts"

echo $(cpd-cli version)
cpd-cli manage restart-container
cpd-cli manage login-to-ocp --username=$CLUSTER_USERNAME --password=$CLUSTER_PASSWORD --server=$CLUSTER_URL
