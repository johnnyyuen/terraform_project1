# There have 2 way to add the Terraform Variable
> to add the variable into environment variable
```
1. Add the variable and value into a file (e.g. awsid.tfvar in this example)
2. run the command $(tfenvvar.sh)
```
OR
> to add the variable using the -var-file option
```
terraform apply -var-file="/path/to/variable/file"
```

# terraform_project1 Command used

Basic command
```
terraform -v
terraform init
terraform plan
terraform apply
terraform apply -auto-approve
terraform apply --auto-approve | tee applylog
terraform destroy
terraform state list
terraform state show "resource name"
terraform refresh
```
installing terraform
```
sudo apt install terraform
```
> or download
```
mv terraform_1.0.2_linux_arm64.zip Downloads/
unzip terraform_1.0.2_linux_arm64.zip 
sudo mv terraform /usr/local/bin
```
  
Setup Git
 ```
 Followed the steps below
 https://hackernoon.com/step-by-step-guide-to-push-your-first-project-on-github-fec1dce574f

sudo apt install git
git status
git init
git remote add origin https://github.com/johnnyyuen/terraform_project1
git push origin master
git add .
git commit -am "first commit"
git config --global user.email "jj1010@gmail.com"
git commit -am "first commit"
git remote add origin git@github.com:johnnyyuen/terraform_project1
git remote -v
ssh -T git@github.com
git pull --rebase origin master
git push origin master
git rm --cached .terraform/providers/registry.terraform.io/hashicorp/aws/3.49.0/linux_arm64/terraform-provider-aws_v3.49.0_x5
git commit --amend -CHEAD
git push
git push origin master
```
Setup SSH
```
ssh-keygen -t rsa -b 4096 -C "jj1010@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub
ssh -T git@github.com
  ```
