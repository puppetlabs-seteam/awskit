# awskit P4C

## Meltdown module


### downgrade kernel

wget http://rpmfind.net/linux/centos/7.4.1708/updates/x86_64/Packages/kernel-3.10.0-693.2.2.el7.x86_64.rpm
yum localinstall kernel-3.10.0-693.2.2.el7.x86_64.rpm
reboot

to change back after upgrading:

grub2-set-default x (x being the old kernel, see /boot/grub2/grub2.cfg)
grub2-mkconfig -o /boot/grub2/grub.cfg


### tasks
run a task  using a query:

inventory[certname] {facts.meltdown.CVE-2017-5754.vulnerable = true}

command line on master:

puppet query 'inventory[certname] {facts.meltdown.CVE-2017-5754.vulnerable = true}'

### cloud

- show centos7a role assignment and website working
- show puppet code - create-demo-host
- run puppet apply create-demo-host.pp
- show creation in AWS

## Pipelines for Containers

- create project webapp
- add containers
- connect source control
- use github
- repo: puppet_webapp
- container name: webapp
- docker registry provider: dockerhub
- docker repo: dimitri-puppet-webapp
- add container
- close

- edit container properties (right)
- build on my own hardware, capablities: docker

- build container
- select container=webapp
- select branch=docker
- press Build
- press View Build
- when build complete, click application 'webapp.webapp' and show timeline

- show kubernetes clusters (clusters)
- create new cluster, select parameters, click create
- continue with existing cluster
- sync clusters (p-p, Selected Projects, Close)
- click on cluster p-p  
- select namespace webapp (top right) and show various things in cluster
- introduce kubectl
  - kubectl get nodes -o wide
  - kubectl get namespaces -o wide
  - kubectl get pods -o wide
  - kubectl get deploy -o wide
  - kubectl get svc -o wide

- go back to projects / webapp
- click deploy
- cluster: p-p, deployment: webapp, namespace: webapp, description: webapp
- add container: webapp, image: latest, configure port: webport, 8080/8080, save port mapping
- chose 2 replicas in configuration
- show volumes, we don't need any
- show yaml
- click deploy
- click here to view deployment results (top)
- do 'kubectl get deploy -o wide' to show results

- q: can we use the app?
- a: no, the pods are not accessible from the outside, we need a service
- go to projects, webapp, services
- select puppet-pipelines, create new service
- load default service spec
- add namespace: webapp to metadata
- do 'kubectl get svc -o wide' - nothing yet
- click create service
- do 'kubectl get svc -o wide' again - svc is there, but no external ip. Describe what we see.
- repeat command until external IP is visible
- open browser and test

- now we want to change our app and have it deployed automatically. We need to create a ... pipeline
- go to projects/webapp, create pipeline webapp
- add container webapp, docker branch
- add stage to namespace webapp
- click 'autopromote on image event' and explain
- now change _version.py to 'awskit London'
- commit and push
- look at the pipeline screen
- when ready, reload browser

optionally: show the rsvp project


