# Automated Provisioning Project
This Project is to Automate Provisioning of MySQL, Memcache, RabbitMQ, Tomcat and NGNIX as a Stack from a Single Vagrantfile 

## Prerequisite
-  Oracle VM Virtualbox
-  Vagrant
-  Vagrant plugin in Vagrant
   ```sh
   vagrant plugin install vagrant-hostmanager
   ```
- Git Bash<br>


 #### <ins> *Note*</ins>  : <br>
> All the VM’s hostname and /etc/hosts file entries will be automatically updated.
>   ```sh
>   cat /etc/hosts
>   ```
>   Vagrant commands will impact on the entire stack if not specified with a hostname.
>   <br> `vagrant up` `vagrant halt` `vagrant reload` `vagrant destroy`
>  <br> <br>To use Vagrant commands on a specific VM use its hostname specified with the command.
>   <br> `vagrant up app01` `vagrant halt db01` `vagrant reload mc01` `vagrant destroy rmq01`
>   
