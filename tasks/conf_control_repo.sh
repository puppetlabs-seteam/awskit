#! /bin/bash
gogs_params() {
    cat <<EOF
{
  "title": "$PT_public_key_name",
  "key": "$PT_public_key_value"
}
EOF
}

control_repo=$PT_control_repo 
cd /tmp
echo git clone $PT_control_repo control-repo
git clone $PT_control_repo control-repo
cd control-repo
git remote add gogs git@localhost:puppet/control-repo.git
git push gogs production
if [ ! -z ${PT_public_key_name+x} ] && [ ! -z  ${PT_public_key_value+x} ] ; then
  url="http://localhost:3000/api/v1/user/keys"
  #echo curl -u puppet:puppetlabs -X POST -H "Content-Type: application/json" --data "$(gogs_params)" $url
  curl -u puppet:puppetlabs -X POST -H "Content-Type: application/json" --data "$(gogs_params)" $url
fi
cd /tmp
rm -rf control-repo