
## Scope
This project aims to deliver the  AWS [CloudFormation Template](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html) that provisions a Single Node OpenShift (SNO) cluster and deploys the IBM watsonx.governance solution on it.

## Introduction
What is Single Node OpenShift?

Red Hat Single Node OpenShift (SNO) is a fully-fledged Kubernetes distribution that consolidates control and worker node functionalities into a single node, offering a smaller footprint than a standard OpenShift cluster. It's a valuable addition to OpenShift's deployment options, enabling new use cases for resource-constrained environments while maintaining Kubernetes' robust orchestration and management capabilities.

Why Deploy Cloud Pak for Watson AIOps on Single Node OpenShift?

The primary purpose of this deployment option is to enable sales teams and customers to easily and quickly set up IBM watsonx.governance to understand the key functionalities/capabilities of the product. 

Key benefits include:

Simplified Cluster Provisioning: Launching a Single Node OpenShift cluster is significantly easier than setting up a typical OpenShift cluster, improving efficiency and addressing a major pain point for users trying to explore watsonx.gov. Cluster preparation often delays deployment, but with SNO, this process is much quicker.

Reduced Hardware Requirements: Single Node OpenShift requires minimal resources, which is a big advantage over the substantial hardware needed for a multi-node OpenShift cluster. This lower resource requirement makes it ideal for users who want to explore features without heavy investment.

Note: This environment should NOT be used for Development, Test, and production environments.  


## Prerequisites
The prerequisites for provisioning the OpenShift cluster and running IBM watsonx.governance are as follows.
- Existing [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) with a pair of subnets that has both inbound and outbound connectivity.
- PEM file (SSH key-pair) to remote login to the Boot node (EC2 instance). For, more details on how it works, click [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html).
- [Redhat Pull Secret](https://console.redhat.com/openshift/install/pull-secret) in JSON format, uploaded to S3 bucket.
- IBM [Entitlement Key](https://myibm.ibm.com/products-services/containerlibrary)

- When executing the CloudFormation template from AWS Console, It is required to have IAM Role to execute the CloudFormation template with administrative permissions and trust relationship to the CloudFormation service.
 
## Assumptions
For clarity, the documentation and screenshots feature the OHIO region (us-east-2) as an example. You’re welcome to choose your preferred AWS region for the automation process.

Additionally, the OpenShift cluster is referred to as 'sno-wxgov' and the domain name is 'ibmworkshops.com.' Please substitute these with your values.

## How to use it?
Open the AWS [CloudFormation Console](https://console.aws.amazon.com/cloudformation/), click the 'Create Stack' button and select the option as 'With new resources (standard)'. It should open a new page, where upload our automation template for execution as follows and click the 'Next' button to provide the value of input parameters.

![image](https://github.com/user-attachments/assets/4a84e614-5809-4105-b430-bc8985aac947)

Provide StackName based on your preference, It is a String. For example, 'snowxgov' is used as StackName.

Next, input values to parameters; and finally submit the template for execution.

## Template execution time
The template takes approximately 4 to 5 hours to provision the OpenShift cluster and deploy the watsonx.governance on it.

When the template finishes successfully, its status will be changed to 'CREATE_COMPLETE' as follows.

![image](https://github.com/user-attachments/assets/69883216-8ad8-4634-a993-a692a3b3295e)

## How do you get credentials for the OpenShift cluster?
Username: kubeadmin

The CFN template's output section will show the details of the Boot node as follows.

![image](https://github.com/user-attachments/assets/8a162868-975b-4142-a297-64e5585fa996)


Do SSH to the Boot node using the PEM file that you provided in the input.
Once connected, run the following command to retrieve the cluster's password.

Command: cat /home/ec2-user/installer/auth/kubeadmin-password

![image](https://github.com/user-attachments/assets/394007a1-d8bf-4bb9-b638-444cdcb1bec3)


## How to get credentials of CloudPak?
The OpenShift Route named 'cp-console' contains a URL for CloudPak login.

![image](https://github.com/user-attachments/assets/182822ad-edcc-430e-b898-32d9ff479d3b)


The OpenShift Secret named 'platform-auth-idp-credentials' contains both the ID and password for CPD login.

![image](https://github.com/user-attachments/assets/57620d26-746b-491d-9a4e-9bf758e47809)

Scroll down the page, and click 'Reveal Values' to display the credentials of CloudPak.
![image](https://github.com/user-attachments/assets/f966e412-9e74-4d61-a120-3d0e93237ff4)




## Debugging
The Cloudformation template execution logs can be viewed after doing SSH to the EC2 instance (a.k.a boot node).

The CFN execution log file is at /var/log/cloud-init-output.log
