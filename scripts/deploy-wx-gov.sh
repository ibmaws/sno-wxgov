#!/bin/bash

echo "Current user: $(whoami)"

# Define the function to stop and remove containers and forcefully remove associated images
cleanup_containers_and_images() {
  local name_pattern="$1"

  # Check if the name pattern is provided
  if [ -z "$name_pattern" ]; then
    echo "Usage: cleanup_containers_and_images <name_pattern>"
    return 1
  fi

  # List all container IDs and names that match the pattern
  containers=$(podman ps --filter "name=$name_pattern" --format "{{.ID}} {{.Names}}")

  if [ -z "$containers" ]; then
    echo "No containers found matching pattern '$name_pattern'."
    return 0
  fi

  # Stop and remove containers
  echo "$containers" | while read -r container_id container_name; do
    echo "Stopping container $container_name ($container_id)..."
    podman stop "$container_id"

    echo "Removing container $container_name ($container_id)..."
    podman rm "$container_id"
  done

  # List all images associated with the containers (forcefully removing them)
  images=$(podman images --format "{{.ID}} {{.Repository}}" | grep -F "$(echo "$containers" | awk '{print $2}' | tr '\n' '|')" | awk '{print $1}')

  if [ -z "$images" ]; then
    echo "No images found for the removed containers."
    return 0
  fi

  echo "$images" | while read -r image_id; do
    echo "Removing image $image_id..."
    podman rmi --force "$image_id"
  done
}

SHORT=curl:,cuser:,cpass:,pcoperators:,pcoperands:,vpc:,entitlement:,vers:,pcertmgr:,plicensesvc:,pschedulingsvc:,sclassblc:,comps:,h
LONG=cluster-url:,cluster-username:,cluster-password:,proj-cpd-operators:,proj-cpd-operands:,vpc-id:,entitlement-key:,version:,proj-cert-mgr:,proj-license-svc:,proj-scheduling-svc:,stg-class-block:,components:,help
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
    -vers | --version)
      VERSION="$2"
      shift 2
      ;;
    -pcertmgr | --proj-cert-mgr)
      PROJECT_CERT_MANAGER="$2"
      shift 2
      ;;
    -plicensesvc | --proj-license-svc)
      PROJECT_LICENSE_SERVICE="$2"
      shift 2
      ;;
    -pschedulingsvc | --proj-scheduling-svc)
      PROJECT_SCHEDULING_SERVICE="$2"
      shift 2
      ;;
    -sclassblc | --stg-class-block)
      STG_CLASS_BLOCK="$2"
      shift 2
      ;;
    -comps | --components)
      COMPONENTS="$2"
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

echo "script to deploy wx gov starts" 

# cleanup, before we start deployment
rm -rf cpd-cli-workspace/
cleanup_containers_and_images "olm-utils"

# Echoing the values of the variables
echo "CLUSTER_URL: $CLUSTER_URL"
echo "CLUSTER_USERNAME: $CLUSTER_USERNAME"
echo "CLUSTER_PASSWORD: $CLUSTER_PASSWORD"
echo "PROJECT_CPD_INST_OPERATORS: $PROJECT_CPD_INST_OPERATORS"
echo "PROJECT_CPD_INST_OPERANDS: $PROJECT_CPD_INST_OPERANDS"
echo "VPC_ID: $VPC_ID"
echo "VERSION: $VERSION"
echo "PROJECT_CERT_MANAGER: $PROJECT_CERT_MANAGER"
echo "PROJECT_LICENSE_SERVICE: $PROJECT_LICENSE_SERVICE"
echo "PROJECT_SCHEDULING_SERVICE: $PROJECT_SCHEDULING_SERVICE"
echo "STG_CLASS_BLOCK: $STG_CLASS_BLOCK"
echo "COMPONENTS: $COMPONENTS"


export installer_workspace=$(pwd)/installer-files
export cpd_cli_version=14.0.2
export PATH=$installer_workspace:$PATH
export KUBECONFIG=/home/ec2-user/installer/auth/kubeconfig
export LD_LIBRARY_PATH=/usr/lib64


#echo 'export PATH=/home/ec2-user/installer-files:$PATH' >> ~/.bashrc
#echo 'export KUBECONFIG=/home/ec2-user/installer/auth/kubeconfig' >> ~/.bashrc

#source ~/.bashrc
ldconfig 

echo "installer_workspace is set to: $installer_workspace"
echo "cpd_cli_version: $cpd_cli_version"
echo "PATH: $PATH"
echo "KUBECONFIG: $KUBECONFIG"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"


echo "oc login $CLUSTER_URL --username=$CLUSTER_USERNAME --password=$CLUSTER_PASSWORD --insecure-skip-tls-verify"
oc login $CLUSTER_URL --username=$CLUSTER_USERNAME --password=$CLUSTER_PASSWORD --insecure-skip-tls-verify

echo "creating project, oc new-project"

oc new-project $PROJECT_CPD_INST_OPERATORS
oc new-project $PROJECT_CPD_INST_OPERANDS

sleep 5

echo $(cpd-cli version)
cpd-cli manage restart-container
echo "***********************"
echo "cpd-cli manage login-to-ocp --username=$CLUSTER_USERNAME --password=$CLUSTER_PASSWORD --server=$CLUSTER_URL"
cpd-cli manage login-to-ocp --username=$CLUSTER_USERNAME --password=$CLUSTER_PASSWORD --server=$CLUSTER_URL

sleep 5

cp install-options.yml /home/ec2-user/cpd-cli-workspace/olm-utils-workspace/work/.

LOAD_BALANCER=`aws elb describe-load-balancers --output text | grep $VPC_ID | awk '{ print $5 }' | cut -d- -f1 | xargs`
for lbs in ${LOAD_BALANCER[@]}; do
  aws elb modify-load-balancer-attributes \
    --load-balancer-name $lbs \
    --load-balancer-attributes "{\"ConnectionSettings\":{\"IdleTimeout\":600}}"
done


cpd-cli manage add-icr-cred-to-global-pull-secret \
  --entitled_registry_key=$IBM_ENTITLEMENT_KEY

cpd-cli manage apply-cluster-components \
  --release=$VERSION \
  --license_acceptance=true \
  --cert_manager_ns=$PROJECT_CERT_MANAGER \
  --licensing_ns=$PROJECT_LICENSE_SERVICE

cpd-cli manage apply-scheduler \
  --release=$VERSION \
  --license_acceptance=true \
  --scheduler_ns=$PROJECT_SCHEDULING_SERVICE

cpd-cli manage authorize-instance-topology \
  --cpd_operator_ns=$PROJECT_CPD_INST_OPERATORS \
  --cpd_instance_ns=$PROJECT_CPD_INST_OPERANDS

cpd-cli manage setup-instance-topology \
  --release=$VERSION \
  --cpd_operator_ns=$PROJECT_CPD_INST_OPERATORS \
  --cpd_instance_ns=$PROJECT_CPD_INST_OPERANDS \
  --license_acceptance=true \
  --block_storage_class=$STG_CLASS_BLOCK

script_current_user=$(oc whoami)
echo "Script current OpenShift user: $script_current_user"

oc label machineconfigpool master custom-kubelet=large-pods-num
oc apply -f max-pods-config.yaml

cpd-cli manage apply-olm \
  --release=${VERSION} \
  --components=${COMPONENTS} \
  --cpd_operator_ns=${PROJECT_CPD_INST_OPERATORS}
