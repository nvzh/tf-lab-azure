name="onovozhylov"

# Cloud Provide Info (aws or azure):
cloud_provider="azure"

# azure: germanywestcentral, uksouth, etc.
region="germanywestcentral"             
caseNo="kubeadm"                    # optional tag to identify resources

# Platform Info
#|------------------------------------------------------------------------------------------------------------|
#| cloud_provider | os_name                      | os_version                                                 |
#|------------------------------------------------------------------------------------------------------------|
#| aws            | ubuntu                       | 20.04, 18.04                                               |
#|                | redhat                       | 8.4, 8.3, 8.2, 8.1, 7.9                                    |
#|                | centos                       | 7.9, 7.8                                                   |
#|                | suse(?)                      | 15SP3, 15SP2, 15SP1, 12SP5 (?)                             |
#|------------------------------------------------------------------------------------------------------------|
#| azure          | UbuntuServer                 | 18.04-LTS                                                  |
#|                | 0001-com-ubuntu-server-focal | 20_04-lts-gen2                                             |
#|                | RHEL                         | 79-gen2, 81gen2, 82gen2, 83-gen2, 84-gen2, 85-gen2, 86-gen2|
#|                | CentOS                       | 7_8-gen2, 7_9-gen2                                         |
#|------------------------------------------------------------------------------------------------------------|
os_name="RHEL"                   
os_version="84-gen2"

mcr_version="20.10.13"              # Please use specific minor engine version.

# MKE Info
manager_count="3"                 # Number of Managers
mke_version="3.5.4"                # MKE Version

# MSR Info
msr_count="3"                      # Number of MSR replicas
msr_version="2.9.9"                # For MSR Classic: 2.8.8, 2.9.7 etc. For MSRv3 choose the helm chart version 1.0.0,1.0.1 etc.
nfs_backend="1"                    # "1" for true and "0" for false, BUT: always put "1" for MSRv3, because we must have NFS for MSR3
msr_version_3="0"                  # Put 1 for MSR version 3

# Worker Info
worker_count="2"
win_worker_count="2"

image_repo="docker.io/mirantis"    #For other repos. E.g, docker.io/mirantiseng