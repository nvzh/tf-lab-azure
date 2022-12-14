#!/bin/bash

# Sourcing config
. ./config.tfvars

azure_config() {

amiUserName="azureuser"
RG="$name-case$caseNo-rg"

if [ $msr_count -ne 0 ] && [ $msr_version_3 -ne 1 ]
  then
    ####### Generating Launchpad Metadata Configuration
    cat > launchpad.yaml << EOL
apiVersion: launchpad.mirantis.com/mke/v1.3
kind: mke+msr
metadata:
  name: launchpad-mke
spec:
  hosts:
EOL
    ####### Generating Manager Node Configuration
    if [[ $manager_count != 0 ]]
      then
        for count in $(seq $manager_count)
            do 
                index=`expr $count - 1` #because index_key starts with 0
                mgr_address="$name-$caseNo-manager-$index.$region.cloudapp.azure.com"
                cat >> launchpad.yaml << EOL
  - role: manager
    hooks:
      apply:
        before:
          - ls -al > test.txt
        after:
          - cat test.txt
    ssh:
      address: $mgr_address
      user: $amiUserName
      port: 22
      keyPath: /Users/nvzh/.ssh/id_rsa
    environment:
    mcrConfig:
      debug: true
      log-opts:
        max-size: 10m
        max-file: "3"
EOL
        done
    else
    ### For minimum 1 Manager 
      manager_count=1
      for count in $(seq $manager_count)
            do 
                index=`expr $count - 1` #because index_key starts with 0
                mgr_address="$name-$caseNo-manager-$index.$region.cloudapp.azure.com"
                cat >> launchpad.yaml << EOL
  - role: manager
    hooks:
      apply:
        before:
          - ls -al > test.txt
        after:
          - cat test.txt
    ssh:
      address: $mgr_address
      user: $amiUserName
      port: 22
      keyPath: /Users/nvzh/.ssh/id_rsa
    environment:
    mcrConfig:
      debug: true
      log-opts:
        max-size: 10m
        max-file: "3"
EOL
    done
    fi

    ####### Generating Worker Node Configuration
    if [[ $worker_count != 0 ]]
        then
            for count in $(seq $worker_count)
            do 
                index=`expr $count - 1` #because index_key starts with 0
                wkr_address="$name-$caseNo-worker-$index.$region.cloudapp.azure.com"
                cat >> launchpad.yaml << EOL
  - role: worker
    ssh:
      address: $wkr_address
      user: $amiUserName
      port: 22
      keyPath: /Users/nvzh/.ssh/id_rsa
EOL
            done
    fi
        ####### Generating Windows Worker Node Configuration
    if [[ $win_worker_count != 0 ]]
        then
            for count in $(seq $win_worker_count)
            do 
                index=`expr $count - 1` #because index_key starts with 0
                win_worker_address="$name-$caseNo-win-$index.$region.cloudapp.azure.com"
                mkeadminPassword=$(cat ./terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.id' 2>/dev/null)
                cat >> launchpad.yaml << EOL
  - role: worker
    winRM:
      address: $win_worker_address
      user: azureuser
      password: $mkeadminPassword
      port: 5986
      useHTTPS: true
      insecure: true
      useNTLM: false
EOL
            done
    fi
    ####### Generating MSR Node Configuration
    
    for count in $(seq $msr_count)
            do 
                index=`expr $count - 1` #because index_key starts with 0
                msr_address="$name-$caseNo-msr-$index.$region.cloudapp.azure.com"
                cat >> launchpad.yaml << EOL
  - role: msr
    ssh:
      address: $msr_address
      user: $amiUserName
      port: 22
      keyPath: /Users/nvzh/.ssh/id_rsa
EOL
    done

    ####### Generating MKE Configuration
    ### !!! NEED TO GET RID OF --force-minimums FLAG !!! ###
    mkeadminUsername=$(cat ./terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null)
    mkeadminPassword=$(cat ./terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.id' 2>/dev/null)                
    cat >> launchpad.yaml << EOL
  mke:
    version: $mke_version
    imageRepo: "$image_repo"
    adminUsername: $mkeadminUsername
    adminPassword: $mkeadminPassword
    installFlags:
    - --force-minimums
EOL

    ####### Generating MSR Configuration
    msr_address="$name-$caseNo-msr-$index.$region.cloudapp.azure.com"
    if [[ $nfs_backend == 0 ]] ; then
      cat >> launchpad.yaml << EOL
  msr:
    version: $msr_version
    imageRepo: "$image_repo"
    installFlags:
    - --dtr-external-url $msr_address
    - --ucp-insecure-tls
    replicaIDs: sequential
EOL
    else
      nfs_address="$name-$caseNo-nfs-0.$region.cloudapp.azure.com"
      cat >> launchpad.yaml << EOL
  msr:
    version: $msr_version
    imageRepo: "$image_repo"
    installFlags:
    - --dtr-external-url $msr_address
    - --ucp-insecure-tls
    - --nfs-storage-url nfs://$nfs_address/var/nfs/general
    replicaIDs: sequential
EOL
  fi
    ####### Generating MCR Configuration
    cat >> launchpad.yaml << EOL
  mcr:
    version: $mcr_version
    channel: stable
    repoURL: https://repos.mirantis.com
    installURLLinux: https://get.mirantis.com/
    installURLWindows: https://get.mirantis.com/install.ps1
  cluster:
    prune: true
EOL

else
    ####### Generating Launchpad Metadata Configuration
    cat > launchpad.yaml << EOL
apiVersion: launchpad.mirantis.com/mke/v1.3
kind: mke
metadata:
  name: launchpad-mke
spec:
  hosts:
EOL
    ####### Generating Manager Node Configuration
    for count in $(seq $manager_count)
        do 
            index=`expr $count - 1` #because index_key starts with 0
            mgr_address="$name-$caseNo-manager-$index.$region.cloudapp.azure.com"
            cat >> launchpad.yaml << EOL
  - role: manager
    hooks:
      apply:
        before:
          - ls -al > test.txt
        after:
          - cat test.txt
    ssh:
      address: $mgr_address
      user: $amiUserName
      port: 22
      keyPath: /Users/nvzh/.ssh/id_rsa
    environment:
    mcrConfig:
      debug: true
      log-opts:
        max-size: 10m
        max-file: "3"
EOL
    done


    ####### Generating Worker Node Configuration
    ### For MSRv3 nodes
    if [[ $msr_count != 0 ]] ; then
    for count in $(seq $msr_count)
      do 
          index=`expr $count - 1` #because index_key starts with 0
          msr_address="$name-$caseNo-msr-$index.$region.cloudapp.azure.com"
          cat >> launchpad.yaml << EOL
  - role: worker
    ssh:
      address: $msr_address
      user: $amiUserName
      port: 22
      keyPath: /Users/nvzh/.ssh/id_rsa
EOL
    done 
    fi
    if [[ $worker_count != 0 ]]
        then
            for count in $(seq $worker_count)
            do 
                index=`expr $count - 1` #because index_key starts with 0
                wkr_address="$name-$caseNo-worker-$index.$region.cloudapp.azure.com"
                cat >> launchpad.yaml << EOL
  - role: worker
    ssh:
      address: $wkr_address
      user: $amiUserName
      port: 22
      keyPath: /Users/nvzh/.ssh/id_rsa
EOL
            done
    fi
        ####### Generating Windows Worker Node Configuration
    if [[ $win_worker_count != 0 ]]
        then
            for count in $(seq $win_worker_count)
            do 
                index=`expr $count - 1` #because index_key starts with 0
                win_worker_address="$name-$caseNo-win-$index.$region.cloudapp.azure.com"
                mkeadminPassword=$(cat ./terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.id' 2>/dev/null)
                cat >> launchpad.yaml << EOL
  - role: worker
    winRM:
      address: $win_worker_address
      user: azureuser
      password: $mkeadminPassword
      port: 5986
      useHTTPS: true
      insecure: true
      useNTLM: false
EOL
            done
    fi
    ####### Generating MKE Configuration
    mkeadminUsername=$(cat ./terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_username") | .instances[] | .attributes.id' 2>/dev/null)
    mkeadminPassword=$(cat ./terraform.tfstate 2>/dev/null | jq -r '.resources[] | select(.name=="mke_password") | .instances[] | .attributes.id' 2>/dev/null)                
    cat >> launchpad.yaml << EOL
  mke:
    version: $mke_version
    imageRepo: "$image_repo"
    adminUsername: $mkeadminUsername
    adminPassword: $mkeadminPassword
    installFlags:
    - --force-minimums
EOL

    ####### Generating MCR Configuration
    cat >> launchpad.yaml << EOL
  mcr:
    version: $mcr_version
    channel: stable
    repoURL: https://repos.mirantis.com
    installURLLinux: https://get.mirantis.com/
    installURLWindows: https://get.mirantis.com/install.ps1
  cluster:
    prune: true
EOL

fi

}


if [[ "$cloud_provider" == "aws" ]]; then
  aws_config
elif [[ "$cloud_provider" == "azure" ]]; then
  azure_config
else
  echo "Wrong provider. Please edit the 'provider' value in the /terraTrain/config file"
fi
