tf-plan: id_rsa.pub
	terraform plan -var cidr=`curl -s echoip.net`

tf-apply: id_rsa.pub
	terraform apply -var cidr=`curl -s echoip.net`

tf-refresh: id_rsa.pub
	terraform refresh -var cidr=`curl -s echoip.net`

tf-destroy: id_rsa.pub
	terraform destroy -var cidr=`curl -s echoip.net`

id_rsa id_rsa.pub:
	ssh-keygen -t rsa -f id_rsa -N ""

ssh:
	ssh -i id_rsa -l centos `terraform output | grep node | peco | sed 's/.*=//'`

playbook: hosts.ini
	ansible-playbook -i hosts.ini playbook.yml --extra-var efs_id=`terraform output efs_id`

ping: hosts.ini
	ansible -m ping -i hosts.ini all

hosts.ini: terraform.tfstate
	terraform output | grep node | sed 's/ = / ansible_ssh_host=/' > hosts.ini
