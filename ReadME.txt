Introduction
----------
S3 
| - Non-Compliance -> S3 resource and Config resource is created as part of it. But Auto-remediation is not enabled
| - Fixed -> Auto Remediation is enabled

EC2-SG
| - Non-Compliance -> EC2/SG/VPC created. And Config is enabled without Auto-remediation
| - Fixed -> Auto-remediation is enabled for AWS Config

Method
------
> Open provider.tf -> Fill the values according to the requirements
> Open terraform.tfvars -> Fill the values according to the requirements
> terraform init
> terraform plan
> terraform apply -auto-approve
> To destroy resources -> terraform destroy -auto-approve

Developer
------------
K.Janarthanan

PS - Images folder contains the sample diagram of resources created as part of this template

Blog - https://scripting4ever.wordpress.com/2023/06/16/achieve-aws-config-compliance-with-auto-remediation/

