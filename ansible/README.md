# To create the IBM Cloud vpc instance, use:

```
ansible-playbook setup_instance.yml -e "instance_name=zopen-ci5" -e "key_name=root"
```

## Required variables:
* `instance_name`: This is the name of the instance to be created
* `key_name`: This is the vpc ssh key. 

# To set up the disk for CI/CD, use:

```
ansible-playbook setup_disk.yml -vv -e "instance_name=zopen-ci5" -e "jenkins_public_key=\"$(cat ~/.ssh/id_rsa_jenkins.pub)\""
```

## Required variables:
* `instance_name`: This is the name of the instance to be created
* `jenkins_public_key`: This is the vpc ssh key. 
