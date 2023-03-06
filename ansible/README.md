# To set up an instance run:

ansible-playbook setup_instance.yml -e "instance_name=zopen-ci3"

# To set up the disk on the instance

ansible-playbook setup_disk.yml -e "instance_name=zopen-ci3"
