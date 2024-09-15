#!/bin/bash


SHORT=curl:,cuser:,cpass:,pcoperators:,pcoperands:,vpc:,entitlement:,h
LONG=cluster-url:,cluster-username:,cluster-password:,proj-cpd-operators:,proj-cpd-operands:,vpc-id:,entitlement-key:,help
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
    -pcoperators | --proj-cpd-operators)
      PROJECT_CPD_INST_OPERATORS="$2"
      shift 2
      ;;
    -pcoperands | --proj-cpd-operands)
      PROJECT_CPD_INST_OPERANDS="$2"
      shift 2
      ;;
    -vpc | --vpc-id)
      VPC_ID="$2"
      shift 2
      ;;
    -entitlement | --entitlement-key)
      IBM_ENTITLEMENT_KEY="$2"
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

# Echoing the values of the variables
echo "CLUSTER_URL: $CLUSTER_URL"
echo "CLUSTER_USERNAME: $CLUSTER_USERNAME"
echo "CLUSTER_PASSWORD: $CLUSTER_PASSWORD"
echo "PROJECT_CPD_INST_OPERATORS: $PROJECT_CPD_INST_OPERATORS"
echo "PROJECT_CPD_INST_OPERANDS: $PROJECT_CPD_INST_OPERANDS"
echo "VPC_ID: $VPC_ID"
echo "IBM_ENTITLEMENT_KEY: $IBM_ENTITLEMENT_KEY"

export installer_workspace=$(pwd)/installer-files
export cpd_cli_version=14.0.2
export PATH=$installer_workspace:$PATH

echo "script to deploy wx gov starts"

echo $(cpd-cli version)
cpd-cli manage restart-container
cpd-cli manage login-to-ocp --username=$CLUSTER_USERNAME --password=$CLUSTER_PASSWORD --server=$CLUSTER_URL

oc new-project $PROJECT_CPD_INST_OPERATORS
oc new-project $PROJECT_CPD_INST_OPERANDS

LOAD_BALANCER=`aws elb describe-load-balancers --output text | grep $VPC_ID | awk '{ print $5 }' | cut -d- -f1 | xargs`
for lbs in ${LOAD_BALANCER[@]}; do
  aws elb modify-load-balancer-attributes \
    --load-balancer-name $lbs \
    --load-balancer-attributes "{\"ConnectionSettings\":{\"IdleTimeout\":600}}"
done


 cpd-cli manage add-icr-cred-to-global-pull-secret \
  --entitled_registry_key=$IBM_ENTITLEMENT_KEY
