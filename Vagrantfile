# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

auto = ENV['AUTO_START_SWARM'] || false
# Increase numworkers if you want more than 3 nodes
numworkers = 3

# VirtualBox settings
# Increase vmmemory if you want more than 512mb memory in the vm's
vmmemory = 2048
# Increase numcpu if you want more cpu's per vm
numcpu = 1

instances = []

(1..numworkers).each do |n| 
  instances.push({:name => "worker#{n}", :ip => "192.168.10.#{n+2}"})
end

manager_ip = "192.168.10.2"

File.open("./hosts", 'w') { |file| 
  instances.each do |i|
    file.write("#{i[:ip]} #{i[:name]} #{i[:name]}\n")
  end
}

Vagrant.configure("2") do |config|

    config.vm.provider "virtualbox" do |v|
    v.memory = vmmemory
  	v.cpus = numcpu
    end
    
    config.vm.define "manager" do |i|
      i.vm.box = "ubuntu/xenial64"
      i.vm.hostname = "manager"
	  i.vm.network "public_network", use_dhcp_assigned_default_route: true
      i.vm.network "private_network", ip: "#{manager_ip}"
      i.vm.network "forwarded_port", guest: 8080, host: 8080
	  i.vm.network "forwarded_port", guest: 9000, host: 9000
      
      i.vm.provision "shell", path: "./provision.sh"

      if File.file?("./hosts") 
        i.vm.provision "file", source: "hosts", destination: "/tmp/hosts"
        i.vm.provision "shell", inline: "cat /tmp/hosts >> /etc/hosts", privileged: true
      end 
      
      if File.file?("./daemon.json") 
        i.vm.provision "file", source: "daemon.json", destination: "/tmp/daemon.json"
        i.vm.provision "shell", inline: "cat /tmp/daemon.json >> /etc/docker/daemon.json", privileged: true
      end 
      
	  i.vm.provision "shell", inline: "docker swarm init --advertise-addr #{manager_ip}"
	  i.vm.provision "shell", inline: "docker swarm join-token -q worker > /vagrant/token"
	
       
	  if File.file?("./portainer-docker-compose.yml") 
        i.vm.provision "file", source: "portainer-docker-compose.yml", destination: "/tmp/portainer-docker-compose.yml"
		i.vm.provision "shell", inline: "docker volume create --name portainer-data", privileged: true
        i.vm.provision "shell", inline: "docker stack deploy --compose-file /tmp/portainer-docker-compose.yml portainer", privileged: true
      end 
  
      if File.file?("./jenkins-docker-compose.yml") 
        i.vm.provision "file", source: "jenkins-docker-compose.yml", destination: "/tmp/jenkins-docker-compose.yml"
		i.vm.provision "shell", inline: "docker volume create --name jenkins_home", privileged: true
        i.vm.provision "shell", inline: "docker stack deploy --compose-file /tmp/jenkins-docker-compose.yml jenkins", privileged: true
      end 
  	
	
    end 

  instances.each do |instance, i | 
    config.vm.define instance[:name] do |i|
      i.vm.box = "ubuntu/xenial64"
      i.vm.hostname = instance[:name]
      i.vm.network "private_network", ip: "#{instance[:ip]}"
      i.vm.provision "shell", path: "./provision.sh"
      if File.file?("./hosts") 
        i.vm.provision "file", source: "hosts", destination: "/tmp/hosts"
        i.vm.provision "shell", inline: "cat /tmp/hosts >> /etc/hosts", privileged: true
      end 
      
      if File.file?("./daemon.json") 
        i.vm.provision "file", source: "daemon.json", destination: "/tmp/daemon.json"
        i.vm.provision "shell", inline: "cat /tmp/daemon.json >> /etc/docker/daemon.json", privileged: true
      end 
	  
	  i.vm.provision "shell", inline: "mkdir -p /var/jenkins", privileged: true
	  i.vm.provision "shell", inline: "chmod -R 775  /var/jenkins/", privileged: true
	  i.vm.provision "shell", inline: "chown ubuntu:  /var/jenkins/", privileged: true
	  
      
      i.vm.provision "shell", inline: "docker swarm join --advertise-addr #{instance[:ip]} --listen-addr #{instance[:ip]}:2377 --token `cat /vagrant/token` #{manager_ip}:2377"
	  i.vm.provision "shell", inline: "docker node update --label-add node.role=worker"
	  i.vm.provision "shell", inline: "docker node update --label-add node.id=#{instance[:name]}"
    end 
  end
end