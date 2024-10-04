
## Scope
This project aims to deliver the  AWS [CloudFormation Template](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html) that provisions a Single Node OpenShift (SNO) cluster and deploys the IBM watsonx.governance solution on it.

## Prerequisites
The prerequisites for provisioning the OpenShift cluster and running IBM watsonx.governance are as follows.
- Existing [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) with a pair of subnets that has both inbound and outbound connectivity.
- PEM file (SSH key-pair) to remote login to the Boot node (EC2 instance). For, more details on how it works, click [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html).
- [Redhat Pull Secret](https://console.redhat.com/openshift/install/pull-secret) in JSON format, uploaded to S3 bucket.
- IBM [Entitlement Key](https://myibm.ibm.com/products-services/containerlibrary)
 
## How do you get credentials for the OpenShift cluster?
Username: kubeadmin

The CFN template's output section will show the details of the Boot node. Do SSH to the Boot node using the PEM file that you provided in the input.
Once connected, run the following command to retrieve the cluster's password.

Command: cat /home/ec2-user/installer/auth/kubeadmin-password

## How to get credentials of CloudPak?

The OpenShift Route named 'cpd' contains URL for CloudPak login.
The OpenShift Secret named 'platform-auth-idp-credentials' contains both the id and password for CPD login.
