## Scope

The purpose of this project is to provide the CloudFormation (CFN) Template which provisions Single Node OpenShift (SNO) cluster, and deploy IBM watsonx governance on it.

## How to get credentials of OpenShift cluster?
Username: kubeadmin

The CFN template's output section will show Boot node. Do SSH to boot node.
Run the following command to get the password.

command: cat /home/ec2-user/installer/auth/kubeadmin-password

## How to get credentials of CloudPak?

The OpenShift Route named 'cpd' contains URL for CloudPak login.
The OpenShift secret named 'platform-auth-idp-credentials' contains both the id and password for CPD login.

