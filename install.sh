#!/usr/bin/env bash
usage()
{
cat <<EOEG

Usage: $0 

    --license-password <License server admin user password. Note: Please use at least one special symbol and numeric value> Supported special symbols are: [!@#$%]

Required only with OIDC:
    --oidc <Enable OIDC for PX-Central components>
    --oidc-clientid <External OIDC client-id>
    --oidc-secret <External OIDC secret>
    --oidc-endpoint <External OIDC endpoint>
    --admin-user <PX-Central OIDC admin username>
    --admin-password <PX-Central OIDC admin user password>
    --admin-email <PX-Central OIDC admin user email address>

Required only for cloud deployments:
    --cloud <Mandatory for cloud deployment. Note: Currently supported K8s managed services: EKS, GKE and AKS, Custom k8s clusters on AWS, GCP and Azure>
    --cloudstorage <Provide if you want portworx to provision required disks>
    --aws-access-key <AWS access key required to provision disks>
    --aws-secret-key <AWS secret key required to provision disks>
    --disk-type <Optional: Data disk type>
    --disk-size <Optional: Data disk size>
    --azure-client-secret <Azure client secret>
    --azure-client-id <Azure client ID>
    --azure-tenant-id <Azure tenant id>
    --managed <Managed k8s service cluster type>
    --portworx-disk-provision-secret-name <Secret name which has disk provision required credentials>

Optional:
    --cluster-name <PX-Central Cluster Name>
    --kubeconfig <Kubeconfig file>
    --custom-registry <Custom image registry path>
    --image-repo-name <Image repo name>
    --air-gapped <Specify for airgapped environment>
    --image-pull-secret <Image pull secret for custom registry>
    --pxcentral-endpoint <Any one of the master or worker node IP of current k8s cluster>
    --openshift <Provide if deploying PX-Central on openshift platform>
    --mini <PX-Central deployment on mini clusters Minikube|K3s|Microk8s>
    --all <Install all the components of PX-Central stack>
    --px-store <Install Portworx>
    --px-backup <Install PX-Backup>
    --px-metrics-store <Install PX-Metrics store and dashboard view>
    --px-license-server <Install PX-Floating License Server>
    --px-backup-organization <Organization ID for PX-Backup>
    --oidc-user-access-token <Provide OIDC user access token required while adding cluster into backup>
    --pxcentral-namespace <Namespace to deploy PX-Central-Onprem cluster>
    --pks <PX-Central-Onprem deployment on PKS>
    --vsphere-vcenter-endpoint <Vsphere vcenter endpoint>
    --vsphere-vcenter-port <Vsphere vcenter port>
    --vsphere-vcenter-datastore-prefix <Vsphere vcenter datastore prefix>
    --vsphere-vcenter-install-mode <Vsphere vcenter install mode>
    --vsphere-user <Vsphere vcenter user>
    --vsphere-password <Vsphere vcenter password>
    --vsphere-insecure <Vsphere vcenter endpoint insecure>
    --domain <Domain to deploy and expose PX-Central services>
    --ingress-controller <Provision ingress controller>
    --proxy-forwarding <Enable proxy forwarding for pay as you go model>
    --log-location <Script logs path like: /opt/install.log>

Examples:
    # Deploy PX-Central without OIDC:
    ./install.sh --license-password 'Adm1n!Ur'

    # Deploy PX-Central with OIDC:
    ./install.sh --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y --license-password 'Adm1n!Ur'

    # Deploy PX-Central without OIDC with user input kubeconfig:
    ./install.sh --license-password 'Adm1n!Ur' --kubeconfig /tmp/test.yaml

    # Deploy PX-Central with OIDC, custom registry with user input kubeconfig:
    ./install.sh  --license-password 'Adm1n!Ur' --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b  --oidc-endpoint X.X.X.X:Y --custom-registry xyz.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret --kubeconfig /tmp/test.yaml

    # Deploy PX-Central with custom registry:
    ./install.sh  --license-password 'Adm1n!Ur' --custom-registry xyz.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret

    # Deploy PX-Central with custom registry with user input kubeconfig:
    ./install.sh  --license-password 'Adm1n!Ur' --custom-registry xyz.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret --kubeconfig /tmp/test.yaml

    # Deploy PX-Central on openshift on onprem
    ./install.sh  --license-password 'Adm1n!Ur' --openshift 

    # Deploy PX-Central on openshift on cloud
    ./install.sh  --license-password 'Adm1n!Ur' --openshift --cloud <aws|gcp|azure> --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on cloud with external public IP
    ./install.sh --license-password 'Adm1n!Ur' --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on air-gapped environment
    ./install.sh  --license-password 'Adm1n!Ur' --air-gapped --custom-registry test.ecr.us-east-1.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret

    # Deploy PX-Central on air-gapped environment with oidc
    ./install.sh  --license-password 'Adm1n!Ur' --oidc-clientid test --oidc-secret 87348ca3d-1a73-907db-b2a6-87356538  --oidc-endpoint X.X.X.X:Y --custom-registry test.ecr.us-east-1.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret

    # Deploy PX-Central on aws without auto disk provision
    ./install.sh  --license-password 'Adm1n!Ur' --cloud aws --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on aws with auto disk provision
    ./install.sh  --license-password 'Adm1n!Ur' --cloud aws --pxcentral-endpoint X.X.X.X --cloudstorage --aws-access-key <AWS_ACCESS_KEY_ID> --aws-secret-key <AWS_SECRET_ACCESS_KEY>

    # Deploy PX-Central on aws with auto disk provision with different disk type and disk size
    ./install.sh  --license-password 'Adm1n!Ur' --cloud aws --disk-type gp2 --disk-size 200 --pxcentral-endpoint X.X.X.X --cloudstorage --aws-access-key <AWS_ACCESS_KEY_ID> --aws-secret-key <AWS_SECRET_ACCESS_KEY>

    # Deploy PX-Central on gcp without auto disk provision
    ./install.sh  --license-password 'Adm1n!Ur' --cloud gcp --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on gcp with auto disk provision
    ./install.sh  --license-password 'Adm1n!Ur' --cloud gcp --pxcentral-endpoint X.X.X.X --cloudstorage

    # Deploy PX-Central on gcp with auto disk provision with different disk type and disk size
    ./install.sh  --license-password 'Adm1n!Ur' --cloud gcp --pxcentral-endpoint X.X.X.X --cloudstorage --disk-type pd-standard --disk-size 200

    # Deploy PX-Central on azure without auto disk provision
    ./install.sh  --license-password 'Adm1n!Ur' --cloud azure --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on azure with auto disk provision
    ./install.sh  --license-password 'Adm1n!Ur' --cloud azure --pxcentral-endpoint X.X.X.X --cloudstorage --azure-client-secret <AZURE_CLIENT_SECRET> --azure-client-id <AZURE_CLIENT_ID> --azure-tenant-id <AZURE_TENANT_ID>

    # Deploy PX-Central on azure with auto disk provision with different disk type and disk size
    ./install.sh  --license-password 'Adm1n!Ur' --cloud azure --pxcentral-endpoint X.X.X.X --cloudstorage --azure-client-secret <AZURE_CLIENT_SECRET> --azure-client-id <AZURE_CLIENT_ID> --azure-tenant-id <AZURE_TENANT_ID> --disk-type Standard_LRS --disk-size 200

    # Deploy PX-Central-Onprem with existing disks on EKS
    ./install.sh  --license-password 'Adm1n!Ur' --cloud aws --managed --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central-Onprem with auto disk provision on EKS
    ./install.sh  --license-password 'Adm1n!Ur' --cloud aws --managed --disk-type gp2 --disk-size 200 --pxcentral-endpoint X.X.X.X --cloudstorage --aws-access-key <AWS_ACCESS_KEY_ID> --aws-secret-key <AWS_SECRET_ACCESS_KEY>

    # Deploy PX-Central-Onprem with existing disks on GKE
    ./install.sh  --license-password 'Adm1n!Ur' --cloud gcp --managed --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central-Onprem with auto disk provision on GKE
    ./install.sh  --license-password 'Adm1n!Ur' --cloud gcp --managed --pxcentral-endpoint X.X.X.X --cloudstorage

    # Deploy PX-Central-Onprem with existing disks on AKS
    ./install.sh  --license-password 'Adm1n!Ur' --cloud azure --managed  --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central-Onprem with auto disk provision on AKS
    ./install.sh  --license-password 'Adm1n!Ur' --cloud azure --managed --pxcentral-endpoint X.X.X.X --cloudstorage --azure-client-secret <AZURE_CLIENT_SECRET> --azure-client-id <AZURE_CLIENT_ID> --azure-tenant-id <AZURE_TENANT_ID>

    # Deploy PX-Central on mini k8s cluster
    ./install.sh --mini

    # Deploy PX-Central on mini k8s cluster with external OIDC
    ./install.sh --mini --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y

    # Deploy PX-Central on mini k8s cluster with PX-Central OIDC
    ./install.sh --mini --oidc --admin-user pxadmin --admin-password Password2 --admin-email  pxadmin@portworx.com

    # Deploy PX-Central with selected components
    ./install.sh --px-store --px-metrics-store --px-backup --px-license-server --license-password 'Adm1n!Ur'

    # Deploy PX-Central on PKS on vsphere cloud with existing disks for Portworx
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --pks --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on openshift on vsphere cloud with existing disks for Portworx
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --openshift --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on PKS on vsphere cloud with existing disks for Portworx with central OIDC
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --pks --oidc --admin-user pxadmin --admin-password Password2 --admin-email  pxadmin@portworx.com --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on PKS on vsphere cloud with existing disks for Portworx with external OIDC
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --pks --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on PKS on vsphere cloud with auto disk provision option
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --pks --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on PKS on vsphere cloud with central OIDC with auto disk provision option
    ./install.sh --license-password 'Adm1n!Ur' --oidc --admin-user pxadmin --admin-password Password2 --admin-email  pxadmin@portworx.com --cloud vsphere --pks --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on PKS on vsphere cloud with external OIDC with auto disk provision option
    ./install.sh --license-password 'Adm1n!Ur' --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y --cloud vsphere --pks --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on openshift on vsphere cloud with auto disk provision option
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --openshift --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on openshift on vsphere cloud with central OIDC with auto disk provision option
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --openshift --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --oidc --admin-user pxadmin --admin-password Password2 --admin-email  pxadmin@portworx.com 

    # Deploy PX-Central on openshift on vsphere cloud with external OIDC with auto disk provision option
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --openshift --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y  --pxcentral-endpoint X.X.X.X

EOEG
exit 1
}

while [ "$1" != "" ]; do
    case $1 in
    --cluster-name)   shift
                      PXCPXNAME=$1
                      ;;
    --admin-user)     shift
                      ADMINUSER=$1
                      ;;
    --admin-password) shift
                      ADMINPASSWORD=$1
                      ;;
    --admin-email)    shift
                      ADMINEMAIL=$1
                      ;;
    --oidc-clientid)  shift
                      EXTERNAL_OIDCCLIENTID=$1
                      ;;
    --oidc-secret)    shift
                      EXTERNAL_OIDCSECRET=$1
                      ;;
    --oidc-endpoint)  shift
                      EXTERNAL_OIDCENDPOINT=$1
                      ;;
    --license-password) shift
                        LICENSEADMINPASSWORD=$1
                        ;;
    --kubeconfig)     shift
                      KC=$1
                      ;;
    --custom-registry)    shift
                          CUSTOMREGISTRY=$1
                          ;;
    --image-pull-secret)  shift
                          IMAGEPULLSECRET=$1
                          ;;
    --image-repo-name)    shift
                          IMAGEREPONAME=$1
                          ;;
    --pxcentral-endpoint) shift
                          PXCINPUTENDPOINT=$1
                          ;;
    --oidc)
                          PXCOIDCREQUIRED="true"
                          ;;
    --air-gapped)
                          AIRGAPPED="true"
                          ;;
    --openshift)
                          OPENSHIFTCLUSTER="true"
                          ;;
    --cloudstorage)
                          CLOUDSTRORAGE="true"
                          ;;
    --cloud)              shift
                          CLOUDPLATFORM=$1
                          ;;
    --aws-access-key)     shift
                          AWS_ACCESS_KEY_ID=$1
                          ;;
    --aws-secret-key)     shift
                          AWS_SECRET_ACCESS_KEY=$1
                          ;;
    --disk-type)          shift
                          CLOUD_DATA_DISK_TYPE=$1
                          ;;
    --disk-size)          shift
                          CLOUD_DATA_DISK_SIZE=$1
                          ;;
    --azure-client-secret)    shift
                              AZURE_CLIENT_SECRET=$1
                              ;;
    --azure-client-id)        shift
                              AZURE_CLIENT_ID=$1
                              ;;
    --azure-tenant-id)        shift
                              AZURE_TENANT_ID=$1
                              ;;
    --managed)
                              MANAGED_K8S_SERVICE="true"
                              ;;
    --all)
                              PXCENTRAL_INSTALL_ALL_COMPONENTS="true"
                              ;;
    --px-store)
                              PX_STORE="true"
                              ;;
    --px-backup)
                              PX_BACKUP="true"
                              ;;
    --px-metrics-store)
                              PX_METRICS="true"
                              ;;
    --px-license-server)
                              PX_LICENSE_SERVER="true"
                              ;;
    --mini)
                              PXCENTRAL_MINIK8S="true"
                              ;;
    --px-backup-organization) shift
                              PX_BACKUP_ORGANIZATION=$1
                              ;;
    --oidc-user-access-token) shift
                              OIDC_USER_ACCESS_TOKEN=$1
                              ;;
    --pxcentral-namespace)    shift
                              PXCNAMESPACE=$1
                              ;;
    --pks)
                                        PKS_CLUSTER="true"
                                        ;;
    --vsphere-insecure)                 VSPHERE_INSECURE="true"
                                        ;;
    --vsphere-vcenter-endpoint)         shift
                                        VSPHERE_VCENTER=$1
                                        ;;
    --vsphere-vcenter-port)             shift
                                        VSPHERE_VCENTER_PORT=$1
                                        ;;
    --vsphere-vcenter-datastore-prefix) shift
                                        VSPHERE_DATASTORE_PREFIX=$1
                                        ;;
    --vsphere-vcenter-install-mode)     shift
                                        VSPHERE_INSTALL_MODE=$1
                                        ;;
    --vsphere-user)                     shift
                                        VSPHERE_USER=$1
                                        ;;
    --vsphere-password)                 shift
                                        VSPHERE_PASSWORD=$1
                                        ;;
    --domain)                           shift
                                        DOMAIN=$1
                                        ;;
    --ingress-controller)                   INGRESS_CONTROLLER_PROVISION="true"
                                            ;;
    --re-configure)                         RE_DEPLOY_ON_SAME_CLUSTER="true"
                                            ;;
    --portworx-disk-provision-secret-name)  shift 
                                            PX_DISK_PROVISION_SECRET_NAME=$1
                                            ;;
    --proxy-forwarding)                     ENABLE_PROXY_FORWARDING="true"
                                            ;;
    --proxy-forwarding-uat)                 ENABLE_PROXY_FORWARDING_FOR_UAT="true"
                                            ;;
    --log-location)                         shift
                                            PXCENTRAL_INSTALL_SCRIPT_LOG_LOCATION=$1
                                            ;;
    -h | --help )   usage
                    ;;
    * )             usage
    esac
    shift
done

TIMEOUT=1800
SLEEPINTERVAL=2
LBSERVICETIMEOUT=300
PXCNAMESPACE_DEFAULT="portworx"

UATLICENCETYPE="false"
AIRGAPPEDLICENSETYPE="false"
ISOPENSHIFTCLUSTER="false"
OPERATOR_UNSUPPORTED_CLUSTER="false"
ISCLOUDDEPLOYMENT="false"
PXCPROVISIONEDOIDC="false"
CLOUDSTORAGEENABLED="false"
AWS_CLOUD_PLATFORM="false"
AZURE_CLOUD_PLATFORM="false"
GOOGLE_CLOUD_PLATFORM="false"
IBM_CLOUD_PLATFORM="false"

EKS_CLUSTER_TYPE="false"
GKE_CLUSTER_TYPE="false"
AKS_CLUSTER_TYPE="false"

AWS_DISK_TYPE="gp2"
GCP_DISK_TYPE="pd-standard"
AZURE_DISK_TYPE="Premium_LRS"
DEFAULT_DISK_SIZE="150"

PXENDPOINT=""
maxRetry=5

ONPREMOPERATORIMAGE="portworx/pxcentral-onprem-operator:1.0.3"
PXCENTRALAPISERVER="portworx/pxcentral-onprem-api:1.0.3"
PXOPERATORIMAGE="portworx/px-operator:1.3.1"
PXCPRESETUPIMAGE="portworx/pxcentral-onprem-pre-setup:1.0.1"
PXDEVIMAGE="portworx/px-dev:2.5.0"
STORK_IMAGE="openstorage/stork:2.4.0"
PXCLSLABELSETIMAGE="pwxbuild/pxc-macaddress-config:1.0.1"
PXBACKUPIMAGE="portworx/px-backup:1.0.1"
PX_CENTRAL_FRONTEND="portworx/pxcentral-onprem-ui-frontend:1.1.1"
PX_CENTRAL_BACKEND="portworx/pxcentral-onprem-ui-backend:1.1.1"
PX_CENTRAL_MIDDLEWARE="portworx/pxcentral-onprem-ui-lhbackend:1.1.1"
PXC_PROXY_FORWARDING_IMAGE="pwxbuild/px-forwarding-proxy:1.0.0"
IMAGEPULLPOLICY="Always"
INGRESS_CHANGE_REQUIRED="false"
PX_BACKUP_ORGANIZATION_DEFAULT="portworx"
PXC_OIDC_CLIENT_ID="pxcentral"
KEYCLOAK_BACKEND_SECRET="pxc-keycloak-postgresql"
KEYCLOAK_BACKEND_PASSWORD="keycloak"
KEYCLOAK_FRONTEND_SECRET="pxc-keycloak-http"
KEYCLOAK_FRONTEND_PASSWORD="Password1"
KEYCLOAK_FRONTEND_USERNAME="pxadmin"
PXC_MODULES_CONFIG="pxc-modules"
PX_SECRET_NAMESPACE="portworx"
PX_BACKUP_SERVICE_ACCOUNT="px-backup-account"
PX_KEYCLOAK_SERVICE_ACCOUNT="px-keycloak-account"
PXC_PX_SERVICE_ACCOUNT="px-account"
PXC_PROMETHEUS_SERVICE_ACCOUNT="px-prometheus-operator"
PXC_OPERATOR_SERVICE_ACCOUNT="pxcentral-onprem-operator"
CLOUD_SECRET_NAME="px-disk-provision-secret"
PXC_INGRESS_CONTROLLER_SERVICE_ACCOUNT="pxc-nginx-ingress-serviceaccount"
PXC_LICENSE_SERVER_SERVICE_ACCOUNT="pxc-lsc-service-account"
PXC_PVC_CONTROLLER_SERVICE_ACCOUNT="portworx-pvc-controller-account"
DOMAIN_SETUP_REQUIRED="false"
PUBLIC_ENDPOINT_SETUP_REQUIRED="true"
INGRESS_SETUP_REQUIRED="false"
INGRESS_ENDPOINT=""
BACKUP_OIDC_SECRET_NAME="pxc-backup-secret"
PX_BACKUP_NAMESPACE="px-backup"
BACKUP_OIDC_ADMIN_SECRET_NAME="px-backup-admin-secret"
OIDCENABLED="false"
PROXY_DEPLOY_URL="rest.zuora.com"
DEFAULT_PROXY_FORWARDING="false"
PX_STORE_DEPLOY="false"
PX_METRICS_DEPLOY="false"
PX_BACKUP_DEPLOY="false"
PX_ETCD_DEPLOY="false"
PX_LICENSE_SERVER_DEPLOY="false"
PX_LOGS_DEPLOY="false"
PX_LIGHTHOUSE_DEPLOY="true"
PX_SINGLE_ETCD_DEPLOY="false"

PXC_UI_EXTERNAL_PORT="31234"
PXC_LIGHTHOUSE_HTTP_PORT="31235"
PXC_LIGHTHOUSE_HTTPS_PORT="31236"
PXC_ETCD_EXTERNAL_CLIENT_PORT="31237"
PXC_METRICS_STORE_PORT="31240"
PXC_KEYCLOAK_HTTP_PORT="31241"
PXC_KEYCLOAK_HTTPS_PORT="31242"
PXCENTRAL_INSTALL_ALL_COMPONENTS="true"
OIDC_USER_AUTH_TOKEN_EXPIARY_DURATION="10d"
EXTERNAL_OIDC_ENABLED="false"
VSPHERE_CLUSTER="false"
VSPHERE_CLUSTER_DISK_PROVISION_REQUIRED="false"
VSPHERE_PROVIDER="vsphere"

PKS_CLUSTER_ENABLED="false"
PX_DISK_TYPE_DEFAULT="zeroedthick"
PX_DISK_SIZE_DEFAULT="150"
PKS_DISK_PROVISIONED_REQUIRED="false"
OCP_DISK_PROVISIONED_REQUIRED="false"

NODE_AFFINITY_KEY="pxc/enabled"
NODE_AFFINITY_VALUE="false"
STORK_SCHEDULER_REQUIRED="true"
STANDARD_NAMESPACE="kube-system"
CENTRAL_DEPLOYED_PX="false"
CLOUD_STORAGE_ENABLED="false"

if [ ${PXCENTRAL_INSTALL_SCRIPT_LOG_LOCATION} ]; then
  LOGFILE="$PXCENTRAL_INSTALL_SCRIPT_LOG_LOCATION"
else
  LOGFILE="/tmp/pxcentral-onprem-install.log"
fi
logInfo() {
    echo "$(date): level=info msg=$@" >> "$LOGFILE"
}
logDebug() {
    echo "$(date): level=debug msg=$@" >> "$LOGFILE"
}
logError() {
    echo "$(date): level=error msg=$@" >> "$LOGFILE"
}
logWarning() {
    echo "$(date): level=warning msg=$@" >> "$LOGFILE"
}

start_time=`date +%s`
logInfo "+================================================+"
logInfo "===========PX-Central-Onprem Installation Started============"
echo ""
echo "Install script logs will be available here: $LOGFILE"
if [[ ${PXCENTRAL_MINIK8S} && "$PXCENTRAL_MINIK8S" == "true" ]]; then
  PX_BACKUP_DEPLOY="true"
  PX_SINGLE_ETCD_DEPLOY="true"
  PXCENTRAL_INSTALL_ALL_COMPONENTS="false"
  STORK_SCHEDULER_REQUIRED="false"
fi
logInfo "Minik8s : $PXCENTRAL_MINIK8S, All components flag: $PXCENTRAL_INSTALL_ALL_COMPONENTS"
if [[ "$PXCENTRAL_MINIK8S" == "true" && "$PXCENTRAL_INSTALL_ALL_COMPONENTS" == "true" ]]; then
  echo ""
  echo "ERROR: --mini and --all cannot be given together."
  logError "--mini and --all cannot be given together."
  echo ""
  usage
fi
logInfo "PX Cluster: $PX_STORE, PX Backup: $PX_BACKUP, PX Metrics Store: $PX_METRICS, Floating License Server: $PX_LICENSE_SERVER"
if [[ ${PX_STORE} || ${PX_BACKUP} || ${PX_METRICS} || ${PX_LICENSE_SERVER} ]]; then
  PXCENTRAL_INSTALL_ALL_COMPONENTS="false"
  if [ -z ${PXCENTRAL_MINIK8S} ]; then
    PXCENTRAL_MINIK8S="false"
  fi
fi

if [ "$PXCENTRAL_INSTALL_ALL_COMPONENTS" == "true" ]; then
  PX_STORE_DEPLOY="true"
  PX_METRICS_DEPLOY="true"
  PX_BACKUP_DEPLOY="true"
  PX_ETCD_DEPLOY="true"
  PX_LICENSE_SERVER_DEPLOY="true"
  CENTRAL_DEPLOYED_PX="true"
fi

if [ -z ${PXCNAMESPACE} ]; then
  PXCNAMESPACE=$PXCNAMESPACE_DEFAULT
fi
if [ -z ${ENABLE_PROXY_FORWARDING} ]; then
  ENABLE_PROXY_FORWARDING=$DEFAULT_PROXY_FORWARDING
  logInfo "Proxy forwarding enabled: $ENABLE_PROXY_FORWARDING"
fi
if [[ ${ENABLE_PROXY_FORWARDING_FOR_UAT} && "$ENABLE_PROXY_FORWARDING_FOR_UAT" == "true" ]]; then
  PROXY_DEPLOY_URL="rest.apisandbox.zuora.com"
fi
logInfo "Proxy Endpoint: $PROXY_DEPLOY_URL"
logInfo "PX-Central Namespace: $PXCNAMESPACE"
if [ ${PX_STORE} ]; then
  PX_STORE_DEPLOY="true"
  CENTRAL_DEPLOYED_PX="true"
fi
if [ ${PX_BACKUP} ]; then
  PX_BACKUP_DEPLOY="true"
  PX_ETCD_DEPLOY="true"
fi
if [ ${PX_METRICS} ]; then
  PX_METRICS_DEPLOY="true"
fi
if [ ${PX_LICENSE_SERVER} ]; then
  PX_LICENSE_SERVER_DEPLOY="true"
fi
logInfo "PX Deploy: $PX_STORE_DEPLOY, PX Metrics store: $PX_METRICS_DEPLOY, PX Backup deploy: $PX_BACKUP_DEPLOY, PX Etcd deploy: $PX_ETCD_DEPLOY, License server: $PX_LICENSE_SERVER_DEPLOY, Central PX: $CENTRAL_DEPLOYED_PX"
if [[ "$PXCENTRAL_MINIK8S" == "true" && ( "$PX_STORE_DEPLOY" == "true" || "$PX_LICENSE_SERVER_DEPLOY" == "true" || "$PX_METRICS_DEPLOY" == "true" ) ]]; then
  echo ""
  echo "ERROR: On mini k8s cluster px-store and license server cannot be deployed."
  logError "On mini k8s cluster px-store and license server cannot be deployed."
  echo ""
  usage
fi

checkKubectlCLI=`which kubectl`
if [[ ${OPENSHIFTCLUSTER} && "$OPENSHIFTCLUSTER" == "true" ]]; then
  checkOC=`which oc`
  if [ -z ${checkOC} ]; then
    echo ""
    echo "ERROR: install script requires 'oc' client utility present on the local machine else run install script from openshift master node."
    logError "Install script requires 'oc' client utility present on the local machine else run install script from openshift master node."
    echo ""
    exit 1
  fi
elif [ -z ${checkKubectlCLI} ]; then
  echo ""
  echo "ERROR: install script requires 'kubectl' client utility present on the instance where it runs."
  logError "Install script requires 'kubectl' client utility present on the instance where it runs."
  echo ""
  exit 1
fi

checkPythonCLI=`which python 2>&1`
checkPython3CLI=`which python3 2>&1`
cmdPython=""
if [[ -z ${checkPythonCLI} || -z ${checkPython3CLI} ]]; then
  echo ""
  echo "ERROR: install script requires 'python' or 'python3' present on the instance where install script will run."
  logError "Install script requires 'python' or 'python3' present on the instance where install script will run."
  echo ""
  exit 1
else
  if [ ${checkPythonCLI} ]; then
    logInfo "Python CLI : $checkPythonCLI"
    cmdPython=$checkPythonCLI
  else
    logInfo "Python3 CLI : $checkPython3CLI"
    cmdPython=$checkPython3CLI
  fi
fi
logInfo "Python executable path: $cmdPython"
echo ""
export dotCount=0
export maxDots=15
function showMessage() {
	msg=$1
	dc=$dotCount
	if [ $dc = 0 ]; then
		i=0
		len=${#msg}
		len=$[$len+$maxDots]	
		b=""
		while [ $i -ne $len ]
		do
			b="$b "
			i=$[$i+1]
		done
		echo -e -n "\r$b"
		dc=1
	else 
		msg="$msg"
		i=0
		while [ $i -ne $dc ]
		do
			msg="$msg."
			i=$[$i+1]
		done
		dc=$[$dc+1]
		if [ $dc = $maxDots ]; then
			dc=0
		fi
	fi
	export dotCount=$dc
	echo -e -n "\r$msg"
}

if [ "${LICENSEADMINPASSWORD}" ]; then
  PX_LICENSE_SERVER_DEPLOY="true"
fi

if [ "$PX_LICENSE_SERVER_DEPLOY" == "true" ]; then
  if [ -z ${LICENSEADMINPASSWORD} ]; then
    echo "ERROR : License server admin password is required"
    logError "License server admin password is required"
    echo ""
    usage
    exit 1
  fi
  license_password=`echo -n $LICENSEADMINPASSWORD | grep -E '[0-9]' | grep -E '[a-z]' | grep -E '[A-Z]' | grep -E '[!@#$%]' | grep -v '[)(*&^<>?~|\/.,+_=-]'`
  if [ -z $license_password ]; then
    echo "ERROR: License server password does not meet secure password requirements, Your password must be have at least 1 special symbol, 1 capital letter and 1 numeric value."
    echo "Warning: Supported special symbols are: [!@#$%]"
    logError "License server password does not meet secure password requirements, Your password must be have at least 1 special symbol, 1 capital letter and 1 numeric value."
    echo ""
    usage
  fi
fi

if [ ${CLOUDPLATFORM} ]; then
  ISCLOUDDEPLOYMENT="true"
fi
PXC_CORTEX_ENDPOINT="pxc-cortex-nginx"
if [ ${DOMAIN} ]; then
    timecheck=0
    http_substring='http'
    if [[ "$DOMAIN" == *"$http_substring"* ]]; then
      CHECK_DOMAIN_ENDPOINT=$DOMAIN
    else
      CHECK_DOMAIN_ENDPOINT="https://$DOMAIN"
      logDebug "Updated domain endpoint $CHECK_DOMAIN_ENDPOINT"
    fi
    CHECK_DOMAIN_ENDPOINT=$(echo $CHECK_DOMAIN_ENDPOINT | sed 's:/*$::')
    logDebug "Removed terminating / from given domain endpoint: $CHECK_DOMAIN_ENDPOINT"
    url=$CHECK_DOMAIN_ENDPOINT
    while true
      do
        status_code=$(curl --write-out %{http_code} --insecure --silent --output /dev/null $url)
        if [[ "$status_code" -eq 200 ]] ; then
          echo -e -n ""
          break
        fi
        showMessage "Validating domain endpoint: $CHECK_DOMAIN_ENDPOINT"
        logInfo "Validating access to domain endpoint: $CHECK_DOMAIN_ENDPOINT"
        sleep $SLEEPINTERVAL
        timecheck=$[$timecheck+$SLEEPINTERVAL]
        if [ $timecheck -gt $LBSERVICETIMEOUT ]; then
          echo ""
          echo "ERROR: Domain endpoint [$CHECK_DOMAIN_ENDPOINT] is not accessible."
          logError "Domain endpoint [$CHECK_DOMAIN_ENDPOINT] is not accessible."
          echo ""
          exit 1
        fi
      done
  echo "Domain endpoint: [$CHECK_DOMAIN_ENDPOINT] is accessible."
  DOMAIN_SETUP_REQUIRED="true"
  PUBLIC_ENDPOINT_SETUP_REQUIRED="false"
  INGRESS_SETUP_REQUIRED="false"
  PXC_FRONTEND="px-central-frontend.$DOMAIN"
  PXC_BACKEND="px-central-backend.$DOMAIN"
  PXC_MIDDLEWARE="px-central-middleware.$DOMAIN"
  PXC_GRAFANA="px-central-grafana.$DOMAIN"
  PXC_KEYCLOAK="px-central-keycloak.$DOMAIN"
  PXC_PROXY_FORWARDING="px-central-proxy.$DOMAIN"
  PXC_CORTEX_ENDPOINT="px-central-cortex.$DOMAIN"
  logInfo "Domain setup required: $DOMAIN_SETUP_REQUIRED, PX-Central endpoint: $PUBLIC_ENDPOINT_SETUP_REQUIRED, Ingress setup required: $INGRESS_SETUP_REQUIRED, Cortex endpoint: $PXC_CORTEX_ENDPOINT"
  logInfo "User input domain name: $DOMAIN"
  logInfo "PX-Central-Frontend sub domain name: $PXC_FRONTEND"
  logInfo "PX-Central-Backend sub domain name: $PXC_BACKEND"
  logInfo "PX-Central-Middleware sub domain name: $PXC_MIDDLEWARE"
  logInfo "PX-Central-Grafana sub domain name: $PXC_GRAFANA"
  logInfo "PX-Central-Keycloak sub domain name: $PXC_KEYCLOAK"
  logInfo "PX-Central-Proxy sub domain name: $PXC_PROXY_FORWARDING"
  logInfo "PX-Central-Cortex sub domain name: $PXC_CORTEX_ENDPOINT"
fi

if [[ "$DOMAIN_SETUP_REQUIRED" == "false" && "$ISCLOUDDEPLOYMENT" == "true" ]]; then
  INGRESS_SETUP_REQUIRED="true"
  logInfo "Ingress setup required: $INGRESS_SETUP_REQUIRED"
fi

pxc_domain="/tmp/pxc_domain.yaml"
logInfo "PX-Central domain spec: $pxc_domain"
cat <<< '
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: pxc-onprem-central-ingress
  namespace: '$PXCNAMESPACE'
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/app-root: /pxcentral
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
    - host: '$PXC_FRONTEND'
      http:
        paths:
        - backend:
            serviceName: pxc-central-frontend
            servicePort: 80
          path: /
    - host: '$PXC_BACKEND'
      http:
        paths:
        - backend:
            serviceName: pxc-central-backend
            servicePort: 80
          path: /
    - host: '$PXC_MIDDLEWARE'
      http:
        paths:
        - backend:
            serviceName: pxc-central-lh-middleware
            servicePort: 8091
          path: /
    - host: '$PXC_GRAFANA'
      http:
        paths:
        - backend:
            serviceName: pxc-grafana
            servicePort: 3000
          path: /
    - host: '$PXC_KEYCLOAK'
      http:
        paths:
        - backend:
            serviceName: pxc-keycloak-http
            servicePort: 80
          path: /
    - host: '$PXC_PROXY_FORWARDING'
      http:
        paths:
        - backend:
            serviceName: pxc-proxy-forwarding
            servicePort: 8081
          path: /
    - host: '$PXC_CORTEX_ENDPOINT'
      http:
        paths:
        - backend:
            serviceName: pxc-cortex-nginx
            servicePort: 80
          path: /
' > $pxc_domain

pxc_ingress="/tmp/pxc_ingress.yaml"
logInfo "PX-Central ingress spec: $pxc_ingress"
cat <<< '
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/app-root: /pxcentral
    nginx.ingress.kubernetes.io/rewrite-target: /$2
  name: pxc-onprem-central-ingress
  namespace: '$PXCNAMESPACE'
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: pxc-central-frontend
          servicePort: 80
        path: /pxcentral(/|$)(.*)
  - http:
      paths:
      - backend:
          serviceName: pxc-central-backend
          servicePort: 80
        path: /backend(/|$)(.*)
  - http:
      paths:
      - backend:
          serviceName: pxc-central-lh-middleware
          servicePort: 8091
        path: /lhBackend(/|$)(.*)
  - http:
      paths:
      - backend:
          serviceName: pxc-grafana
          servicePort: 3000
        path: /grafana(/|$)(.*)
  - http:
      paths:
      - backend:
          serviceName: pxc-proxy-forwarding
          servicePort: 8081
        path: /proxy(/|$)(.*)
  - http:
      paths:
      - backend:
          serviceName: pxc-cortex-nginx
          servicePort: 80
        path: /cortex(/|$)(.*)
' > $pxc_ingress

pxc_keycloak_ingress="/tmp/pxc_keycloak_ingress.yaml"
logInfo "PX-Central keycloak ingress spec: $pxc_keycloak_ingress"
cat <<< '
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
  name: pxc-onprem-central-keycloak-ingress
  namespace: '$PXCNAMESPACE'
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: pxc-keycloak-http
          servicePort: 80
        path: /keycloak
' > $pxc_keycloak_ingress

if [[ ${PKS_CLUSTER} && "$PKS_CLUSTER" == "true" ]]; then
  PKS_CLUSTER_ENABLED="true"
  logInfo "PKS cluster enabled: $PKS_CLUSTER_ENABLED"
fi

if [ -z ${VSPHERE_INSECURE} ]; then
  VSPHERE_INSECURE="false"
  logInfo "vSphere Insecure: $VSPHERE_INSECURE"
fi

if [[ "$PKS_CLUSTER" == "true" &&  "$CLOUDPLATFORM" == "$VSPHERE_PROVIDER" && "$CLOUDSTRORAGE" == "true" ]]; then
  VSPHERE_CLUSTER="true"
  VSPHERE_CLUSTER_DISK_PROVISION_REQUIRED="true"
  logInfo "vSphere cluster enabled: $VSPHERE_CLUSTER, vSphere cluster disk provision required: $VSPHERE_CLUSTER_DISK_PROVISION_REQUIRED"
fi 

if [[ "$OPENSHIFTCLUSTER" == "true" &&  "$CLOUDPLATFORM" == "$VSPHERE_PROVIDER" && "$CLOUDSTRORAGE" == "true" ]]; then
  VSPHERE_CLUSTER="true"
  VSPHERE_CLUSTER_DISK_PROVISION_REQUIRED="true"
  logInfo "vSphere cluster enabled: $VSPHERE_CLUSTER, vSphere cluster disk provision required: $VSPHERE_CLUSTER_DISK_PROVISION_REQUIRED"
fi

if [[ "$VSPHERE_CLUSTER" == "true" && "$VSPHERE_CLUSTER_DISK_PROVISION_REQUIRED" == "true" ]]; then  
  CLOUD_STORAGE_ENABLED="true"
  if [[ "$CLOUD_STORAGE_ENABLED" == "true" && -z ${PX_DISK_PROVISION_SECRET_NAME} ]]; then
    if [[ -z ${VSPHERE_USER} || -z ${VSPHERE_PASSWORD} || -z ${VSPHERE_VCENTER} || -z ${VSPHERE_VCENTER_PORT} || -z ${VSPHERE_DATASTORE_PREFIX} || -z "$VSPHERE_INSTALL_MODE" ]]; then
      echo ""
      echo "ERROR: Provide px-central-onprem deployment required details: --vsphere-vcenter-endpoint, --vsphere-vcenter-port, --vsphere-vcenter-datastore-prefix, --vsphere-vcenter-install-mode, --vsphere-user and --vsphere-password"
      logError "Provide px-central-onprem deployment required details: --vsphere-vcenter-endpoint, --vsphere-vcenter-port, --vsphere-vcenter-datastore-prefix, --vsphere-vcenter-install-mode, --vsphere-user and --vsphere-password"
      echo ""
      usage
    fi
  fi
  if [ -z ${CLOUD_DATA_DISK_TYPE} ]; then
    CLOUD_DATA_DISK_TYPE=$PX_DISK_TYPE_DEFAULT
  fi

  if [ -z ${CLOUD_DATA_DISK_SIZE} ]; then
    CLOUD_DATA_DISK_SIZE=$PX_DISK_SIZE_DEFAULT
  fi
  logInfo "Disk type: $CLOUD_DATA_DISK_TYPE, Disk size: $CLOUD_DATA_DISK_SIZE"
fi

if [ ${PXCOIDCREQUIRED} ]; then
  PXCPROVISIONEDOIDC="true"
  OIDCENABLED="true"
elif [[  -z ${EXTERNAL_OIDCCLIENTID} && -z ${EXTERNAL_OIDCSECRET} && -z ${EXTERNAL_OIDCENDPOINT} ]]; then
  EXTERNAL_OIDC_ENABLED="false"
fi

if [[  ${EXTERNAL_OIDCCLIENTID} || ${EXTERNAL_OIDCSECRET} || ${EXTERNAL_OIDCENDPOINT} ]]; then
  EXTERNAL_OIDC_ENABLED="true"
  PXCPROVISIONEDOIDC="true"
  OIDCENABLED="true"
fi

if [[ "$EXTERNAL_OIDC_ENABLED" == "true" && "$PXCPROVISIONEDOIDC" == "true" ]]; then
  if [ -z $EXTERNAL_OIDCCLIENTID ]; then
    echo "ERROR: PX-Central OIDC Client ID is required"
    logError "PX-Central OIDC Client ID is required"
    echo ""
    usage
    exit 1
  fi

  if [ -z $EXTERNAL_OIDCSECRET ]; then
    echo "ERROR: PX-Central OIDC Client Secret is required"
    logError "PX-Central OIDC Client Secret is required"
    echo ""
    usage
    exit 1
  fi

  if [ -z $EXTERNAL_OIDCENDPOINT ]; then
    echo "ERROR: PX-Central OIDC Endpoint is required"
    logError "PX-Central OIDC Endpoint is required"
    echo ""
    usage
    exit 1
  else
    timecheck=0
    http_substring='http'
    if [[ "$EXTERNAL_OIDCENDPOINT" == *"$http_substring"* ]]; then
      logDebug "No need to update External OIDC endpoint"
      CHECK_EXTERNAL_OIDCENDPOINT=$EXTERNAL_OIDCENDPOINT
    else
      CHECK_EXTERNAL_OIDCENDPOINT="https://$EXTERNAL_OIDCENDPOINT"
      logDebug "Updated External OIDC endpoint $CHECK_EXTERNAL_OIDCENDPOINT"
    fi
    CHECK_EXTERNAL_OIDCENDPOINT=$(echo $CHECK_EXTERNAL_OIDCENDPOINT | sed 's:/*$::')
    logDebug "Removed terminating / from given OIDC endpoint: $CHECK_EXTERNAL_OIDCENDPOINT"
    url=$CHECK_EXTERNAL_OIDCENDPOINT/.well-known/openid-configuration
    while true
      do
        status_code=$(curl --write-out %{http_code} --silent --output /dev/null $url)
        if [[ "$status_code" -eq 200 ]] ; then
          echo -e -n ""
          break
        fi
        showMessage "Validating access to OIDC endpoint: $CHECK_EXTERNAL_OIDCENDPOINT"
        logInfo "Validating access to OIDC endpoint: $CHECK_EXTERNAL_OIDCENDPOINT"
        sleep $SLEEPINTERVAL
        timecheck=$[$timecheck+$SLEEPINTERVAL]
        if [ $timecheck -gt $LBSERVICETIMEOUT ]; then
          echo ""
          echo "ERROR: External OIDC endpoint is not accessible."
          logError "External OIDC endpoint [$CHECK_EXTERNAL_OIDCENDPOINT] is not accessible."
          echo ""
          exit 1
        fi
      done
  fi
  echo ""
  echo "External OIDC endpoint: $CHECK_EXTERNAL_OIDCENDPOINT is accessible."
  if [ -z ${ADMINUSER} ]; then
    echo "ERROR: OIDC admin user name is required"
    logError "OIDC admin user name is required"
    echo ""
    usage
    exit 1
  fi

  if [ -z ${ADMINPASSWORD} ]; then
    echo "ERROR: OIDC admin user password is required"
    logError "OIDC admin user password is required"
    echo ""
    usage
    exit 1
  else
    oidc_admin_password=`echo -n $ADMINPASSWORD | grep -E '[0-9]' | grep -E '[a-z]' | grep -E '[A-Z]' | grep -E '[!@#$%]' | grep -v '[)(*&^<>?~|\/.,+_=-]'`
    if [ -z $oidc_admin_password ]; then
      echo "ERROR: OIDC admin user password does not meet secure password requirements, Your password must be have at least 1 special symbol, 1 capital letter and 1 numeric value."
      echo "Warning: Supported special symbols are: [!@#$%]"
      logError "OIDC admin user password does not meet secure password requirements, Your password must be have at least 1 special symbol, 1 capital letter and 1 numeric value."
      echo ""
      exit 1
    fi
  fi

  if [ -z ${ADMINEMAIL} ]; then
    echo "ERROR: OIDC admin user email is required"
    logError "OIDC admin user email is required"
    echo ""
    usage
    exit 1
  fi
fi

if [[ "$EXTERNAL_OIDC_ENABLED" == "false" && "$PXCPROVISIONEDOIDC" == "true" ]]; then
  if [ -z ${ADMINUSER} ]; then
    echo "ERROR: OIDC admin user name is required"
    logError "OIDC admin user name is required"
    echo ""
    usage
    exit 1
  fi

  if [ -z ${ADMINPASSWORD} ]; then
    echo "ERROR: OIDC admin user password is required"
    logError "OIDC admin user password is required"
    echo ""
    usage
    exit 1
  else
    oidc_admin_password=`echo -n $ADMINPASSWORD | grep -E '[0-9]' | grep -E '[a-z]' | grep -E '[A-Z]' | grep -E '[!@#$%]' | grep -v '[)(*&^<>?~|\/.,+_=-]'`
    if [ -z $oidc_admin_password ]; then
      echo "ERROR: OIDC admin user password does not meet secure password requirements, Your password must be have at least 1 special symbol, 1 capital letter and 1 numeric value."
      echo "Warning: Supported special symbols are: [!@#$%]"
      logError "OIDC admin user password does not meet secure password requirements, Your password must be have at least 1 special symbol, 1 capital letter and 1 numeric value."
      echo ""
      exit 1
    fi
  fi

  if [ -z ${ADMINEMAIL} ]; then
    echo "ERROR: OIDC admin user email is required"
    logError "OIDC admin user email is required"
    echo ""
    usage
    exit 1
  fi
fi

if [ -z ${KC} ]; then
  KC=$KUBECONFIG
fi

if [ -z ${KC} ]; then
    KC="$HOME/.kube/config"
fi

userKubeConfigPermissionCheckClusterrole=`kubectl --kubeconfig=$KC create clusterrole pxcentral-test --verb=get,list,watch --resource=pods 2>&1 | grep -i "forbidden" | grep -i "permission(s)" | grep -i "error" | wc -l 2>&1`
userKubeConfigPermissionCheckClusterrolebinding=`kubectl --kubeconfig=$KC create clusterrolebinding pxcentral-test --clusterrole=pxcentral-test --user=user1 --user=user2 --group=group1 2>&1 | grep -i "forbidden" | grep -i "permission(s)" | grep -i "error" | wc -l 2>&1`
logInfo "Cluster role create status: $userKubeConfigPermissionCheckClusterrole, cluster rolebinding create status: $userKubeConfigPermissionCheckClusterrolebinding"
if [[ "$userKubeConfigPermissionCheckClusterrole" -eq "1" || "$userKubeConfigPermissionCheckClusterrolebinding" -eq "1" ]]; then
  echo "Given kubeconfig: [$KC] does not have permissions to create and configure clusterrole and clusterrolebindings."
  echo "PX-Central-Onprem deployment needs admin privileges."
  exit 1
else
  kubectl --kubeconfig=$KC delete clusterrole pxcentral-test >> "$LOGFILE"
  kubectl --kubeconfig=$KC delete clusterrolebinding pxcentral-test >> "$LOGFILE"
fi
logInfo "Given kubeconfig: [$KC] has correct permissions to deploy PX-Central-Onprem."
if [ "$OIDCENABLED" == "false" ]; then
  logInfo "External OIDC Enabled: $OIDCENABLED, PX-Central OIDC: $PXCPROVISIONEDOIDC"
  if [ -z ${ADMINUSER} ]; then
    ADMINUSER="pxadmin"
  fi
  if [ -z ${ADMINPASSWORD} ]; then
    ADMINPASSWORD="Password1"
  fi
  if [ -z ${ADMINEMAIL} ]; then
    ADMINEMAIL="pxadmin@portworx.com"
  fi
fi

if [ -z ${PXCPXNAME} ]; then
    PXCPXNAME="pxcentral-onprem"
    logInfo "PX-Central-Onprem portworx cluster name: $PXCPXNAME"
fi

if [ -z ${PX_BACKUP_ORGANIZATION} ]; then
  PX_BACKUP_ORGANIZATION=$PX_BACKUP_ORGANIZATION_DEFAULT
  logInfo "PX-Backup organization name: $PX_BACKUP_ORGANIZATION"
else
  backup_org_name=`echo -n $PX_BACKUP_ORGANIZATION | grep -E '[a-z]' | grep -v '[A-Z]' | grep -v '[!@#$%]' | grep -v '[)(*&^<>?~|\/.,+_=]'`
  if [ -z $backup_org_name ]; then
    echo "ERROR: PX-Backup Organization name does not meet secure password requirements, Organization name required. Minimum 3 characters, No special symbol (!@#$%) and numbers."
    logError "PX-Backup Organization name does not meet secure password requirements, Organization name required. Minimum 3 characters, No special symbol (!@#$%) and numbers."
    echo ""
    exit 1
  fi
fi

# If not provided then reading from environment variables
if [ -z ${AWS_ACCESS_KEY_ID} ]; then
  AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
fi

if [ -z ${AWS_SECRET_ACCESS_KEY} ]; then
  AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
fi

if [ -z ${AZURE_CLIENT_SECRET} ]; then
  AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET
fi

if [ -z ${AZURE_CLIENT_ID} ]; then
  AZURE_CLIENT_ID=$AZURE_CLIENT_ID
fi

if [ -z ${AZURE_TENANT_ID} ]; then
  AZURE_TENANT_ID=$AZURE_TENANT_ID
fi

CUSTOMREGISTRYENABLED=""
if [[ ( ! -n ${CUSTOMREGISTRY} ) &&  ( ! -n ${IMAGEPULLSECRET} ) && ( ! -n ${IMAGEREPONAME} ) ]]; then
  CUSTOMREGISTRYENABLED="false"
else
  CUSTOMREGISTRYENABLED="true"
fi

if [[ ( ${CUSTOMREGISTRYENABLED} = "true" ) && ( -z ${CUSTOMREGISTRY} ) ]]; then
    echo "ERROR: Custom registry url is required for air-gapped installation."
    logError "Custom registry url is required for air-gapped installation."
    echo ""
    usage 
    exit 1
fi

if [[ ( $CUSTOMREGISTRYENABLED = "true" ) && ( -z ${IMAGEPULLSECRET} ) ]]; then
    echo "ERROR: Custom registry url and Image pull secret are required for air-gapped installation."
    logError "Custom registry url and Image pull secret are required for air-gapped installation."
    echo ""
    usage 
    exit 1
fi

if [[ ( $CUSTOMREGISTRYENABLED = "true" ) && ( -z ${IMAGEREPONAME} ) ]]; then
    echo "ERROR: Custom registry url and image repository is required for air-gapped installation."
    logError "Custom registry url and image repository is required for air-gapped installation."
    echo ""
    usage 
    exit 1
fi

if [ ${AIRGAPPED} ]; then
  if [ "$AIRGAPPED" == "true" ]; then
    AIRGAPPEDLICENSETYPE="true"
    if [[ ( "$CUSTOMREGISTRYENABLED" == "false" ) || ( -z ${CUSTOMREGISTRY} ) || ( -z ${IMAGEPULLSECRET} ) || ( -z ${IMAGEREPONAME} ) ]]; then
      echo "ERROR: Air gapped deployment requires --custom-registry,--image-repo-name and --image-pull-secret"
      logError "Air gapped deployment requires --custom-registry,--image-repo-name and --image-pull-secret"
      echo ""
      usage
      exit 1
    fi
  fi
fi

if [ "$CUSTOMREGISTRYENABLED" == "true" ]; then
  ONPREMOPERATORIMAGE="$CUSTOMREGISTRY/$IMAGEREPONAME/pxcentral-onprem-operator:1.0.3"
  PXCENTRALAPISERVER="$CUSTOMREGISTRY/$IMAGEREPONAME/pxcentral-onprem-api:1.0.3"
  PXOPERATORIMAGE="$CUSTOMREGISTRY/$IMAGEREPONAME/px-operator:1.3.1"
  PXCPRESETUPIMAGE="$CUSTOMREGISTRY/$IMAGEREPONAME/pxcentral-onprem-pre-setup:1.0.1"
  PXDEVIMAGE="$CUSTOMREGISTRY/$IMAGEREPONAME/px-dev:2.5.0"
  STORK_IMAGE="$CUSTOMREGISTRY/$IMAGEREPONAME/stork:2.4.0"
  PXCLSLABELSETIMAGE="$CUSTOMREGISTRY/$IMAGEREPONAME/pxc-macaddress-config:1.0.1"
  PXBACKUPIMAGE="$CUSTOMREGISTRY/$IMAGEREPONAME/px-backup:1.0.1"
  PX_CENTRAL_FRONTEND="$CUSTOMREGISTRY/$IMAGEREPONAME/pxcentral-onprem-ui-frontend:1.1.1"
  PX_CENTRAL_BACKEND="$CUSTOMREGISTRY/$IMAGEREPONAME/pxcentral-onprem-ui-backend:1.1.1"
  PX_CENTRAL_MIDDLEWARE="$CUSTOMREGISTRY/$IMAGEREPONAME/pxcentral-onprem-ui-lhbackend:1.1.1"
  PXC_PROXY_FORWARDING_IMAGE="$CUSTOMREGISTRY/$IMAGEREPONAME/px-forwarding-proxy:1.0.0"
  echo "PX-Central-Operator Image: $ONPREMOPERATORIMAGE"
  echo "PX-Central-API-Server Image: $PXCENTRALAPISERVER"
  echo "PX-Central-PX-Operator Image: $PXOPERATORIMAGE"
  echo "PX-Central-Pre-Sertup Image: $PXCPRESETUPIMAGE"
  echo "PX-Central-PX-Dev Image: $PXDEVIMAGE"
  echo "PX-Central-License-LabelSet Image: $PXCLSLABELSETIMAGE"
  echo "PX-Central-PX-Backup Image: $PXCLSLABELSETIMAGE"
  echo ""
  logInfo "PX-Central operator image: $ONPREMOPERATORIMAGE, PX API server image: $PXCENTRALAPISERVER, PX operator image: $PXOPERATORIMAGE, PX pre-setup image: $PXCPRESETUPIMAGE, PX dev image: $PXDEVIMAGE, PX license server image: $PXCLSLABELSETIMAGE, PX backup image: $PXCLSLABELSETIMAGE, Proxy image: $PXC_PROXY_FORWARDING_IMAGE"
fi

echo "Validate and Pre-Install check in progress:"
AWS_PROVIDER="aws"
GOOGLE_PROVIDER="gcp"
AZURE_PROVIDER="azure"
IBM_PROVIDER="ibm"
METRICS_ENDPOINT="pxc-cortex-nginx.$PXCNAMESPACE.svc.cluster.local:80"
logInfo "Metrics endpoint: $METRICS_ENDPOINT"
AWS_DISK_PROVISIONED_REQUIRED="false"
GCP_DISK_PROVISIONED_REQUIRED="false"
AZURE_DISK_PROVISIONED_REQUIRED="false"
if [ ${CLOUDPLATFORM} ]; then
  ISCLOUDDEPLOYMENT="true"
  if [[ -z "$CLOUDPLATFORM" && "$CLOUDPLATFORM" != "$AWS_PROVIDER" && "$CLOUDPLATFORM" != "$GOOGLE_PROVIDER" && "$CLOUDPLATFORM" != "$AZURE_PROVIDER" && "$CLOUDPLATFORM" != "$VSPHERE_PROVIDER" && "$CLOUDPLATFORM" != "$IBM_PROVIDER" ]]; then
    echo ""
    echo "Warning: PX-Central cloud deployments supports following providers:"
    echo "         aws | gcp | azure | vsphere | ibm"
    logWarning "PX-Central cloud deployments supports following providers:"
    logWarning "         aws | gcp | azure | vsphere | ibm"
    exit 1
  fi
  if [[ "$CLOUDPLATFORM" == "$AWS_PROVIDER" && ${CLOUDSTRORAGE} ]]; then
    CLOUD_STORAGE_ENABLED="true"
    if [[ "$CLOUD_STORAGE_ENABLED" == "true" && -z ${PX_DISK_PROVISION_SECRET_NAME} ]]; then
      if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" ]]; then
        echo ""
        echo "ERROR: PX-Central deployments on aws cloud with cloudstorage option requires --aws-access-key and --aws-secret-key"
        logError "PX-Central deployments on aws cloud with cloudstorage option requires --aws-access-key and --aws-secret-key"
        echo ""
        usage
      fi
    fi
    AWS_CLOUD_PLATFORM="true"
    AWS_DISK_PROVISIONED_REQUIRED="true"
    if [ -z ${CLOUD_DATA_DISK_TYPE} ]; then
      CLOUD_DATA_DISK_TYPE=$AWS_DISK_TYPE
    fi
    if [ -z ${CLOUD_DATA_DISK_SIZE} ]; then
      CLOUD_DATA_DISK_SIZE=$DEFAULT_DISK_SIZE
    fi
  elif [[ "$CLOUDPLATFORM" == "$GOOGLE_PROVIDER" && ${CLOUDSTRORAGE} ]]; then
    CLOUD_STORAGE_ENABLED="true"
    GOOGLE_CLOUD_PLATFORM="true"
    GCP_DISK_PROVISIONED_REQUIRED="true"
    if [ -z ${CLOUD_DATA_DISK_TYPE} ]; then
      CLOUD_DATA_DISK_TYPE=$GCP_DISK_TYPE
    fi
    if [ -z ${CLOUD_DATA_DISK_SIZE} ]; then
      CLOUD_DATA_DISK_SIZE=$DEFAULT_DISK_SIZE
    fi
  elif [[ "$CLOUDPLATFORM" == "$AZURE_PROVIDER" && ${CLOUDSTRORAGE} ]]; then
    CLOUD_STORAGE_ENABLED="true"
    if [[ "$CLOUD_STORAGE_ENABLED" == "true" && -z ${PX_DISK_PROVISION_SECRET_NAME} ]]; then
      if [[ -z "$AZURE_CLIENT_SECRET" || -z "$AZURE_CLIENT_ID" || -z "$AZURE_TENANT_ID" ]]; then
        echo ""
        echo "ERROR: PX-Central deployments on azure cloud with cloudstorage option requires --azure-client-secret, --azure-client-id and --azure-tenant-id"
        logError "PX-Central deployments on azure cloud with cloudstorage option requires --azure-client-secret, --azure-client-id and --azure-tenant-id"
        echo ""
        usage
      fi
    fi
    AZURE_CLOUD_PLATFORM="true"
    AZURE_DISK_PROVISIONED_REQUIRED="true"
    if [ -z ${CLOUD_DATA_DISK_TYPE} ]; then
      CLOUD_DATA_DISK_TYPE=$AZURE_DISK_TYPE
    fi
    if [ -z ${CLOUD_DATA_DISK_SIZE} ]; then
      CLOUD_DATA_DISK_SIZE=$DEFAULT_DISK_SIZE
    fi
  elif [ "$CLOUDPLATFORM" == "$IBM_PROVIDER" ]; then
    IBM_CLOUD_PLATFORM="true"
  fi
fi

if [ -f "$KC" ]; then
    echo "Using Kubeconfig: $KC"
    logInfo "Using Kubeconfig: $KC"
else 
    echo "ERROR : Kubeconfig [ $KC ] does not exist"
    logError "Kubeconfig [ $KC ] does not exist"
    usage
fi

checkK8sVersion=`kubectl --kubeconfig=$KC version --short | grep -v "i/o timeout" | awk -Fv '/Server Version: / {print $3}' 2>&1`
if [ -z $checkK8sVersion ]; then
  echo ""
  echo "ERROR : Invalid kubeconfig, Unable to connect to the server"
  logError "Invalid kubeconfig, Unable to connect to the server"
  echo ""
  exit 1
fi

if [ -z ${RE_DEPLOY_ON_SAME_CLUSTER} ]; then
  RE_DEPLOY_ON_SAME_CLUSTER="false"
fi
existing_pxcentralonprem_name=`kubectl --kubeconfig=$KC get pxcentralonprem --all-namespaces 2>&1 | grep NAME | wc -l 2>&1`
existing_pxcentralonprem_object=`kubectl --kubeconfig=$KC get pxcentralonprem --all-namespaces 2>&1 | grep -v NAME | grep "pxcentralonprem" | wc -l 2>&1`
if [[ "$existing_pxcentralonprem_name" -eq "1" && "$existing_pxcentralonprem_object" -eq "1" && "$RE_DEPLOY_ON_SAME_CLUSTER" == "false" ]]; then
  logInfo "PX-Central-Onprem already running on this cluster."
  kubectl --kubeconfig=$KC get pxcentralonprem --all-namespaces >> "$LOGFILE"
  echo ""
  echo "PX-Central-Onprem already running on this cluster, More than one PX-Central-Onprem clusters on same kubernetes or openshift cluster is not supported."
  echo "If you want to re-configure PX-Central-Onprem cluster use flag : --re-configure"
  echo ""
  exit 1
fi

kubectl --kubeconfig=$KC create namespace $PXCNAMESPACE >> "$LOGFILE"
kubectl --kubeconfig=$KC create namespace $PX_BACKUP_NAMESPACE >> "$LOGFILE"

echo "Kubernetes cluster version: $checkK8sVersion"
logInfo "Kubernetes cluster version: $checkK8sVersion"
k8sVersion=$checkK8sVersion
k8sVersion111Validate=`echo -n $checkK8sVersion | grep -E '1.11'`
k8sVersion112Validate=`echo -n $checkK8sVersion | grep -E '1.12'`
k8sVersion113Validate=`echo -n $checkK8sVersion | grep -E '1.13'`
k8sVersion114Validate=`echo -n $checkK8sVersion | grep -E '1.14'`
k8sVersion115Validate=`echo -n $checkK8sVersion | grep -E '1.15'`
k8sVersion116Validate=`echo -n $checkK8sVersion | grep -E '1.16'`
k8sVersion117Validate=`echo -n $checkK8sVersion | grep -E '1.17'`
k8sVersion118Validate=`echo -n $checkK8sVersion | grep -E '1.18'`
if [[ -z "$k8sVersion111Validate" && -z "$k8sVersion112Validate" && -z "$k8sVersion113Validate" && -z "$k8sVersion114Validate" && -z "$k8sVersion115Validate" && -z "$k8sVersion116Validate" && -z "$k8sVersion117Validate" && -z "$k8sVersion118Validate" ]]; then
  echo ""
  echo "Warning: PX-Central supports following versions:"
  echo "         K8s: 1.11.x, 1.12.x, 1.13.x, 1.14.x, 1.15.x, 1.16.x, 1.17.x and 1.18.x"
  echo "         Openshift: 3.11, 4.2 and 4.3"
  logWarning "PX-Central supports following versions:"
  logInfo "         K8s: 1.11.x, 1.12.x, 1.13.x, 1.14.x, 1.15.x, 1.16.x, 1.17.x and 1.18.x"
  logInfo "         Openshift: 3.11, 4.2 and 4.3"
  echo ""
  exit 1
fi 

if [ -z ${MANAGED_K8S_SERVICE} ]; then
  gke_cluster=`kubectl --kubeconfig=$KC version --short | grep -v "i/o timeout" | awk -Fv '/Server Version: / {print $3}' 2>&1 | grep -i "gke" 2>&1 | wc -l 2>&1`
  eks_cluster=`kubectl --kubeconfig=$KC version --short | grep -v "i/o timeout" | awk -Fv '/Server Version: / {print $3}' 2>&1 | grep -i "eks" 2>&1 | wc -l 2>&1`
  aks_cluster=`kubectl --kubeconfig=$KC version --short | grep -v "i/o timeout" | awk -Fv '/Server Version: / {print $3}' 2>&1 | grep -i "aks" 2>&1 | wc -l 2>&1`
  if [[ "$gke_cluster" -eq "1" || "$eks_cluster" -eq "1" || "$aks_cluster" -eq "1" ]]; then
    MANAGED_K8S_SERVICE="true"
  fi
fi

if [ ${MANAGED_K8S_SERVICE} ]; then
  if [[ "$CLOUDPLATFORM" == "gcp" && "$MANAGED_K8S_SERVICE" == "true" ]]; then
    GKE_CLUSTER_TYPE="true"
  elif [[ "$CLOUDPLATFORM" == "aws" && "$MANAGED_K8S_SERVICE" == "true" ]]; then
    EKS_CLUSTER_TYPE="true"
  elif [[ "$CLOUDPLATFORM" == "azure" && "$MANAGED_K8S_SERVICE" == "true" ]]; then
    AKS_CLUSTER_TYPE="true"
  fi
fi
logInfo "Manage k8s service: $MANAGED_K8S_SERVICE, GKE cluster: $GKE_CLUSTER_TYPE, EKS cluster: $EKS_CLUSTER_TYPE, AKS cluster: $AKS_CLUSTER_TYPE"
if [[ -z "$k8sVersion112Validate" && -z "$k8sVersion113Validate" && -z "$k8sVersion114Validate" && -z "$k8sVersion115Validate" && -z "$k8sVersion116Validate" && -z "$k8sVersion117Validate" && -z "$k8sVersion118Validate" ]]; then
  OPERATOR_UNSUPPORTED_CLUSTER="true"
fi

if [[ "$k8sVersion111Validate" || "$k8sVersion112Validate" || "$k8sVersion113Validate" ]]; then
  INGRESS_CHANGE_REQUIRED="true"
fi

if [[ "$k8sVersion112Validate" || "$k8sVersion113Validate" || "$k8sVersion114Validate" || "$k8sVersion115Validate" || "$k8sVersion116Validate" || "$k8sVersion117Validate" || "$k8sVersion118Validate" ]]; then
  OPERATOR_UNSUPPORTED_CLUSTER="false"
fi

if [ "$DOMAIN_SETUP_REQUIRED" = "true" ]; then
  PXCINPUTENDPOINT=$PXC_FRONTEND
fi

if [[ ${PXCINPUTENDPOINT} || "$CLOUDPLATFORM" == "$VSPHERE_PROVIDER" ]]; then
  INGRESS_SETUP_REQUIRED="false"
fi

if [[ "$INGRESS_CONTROLLER_PROVISION" == "true" || "$INGRESS_SETUP_REQUIRED" == "true" ]]; then
  PUBLIC_ENDPOINT_SETUP_REQUIRED="false"
  ingress_controller_config="/tmp/ingress_controller.yaml"
  logInfo "Ingress controller spec: $ingress_controller_config"
cat <<< '
apiVersion: v1
kind: Namespace
metadata:
  name: '$PXCNAMESPACE'
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
---
# Source: ingress-nginx/templates/controller-serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/component: controller
  name: ingress-nginx
  namespace: '$PXCNAMESPACE'
---
# Source: ingress-nginx/templates/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
  name: ingress-nginx
  namespace: '$PXCNAMESPACE'
rules:
  - apiGroups:
      - '\'\''
    resources:
      - configmaps
      - endpoints
      - nodes
      - pods
      - secrets
    verbs:
      - list
      - watch
  - apiGroups:
      - '\'\''
    resources:
      - nodes
    verbs:
      - get
  - apiGroups:
      - '\'\''
    resources:
      - services
    verbs:
      - get
      - list
      - update
      - watch
  - apiGroups:
      - extensions
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - '\'\''
    resources:
      - events
    verbs:
      - create
      - patch
  - apiGroups:
      - extensions
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingresses/status
    verbs:
      - update
  - apiGroups:
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingressclasses
    verbs:
      - get
      - list
      - watch
---
# Source: ingress-nginx/templates/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
  name: ingress-nginx
  namespace: '$PXCNAMESPACE'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ingress-nginx
subjects:
  - kind: ServiceAccount
    name: ingress-nginx
    namespace: '$PXCNAMESPACE'
---
# Source: ingress-nginx/templates/controller-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/component: controller
  name: ingress-nginx
  namespace: '$PXCNAMESPACE'
rules:
  - apiGroups:
      - '\'\''
    resources:
      - namespaces
    verbs:
      - get
  - apiGroups:
      - '\'\''
    resources:
      - configmaps
      - pods
      - secrets
      - endpoints
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - '\'\''
    resources:
      - services
    verbs:
      - get
      - list
      - update
      - watch
  - apiGroups:
      - extensions
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - extensions
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingresses/status
    verbs:
      - update
  - apiGroups:
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingressclasses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - '\'\''
    resources:
      - configmaps
    resourceNames:
      - ingress-controller-leader-nginx
    verbs:
      - get
      - update
  - apiGroups:
      - '\'\''
    resources:
      - configmaps
    verbs:
      - create
  - apiGroups:
      - '\'\''
    resources:
      - endpoints
    verbs:
      - create
      - get
      - update
  - apiGroups:
      - '\'\''
    resources:
      - events
    verbs:
      - create
      - patch
---
# Source: ingress-nginx/templates/controller-rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/component: controller
  name: ingress-nginx
  namespace: '$PXCNAMESPACE'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ingress-nginx
subjects:
  - kind: ServiceAccount
    name: ingress-nginx
    namespace: '$PXCNAMESPACE'
---
# Source: ingress-nginx/templates/controller-service-webhook.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller-admission
  namespace: '$PXCNAMESPACE'
spec:
  type: ClusterIP
  ports:
    - name: https-webhook
      port: 443
      targetPort: webhook
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/component: controller
---
# Source: ingress-nginx/templates/controller-service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller
  namespace: '$PXCNAMESPACE'
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: http
    - name: https
      port: 443
      protocol: TCP
      targetPort: https
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/component: controller
---
# Source: ingress-nginx/templates/controller-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller
  namespace: '$PXCNAMESPACE'
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: ingress-nginx
      app.kubernetes.io/instance: ingress-nginx
      app.kubernetes.io/component: controller
  revisionHistoryLimit: 10
  minReadySeconds: 0
  template:
    metadata:
      labels:
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/component: controller
    spec:
      dnsPolicy: ClusterFirst
      containers:
        - name: controller
          image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.31.1
          imagePullPolicy: IfNotPresent
          lifecycle:
            preStop:
              exec:
                command:
                  - /wait-shutdown
          args:
            - /nginx-ingress-controller
            - --publish-service='$PXCNAMESPACE'/ingress-nginx-controller
            - --election-id=ingress-controller-leader
            - --ingress-class=nginx
            - --configmap='$PXCNAMESPACE'/ingress-nginx-controller
            - --validating-webhook=:8443
            - --validating-webhook-certificate=/usr/local/certificates/cert
            - --validating-webhook-key=/usr/local/certificates/key
          securityContext:
            capabilities:
              drop:
                - ALL
              add:
                - NET_BIND_SERVICE
            runAsUser: 101
            allowPrivilegeEscalation: true
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          livenessProbe:
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 1
            successThreshold: 1
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 1
            successThreshold: 1
            failureThreshold: 3
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
            - name: https
              containerPort: 443
              protocol: TCP
            - name: webhook
              containerPort: 8443
              protocol: TCP
          volumeMounts:
            - name: webhook-cert
              mountPath: /usr/local/certificates/
              readOnly: true
          resources:
            requests:
              cpu: 100m
              memory: 90Mi
      serviceAccountName: ingress-nginx
      terminationGracePeriodSeconds: 300
      volumes:
        - name: webhook-cert
          secret:
            secretName: ingress-nginx-admission
---
# Source: ingress-nginx/templates/admission-webhooks/validating-webhook.yaml
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingWebhookConfiguration
metadata:
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/component: admission-webhook
  name: ingress-nginx-admission
  namespace: '$PXCNAMESPACE'
webhooks:
  - name: validate.nginx.ingress.kubernetes.io
    rules:
      - apiGroups:
          - extensions
          - networking.k8s.io
        apiVersions:
          - v1beta1
        operations:
          - CREATE
          - UPDATE
        resources:
          - ingresses
    failurePolicy: Fail
    clientConfig:
      service:
        namespace: '$PXCNAMESPACE'
        name: ingress-nginx-controller-admission
        path: /extensions/v1beta1/ingresses
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ingress-nginx-admission
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: '$PXCNAMESPACE'
rules:
  - apiGroups:
      - admissionregistration.k8s.io
    resources:
      - validatingwebhookconfigurations
    verbs:
      - get
      - update
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ingress-nginx-admission
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: '$PXCNAMESPACE'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ingress-nginx-admission
subjects:
  - kind: ServiceAccount
    name: ingress-nginx-admission
    namespace: '$PXCNAMESPACE'
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/job-createSecret.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: ingress-nginx-admission-create
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/component: admission-webhook
  namespace: '$PXCNAMESPACE'
spec:
  template:
    metadata:
      name: ingress-nginx-admission-create
      labels:
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/version: 0.31.1
        app.kubernetes.io/component: admission-webhook
    spec:
      containers:
        - name: create
          image: jettech/kube-webhook-certgen:v1.2.0
          imagePullPolicy: IfNotPresent
          args:
            - create
            - --host=ingress-nginx-controller-admission,ingress-nginx-controller-admission.'$PXCNAMESPACE'.svc
            - --namespace='$PXCNAMESPACE'
            - --secret-name=ingress-nginx-admission
      restartPolicy: OnFailure
      serviceAccountName: ingress-nginx-admission
      securityContext:
        runAsNonRoot: true
        runAsUser: 2000
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/job-patchWebhook.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: ingress-nginx-admission-patch
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/component: admission-webhook
  namespace: '$PXCNAMESPACE'
spec:
  template:
    metadata:
      name: ingress-nginx-admission-patch
      labels:
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/version: 0.31.1
        app.kubernetes.io/component: admission-webhook
    spec:
      containers:
        - name: patch
          image: jettech/kube-webhook-certgen:v1.2.0
          args:
            - patch
            - --webhook-name=ingress-nginx-admission
            - --namespace='$PXCNAMESPACE'
            - --patch-mutating=false
            - --secret-name=ingress-nginx-admission
            - --patch-failure-policy=Fail
      restartPolicy: OnFailure
      serviceAccountName: ingress-nginx-admission
      securityContext:
        runAsNonRoot: true
        runAsUser: 2000
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ingress-nginx-admission
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/component: admission-webhook
  namespace: '$PXCNAMESPACE'
rules:
  - apiGroups:
      - '\'\''
    resources:
      - secrets
    verbs:
      - get
      - create
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ingress-nginx-admission
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/component: admission-webhook
  namespace: '$PXCNAMESPACE'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ingress-nginx-admission
subjects:
  - kind: ServiceAccount
    name: ingress-nginx-admission
    namespace: '$PXCNAMESPACE'
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ingress-nginx-admission
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/component: admission-webhook
  namespace: '$PXCNAMESPACE'
---
' > $ingress_controller_config
fi

resource_check="true"
USE_EXISTING_PX="false"
PXOPERATORDEPLOYMENT="true"
PXCENTRAL_PX_APP_SAME_K8S_CLUSTER="false"
nodeCount=`kubectl --kubeconfig=$KC get node  | grep -i ready | awk '{print$1}' | xargs kubectl --kubeconfig=$KC get node  -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.taints}{"\n"}{end}' | grep -iv noschedule | wc -l 2>&1`
echo "Number of total nodes in k8s cluster: $nodeCount"
logInfo "Number of nodes in k8s cluster: $nodeCount"
if [ "$nodeCount" -lt 3 ]; then 
  if [ "$PXCENTRAL_MINIK8S" == "true" ]; then
    PX_SINGLE_ETCD_DEPLOY="true"
    PX_ETCD_DEPLOY="false"
    resource_check="false"
    CENTRAL_DEPLOYED_PX="false"
  else
    echo "PX-Central deployments needs minimum 3 worker nodes. found: $nodeCount"
    logInfo "PX-Central deployments needs minimum 3 worker nodes. found: $nodeCount"
    exit 1
  fi
else
  affinityNodeCount=`kubectl --kubeconfig=$KC get nodes -l $NODE_AFFINITY_KEY=true 2>&1 | grep -v NAME | awk '{print $1}' | wc -l 2>&1`
  if [ "$affinityNodeCount" -ge 3 ]; then
    PXCENTRAL_PX_APP_SAME_K8S_CLUSTER="true"
  fi
  pxNodeCount=`kubectl --kubeconfig=$KC get pods -lname=portworx --all-namespaces 2>&1 |  grep -v NAME | grep -iv "error" | grep -v "No resources found" | wc -l 2>&1`
  if [[ "$pxNodeCount" -ge 3 && "$PXCENTRAL_PX_APP_SAME_K8S_CLUSTER" == "false" ]]; then
    if [ "$PX_STORE_DEPLOY" == "true" ]; then
      resource_check="false"
      USE_EXISTING_PX="true"
      PXOPERATORDEPLOYMENT="false"
      CENTRAL_DEPLOYED_PX="false"
    fi
    if [ "$PX_BACKUP_DEPLOY" == "true" ]; then
      PX_ETCD_DEPLOY="true"
      PX_SINGLE_ETCD_DEPLOY="false"
    fi
  fi
fi
logDebug "Portworx cluster deploy request: $PX_STORE_DEPLOY, Existing portworx cluster: $USE_EXISTING_PX"
if [[ "$PX_STORE_DEPLOY" == "true" && "$nodeCount" -gt 3 && "$USE_EXISTING_PX" == "false" ]]; then
  pxDeployNodeCount=`kubectl --kubeconfig=$KC get node -lpx/enabled=false 2>&1 | grep -i ready | awk '{print$1}' | wc -l 2>&1`
  echo "K8s cluster total nodes: $nodeCount, Nodes labeled portworx deployment to false: $pxDeployNodeCount"
  pxClusterNodeCount=$[$nodeCount-$pxDeployNodeCount]
  echo "Number of nodes for portworx cluster deployment: $pxClusterNodeCount"
  if [ "$pxClusterNodeCount" -gt 3 ]; then
    echo ""
    echo "PX-Central-Onprem portworx cluster supports only 3 node cluster. If the current k8s/openshift cluster has more than 3 woker nodes for portworx cluster deployment then need to set 'px/enabled=false' label to remaining nodes."
    echo "Use command: kubectl label node <NODE_HOST_NAME> px/enabled=false"
    echo "Re-run the command to proceed with installation: --re-configure flag"
    echo ""
    exit 1
  fi
fi
if [ "$PXCENTRAL_MINIK8S" == "true" ]; then
  echo "MINI Setup: $PXCENTRAL_MINIK8S, BACKUP: $PX_BACKUP_DEPLOY, PXSTORE: $PX_STORE_DEPLOY, LICENSE: $PX_LICENSE_SERVER_DEPLOY, METRICS: $PX_METRICS_DEPLOY, ETCD CLUSTER: $PX_ETCD_DEPLOY, STANDALONE ETCD: $PX_SINGLE_ETCD_DEPLOY, KEYCLOAK: $PXCPROVISIONEDOIDC"
  logInfo "MINI Setup: $PXCENTRAL_MINIK8S, BACKUP: $PX_BACKUP_DEPLOY, PXSTORE: $PX_STORE_DEPLOY, LICENSE: $PX_LICENSE_SERVER_DEPLOY, METRICS: $PX_METRICS_DEPLOY, ETCD CLUSTER: $PX_ETCD_DEPLOY, STANDALONE ETCD: $PX_SINGLE_ETCD_DEPLOY, KEYCLOAK: $PXCPROVISIONEDOIDC"
  echo ""
fi

if [ "$resource_check" == "true" ]; then
  echo "PX-Central cluster resource check:"
  logInfo "PX-Central cluster resource check:"
  resource_check="/tmp/resource_check.py"
  logInfo "Resource check script: $resource_check"
  nodesData=`kubectl --kubeconfig=$KC get node  | grep -i ready | awk '{print$1}' | xargs kubectl --kubeconfig=$KC get node  -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.taints}{"\n"}{end}' | grep -iv noschedule 2>&1`
  logInfo "K8s cluster worker nodes: $nodesData"
cat > $resource_check <<- "EOF"
import os
import sys
import subprocess

kubeconfig=sys.argv[1]
nodes_data=sys.argv[2]
cpu_check_list=[]
memory_check_list=[]
try:
  if not nodes_data:
    cmd = "kubectl --kubeconfig=%s get nodes | grep -v NAME | awk '{print $1}'" % kubeconfig
    output= subprocess.check_output(cmd, shell=True)
  output= nodes_data
  nodes_output = output.decode("utf-8")
  nodes_list = nodes_output.split("\n")
  nodes_count = len(nodes_list)
  for node in nodes_list:
    try:
      cmd = "kubectl --kubeconfig=%s get node %s -o=jsonpath='{.status.capacity.cpu}'" % (kubeconfig, node)
      cpu_output = subprocess.check_output(cmd, shell=True)
      cpu_output = cpu_output.decode("utf-8")
      if cpu_output:
        cpu = int(cpu_output)
        if cpu > 3:
          cpu_check_list.append(True)
        else:
          cpu_check_list.append(False)

      cmd = "kubectl --kubeconfig=%s get node %s -o=jsonpath='{.status.capacity.memory}'" % (kubeconfig, node)
      memory_output = subprocess.check_output(cmd, shell=True)
      memory_output = memory_output.decode("utf-8")
      if memory_output:
        memory = memory_output.split("K")[0]
        memory = int(memory)
        if memory > 7000000:
          memory_check_list.append(True)
        else:
          memory_check_list.append(False)
    except Exception as ex:
      pass
except Exception as ex:
  pass
finally:
  if cpu_check_list == memory_check_list:
    print(True)
  else:
    print(False)
EOF

  if [ -f ${resource_check} ]; then
    status=`$cmdPython $resource_check $KC $nodesData`
    if [ ${status} = "True" ]; then
      echo "Resource check passed.."
      logInfo "Resource check passed.."
      echo ""
    else
      echo ""
      echo "Nodes in k8s cluster does not have minimum required  resources..."
      echo "CPU: 4, Memory: 8GB, Drives: 2  needed on each k8s worker node"
      logInfo "Nodes in k8s cluster does not have minimum required  resources..."
      logInfo "CPU: 4, Memory: 8GB, Drives: 2  needed on each k8s worker node"
      exit 1
    fi
  fi
fi 

if [[ "$INGRESS_CONTROLLER_PROVISION" == "true" || "$INGRESS_SETUP_REQUIRED" == "true" ]]; then
  if [ ! -f $ingress_controller_config ]; then
    echo "Failed to create file: $ingress_controller_config, verify you have right access to create file: $ingress_controller_config"
    logError "Failed to create file: $ingress_controller_config, verify you have right access to create file: $ingress_controller_config"
    echo ""
    exit 1
  fi
  logInfo "Creating ingress controller config using spec: $ingress_controller_config"
  kubectl --kubeconfig=$KC apply -f $ingress_controller_config --namespace $PXCNAMESPACE >> "$LOGFILE"
  sleep $SLEEPINTERVAL
  ingressControllerCheck="0"
  timecheck=0
  while [ $ingressControllerCheck -ne "1" ]
    do
      ingress_pod=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "ingress-nginx-controller" | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
      logInfo "Ingress controller ready replica count: $ingress_pod"
      if [ "$ingress_pod" -eq "1" ]; then
        ingressControllerCheck="1"
        break
      fi
      showMessage "Waiting for Ingress Nginx Controller to be ready"
      logInfo "Waiting for Ingress Nginx Controller to be ready"
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $TIMEOUT ]; then
        echo ""
        kubectl --kubeconfig=$KC logs $ingress_pod --namespace $PXCNAMESPACE >> "$LOGFILE"
        echo "Nginx ingress controller deployment failed. check the pods status and logs in given namespace: $PXCNAMESPACE"
        echo "ERROR: Failed to deploy Ingress Nginx Controller, Contact: support@portworx.com"
        logError "Failed to deploy Ingress Nginx Controller, Contact: support@portworx.com"
        echo ""
        exit 1
      fi
    done
    logInfo "Ingress controller deployed successfully..."
fi

if [ "$INGRESS_SETUP_REQUIRED" == "true" ]; then
  if [ ! -f $pxc_ingress ]; then
    echo "Failed to create file: $pxc_ingress, verify you have right access to create file: $pxc_ingress"
    logError "Failed to create file: $pxc_ingress, verify you have right access to create file: $pxc_ingress"
    echo ""
    exit 1
  fi
  logInfo "Creating ingress for px-central services using spec: $pxc_ingress"
  kubectl --kubeconfig=$KC apply -f $pxc_ingress --namespace $PXCNAMESPACE >> "$LOGFILE"
  if [ ! -f $pxc_keycloak_ingress ]; then
    echo "Failed to create file: $pxc_keycloak_ingress, verify you have right access to create file: $pxc_keycloak_ingress"
    logError "Failed to create file: $pxc_keycloak_ingress, verify you have right access to create file: $pxc_keycloak_ingress"
    echo ""
    exit 1
  fi
  logInfo "Creating ingress for keycloak using spec: $pxc_keycloak_ingress"
  kubectl --kubeconfig=$KC apply -f $pxc_keycloak_ingress --namespace $PXCNAMESPACE >> "$LOGFILE"
  sleep 10
  ingresscheck="0"
  timecheck=0
  while [ $ingresscheck -ne "1" ]
    do
      ingressHostEndpoint=`kubectl --kubeconfig=$KC get ingress pxc-onprem-central-ingress --namespace $PXCNAMESPACE -o jsonpath={.status.loadBalancer.ingress[0].hostname} 2>&1 | grep -iv "error" | grep -v "No resources found" | grep -v "NotFound"`
      ingressIPEndpoint=`kubectl --kubeconfig=$KC get ingress pxc-onprem-central-ingress --namespace $PXCNAMESPACE -o jsonpath={.status.loadBalancer.ingress[0].ip} 2>&1 | grep -iv "error" | grep -v "No resources found" | grep -v "NotFound"`
      keycloakIngressHostEndpoint=`kubectl --kubeconfig=$KC get ingress pxc-onprem-central-keycloak-ingress --namespace $PXCNAMESPACE -o jsonpath={.status.loadBalancer.ingress[0].hostname} 2>&1 | grep -iv "error" | grep -v "No resources found" | grep -v "NotFound"`
      keycloakIngressIPEndpoint=`kubectl --kubeconfig=$KC get ingress pxc-onprem-central-keycloak-ingress --namespace $PXCNAMESPACE -o jsonpath={.status.loadBalancer.ingress[0].ip} 2>&1 | grep -iv "error" | grep -v "No resources found" | grep -v "NotFound"`
      if [[ ${ingressHostEndpoint} && ${keycloakIngressHostEndpoint} ]]; then
        ingresscheck="1"
        break
      elif [[ ${ingressIPEndpoint} && ${keycloakIngressIPEndpoint} ]]; then
        ingresscheck="1"
        break
      fi
      showMessage "Waiting for PX-Central-Onprem endpoint"
      logInfo "Waiting for PX-Central-Onprem endpoint.."
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $TIMEOUT ]; then
        echo ""
        podName=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "ingress-nginx-controller" | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
        kubectl --kubeconfig=$KC logs $podName --namespace $PXCNAMESPACE >> "$LOGFILE"
        echo "Nginx ingress controller deployment failed. check the pods status and logs in given namespace: $PXCNAMESPACE"
        echo "ERROR: PX-Central deployment failed, failed to get hostname. Contact: support@portworx.com"
        logError "PX-Central deployment failed, failed to get hostname. Contact: support@portworx.com"
        echo ""
        exit 1
      fi
    done
  if [[ ${ingressHostEndpoint} && ${keycloakIngressHostEndpoint} ]]; then
    PXCINPUTENDPOINT=$ingressHostEndpoint
    OIDCENDPOINT="$keycloakIngressHostEndpoint/keycloak"
  elif [[ ${ingressIPEndpoint} && ${keycloakIngressIPEndpoint} ]]; then
    PXCINPUTENDPOINT=$ingressIPEndpoint
    OIDCENDPOINT="$keycloakIngressIPEndpoint/keycloak"
  fi
  INGRESS_ENDPOINT=$PXCINPUTENDPOINT
  KEYCLOAK_INGRESS_ENDPOINT=$OIDCENDPOINT
  echo ""
  echo "PX-Central-Onprem Endpont: $INGRESS_ENDPOINT"
  echo "PX-Central-Onprem Keycloak Endpont: $KEYCLOAK_INGRESS_ENDPOINT"
  logInfo "PX-Central-Onprem Endpont: $INGRESS_ENDPOINT"
  logInfo "PX-Central-Onprem Keycloak Endpont: $KEYCLOAK_INGRESS_ENDPOINT"
fi

if [ -z ${PXCINPUTENDPOINT} ]; then
  PXENDPOINT=`kubectl --kubeconfig=$KC get nodes -o wide 2>&1 | grep -i "master" | awk '{print $6}' | head -n 1 2>&1`
  if [ -z ${PXENDPOINT} ]; then
    PXENDPOINT=`kubectl --kubeconfig=$KC get nodes -o wide 2>&1 | grep -v "master" | grep -v "INTERNAL-IP" | awk '{print $6}' | head -n 1 2>&1`
  fi

  if [ -z ${PXENDPOINT} ]; then
    echo "PX-Central endpoint empty."
    logError "PX-Central endpoint empty, Provide public endpoint to configure and access PX-Central."
    echo ""
    usage
    exit 1
  fi
else
  PXENDPOINT=$PXCINPUTENDPOINT
fi
echo "Using PX-Central Endpoint as: $PXENDPOINT"
logInfo "Using PX-Central Endpoint as: $PXENDPOINT"
echo ""

openshift_count=`kubectl --kubeconfig=$KC get nodes -o wide 2>&1 | grep -v NAME | grep -iv "error" | grep -v "No resources found" | awk '{print $8}' | grep -i "OpenShift" | wc -l 2>&1`
if [ "$openshift_count" -gt 0 ]; then
  OPENSHIFTCLUSTER="true"
fi

pxc_store_enabled=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.portworx} 2>&1`
pxc_backup_enabled=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.backup} 2>&1`
pxc_metrics_enabled=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.metrics} 2>&1`
pxc_sso_enabled=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.sso} 2>&1`
pxc_minik8s_enabled=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.minik8s} 2>&1`
logInfo "Existing configuration: PX-Store: $pxc_store_enabled, PX-Backup: $pxc_backup_enabled, PX-Metrics: $pxc_metrics_enabled, PX-SSO: $pxc_sso_enabled, PX-MiniK8s: $pxc_minik8s_enabled"
if [[ "$PX_STORE_DEPLOY" == "true" && "$pxc_store_enabled" == "false" ]]; then
  if [[ "$pxc_backup_enabled" == "true" || "$pxc_metrics_enabled" == "true" || "$pxc_sso_enabled" == "true" || "$pxc_minik8s_enabled" == "true" ]]; then
    echo ""
    echo "ERROR: Current PX-Central-Onprem cluster already has components running without px-store, px-store cannot be deployed."
    logInfo "Current PX-Central-Onprem cluster already has components running without px-store, px-store cannot be deployed."
    echo ""
    exit 1
  fi
fi

if [ "$PXCNAMESPACE" != "$PX_SECRET_NAMESPACE" ]; then
  kubectl --kubeconfig=$KC create namespace $PX_SECRET_NAMESPACE >> "$LOGFILE"
fi

if [ "$DOMAIN_SETUP_REQUIRED" == "true" ]; then
  if [ ! -f $pxc_domain ]; then
    echo "Failed to create file: $pxc_domain, verify you have right access to create file: $pxc_domain"
    logError "Failed to create file: $pxc_domain, verify you have right access to create file: $pxc_domain"
    echo ""
    exit 1
  fi
  logInfo "Creating ingress for px-central services with sub domains using spec: $pxc_domain"
  kubectl --kubeconfig=$KC apply -f $pxc_domain --namespace $PXCNAMESPACE >> "$LOGFILE"
fi

if [ "$CLOUD_STORAGE_ENABLED" == "true" ]; then
  if [[ "$AWS_CLOUD_PLATFORM" == "true" || "$AZURE_CLOUD_PLATFORM" == "true" ]]; then
    echo "Cloud platform: $CLOUDPLATFORM, Managed k8s service: $MANAGED_K8S_SERVICE, Disk type: $CLOUD_DATA_DISK_TYPE, Disk size: $CLOUD_DATA_DISK_SIZE"
    logInfo "Cloud platform: $CLOUDPLATFORM, Managed k8s service: $MANAGED_K8S_SERVICE, Disk type: $CLOUD_DATA_DISK_TYPE, Disk size: $CLOUD_DATA_DISK_SIZE"
    echo ""
  fi
  if [ -z ${PX_DISK_PROVISION_SECRET_NAME} ]; then
    if [ "$AWS_CLOUD_PLATFORM" == "true" ]; then
      kubectl --kubeconfig=$KC create secret generic $CLOUD_SECRET_NAME --from-literal=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID --from-literal=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY --namespace $PXCNAMESPACE &>/dev/null
    elif [ "$AZURE_CLOUD_PLATFORM" == "true" ]; then
      kubectl --kubeconfig=$KC create secret generic $CLOUD_SECRET_NAME --from-literal=AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET --from-literal=AZURE_CLIENT_ID=$AZURE_CLIENT_ID --from-literal=AZURE_TENANT_ID=$AZURE_TENANT_ID --namespace $PXCNAMESPACE &>/dev/null
    elif [[ "$VSPHERE_CLUSTER_DISK_PROVISION_REQUIRED" == "true" ]]; then
      kubectl --kubeconfig=$KC create secret generic $CLOUD_SECRET_NAME --from-literal=VSPHERE_USER=$VSPHERE_USER --from-literal=VSPHERE_PASSWORD=$VSPHERE_PASSWORD --namespace $PXCNAMESPACE &>/dev/null
    fi
  else
    CLOUD_SECRET_NAME=$PX_DISK_PROVISION_SECRET_NAME
  fi
  logInfo "Cloud portworx disk provision secret name: $CLOUD_SECRET_NAME"
  secretcheck="0"
  timecheck=0
  while [ $secretcheck -ne "1" ]
    do
      cloudSecret=`kubectl --kubeconfig=$KC get secret $CLOUD_SECRET_NAME --namespace $PXCNAMESPACE 2>&1 |  grep -v NAME | grep -v "No resources found" | wc -l 2>&1`
      if [ $cloudSecret -eq "1" ]; then
        logInfo "Cloud secret: $CLOUD_SECRET_NAME available into namespace: $PXCNAMESPACE"
        secretcheck="1"
        break
      fi
      showMessage "Preparing cloud secret: $CLOUD_SECRET_NAME into namespace: $PXCNAMESPACE"
      logInfo "Preparing cloud secret: $CLOUD_SECRET_NAME into namespace: $PXCNAMESPACE"
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $LBSERVICETIMEOUT ]; then
          echo ""
          echo "Failed to prepare cloud secret: $CLOUD_SECRET_NAME into namespace: $PXCNAMESPACE for auto disk provision, TIMEOUT: $LBSERVICETIMEOUT"
          logError "Failed to prepare cloud secret: $CLOUD_SECRET_NAME into namespace: $PXCNAMESPACE for auto disk provision, TIMEOUT: $LBSERVICETIMEOUT"
          echo "Contact: support@portworx.com"
          echo ""
          exit 1
      fi
      sleep $SLEEPINTERVAL
    done
fi

if [ "$PXCPROVISIONEDOIDC" == "true" ]; then
  KEYCLOAK_FRONTEND_PASSWORD=$ADMINPASSWORD
  KEYCLOAK_FRONTEND_USERNAME=$ADMINUSER
  kubectl --kubeconfig=$KC create secret generic $KEYCLOAK_BACKEND_SECRET --from-literal=postgresql-password=$KEYCLOAK_BACKEND_PASSWORD --namespace $PXCNAMESPACE &>/dev/null
  kubectl --kubeconfig=$KC create secret generic $KEYCLOAK_FRONTEND_SECRET --from-literal=password=$KEYCLOAK_FRONTEND_PASSWORD --namespace $PXCNAMESPACE &>/dev/null
  secretcheck="0"
  timecheck=0
  while [ $secretcheck -ne "1" ]
    do
      keyCloakFrontendSecret=`kubectl --kubeconfig=$KC get secret $KEYCLOAK_BACKEND_SECRET --namespace $PXCNAMESPACE 2>&1 |  grep -v NAME | grep -v "No resources found" | wc -l 2>&1`
      keyCloakBackendSecret=`kubectl --kubeconfig=$KC get secret $KEYCLOAK_FRONTEND_SECRET --namespace $PXCNAMESPACE 2>&1 |  grep -v NAME | grep -v "No resources found" | wc -l 2>&1`
      if [[ $keyCloakFrontendSecret -eq "1" && "$keyCloakBackendSecret" -eq "1" ]]; then
        secretcheck="1"
        break
      fi
      showMessage "Preparing oidc secret: $KEYCLOAK_BACKEND_SECRET and $KEYCLOAK_FRONTEND_SECRET into namespace: $PXCNAMESPACE"
      logInfo "Preparing oidc secret: $KEYCLOAK_BACKEND_SECRET and $KEYCLOAK_FRONTEND_SECRET into namespace: $PXCNAMESPACE"
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $LBSERVICETIMEOUT ]; then
          echo ""
          echo "Failed to prepare keycloak secrets: $KEYCLOAK_BACKEND_SECRET and $KEYCLOAK_FRONTEND_SECRET into namespace: $PXCNAMESPACE for OIDC, TIMEOUT: $LBSERVICETIMEOUT"
          logError "Failed to prepare keycloak secrets: $KEYCLOAK_BACKEND_SECRET and $KEYCLOAK_FRONTEND_SECRET into namespace: $PXCNAMESPACE for OIDC, TIMEOUT: $LBSERVICETIMEOUT"
          echo "Contact: support@portworx.com"
          echo ""
          exit 1
      fi
      sleep $SLEEPINTERVAL
    done

  OIDCCLIENTID=$PXC_OIDC_CLIENT_ID
  OIDCSECRET="dummy"
  pxcGrafanaEndpoint="http://pxc-grafana.$PXCNAMESPACE.svc.cluster.local:3000/grafana"
  logInfo "Grafana default endpoint: $pxcGrafanaEndpoint"
  if [ "$DOMAIN_SETUP_REQUIRED" == "true" ]; then
    OIDCENDPOINT="$PXC_KEYCLOAK/auth"
    EXTERNAL_ENDPOINT_URL=$PXC_FRONTEND
    pxcGrafanaEndpoint=$PXC_GRAFANA
    logInfo "Domain setup: OIDC Endpoint: $OIDCENDPOINT, External endpoint URL: $EXTERNAL_ENDPOINT_URL, Grafana Endpoint: $pxcGrafanaEndpoint"
  elif [ "$INGRESS_SETUP_REQUIRED" == "true" ]; then
    EXTERNAL_ENDPOINT_URL="$PXENDPOINT"
    pxcGrafanaEndpoint=$PXENDPOINT
    logInfo "Ingress setup: External endpoint URL: $EXTERNAL_ENDPOINT_URL, Grafana Endpoint: $pxcGrafanaEndpoint"
  else
    OIDCENDPOINT="$PXENDPOINT:$PXC_KEYCLOAK_HTTP_PORT/auth"
    EXTERNAL_ENDPOINT_URL="$PXENDPOINT:$PXC_UI_EXTERNAL_PORT"
    pxcGrafanaEndpoint="$PXENDPOINT:$PXC_UI_EXTERNAL_PORT"
    logInfo "Public IP setup: OIDC Endpoint: $OIDCENDPOINT, External endpoint URL: $EXTERNAL_ENDPOINT_URL, Grafana Endpoint: $pxcGrafanaEndpoint"
  fi
else
  EXTERNAL_ENDPOINT_URL="$PXENDPOINT:$PXC_UI_EXTERNAL_PORT"
  pxcGrafanaEndpoint="$PXENDPOINT:$PXC_UI_EXTERNAL_PORT"
  echo "External Endpoint: $EXTERNAL_ENDPOINT_URL"
  logInfo "External Endpoint: $EXTERNAL_ENDPOINT_URL"
fi

if [[ "$OIDCENABLED" == "true" &&  "$PX_BACKUP_DEPLOY" == "true" ]]; then
  echo "External Access OIDC Endpoint: $OIDCENDPOINT"
  logInfo "External Access OIDC Endpoint: $OIDCENDPOINT"
  oidc_endpoint="http://$OIDCENDPOINT/realms/master"
  logInfo "OIDC Endpoint: $oidc_endpoint"
  kubectl --kubeconfig=$KC create secret generic $BACKUP_OIDC_SECRET_NAME --from-literal=OIDC_CLIENT_ID=$OIDCCLIENTID --from-literal=OIDC_ENDPOINT=$oidc_endpoint --namespace $PXCNAMESPACE &>/dev/null
  backupsecretcheck="0"
  timecheck=0
  while [ $backupsecretcheck -ne "1" ]
    do
      cloudSecret=`kubectl --kubeconfig=$KC get secret $BACKUP_OIDC_SECRET_NAME --namespace $PXCNAMESPACE 2>&1 |  grep -v NAME | grep -iv "error" | grep -v "No resources found" | wc -l 2>&1`
      if [ $cloudSecret -eq "1" ]; then
        backupsecretcheck="1"
        break
      fi
      showMessage "Preparing oidc secret: $BACKUP_OIDC_SECRET_NAME into namespace: $PXCNAMESPACE"
      logInfo "Preparing oidc secret: $BACKUP_OIDC_SECRET_NAME into namespace: $PXCNAMESPACE"
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $LBSERVICETIMEOUT ]; then
          echo ""
          echo "Failed to create OIDC secret for PX-Backup: $BACKUP_OIDC_SECRET_NAME into namespace: $PXCNAMESPACE for auto disk provision, TIMEOUT: $LBSERVICETIMEOUT"
          logInfo "Failed to create OIDC secret for PX-Backup: $BACKUP_OIDC_SECRET_NAME into namespace: $PXCNAMESPACE for auto disk provision, TIMEOUT: $LBSERVICETIMEOUT"
          echo "Contact: support@portworx.com"
          echo ""
          exit 1
      fi
      sleep $SLEEPINTERVAL
    done
fi

if [ "$CUSTOMREGISTRYENABLED" == "true" ]; then
  echo "Verifying image pull secret [$IMAGEPULLSECRET] in namespace [$PXCNAMESPACE]"
  logInfo "Verifying image pull secret [$IMAGEPULLSECRET] in namespace [$PXCNAMESPACE]"
  validatesecret=`kubectl --kubeconfig=$KC get secret $IMAGEPULLSECRET  --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | grep -iv "error" | grep -v "not found" | awk '{print $1}' | wc -l 2>&1`
  logDebug "Validate secret status: $validatesecret"
  if [ $validatesecret -ne "1" ]; then
    echo "ERROR: --image-pull-secret provided is not present in $PXCNAMESPACE namespace, please create it in $PXCNAMESPACE namespace and re-run the script"
    logError "--image-pull-secret provided is not present in $PXCNAMESPACE namespace, please create it in $PXCNAMESPACE namespace and re-run the script"
    exit 1
  else
    echo "Image pull secret: $IMAGEPULLSECRET present in namespace: $PXCNAMESPACE"
  fi
fi

if [ -z $IMAGEPULLSECRET ]; then
  IMAGEPULLSECRET="docregistry-secret"
fi

if [ ${OPENSHIFTCLUSTER} ]; then
  if [ "$OPENSHIFTCLUSTER" == "true" ]; then
    ISOPENSHIFTCLUSTER="true"
    if [ "$PX_BACKUP_DEPLOY" == "true" ]; then
      echo "Detected OpenShift system. Adding $PX_BACKUP_SERVICE_ACCOUNT user to privileged scc"
      logInfo "Detected OpenShift system. Adding $PX_BACKUP_SERVICE_ACCOUNT user to privileged scc"
      oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PX_BACKUP_SERVICE_ACCOUNT >> "$LOGFILE"
      if [ $? -ne 0 ]; then
        echo "failed to add $PX_BACKUP_SERVICE_ACCOUNT to privileged scc. exit code: $?"
        logError "failed to add $PX_BACKUP_SERVICE_ACCOUNT to privileged scc. exit code: $?"
      fi
    fi
    if [ "$PXCPROVISIONEDOIDC" == "true" ]; then
      echo "Detected OpenShift system. Adding $PX_KEYCLOAK_SERVICE_ACCOUNT user to privileged scc"
      logInfo "Detected OpenShift system. Adding $PX_KEYCLOAK_SERVICE_ACCOUNT user to privileged scc"
      oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PX_KEYCLOAK_SERVICE_ACCOUNT >> "$LOGFILE"
      if [ $? -ne 0 ]; then
        echo "failed to add $PX_KEYCLOAK_SERVICE_ACCOUNT to privileged scc. exit code: $?"
        logError "failed to add $PX_KEYCLOAK_SERVICE_ACCOUNT to privileged scc. exit code: $?"
      fi
    fi
    if [ "$PX_STORE_DEPLOY" == "true" ]; then
      echo "Detected OpenShift system. Adding $PXC_PX_SERVICE_ACCOUNT user to privileged scc"
      logInfo "Detected OpenShift system. Adding $PXC_PX_SERVICE_ACCOUNT user to privileged scc"
      oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PXC_PX_SERVICE_ACCOUNT >> "$LOGFILE"
      if [ $? -ne 0 ]; then
        echo "failed to add $PXC_PX_SERVICE_ACCOUNT to privileged scc. exit code: $?"
        logError "failed to add $PXC_PX_SERVICE_ACCOUNT to privileged scc. exit code: $?"
      fi
      echo "Detected OpenShift system. Adding $PXC_PVC_CONTROLLER_SERVICE_ACCOUNT user to privileged scc"
      logInfo "Detected OpenShift system. Adding $PXC_PVC_CONTROLLER_SERVICE_ACCOUNT user to privileged scc"
      oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PXC_PVC_CONTROLLER_SERVICE_ACCOUNT >> "$LOGFILE"
      if [ $? -ne 0 ]; then
        echo "failed to add $PXC_PVC_CONTROLLER_SERVICE_ACCOUNT to privileged scc. exit code: $?"
        logError "failed to add $PXC_PVC_CONTROLLER_SERVICE_ACCOUNT to privileged scc. exit code: $?"
      fi      
    fi
    if [ "$PX_METRICS_DEPLOY" == "true" ]; then
      echo "Detected OpenShift system. Adding $PXC_PROMETHEUS_SERVICE_ACCOUNT user to privileged scc"
      logInfo "Detected OpenShift system. Adding $PXC_PROMETHEUS_SERVICE_ACCOUNT user to privileged scc"
      oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PXC_PROMETHEUS_SERVICE_ACCOUNT >> "$LOGFILE"
      if [ $? -ne 0 ]; then
        echo "failed to add $PXC_PROMETHEUS_SERVICE_ACCOUNT to privileged scc. exit code: $?"
        logError "failed to add $PXC_PROMETHEUS_SERVICE_ACCOUNT to privileged scc. exit code: $?"
      fi
    fi
    if [ "$PX_LICENSE_SERVER_DEPLOY" == "true" ]; then
      echo "Detected OpenShift system. Adding $PXC_LICENSE_SERVER_SERVICE_ACCOUNT user to privileged scc"
      logInfo "Detected OpenShift system. Adding $PXC_LICENSE_SERVER_SERVICE_ACCOUNT user to privileged scc"
      oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PXC_LICENSE_SERVER_SERVICE_ACCOUNT >> "$LOGFILE"
      if [ $? -ne 0 ]; then
        echo "failed to add $PXC_LICENSE_SERVER_SERVICE_ACCOUNT to privileged scc. exit code: $?"
        logError "failed to add $PXC_LICENSE_SERVER_SERVICE_ACCOUNT to privileged scc. exit code: $?"
      fi
    fi
    echo "Detected OpenShift system. Adding $PXC_INGRESS_CONTROLLER_SERVICE_ACCOUNT user to privileged scc"
    logInfo "Detected OpenShift system. Adding $PXC_INGRESS_CONTROLLER_SERVICE_ACCOUNT user to privileged scc"
    oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PXC_INGRESS_CONTROLLER_SERVICE_ACCOUNT >> "$LOGFILE"
    if [ $? -ne 0 ]; then
      echo "failed to add $PXC_INGRESS_CONTROLLER_SERVICE_ACCOUNT to privileged scc. exit code: $?"
      logError "failed to add $PXC_INGRESS_CONTROLLER_SERVICE_ACCOUNT to privileged scc. exit code: $?"
    fi
    echo "Detected OpenShift system. Adding $PXC_OPERATOR_SERVICE_ACCOUNT user to privileged scc"
    logInfo "Detected OpenShift system. Adding $PXC_OPERATOR_SERVICE_ACCOUNT user to privileged scc"
    oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PXC_OPERATOR_SERVICE_ACCOUNT >> "$LOGFILE"
    if [ $? -ne 0 ]; then
      echo "failed to add $PXC_OPERATOR_SERVICE_ACCOUNT to privileged scc. exit code: $?"
      logError "failed to add $PXC_OPERATOR_SERVICE_ACCOUNT to privileged scc. exit code: $?"
    fi
  fi
fi

PXDAEMONSETDEPLOYMENT="false"
PVC_CONTROLLER_REQUIRED="false"
STORK_PROVISION_REQUIRED="false"
if [[ "$PXCENTRAL_PX_APP_SAME_K8S_CLUSTER" == "true" && "$PX_STORE_DEPLOY" == "true" ]]; then
  PXDAEMONSETDEPLOYMENT="true"
  PXOPERATORDEPLOYMENT="false"
  OPERATOR_UNSUPPORTED_CLUSTER="false"
  STORK_SCHEDULER_REQUIRED="false"
elif [[ "$OPERATOR_UNSUPPORTED_CLUSTER" == "true" && "$PX_STORE_DEPLOY" == "true" ]]; then
  PXDAEMONSETDEPLOYMENT="true"
  PXOPERATORDEPLOYMENT="false"
fi

if [[ "$PXDAEMONSETDEPLOYMENT" == "true" && "$PXCNAMESPACE" != "$STANDARD_NAMESPACE" ]]; then
  PVC_CONTROLLER_REQUIRED="true"
fi

modules_config="/tmp/pxc-modules.yaml"
logInfo "Modules spec: $modules_config"
cat <<< '
apiVersion: v1
kind: ConfigMap
metadata:
  name: '$PXC_MODULES_CONFIG'
  namespace: '$PXCNAMESPACE'
data:
  backup: '\"$PX_BACKUP_DEPLOY\"'
  licenseserver: '\"$PX_LICENSE_SERVER_DEPLOY\"'
  metrics: '\"$PX_METRICS_DEPLOY\"'
  minik8s: '\"$PXCENTRAL_MINIK8S\"'
  portworx: '\"$PX_STORE_DEPLOY\"'
  sso: '\"$OIDCENABLED\"'
  centralpx: '\"$CENTRAL_DEPLOYED_PX\"'
  existingpx: '\"$USE_EXISTING_PX\"'
  daemonsetpx: '\"$PXDAEMONSETDEPLOYMENT\"'
  operatorpx: '\"$PXOPERATORDEPLOYMENT\"'
' > $modules_config

central_px=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.centralpx} 2>&1`
existing_px=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.existingpx} 2>&1`
daemonset_px=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.daemonsetpx} 2>&1`
operator_px=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.operatorpx} 2>&1`
metrics_store_enabled=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.metrics} 2>&1`
license_server_enabled=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.licenseserver} 2>&1`
logInfo "Central PX: $central_px, Existing px: $existing_px, Daemonset based portworx: $daemonset_px, Operator based portworx: $operator_px, Metric store: $metrics_store_enabled, License server: $license_server_enabled"
if [ "$central_px" == "true" ]; then
  existingpx="false"
fi
if [ "$existingpx" == "true" ]; then
  central_px="false"
fi
if [[ "$USE_EXISTING_PX" == "true" && "$existing_px" == "true" ]]; then
  echo "Using existing px cluster for PX-Central-Onprem setup"
  logInfo "Using existing px cluster for PX-Central-Onprem setup"
  PXDAEMONSETDEPLOYMENT="false"
  PXOPERATORDEPLOYMENT="false"
fi
config_check=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE 2>&1 | grep -iv "error" | grep -v "NotFound" | grep -v "No resources found" | grep -v NAME | awk '{print $1}' | wc -l 2>&1`
if [[ "$metrics_store_enabled" == "false" && "$PX_METRICS_DEPLOY" == "true" ]]; then
  config_check=0
fi
if [[ "$license_server_enabled" == "false" && "$PX_LICENSE_SERVER_DEPLOY" == "true" ]]; then
  config_check=0
fi
if [ $config_check -eq 0 ]; then
  if [ ! -f $modules_config ]; then
    echo "Failed to create file: $modules_config, verify you have right access to create file: $modules_config"
    logError "Failed to create file: $modules_config, verify you have right access to create file: $modules_config"
    echo ""
    exit 1
  fi
  logInfo "Creating modules config using spec: $modules_config"
  kubectl --kubeconfig=$KC apply -f $modules_config --namespace $PXCNAMESPACE >> "$LOGFILE"
  if [[ "$license_server_enabled" == "false" && "$PX_LICENSE_SERVER_DEPLOY" == "true" ]]; then
    kubectl --kubeconfig=$KC delete job pxc-pre-setup --namespace $PXCNAMESPACE >> "$LOGFILE"
    sleep $SLEEPINTERVAL
    kubectl --kubeconfig=$KC delete job pxc-ls-ha-setup --namespace $PXCNAMESPACE >> "$LOGFILE"
  fi
else
  if [[ "$central_px" == "true" && "$daemonset_px" == "true" ]]; then
    PXDAEMONSETDEPLOYMENT="true"
    PXOPERATORDEPLOYMENT="false"
  elif [[ "$central_px" == "true" && "$operator_px" == "true" ]]; then
    PXOPERATORDEPLOYMENT="true"
    PXDAEMONSETDEPLOYMENT="false"
  elif [[ "$existing_px" == "true" || "$PX_STORE_DEPLOY" == "false" ]]; then
    PXOPERATORDEPLOYMENT="false"
    PXDAEMONSETDEPLOYMENT="false"
    OPERATOR_UNSUPPORTED_CLUSTER="false"
    PXCENTRAL_PX_APP_SAME_K8S_CLUSTER="false"
  fi
fi

if [ "$PX_STORE_DEPLOY" == "false" ]; then
  PXOPERATORDEPLOYMENT="false"
  PXDAEMONSETDEPLOYMENT="false"
fi

if [ "$PXDAEMONSETDEPLOYMENT" == "true" ]; then
  echo "PX daemonset deployment: $PXDAEMONSETDEPLOYMENT"
elif [ "$PXOPERATORDEPLOYMENT" == "true" ]; then
  echo "PX operator deployment: $PXOPERATORDEPLOYMENT"
fi

if [ "$PXCENTRAL_MINIK8S"  == "false" ]; then
  PX_STORE_DEPLOY="true"
fi

storkPodsCount=`kubectl --kubeconfig=$KC get pods -lname=stork --all-namespaces 2>&1 |  grep -v NAME | grep -iv "error" | grep -v "No resources found" | wc -l 2>&1`
if [[ $storkPodsCount -lt 3  && "$PXDAEMONSETDEPLOYMENT" == "true" ]]; then
  STORK_PROVISION_REQUIRED="true"
fi
logInfo "Operator based portworx deployment: $PXOPERATORDEPLOYMENT"
logInfo "Daemonset based portworx deployment: $PXDAEMONSETDEPLOYMENT"
logInfo "Operator unsupported cluster: $OPERATOR_UNSUPPORTED_CLUSTER"
logInfo "Stork scheduler required: $STORK_SCHEDULER_REQUIRED"
logInfo "Stork provision required: $STORK_PROVISION_REQUIRED"
logInfo "PVC Controller required: $PVC_CONTROLLER_REQUIRED"
logInfo "Openshift cluster: $ISOPENSHIFTCLUSTER"
logInfo "PX-Central namespace: $PXCNAMESPACE, Portworx cluster name: $PXCPXNAME"
if [ "$ISCLOUDDEPLOYMENT" == "true" ]; then
  logInfo "Cloud deployment: $ISCLOUDDEPLOYMENT, $AWS Cloud : $AWS_CLOUD_PLATFORM, GCP: $GOOGLE_CLOUD_PLATFORM, Azure: $AZURE_CLOUD_PLATFORM, IBM: $IBM_CLOUD_PLATFORM, vSphere: $VSPHERE_CLUSTER, PKS: $PKS_CLUSTER_ENABLED"
  logInfo "Cloud disk provision secret name: $CLOUD_SECRET_NAME"
  logInfo "Cloud storage enabled: $CLOUD_STORAGE_ENABLED, Disk type: $CLOUD_DATA_DISK_TYPE, Disk size: $CLOUD_DATA_DISK_SIZE"
  logInfo "EKS cluster: $EKS_CLUSTER_TYPE, GKE Cluster: $GKE_CLUSTER_TYPE, AKS cluster: $AKS_CLUSTER_TYPE"
fi
if [ "$ISOPENSHIFTCLUSTER" == "true" ]; then
prometheus_cluster_role="/tmp/px-prometheus-clusterrole.yaml"
logInfo "Prometheus cluster role template: $prometheus_cluster_role"
cat <<< '
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: px-prometheus
  namespace: '$PXCNAMESPACE'
rules:
  - apiGroups: [""]
    resources:
      - nodes
      - services
      - endpoints
      - pods
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources:
      - configmaps
    verbs: ["get"]
  - nonResourceURLs: ["/metrics", "/federate"]
    verbs: ["get"]
' > $prometheus_cluster_role

  if [ ! -f $prometheus_cluster_role ]; then
      echo "Failed to create file: $prometheus_cluster_role, verify you have right access to create file: $prometheus_cluster_role"
      logError "Failed to create file: $prometheus_cluster_role, verify you have right access to create file: $prometheus_cluster_role"
      echo ""
      exit 1
  fi
  logInfo "Creating prometheus cluster role using spec: $prometheus_cluster_role"
  kubectl --kubeconfig=$KC apply -f $prometheus_cluster_role  >> "$LOGFILE"
fi

pxcentral_onprem_crd="/tmp/pxcentralonprem_crd.yaml"
logInfo "Onprem CRD spec: $pxcentral_onprem_crd"
cat <<< '
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
   name: pxcentral-onprem-operator
   namespace: '$PXCNAMESPACE'
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pxcentral-onprem-operator
  namespace: '$PXCNAMESPACE'
subjects:
- kind: ServiceAccount
  name: pxcentral-onprem-operator
  namespace: '$PXCNAMESPACE'
roleRef:
  kind: ClusterRole
  name: pxcentral-onprem-operator
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: px-cluster-admin-binding
  namespace: '$PXCNAMESPACE'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: system:serviceaccount:$PXCNAMESPACE:default
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: pxc-onprem-operator-cluster-admin-binding
  namespace: '$PXCNAMESPACE'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: system:serviceaccount:$PXCNAMESPACE:pxcentral-onprem-operator
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pxcentral-onprem-operator
  namespace: '$PXCNAMESPACE'
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: '$PXCNAMESPACE'
  name: pxcentral-onprem-operator
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - services
  - services/finalizers
  - endpoints
  - persistentvolumeclaims
  - events
  - configmaps
  - secrets
  verbs:
  - "*"
- apiGroups:
  - apps
  resources:
  - deployments
  - daemonsets
  - replicasets
  - statefulsets
  verbs:
  - "*"
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  verbs:
  - "*"
- apiGroups:
  - monitoring.coreos.com
  resources:
  - servicemonitors
  verbs:
  - get
  - create
- apiGroups:
  - apps
  resourceNames:
  - pxcentral-onprem-operator
  resources:
  - deployments/finalizers
  verbs:
  - update
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
- apiGroups:
  - apps
  resources:
  - replicasets
  - deployments
  verbs:
  - get
- apiGroups:
  - pxcentral.com
  resources:
  - "*"
  verbs:
  - "*"
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: pxcentralonprems.pxcentral.com
  namespace: '$PXCNAMESPACE'
spec:
  group: pxcentral.com
  names:
    kind: PxCentralOnprem
    listKind: PxCentralOnpremList
    plural: pxcentralonprems
    singular: pxcentralonprem
    shortNames:
    - pxc
  scope: Namespaced
  subresources:
    status: {}
  versions:
  - name: v1alpha1
    served: true
    storage: true
---
apiVersion: v1
kind: Service
metadata:
  name: px-central
  namespace: '$PXCNAMESPACE'
  labels:
    app: px-central
spec:
  selector:
    app: px-central
  ports:
    - name: px-central-grpc
      protocol: TCP
      port: 10005
      targetPort: 10005
    - name: px-central-rest
      protocol: TCP
      port: 10006
      targetPort: 10006
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pxcentral-onprem-operator
  namespace: '$PXCNAMESPACE'
spec:
  replicas: 1
  selector:
    matchLabels:
      name: pxcentral-onprem-operator
      app: px-central
  template:
    metadata:
      labels:
        name: pxcentral-onprem-operator
        app: px-central
    spec:
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
              - matchExpressions:
                - key: '$NODE_AFFINITY_KEY'
                  operator: NotIn
                  values:
                  - '\"$NODE_AFFINITY_VALUE\"'
        initContainers:
        - command:
          - python
          - /specs/pxc-pre-setup.py
          image: '$PXCPRESETUPIMAGE'
          imagePullPolicy: '$IMAGEPULLPOLICY'
          env:
            - name: PXC_NAMESPACE
              value: '$PXCNAMESPACE'
          name: pxc-pre-setup
          resources: {}
          securityContext:
            privileged: true
        serviceAccount: pxcentral-onprem-operator
        serviceAccountName: pxcentral-onprem-operator
        containers:
          - name: pxcentral-onprem-operator
            image: '$ONPREMOPERATORIMAGE'
            imagePullPolicy: '$IMAGEPULLPOLICY'
            env:
              - name: OPERATOR_NAME
                value: pxcentral-onprem-operator
              - name: POD_NAME
                valueFrom:
                  fieldRef:
                    apiVersion: v1
                    fieldPath: metadata.name
              - name: WATCH_NAMESPACE
                valueFrom:
                  fieldRef:
                    apiVersion: v1
                    fieldPath: metadata.namespace
          - name: px-central
            image: '$PXCENTRALAPISERVER'
            env:
              - name: PXC_NAMESPACE
                value: '$PXCNAMESPACE'
            imagePullPolicy: '$IMAGEPULLPOLICY'
            readinessProbe:
              httpGet:
                path: /v1/health
                port: 10006
              initialDelaySeconds: 10
              timeoutSeconds: 120
              periodSeconds: 20
            resources:
              limits:
                cpu: 512m
                memory: "512Mi"
              requests:
                memory: "512Mi"
                cpu: 256m
            securityContext:
              privileged: true
            command:
            - /pxcentral-onprem
            - start
        imagePullSecrets:
        - name: '$IMAGEPULLSECRET'
' > $pxcentral_onprem_crd

pxcentral_onprem_cr="/tmp/pxcentralonprem_cr.yaml"
logInfo "Onprem CR spec: $pxcentral_onprem_cr"
cat <<< '
apiVersion: pxcentral.com/v1alpha1
kind: PxCentralOnprem
metadata:
  name: pxcentralonprem
  namespace: '$PXCNAMESPACE'
spec:
  namespace: '$PXCNAMESPACE'                    # Provide namespace to install px and pxcentral stack
  k8sVersion: '$k8sVersion'
  nodeAffinityKey: '$NODE_AFFINITY_KEY'
  nodeAffinityValue: '$NODE_AFFINITY_VALUE'
  storkRequired: '$STORK_SCHEDULER_REQUIRED'
  storkProvisionRequired: '$STORK_PROVISION_REQUIRED'
  portworx:
    pxstore: '$PX_STORE_DEPLOY'
    enabled: '$PXOPERATORDEPLOYMENT'
    daemonsetDeployment: '$PXDAEMONSETDEPLOYMENT' 
    clusterName: '$PXCPXNAME'   # Note: Use a unique name for your cluster: The characters allowed in names are: digits (0-9), lower case letters (a-z) and (-)
    pxOperatorImage: '$PXOPERATORIMAGE'
    pxDevImage: '$PXDEVIMAGE'
    storkImage: '$STORK_IMAGE'
    pvcControllerRequired: '$PVC_CONTROLLER_REQUIRED'
    security:
      enabled: false
      oidc:
        enabled: false
      selfSigned:
        enabled: false
  centralLighthouse:
    enabled: '$PX_LIGHTHOUSE_DEPLOY'
    externalHttpPort: '$PXC_LIGHTHOUSE_HTTP_PORT'
    externalHttpsPort: '$PXC_LIGHTHOUSE_HTTPS_PORT'
  externalEndpoint: '$EXTERNAL_ENDPOINT_URL'       # For ingress endpint only
  loadBalancerEndpoint: '$PXENDPOINT'
  username: '$ADMINUSER'                       
  password: '$ADMINPASSWORD'
  email: '$ADMINEMAIL'
  imagePullSecrets: '$IMAGEPULLSECRET'
  customRegistryURL: '$CUSTOMREGISTRY'
  customeRegistryEnabled: '$CUSTOMREGISTRYENABLED'
  imagesRepoName: '$IMAGEREPONAME'
  imagePullPolicy: '$IMAGEPULLPOLICY'
  isOpenshiftCluster: '$ISOPENSHIFTCLUSTER'
  ingressAPIVersionChangeRequired: '$INGRESS_CHANGE_REQUIRED'
  cloud:
    aws: '$AWS_CLOUD_PLATFORM'
    cloudSecretName: '$CLOUD_SECRET_NAME'
    gcp: '$GOOGLE_CLOUD_PLATFORM'
    azure: '$AZURE_CLOUD_PLATFORM'
    ibm: '$IBM_CLOUD_PLATFORM'
    isCloud: '$ISCLOUDDEPLOYMENT'
    cloudStorage: '$CLOUD_STORAGE_ENABLED'
    cloudDataDiskType: '$CLOUD_DATA_DISK_TYPE'
    cloudDataDiskSize: '$CLOUD_DATA_DISK_SIZE'
    eksCluster: '$EKS_CLUSTER_TYPE'
    gkeCluster: '$GKE_CLUSTER_TYPE'
    aksCluster: '$AKS_CLUSTER_TYPE'
    awsDiskProvisionRequired: '$AWS_DISK_PROVISIONED_REQUIRED'
    gcpDiskProvisionRequired: '$GCP_DISK_PROVISIONED_REQUIRED'
    azureDiskProvisionRequired: '$AZURE_DISK_PROVISIONED_REQUIRED'
  pks:
    enabled: '$PKS_CLUSTER_ENABLED'
  vshpere:
    enabled: '$VSPHERE_CLUSTER'
    vshpereDiskProvisionRequired: '$VSPHERE_CLUSTER_DISK_PROVISION_REQUIRED'
    secretName: '$CLOUD_SECRET_NAME'
    vsphereVcenter: '$VSPHERE_VCENTER'
    vsphereVcenterPort: '$VSPHERE_VCENTER_PORT'
    vsphereInsecure: '$VSPHERE_INSECURE'
    vsphereInstallationMode: '$VSPHERE_INSTALL_MODE'
    vsphereDatastorePrefix: '$VSPHERE_DATASTORE_PREFIX'
  ocp:
    enabled: '$OPERATOR_UNSUPPORTED_CLUSTER'
  monitoring:
    prometheus:
      enabled: '$PX_METRICS_DEPLOY'
      externalPort: '$PXC_METRICS_STORE_PORT'
      externalEndpoint: '$METRICS_ENDPOINT'
    grafana:
      enabled: '$PX_METRICS_DEPLOY'
      endpoint: '$pxcGrafanaEndpoint'
  frontendEndpoint: '$PXC_FRONTEND'
  backendEndpoint: '$PXC_BACKEND'
  middlewareEndpoint: '$PXC_MIDDLEWARE'
  grafanaEndpoint: '$PXC_GRAFANA'
  keycloakEndpoint: '$PXC_KEYCLOAK'
  ingressEndpoint: '$INGRESS_ENDPOINT'
  cortexEndpoint: '$PXC_CORTEX_ENDPOINT'
  proxyForwarding:
    enabled: '$ENABLE_PROXY_FORWARDING'
    deployURL: '$PROXY_DEPLOY_URL'
    image: '$PXC_PROXY_FORWARDING_IMAGE'
  pxcentral:
    enabled: true
    pxcApiServer: '$PXCENTRALAPISERVER'
    domainSetupRequired: '$DOMAIN_SETUP_REQUIRED'
    publicEndpointSetupRequired: '$PUBLIC_ENDPOINT_SETUP_REQUIRED'
    ingressSetupRequired: '$INGRESS_SETUP_REQUIRED'
    pxcui:                    # Deploy PX-Central UI, required on pxcentral cluster only 
      enabled: true
      externalAccessPort: '$PXC_UI_EXTERNAL_PORT'
      security:
        pxcProvisionedOIDC: '$PXCPROVISIONEDOIDC'
        keyCloakAdminUser: '$KEYCLOAK_FRONTEND_USERNAME'
        keyCloakExternalPortHttp: '$PXC_KEYCLOAK_HTTP_PORT'
        keyCloakExternalPortHttps: '$PXC_KEYCLOAK_HTTPS_PORT'
        enabled: '$OIDCENABLED'
        clientId: '$OIDCCLIENTID'
        clientSecret: '$OIDCSECRET'
        oidcEndpoint: '$OIDCENDPOINT'
      metallb:
        enabled: false
      pxcentralFrontendImage: '$PX_CENTRAL_FRONTEND'
      pxcentralBackendImage: '$PX_CENTRAL_BACKEND'
      pxcentralMiddlewareImage: '$PX_CENTRAL_MIDDLEWARE'
    licenseserver:            # License Server
      enabled: '$PX_LICENSE_SERVER_DEPLOY'
      type:
        UAT: '$UATLICENCETYPE'
        airgapped: '$AIRGAPPEDLICENSETYPE'
      adminPassword: '$LICENSEADMINPASSWORD'
    etcd:
      enabled: '$PX_ETCD_DEPLOY'
      singleETCD: '$PX_SINGLE_ETCD_DEPLOY'
      externalEtcdClientPort: '$PXC_ETCD_EXTERNAL_CLIENT_PORT'
    pxbackup:
      enabled: '$PX_BACKUP_DEPLOY'
      image: '$PXBACKUPIMAGE'
      orgName: '$PX_BACKUP_ORGANIZATION'
' > $pxcentral_onprem_cr

mac_daemonset="/tmp/pxc-mac-check.yaml"
logInfo "License server label set based on mac address spec: $mac_daemonset"
cat <<< '
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pxc-license-ha
  namespace: '$PXCNAMESPACE'
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pxc-license-ha-role
  namespace: '$PXCNAMESPACE'
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pxc-license-ha-role-binding
  namespace: '$PXCNAMESPACE'
subjects:
- kind: ServiceAccount
  name: pxc-license-ha
  namespace: '$PXCNAMESPACE'
roleRef:
  kind: ClusterRole
  name: pxc-license-ha-role
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    run: pxc-mac-setup
  name: pxc-mac-setup
  namespace: '$PXCNAMESPACE'
spec:
  selector:
    matchLabels:
      run: pxc-mac-setup
  minReadySeconds: 0
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  template:
    metadata:
      labels:
        run: pxc-mac-setup
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: '$NODE_AFFINITY_KEY'
                operator: NotIn
                values:
                - '\"$NODE_AFFINITY_VALUE\"'
      hostNetwork: true
      hostPID: false
      restartPolicy: Always
      serviceAccountName: pxc-license-ha
      containers:
      - args:
        - bash
        - -c
        - python3 /code/setup_mac_address.py
        image: '$PXCLSLABELSETIMAGE'
        env:
          - name: PXC_NAMESPACE
            value: '$PXCNAMESPACE'
        imagePullPolicy: '$IMAGEPULLPOLICY'
        name: pxc-mac-setup
      imagePullSecrets:
        - name: '$IMAGEPULLSECRET'
' > $mac_daemonset

echo "PX-Central cluster deployment started:"
echo "This process may take several minutes. Please wait for it to complete..."
logInfo "PX-Central cluster deployment started:"
logInfo "This process may take several minutes. Please wait for it to complete..."
if [ "$PX_LICENSE_SERVER_DEPLOY" == "true" ]; then
  pxclicensecm="0"
  main_node_count=`kubectl --kubeconfig=$KC get nodes -lprimary/ls=true 2>&1 | grep Ready | wc -l 2>&1`
  backup_node_count=`kubectl --kubeconfig=$KC get nodes -lbackup/ls=true 2>&1 | grep Ready | wc -l 2>&1`
  logInfo "Main node count: $main_node_count, Backup node count: $backup_node_count"
  if [[ $main_node_count -eq 1 && $backup_node_count -eq 1 ]]; then
    pxclicensecm="1"
  fi
  pxclicensecmcreated="0"
  timecheck=0
  count=0

  if [ "$pxclicensecm" -eq "0" ]; then
    if [ ! -f $mac_daemonset ]; then
      echo "Failed to create file: $mac_daemonset, verify you have right access to create file: $mac_daemonset"
      logInfo "Failed to create file: $mac_daemonset, verify you have right access to create file: $mac_daemonset"
      echo ""
      exit 1
    fi
    logInfo "Creating mac address daemonset for license label set using spec: $mac_daemonset"
    kubectl --kubeconfig=$KC apply -f $mac_daemonset >> "$LOGFILE"
    sleep $SLEEPINTERVAL
    kubectl --kubeconfig=$KC get po -lrun=pxc-mac-setup --namespace $PXCNAMESPACE >> "$LOGFILE"
  fi

  while [ $pxclicensecm -ne "1" ]
    do
      logInfo "License server label set, daemonset pods:"
      kubectl --kubeconfig=$KC get po -lrun=pxc-mac-setup --namespace $PXCNAMESPACE >> "$LOGFILE"
      pxcentral_license_cm=`kubectl --kubeconfig=$KC get cm --namespace $PXCNAMESPACE 2>&1 | grep -i "pxc-lsc-hasetup" | wc -l 2>&1`
      if [ "$PXCENTRAL_PX_APP_SAME_K8S_CLUSTER" == "true" ]; then
        nodeCount=`kubectl --kubeconfig=$KC get nodes -l $NODE_AFFINITY_KEY=true 2>&1 | grep -v NAME | awk '{print $1}' | wc -l 2>&1`
      fi
      if [ "$pxcentral_license_cm" -eq "$nodeCount" ]; then
        pxclicensecm="1"
        pxclicensecmcreated="1"
        break
      fi
      showMessage "Waiting for PX-Central required components --License-Server-Labels-- to be ready (0/7)"
      logInfo "Waiting for PX-Central required components --License-Server-Labels-- to be ready (0/7)"
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $LBSERVICETIMEOUT ]; then
        logDebug "Starting labeling of nodes for the license server."
        showMessage "Starting labeling of nodes for the license server."
        kubectl --kubeconfig=$KC get po -lrun=pxc-mac-setup --namespace $PXCNAMESPACE >> "$LOGFILE"
        logError "License server label set pre-setup job pod:"
        kubectl --kubeconfig=$KC get po -ljob-name=pxc-pre-setup --namespace $PXCNAMESPACE >> "$LOGFILE"
        echo "Failed to set license server deployment required labels to the worker nodes. check the logs of following pods: "
        echo "1. kubectl --kubeconfig=$KC get po -lrun=pxc-mac-setup --namespace $PXCNAMESPACE"
        echo "2. kubectl --kubeconfig=$KC get po -ljob-name=pxc-pre-setup --namespace $PXCNAMESPACE"
        echo "Run following commands to proceed: select any 2 worker nodes for license server deployments."
        echo "1: kubectl label node <NODE-A> px/ls=true"
        echo "2: kubectl label node <NODE-A> primary/ls=true"
        echo "3. kubectl label node <NODE-B> px/ls=true"
        echo "4. kubectl label node <NODE-B> backup/ls=true"
        echo "Delete daemonset using command: kubectl --kubeconfig=$KC delete ds pxc-mac-setup --namespace $PXCNAMESPACE"
        exit 1
      fi
    done
  if [ "$pxclicensecmcreated" -eq "1" ]; then
    kubectl --kubeconfig=$KC delete -f $mac_daemonset >> "$LOGFILE"
  fi
  main_node_count=`kubectl --kubeconfig=$KC get nodes -lprimary/ls=true 2>&1 | grep Ready | wc -l 2>&1`
  backup_node_count=`kubectl --kubeconfig=$KC get nodes -lbackup/ls=true 2>&1 | grep Ready | wc -l 2>&1`
  logInfo "License servers: Main: $main_node_count, Backup: $backup_node_count"
fi

if [ ! -f $pxcentral_onprem_crd ]; then
  echo "Failed to create file: $pxcentral_onprem_crd, verify you have right access to create file: $pxcentral_onprem_crd"
  logError "Failed to create file: $pxcentral_onprem_crd, verify you have right access to create file: $pxcentral_onprem_crd"
  echo ""
  exit 1
fi
logInfo "Creating PX-Central-Onprem CRD using spec: $pxcentral_onprem_crd"
kubectl --kubeconfig=$KC apply -f $pxcentral_onprem_crd >> "$LOGFILE"
pxcentralcrdregistered="0"
timecheck=0
count=0
while [ $pxcentralcrdregistered -ne "1" ]
  do
    pxcentral_crd=`kubectl --kubeconfig=$KC get crds 2>&1 | grep -i "pxcentralonprems.pxcentral.com" | wc -l 2>&1`
    if [ "$pxcentral_crd" -eq "1" ]; then
      pxcentralcrdregistered="1"
      break
    fi
    showMessage "Waiting for PX-Central required components --Central-CRD's-- to be ready (0/7)"
    logInfo "Waiting for PX-Central required components --Central-CRD's-- to be ready (0/7)"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      echo ""
      echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
      logError "PX-Central deployment is not ready, Contact: support@portworx.com"
      exit 1
    fi
  done
if [ ! -f $pxcentral_onprem_cr ]; then
  echo "Failed to create file: $pxcentral_onprem_cr, verify you have right access to create file: $pxcentral_onprem_cr"
  logError "Failed to create file: $pxcentral_onprem_cr, verify you have right access to create file: $pxcentral_onprem_cr"
  echo ""
  exit 1
fi
logInfo "Creating PX-Central-Onprem CR using spec: $pxcentral_onprem_cr"
kubectl --kubeconfig=$KC apply -f $pxcentral_onprem_cr >> "$LOGFILE"
showMessage "Waiting for PX-Central required components --PX-Central-Operator-- to be ready (0/7)"
logInfo "Waiting for PX-Central required components --PX-Central-Operator-- to be ready (0/7)"
kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE >> "$LOGFILE"
operatordeploymentready="0"
timecheck=0
count=0
while [ $operatordeploymentready -ne "1" ]
  do
    operatoronpremdeployment=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "pxcentral-onprem-operator" | awk '{print $2}' | grep -v READY | grep "1/2" | wc -l 2>&1`
    if [ "$operatoronpremdeployment" -eq "1" ]; then
        operatordeploymentready="1"
        break
    fi
    operatoronpremdeploymentready=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "pxcentral-onprem-operator" | awk '{print $2}' | grep -v READY | grep "2/2" | wc -l 2>&1`
    if [ "$operatoronpremdeploymentready" -eq "1" ]; then
        operatordeploymentready="1"
        break
    fi
    showMessage "Waiting for PX-Central required components --PX-Central-Operator-- to be ready (0/7)"
    logInfo "Waiting for PX-Central required components --PX-Central-Operator-- to be ready (0/7)"
    pxcOperatorPodCreated=`kubectl --kubeconfig=$KC get po -lname=pxcentral-onprem-operator --namespace $PXCNAMESPACE 2>&1 | grep -v "No resources found." | awk '{print $2}' | wc -l 2>&1`
    if [ "$pxcOperatorPodCreated" -gt "0" ]; then
      kubectl --kubeconfig=$KC get po -lname=pxcentral-onprem-operator --namespace $PXCNAMESPACE >> "$LOGFILE"
    fi
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      echo ""
      echo "PX-Central onprem deployment not ready... Timeout: $TIMEOUT seconds"
      logError "PX-Central onprem deployment not ready... Timeout: $TIMEOUT seconds"
      operatorPodName=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "pxcentral-onprem-operator" | awk '{print $1}' | grep -v NAME 2>&1`
      kubectl --kubeconfig=$KC logs $operatorPodName --namespace $PXCNAMESPACE -c pxcentral-onprem-operator >> "$LOGFILE"
      echo "Check the PX-Central-Onprem operator pod $operatorPodName logs: kubectl --kubeconfig=$KC logs $operatorPodName --namespace $PXCNAMESPACE -c pxcentral-onprem-operator"
      echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
      logError "PX-Central deployment is not ready, Contact: support@portworx.com"
      echo ""
      exit 1
    fi
  done
kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE >> "$LOGFILE"
if [[ "$PX_LICENSE_SERVER_DEPLOY" == "true" || "$PX_STORE_DEPLOY" == "true" ]]; then
  showMessage "Waiting for PX-Central required components --PX-Central-Operator-PX-- to be ready (1/7)"
  logInfo "Waiting for PX-Central required components --PX-Central-Operator-PX-- to be ready (1/7)"
  pxready="0"
  sleep $SLEEPINTERVAL
  timecheck=0
  count=0
  license_server_cm_available="0"
  while [ $pxready -ne "1" ]
    do
      if [ "$PX_STORE_DEPLOY" == "true" ]; then
        logInfo "Portworx pods:"
        if [ "$USE_EXISTING_PX" == "true" ]; then
          pxPodsReady=`kubectl --kubeconfig=$KC get pods --all-namespaces -lname=portworx 2>&1 | awk '{print $3}' | grep -v READY | grep "1/1" | wc -l 2>&1`
          kubectl --kubeconfig=$KC get po -lname=portworx --all-namespaces >> "$LOGFILE"
          pxCSIPodsReady=`kubectl --kubeconfig=$KC get pods --all-namespaces -lname=portworx 2>&1 | awk '{print $3}' | grep -v READY | grep "2/2" | wc -l 2>&1`
          kubectl --kubeconfig=$KC get po -lname=portworx --all-namespaces >> "$LOGFILE"
        else
          pxPodsReady=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE -lname=portworx 2>&1 | grep -v "No resources found." | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
        fi
        pxPodCreated=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE -lname=portworx 2>&1 | grep -iv "No resources found." | awk '{print $2}' | wc -l 2>&1`
        if [ "$pxPodCreated" -gt "0" ]; then
            kubectl --kubeconfig=$KC get po -lname=portworx --namespace $PXCNAMESPACE >> "$LOGFILE"
        fi
        showMessage "Waiting for PX-Central required components --PX-Central-Operator-PX-- to be ready (1/7)"
        logInfo "Waiting for PX-Central required components --PX-Central-Operator-PX-- to be ready (1/7)"
      fi
      if [ "$PX_LICENSE_SERVER_DEPLOY" == "false" ]; then
        license_server_cm_available="1"
      else
        main_node_count=`kubectl --kubeconfig=$KC get node -lprimary/ls=true | grep Ready | wc -l 2>&1`
        backup_node_count=`kubectl --kubeconfig=$KC get node -lbackup/ls=true | grep Ready | wc -l 2>&1`
        logInfo "License servers: Main: $main_node_count, Backup: $backup_node_count"
        if [[ $main_node_count -eq 1 && $backup_node_count -eq 1 ]]; then
          license_server_cm_available="1"
        else
          main_node_ip=`kubectl --kubeconfig=$KC get cm --namespace $PXCNAMESPACE pxc-lsc-replicas -o jsonpath={.data.primary} 2>&1`
          backup_node_ip=`kubectl --kubeconfig=$KC get cm --namespace $PXCNAMESPACE pxc-lsc-replicas -o jsonpath={.data.secondary} 2>&1`
          if [[ ( ! -z "$main_node_ip" ) && ( ! -z "$backup_node_ip" ) ]]; then
            main_node_hostname=`kubectl --kubeconfig=$KC get nodes -o wide | grep "$main_node_ip" | awk '{print $1}' 2>&1`
            backup_node_hostname=`kubectl --kubeconfig=$KC get nodes -o wide | grep "$backup_node_ip" | awk '{print $1}' 2>&1`
            logInfo "License server nodes hostname: Main: $main_node_hostname, Backup: $backup_node_hostname"
            logDebug "Setting label px/ls=true to node $main_node_hostname"
            kubectl --kubeconfig=$KC label node $main_node_hostname px/ls=true >> "$LOGFILE"
            logDebug "Setting label px/ls=true to node $backup_node_hostname"
            kubectl --kubeconfig=$KC label node $backup_node_hostname px/ls=true >> "$LOGFILE"
            logDebug "Setting label primary/ls=true to node $main_node_hostname"
            kubectl --kubeconfig=$KC label node $main_node_hostname primary/ls=true >> "$LOGFILE"
            logDebug "Setting label backup/ls=true to node $backup_node_hostname"
            kubectl --kubeconfig=$KC label node $backup_node_hostname backup/ls=true >> "$LOGFILE"
            main_node_count=`kubectl --kubeconfig=$KC get node -lprimary/ls=true | grep Ready | wc -l 2>&1`
            backup_node_count=`kubectl --kubeconfig=$KC get node -lbackup/ls=true | grep Ready | wc -l 2>&1`
            logInfo "License servers: Main: $main_node_count, Backup: $backup_node_count"
            if [[ $main_node_count -eq 1 && $backup_node_count -eq 1 ]]; then
              license_server_cm_available="1"
            fi
          fi
        fi
      fi
      if [[ ( "$pxPodsReady" -ge "3" || "$pxCSIPodsReady" -ge "3" ) && "$license_server_cm_available" -eq "1" ]]; then
        pxready="1"
        break
      fi
      if [[ "$PX_LICENSE_SERVER_DEPLOY" == "true" && "$PX_STORE_DEPLOY" == "false" ]]; then
        pxready="1"
        break
      fi
      if [[ "$PXCENTRAL_MINIK8S" == "true" && "$PX_STORE_DEPLOY" == "false" ]]; then
        pxready="1"
        break
      fi
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $TIMEOUT ]; then
        echo ""
        operatorPodName=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "pxcentral-onprem-operator" | awk '{print $1}' | grep -v NAME 2>&1`
        kubectl --kubeconfig=$KC logs $operatorPodName --namespace $PXCNAMESPACE -c pxcentral-onprem-operator >> "$LOGFILE"
        echo "Check the PX-Central-Onprem operator pod $operatorPodName logs: kubectl --kubeconfig=$KC logs $operatorPodName --namespace $PXCNAMESPACE -c pxcentral-onprem-operator"
        echo "Check the logs of portworx cluster deployed by PX-Central-Onprem, to get portworx cluster pods use command: kubectl --kubeconfig=$KC get po -lname=portworx --namespace $PXCNAMESPACE"
        echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
        logInfo "PX-Central deployment is not ready, Contact: support@portworx.com"
        echo ""
        exit 1
      fi
    done
    if [[ "$PXCENTRAL_PX_APP_SAME_K8S_CLUSTER" == "true" && "$PXCNAMESPACE" != "$STANDARD_NAMESPACE" ]]; then
      kubectl --kubeconfig=$KC scale deployment --namespace $PXCNAMESPACE portworx-pvc-controller --replicas=0 >> "$LOGFILE"
      sleep 5
      kubectl --kubeconfig=$KC scale deployment --namespace $PXCNAMESPACE portworx-pvc-controller --replicas=3 >> "$LOGFILE"
    fi
fi

if [ "$PX_METRICS_DEPLOY" == "true" ]; then
  cassandrapxready="0"
  timecheck=0
  count=0
  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Metrics-Store-- to be ready (2/7)"
  logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Metrics-Store-- to be ready (2/7)"
  while [ $cassandrapxready -ne "1" ]
    do
      pxcassandraready=`kubectl --kubeconfig=$KC get sts --namespace $PXCNAMESPACE pxc-cortex-cassandra 2>&1 | grep -v READY | awk '{print $2}' | grep "3/3" | wc -l 2>&1`
      pxcassandrareadyocp=`kubectl --kubeconfig=$KC get sts --namespace $PXCNAMESPACE pxc-cortex-cassandra 2>&1 | grep -v CURRENT | awk '{print $3}' | grep "3" | wc -l 2>&1`
      if [ "$OPENSHIFTCLUSTER" == "true" ]; then
        if [ "$pxcassandrareadyocp" -eq "1" ]; then
            cassandrapxready="1"
            break
        fi
      elif [ "$pxcassandraready" -eq "1" ]; then
        cassandrapxready="1"
        break
      fi
      showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Metrics-Store-- to be ready (2/7)"
      logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Metrics-Store-- to be ready (2/7)"
      logInfo "Cortex cassandra pods:"
      kubectl --kubeconfig=$KC get po -lapp=pxc-cortex-cassandra --namespace $PXCNAMESPACE >> "$LOGFILE"
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $TIMEOUT ]; then
        echo ""
        echo "Check cortex cassandra statefulset pods logs, to get pods use command: kubectl --kubeconfig=$KC get po -lapp=pxc-cortex-cassandra --namespace $PXCNAMESPACE"
        echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
        logError "PX-Central deployment is not ready, Contact: support@portworx.com"
        echo ""
        exit 1
      fi
    done
fi

if [ "$PX_LICENSE_SERVER_DEPLOY" == "true" ]; then
  lscready="0"
  timecheck=0
  count=0
  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-License-Server-- to be ready (3/7)"
  logInfo "Waiting for PX-Central required components --PX-Central-Onprem-License-Server-- to be ready (3/7)"
  while [ $lscready -ne "1" ]
    do
      licenseserverready=`kubectl --kubeconfig=$KC get deployment --namespace $PXCNAMESPACE pxc-license-server 2>&1 | grep -v READY | awk '{print $2}' | grep "2/2" | wc -l 2>&1`
      licenseserverreadyocp=`kubectl --kubeconfig=$KC get deployment --namespace $PXCNAMESPACE pxc-license-server 2>&1 | grep -v CURRENT | awk '{print $3}' | grep "2" | wc -l 2>&1`
      if [ "$OPENSHIFTCLUSTER" == "true" ]; then
        if [ "$licenseserverreadyocp" -eq "1" ]; then
          lscready="1"
          break
        fi
      elif [ "$licenseserverready" -eq "1" ]; then
        lscready="1"
        break
      fi
      showMessage "Waiting for PX-Central required components --PX-Central-Onprem-License-Server-- to be ready (3/7)"
      logInfo "Waiting for PX-Central required components --PX-Central-Onprem-License-Server-- to be ready (3/7)"
      logInfo "License server pods:"
      kubectl --kubeconfig=$KC get po -lapp=pxc-license-server --namespace $PXCNAMESPACE >> "$LOGFILE"
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $TIMEOUT ]; then
        echo ""
        echo "Check license server deployment pod logs: kubectl --kubeconfig=$KC get po -lapp=pxc-license-server --namespace $PXCNAMESPACE"
        echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
        logError "PX-Central deployment is not ready, Contact: support@portworx.com"
        echo ""
        exit 1
      fi
    done
    showMessage "Waiting for PX-Central required components --PX-Central-Onprem-License-Server-- to be ready (4/7)"
    logInfo "Waiting for PX-Central required components --PX-Central-Onprem-License-Server-- to be ready (4/7)"
fi

if [ "$PXCPROVISIONEDOIDC" == "true" ]; then
  timecheck=0
  keycloakready="0"
  while [ $keycloakready -ne "1" ]
    do
      logInfo "Keycloak Backend:"
      kubectl --kubeconfig=$KC get po -lapp=postgresql --namespace $PXCNAMESPACE >> "$LOGFILE"
      logInfo "Keycloak Frontend:"
      kubectl --kubeconfig=$KC get po -lapp.kubernetes.io/name=keycloak --namespace $PXCNAMESPACE >> "$LOGFILE"
      oidcready=`kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | grep -iv "error" | grep -v "NotFound" | grep "pxc-keycloak" | awk '{print $2}' | grep "1/1" | wc -l 2>&1`
      if [ $oidcready -eq 2 ]; then
        keycloakready="1"
        break
      fi
      showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
      logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $TIMEOUT ]; then
        echo ""
        echo "Check keycloak pod logs, to get keycloak pod: kubectl --kubeconfig=$KC get po -lapp.kubernetes.io/name=keycloak --namespace $PXCNAMESPACE"
        echo "Check keycloak backend pod logs, to get keycloak backend pod: kubectl --kubeconfig=$KC get po -lapp=postgresql --namespace $PXCNAMESPACE"
        echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
        logError "PX-Central deployment is not ready, Contact: support@portworx.com"
        echo ""
        exit 1
      fi
    done
    keycloakPodName=`kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE -lapp.kubernetes.io/name=keycloak 2>&1 | grep -v NAME | awk '{print $1}'`
    echo ""
    echo "Keycloak pod: $keycloakPodName"
    logInfo "Keycloak pod: $keycloakPodName"
    if [ ${keycloakPodName} ]; then
      if [ "$INGRESS_SETUP_REQUIRED" == "true" ]; then
        kubectl --kubeconfig=$KC exec -it $keycloakPodName --namespace $PXCNAMESPACE -- bash -c "cd /opt/jboss/keycloak/bin/ && ./kcadm.sh config credentials --server http://localhost:8080/keycloak --realm master --user '$KEYCLOAK_FRONTEND_USERNAME' --password '$KEYCLOAK_FRONTEND_PASSWORD' && ./kcadm.sh update realms/master -s sslRequired=NONE"
      else
        kubectl --kubeconfig=$KC exec -it $keycloakPodName --namespace $PXCNAMESPACE -- bash -c "cd /opt/jboss/keycloak/bin/ && ./kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user '$KEYCLOAK_FRONTEND_USERNAME' --password '$KEYCLOAK_FRONTEND_PASSWORD' && ./kcadm.sh update realms/master -s sslRequired=NONE"
      fi
      echo "Disabled ssl-required"
      logInfo "Disabled ssl-required"
      echo ""
    fi
    timecheck=0
    KEYCLOAK_URL="http://$OIDCENDPOINT"
    while true
      do
        status_code=$(curl --write-out %{http_code} --insecure --silent --output /dev/null $KEYCLOAK_URL)
        logDebug "Endpoint : [$KEYCLOAK_URL] status code: [$status_code]"
        if [[ "$status_code" -eq 200 || "$status_code" -eq 303 ]] ; then
          echo -e -n ""
          break
        fi
        showMessage "Validating keycloak endpoint: $KEYCLOAK_URL"
        logInfo "Validating access to keycloak endpoint: $KEYCLOAK_URL"
        sleep $SLEEPINTERVAL
        timecheck=$[$timecheck+$SLEEPINTERVAL]
        if [ $timecheck -gt $LBSERVICETIMEOUT ]; then
          echo ""
          echo "ERROR: keycloak endpoint [$KEYCLOAK_URL] is not accessible."
          logError "keycloak endpoint [$KEYCLOAK_URL] is not accessible."
          echo ""
          exit 1
        fi
      done
    echo ""
    echo "Keycloak endpoint:[$KEYCLOAK_URL] is accessible"
    showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
    logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
    KEYCLOAK_TOKEN=`curl -s -d "client_id=admin-cli" -d "username=$KEYCLOAK_FRONTEND_USERNAME" -d "password=$KEYCLOAK_FRONTEND_PASSWORD" -d "grant_type=password" "http://$OIDCENDPOINT/realms/master/protocol/openid-connect/token" | jq ".access_token" | sed 's/\"//g'`
    client_details="/tmp/clients.json"
    logInfo "Client details template: $client_details"
    curl -s -X GET "http://$OIDCENDPOINT/admin/realms/master/clients/" -H 'Content-Type: application/json' -H "Authorization: Bearer $KEYCLOAK_TOKEN" | jq "." > $client_details
    cid_check="/tmp/clientid.py"
cat > $cid_check <<- "EOF"
import json
import sys
input_file=sys.argv[1]
clientID=sys.argv[2]
client_required_id=""
try:
    with open(input_file, "r") as fout:
        data = json.load(fout)
    for raw in data:
        client_id=raw.get('clientId')
        client_required_id=raw.get('id')
        if client_id == clientID:
            break
except Exception as ex:
    pass
print(client_required_id)
EOF
    if [ -f ${cid_check} ]; then 
      admincli_id=`$cmdPython $cid_check $client_details admin-cli`
      KEYCLOAK_TOKEN=`curl -s -d "client_id=admin-cli" -d "username=$KEYCLOAK_FRONTEND_USERNAME" -d "password=$KEYCLOAK_FRONTEND_PASSWORD" -d "grant_type=password" "http://$OIDCENDPOINT/realms/master/protocol/openid-connect/token" | jq ".access_token" | sed 's/\"//g'`
      curl -s -X PUT "http://$OIDCENDPOINT/admin/realms/master/clients/$admincli_id" \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer $KEYCLOAK_TOKEN" \
      --data '{
        "attributes": {
            "access.token.lifespan": "31536000"
        }
      }'
    fi    
    KEYCLOAK_TOKEN=`curl -s -d "client_id=admin-cli" -d "username=$KEYCLOAK_FRONTEND_USERNAME" -d "password=$KEYCLOAK_FRONTEND_PASSWORD" -d "grant_type=password" "http://$OIDCENDPOINT/realms/master/protocol/openid-connect/token" | jq ".access_token" | sed 's/\"//g'`
    curl -s -X PUT "http://$OIDCENDPOINT/admin/realms/master" \
    -H "Authorization: Bearer $KEYCLOAK_TOKEN" \
    -H 'Content-Type: application/json' \
    --data '{
	    "loginTheme": "portworx"
    }'
    if [ "$PUBLIC_ENDPOINT_SETUP_REQUIRED" == "true" ]; then
      keycloakBaseURL="/auth/realms/master/account"
    else
      keycloakBaseURL="/keycloak/realms/master/account"
    fi
    curl -s -X POST "http://$OIDCENDPOINT/admin/realms/master/clients/" \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $KEYCLOAK_TOKEN" \
    --data '{
    "clientId": '\"$PXC_OIDC_CLIENT_ID\"',
    "name": "${client_account}",
    "rootUrl": '\"http://$OIDCENDPOINT\"',
    "adminUrl": '\"http://$OIDCENDPOINT\"',
    "baseUrl": '\"$keycloakBaseURL\"',
    "surrogateAuthRequired": false,
    "enabled": true,
    "clientAuthenticatorType": "client-secret",
    "redirectUris": [
        '\"http://$EXTERNAL_ENDPOINT_URL/*\"',
        '\"http://$PXC_FRONTEND/*\"',
        '\"http://$PXC_GRAFANA/*\"'
    ],
    "webOrigins": [
        '\"http://$PXC_FRONTEND\"',
        '\"http://$OIDCENDPOINT\"',
        '\"http://$PXC_GRAFANA\"',
        '\"http://$PXC_KEYCLOAK\"'  
    ],
    "notBefore": 0,
    "bearerOnly": false,
    "consentRequired": false,
    "standardFlowEnabled": true,
    "implicitFlowEnabled": false,
    "directAccessGrantsEnabled": true,
    "serviceAccountsEnabled": false,
    "publicClient": true,
    "frontchannelLogout": false,
    "protocol": "openid-connect",
    "attributes": {
        "saml.assertion.signature": "false",
        "access.token.lifespan": "31536000",
        "saml.multivalued.roles": "false",
        "saml.force.post.binding": "false",
        "saml.encrypt": "false",
        "saml.server.signature": "false",
        "saml.server.signature.keyinfo.ext": "false",
        "exclude.session.state.from.auth.response": "false",
        "saml_force_name_id_format": "false",
        "saml.client.signature": "false",
        "tls.client.certificate.bound.access.tokens": "false",
        "saml.authnstatement": "false",
        "display.on.consent.screen": "false",
        "saml.onetimeuse.condition": "false"
    },
    "authenticationFlowBindingOverrides": {},
    "fullScopeAllowed": true,
    "nodeReRegistrationTimeout": -1,
    "protocolMappers": [
        {
            "name": "Client ID",
            "protocol": "openid-connect",
            "protocolMapper": "oidc-usersessionmodel-note-mapper",
            "consentRequired": false,
            "config": {
                "user.session.note": "clientId",
                "id.token.claim": "true",
                "access.token.claim": "true",
                "claim.name": "clientId",
                "jsonType.label": "String"
            }
        },
        {
            "name": "Client Host",
            "protocol": "openid-connect",
            "protocolMapper": "oidc-usersessionmodel-note-mapper",
            "consentRequired": false,
            "config": {
                "user.session.note": "clientHost",
                "id.token.claim": "true",
                "access.token.claim": "true",
                "claim.name": "clientHost",
                "jsonType.label": "String"
            }
        },
        {
            "name": "roles",
            "protocol": "openid-connect",
            "protocolMapper": "oidc-usermodel-realm-role-mapper",
            "consentRequired": false,
            "config": {
                "multivalued": "true",
                "userinfo.token.claim": "true",
                "id.token.claim": "true",
                "access.token.claim": "true",
                "claim.name": "roles",
                "jsonType.label": "String"
            }
        },
        {
            "name": "Client IP Address",
            "protocol": "openid-connect",
            "protocolMapper": "oidc-usersessionmodel-note-mapper",
            "consentRequired": false,
            "config": {
                "user.session.note": "clientAddress",
                "id.token.claim": "true",
                "access.token.claim": "true",
                "claim.name": "clientAddress",
                "jsonType.label": "String"
            }
        }
    ],
    "defaultClientScopes": [
        "web-origins",
        "role_list",
        "profile",
        "roles",
        "email"
    ],
    "optionalClientScopes": [
        "address",
        "phone",
        "offline_access"
    ],
    "access": {
        "view": true,
        "configure": true,
        "manage": true,
        "admin": true
    }
}' >> "$LOGFILE"
  echo ""
  echo "OIDC Client: $PXC_OIDC_CLIENT_ID configured."
  logInfo "OIDC Client: $PXC_OIDC_CLIENT_ID configured."
  client_details="/tmp/clients.json"
  logInfo "Client details: $client_details"
  curl -s -X GET "http://$OIDCENDPOINT/admin/realms/master/clients/" -H 'Content-Type: application/json' -H "Authorization: Bearer $KEYCLOAK_TOKEN" | jq "." > $client_details
  cid_check="/tmp/clientid.py"
cat > $cid_check <<- "EOF"
import json
import sys
input_file=sys.argv[1]
clientID=sys.argv[2]
client_required_id=""
try:
    with open(input_file, "r") as fout:
        data = json.load(fout)
    for raw in data:
        client_id=raw.get('clientId')
        client_required_id=raw.get('id')
        if client_id == clientID:
            break
except Exception as ex:
    pass
print(client_required_id)
EOF
  if [ -f ${cid_check} ]; then
    pxcentral_id=`$cmdPython $cid_check $client_details $PXC_OIDC_CLIENT_ID`
    PXC_OIDC_CLIENT_SECRET=`curl -s -X GET "http://$OIDCENDPOINT/admin/realms/master/clients/$pxcentral_id/client-secret/" -H "Authorization: Bearer $KEYCLOAK_TOKEN" | jq ".value"`
    echo "OIDC client [$PXC_OIDC_CLIENT_ID] id: $pxcentral_id"
    echo "OIDC Client ID: $PXC_OIDC_CLIENT_ID"
    echo "OIDC Client Secret: $PXC_OIDC_CLIENT_SECRET"
    logInfo "OIDC client [$PXC_OIDC_CLIENT_ID] id: $pxcentral_id"
    logInfo "OIDC Client ID: $PXC_OIDC_CLIENT_ID"
    logInfo "OIDC Client Secret: $PXC_OIDC_CLIENT_SECRET"
    if [[ -z ${PXC_OIDC_CLIENT_ID} || -z ${PXC_OIDC_CLIENT_SECRET} ]]; then
      echo ""
      echo "ERROR: Failed to setup PX-Central-Onprem OIDC."
      echo "Failed to configure OIDC client in PX-Central-Onprem keycloak."
      echo "Check keycloak pod logs, to get keycloak pod: kubectl --kubeconfig=$KC get po -lapp.kubernetes.io/name=keycloak --namespace $PXCNAMESPACE"
      echo "Check keycloak backend pod logs, to get keycloak backend pod: kubectl --kubeconfig=$KC get po -lapp=postgresql --namespace $PXCNAMESPACE"
      logError "Failed to setup PX-Central-Onprem OIDC."
      echo "Contact: support@portworx.com"
      echo ""
      exit 1
    fi
  fi
  pxadmin_user_id=`curl -s -X GET "http://$OIDCENDPOINT/admin/realms/master/users/" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $KEYCLOAK_TOKEN" | jq ".[].id" | sed 's/\"//g'`
  echo "OIDC Admin user [$KEYCLOAK_FRONTEND_USERNAME] id: $pxadmin_user_id"
  logInfo "OIDC Admin user [$KEYCLOAK_FRONTEND_USERNAME] id: $pxadmin_user_id"
  user_update_status=`curl -s -X PUT "http://$OIDCENDPOINT/admin/realms/master/users/$pxadmin_user_id" \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer $KEYCLOAK_TOKEN" \
      --data '{
          "emailVerified": true,
          "firstName": '\"$KEYCLOAK_FRONTEND_USERNAME\"',
          "lastName": "Admin",
          "email": '\"$ADMINEMAIL\"'
      }'`
  updated_user_details="/tmp/admin_user.json"
  curl -s -X GET "http://$OIDCENDPOINT/admin/realms/master/users/" \
          -H 'Content-Type: application/json' \
          -H "Authorization: Bearer $KEYCLOAK_TOKEN" | jq "." > $updated_user_details
  logInfo "Creating portworx admin user role."
  curl -s -X POST "http://$OIDCENDPOINT/admin/realms/master/roles" \
  -H "Authorization: Bearer $KEYCLOAK_TOKEN" \
  -H 'Content-Type: application/json' \
  --data '{
	  "name":"system.admin",
	  "description":"Portworx admin user role"
  }'
  admin_user_role_id=`curl -s -X GET "http://$OIDCENDPOINT/admin/realms/master/roles/system.admin" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $KEYCLOAK_TOKEN" | jq ".id" | sed 's/\"//g'`
  logInfo "Admin user role id: $admin_user_role_id"
  if [ ${admin_user_role_id} ]; then
    curl -s -X POST "http://$OIDCENDPOINT/admin/realms/master/users/$pxadmin_user_id/role-mappings/realm" \
    -H "Authorization: Bearer $KEYCLOAK_TOKEN" \
    -H 'Content-Type: application/json' \
    --data '[
	    {
        "name": "system.admin",
        "id": '\"$admin_user_role_id\"',
        "composite": false,
        "clientRole": false,
        "containerId": "master",
        "description": "Portworx admin user role"
	    }
    ]'   
  else
    logError "Failed to configure portworx admin user role [system.admin]"
    echo "Create [system.admin] role from keycloak [ http://$OIDCENDPOINT/ ] and assign it to admin user."
    logInfo "Create [system.admin] role from keycloak [ http://$OIDCENDPOINT/ ] and assign it to admin user."
  fi
  if [ "$PX_LICENSE_SERVER_DEPLOY" == "true" ]; then
    main_node_ip=`kubectl --kubeconfig=$KC get cm --namespace $PXCNAMESPACE pxc-lsc-replicas -o jsonpath={.data.primary} 2>&1`
    backup_node_ip=`kubectl --kubeconfig=$KC get cm --namespace $PXCNAMESPACE pxc-lsc-replicas -o jsonpath={.data.secondary} 2>&1`
    license_servers="$main_node_ip:7070,$backup_node_ip:7070"
  else
    license_servers="pxc-license.$PXCNAMESPACE.svc.cluster.local:7070"
  fi

  if [[ "$PX_LICENSE_SERVER_DEPLOY" == "false" &&  -z "${LICENSEADMINPASSWORD}" ]]; then
    LICENSEADMINPASSWORD="Adm1n!Ur"
  fi

  backup_service_endpoint="px-backup.$PXCNAMESPACE.svc.cluster.local:10002"
  pxc_status_endpoint="http://pxc-apiserver.$PXCNAMESPACE.svc.cluster.local:10006"
  backend_config="/tmp/pxc-backend.yaml"
cat <<< '
apiVersion: v1
kind: ConfigMap
metadata:
  name: pxc-central-ui-configmap
  namespace: '$PXCNAMESPACE'
data:
  FRONTEND_UI_URL: http://'$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/pxcentral    # The base url of frontend service
  BASE_ROOT_PATH: /pxcentral/
  FRONTEND_URL: http://'$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/               # The base url of Ingress
  API_URL: http://'$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/backend             # px-central-backend url
  LH_MIDDLEWARE_URL: '$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/lhBackend        # lh middleware url
  FRONTEND_ENABLED_MODULES: COMPANY,LH,SSO,USERS,PXBACKUP,PXLICENSE,PXMETRICS
  LIGHT_HOUSE_TYPE: PRODUCTION                      # PRODUCTION always
  PX_BACKUP_ENDPOINT: '$backup_service_endpoint'
  PX_BACKUP_ORGID: '$PX_BACKUP_ORGANIZATION'                           # PX-Backup org - always 0
  APACHE_RUN_GROUP: www-data
  APACHE_RUN_USER: www-data
  APP_DEBUG: "true"
  APP_DOMAIN: '$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/pxcentral
  APP_ENV: local
  APP_KEY: base64:J1RH3W4+CILq3/eac9zqYbAMzeptqCJgR9KcWRdhtHw=
  APP_LOG: stderr
  APP_NAME: Portworx
  BACKEND_HOSTNAME: '$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/backend
  FRONTEND_HOSTNAME: '$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/pxcentral
  FRONTEND_GRAFANA_URL: "http://'$pxcGrafanaEndpoint'/grafana"           # grafana url
  BROADCAST_DRIVER: log
  CACHE_DRIVER: file
  DB_CONNECTION: mysql
  DB_DATABASE: pxcentral
  DB_HOST: pxc-mysql
  DB_PASSWORD: singapore
  DB_PORT: "3306"
  DB_USERNAME: root
  LOG_CHANNEL: stderr
  PX_LICENSE_SERVER: '$license_servers'
  PX_LICENSE_PASSWORD: '$LICENSEADMINPASSWORD'
  PX_LICENSE_USER: admin
  PX_STATUS_ENDPOINT: '$pxc_status_endpoint'
  QUEUE_CONNECTION: sync
  SESSION_DRIVER: file
  SESSION_LIFETIME: "120"
  OIDC_AUTHSERVERURL: http://'$OIDCENDPOINT'/realms/master
  OIDC_CLIENT_ID: '$PXC_OIDC_CLIENT_ID'
  OIDC_CLIENT_SECRET: '$PXC_OIDC_CLIENT_SECRET'
  OIDC_CLIENT_CALLBACK: http://'$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/pxcentral/landing/oauth/oidc
  OIDC_REDIRECTURI: http://'$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/pxcentral/landing/oauth/oidc
' > $backend_config

  with_dns_backend_config="/tmp/pxc-ui-configmap.yaml"
cat <<< '
apiVersion: v1
kind: ConfigMap
metadata:
  name: pxc-central-ui-configmap
  namespace: '$PXCNAMESPACE'
data:
  FRONTEND_UI_URL: http://'$PXC_FRONTEND'/    # The base url of frontend service
  BASE_ROOT_PATH: /
  FRONTEND_URL: http://'$PXC_FRONTEND'               # The base url of Ingress
  API_URL: http://'$PXC_BACKEND'             # px-central-backend url
  LH_MIDDLEWARE_URL: '$PXC_MIDDLEWARE'        # lh middleware url
  FRONTEND_ENABLED_MODULES: COMPANY,LH,SSO,USERS,PXBACKUP,PXLICENSE,PXMETRICS
  LIGHT_HOUSE_TYPE: PRODUCTION                      # PRODUCTION always
  PX_BACKUP_ENDPOINT: '$backup_service_endpoint'
  PX_BACKUP_ORGID: '$PX_BACKUP_ORGANIZATION'                           # PX-Backup org - always 0
  APACHE_RUN_GROUP: www-data
  APACHE_RUN_USER: www-data
  APP_DEBUG: "true"
  APP_DOMAIN: '$PXC_FRONTEND'
  APP_ENV: local
  APP_KEY: base64:J1RH3W4+CILq3/eac9zqYbAMzeptqCJgR9KcWRdhtHw=
  APP_LOG: stderr
  APP_NAME: Portworx
  BACKEND_HOSTNAME: '$PXC_BACKEND'
  FRONTEND_HOSTNAME: '$PXC_FRONTEND'
  FRONTEND_GRAFANA_URL: http://'$pxcGrafanaEndpoint'           # grafana url
  BROADCAST_DRIVER: log
  CACHE_DRIVER: file
  DB_CONNECTION: mysql
  DB_DATABASE: pxcentral
  DB_HOST: pxc-mysql
  DB_PASSWORD: singapore
  DB_PORT: "3306"
  DB_USERNAME: root
  LOG_CHANNEL: stderr
  PX_LICENSE_SERVER: '$license_servers'
  PX_LICENSE_PASSWORD: '$LICENSEADMINPASSWORD'
  PX_LICENSE_USER: admin
  PX_STATUS_ENDPOINT: '$pxc_status_endpoint'
  QUEUE_CONNECTION: sync
  SESSION_DRIVER: file
  SESSION_LIFETIME: "120"
  OIDC_AUTHSERVERURL: http://'$OIDCENDPOINT'/realms/master
  OIDC_CLIENT_ID: '$PXC_OIDC_CLIENT_ID'
  OIDC_CLIENT_SECRET: '$PXC_OIDC_CLIENT_SECRET'
  OIDC_CLIENT_CALLBACK: http://'$PXC_FRONTEND'/landing/oauth/oidc
  OIDC_REDIRECTURI: http://'$PXC_FRONTEND'/landing/oauth/oidc
' > $with_dns_backend_config

with_ingress_backend_config="/tmp/pxc-ui-ingress-configmap.yaml"
cat <<< '
apiVersion: v1
kind: ConfigMap
metadata:
  name: pxc-central-ui-configmap
  namespace: '$PXCNAMESPACE'
data:
  FRONTEND_UI_URL: http://'$INGRESS_ENDPOINT'/pxcentral    # The base url of frontend service
  BASE_ROOT_PATH: /pxcentral/
  FRONTEND_URL: http://'$INGRESS_ENDPOINT'/               # The base url of Ingress
  API_URL: http://'$INGRESS_ENDPOINT'/backend             # px-central-backend url
  LH_MIDDLEWARE_URL: '$INGRESS_ENDPOINT'/lhBackend        # lh middleware url
  FRONTEND_ENABLED_MODULES: COMPANY,LH,SSO,USERS,PXBACKUP,PXLICENSE,PXMETRICS
  LIGHT_HOUSE_TYPE: PRODUCTION                      # PRODUCTION always
  PX_BACKUP_ENDPOINT: '$backup_service_endpoint'
  PX_BACKUP_ORGID: '$PX_BACKUP_ORGANIZATION'                           # PX-Backup org - always 0
  APACHE_RUN_GROUP: www-data
  APACHE_RUN_USER: www-data
  APP_DEBUG: "true"
  APP_DOMAIN: '$INGRESS_ENDPOINT'/pxcentral
  APP_ENV: local
  APP_KEY: base64:J1RH3W4+CILq3/eac9zqYbAMzeptqCJgR9KcWRdhtHw=
  APP_LOG: stderr
  APP_NAME: Portworx
  BACKEND_HOSTNAME: '$INGRESS_ENDPOINT'/backend
  FRONTEND_HOSTNAME: '$INGRESS_ENDPOINT'/pxcentral
  FRONTEND_GRAFANA_URL: http://'$pxcGrafanaEndpoint'/grafana
  BROADCAST_DRIVER: log
  CACHE_DRIVER: file
  DB_CONNECTION: mysql
  DB_DATABASE: pxcentral
  DB_HOST: pxc-mysql
  DB_PASSWORD: singapore
  DB_PORT: "3306"
  DB_USERNAME: root
  LOG_CHANNEL: stderr
  PX_LICENSE_SERVER: '$license_servers'
  PX_LICENSE_PASSWORD: '$LICENSEADMINPASSWORD'
  PX_LICENSE_USER: admin
  PX_STATUS_ENDPOINT: '$pxc_status_endpoint'
  QUEUE_CONNECTION: sync
  SESSION_DRIVER: file
  SESSION_LIFETIME: "120"
  OIDC_AUTHSERVERURL: http://'$OIDCENDPOINT'/realms/master
  OIDC_CLIENT_ID: '$PXC_OIDC_CLIENT_ID'
  OIDC_CLIENT_SECRET: '$PXC_OIDC_CLIENT_SECRET'
  OIDC_CLIENT_CALLBACK: http://'$INGRESS_ENDPOINT'/pxcentral/landing/oauth/oidc
  OIDC_REDIRECTURI: http://'$INGRESS_ENDPOINT'/pxcentral/landing/oauth/oidc
' > $with_ingress_backend_config

  if [ "$DOMAIN_SETUP_REQUIRED" == "true" ]; then
    if [ ! -f $with_dns_backend_config ]; then
      echo "Failed to create file: $with_dns_backend_config, verify you have right access to create file: $with_dns_backend_config"
      logError "Failed to create file: $with_dns_backend_config, verify you have right access to create file: $with_dns_backend_config"
      echo ""
      exit 1
    fi
    logInfo "Creating UI configmap using spec: $with_dns_backend_config"
    kubectl --kubeconfig=$KC apply -f $with_dns_backend_config --namespace $PXCNAMESPACE >> "$LOGFILE"
  elif [ "$INGRESS_SETUP_REQUIRED" == "true" ]; then
    if [ ! -f $with_ingress_backend_config ]; then
      echo "Failed to create file: $with_ingress_backend_config, verify you have right access to create file: $with_ingress_backend_config"
      logError "Failed to create file: $with_ingress_backend_config, verify you have right access to create file: $with_ingress_backend_config"
      echo ""
      exit 1
    fi
    logInfo "Creating UI configmap using spec: $with_ingress_backend_config"
    kubectl --kubeconfig=$KC apply -f $with_ingress_backend_config --namespace $PXCNAMESPACE >> "$LOGFILE"
  else
    if [ ! -f $backend_config ]; then
      echo "Failed to create file: $backend_config, verify you have right access to create file: $backend_config"
      logError "Failed to create file: $backend_config, verify you have right access to create file: $backend_config"
      echo ""
      exit 1
    fi
    logInfo "Creating UI configmap using spec: $backend_config"
    kubectl --kubeconfig=$KC apply -f $backend_config --namespace $PXCNAMESPACE >> "$LOGFILE"
  fi

  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  sleep 10
  kubectl --kubeconfig=$KC delete pod --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC get pod --namespace $PXCNAMESPACE 2>&1 | grep "pxc-central-backend" 2>&1| grep -v NAME | awk '{print $1}') >> "$LOGFILE"
  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  kubectl --kubeconfig=$KC delete pod --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC get pod --namespace $PXCNAMESPACE 2>&1 | grep "pxc-central-frontend" 2>&1| grep -v NAME | awk '{print $1}') >> "$LOGFILE"
  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  kubectl --kubeconfig=$KC delete pod --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC get pod --namespace $PXCNAMESPACE 2>&1 | grep "pxc-central-lh-middleware" 2>&1| grep -v NAME | awk '{print $1}') >> "$LOGFILE"
  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  if [ "$PX_METRICS_DEPLOY" == "true" ]; then
    grafana_config="/tmp/grafana-ini.yaml"
cat <<< '
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-ini-config
  namespace: '$PXCNAMESPACE'
  labels:
    grafana: portworx
data:
  grafana.ini: |
    [users]
    auto_assign_org_role = Admin
    [server]
    domain = '$pxcGrafanaEndpoint'
    root_url = "%(protocol)s://%(domain)s/"
    enforce_domain = false

    [auth.basic]
    disable_login_form= true
    oauth_auto_login= true

    [auth.generic_oauth]
    enabled= true
    client_id= '$PXC_OIDC_CLIENT_ID'
    name= "OIDC"
    client_secret= '$PXC_OIDC_CLIENT_SECRET'
    auth_url= http://'$OIDCENDPOINT'/realms/master/protocol/openid-connect/auth 
    token_url= http://'$OIDCENDPOINT'/realms/master/protocol/openid-connect/token 
    api_url= http://'$OIDCENDPOINT'/realms/master/protocol/openid-connect/userinfo 
    redirect_uri= http://'$pxcGrafanaEndpoint'/login/generic_oauth
    allowed_domains= 
    allow_sign_up= true
' > $grafana_config

  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  if [ ! -f $grafana_config ]; then
    echo "Failed to create file: $grafana_config, verify you have right access to create file: $grafana_config"
    logError "Failed to create file: $grafana_config, verify you have right access to create file: $grafana_config"
    echo ""
    exit 1
  fi
  logInfo "Creating grafana configmap using spec: $grafana_config"
  kubectl --kubeconfig=$KC apply -f $grafana_config --namespace $PXCNAMESPACE >> "$LOGFILE"
  kubectl --kubeconfig=$KC delete pod --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC get pod --namespace $PXCNAMESPACE 2>&1 | grep "pxc-grafana" 2>&1 | grep -v NAME | awk '{print $1}') >> "$LOGFILE"
  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  fi

  OIDC_USER_ACCESS_TOKEN=`curl -s --data "grant_type=password&client_id=$PXC_OIDC_CLIENT_ID&username=$KEYCLOAK_FRONTEND_USERNAME&password=$KEYCLOAK_FRONTEND_PASSWORD&token-duration=$OIDC_USER_AUTH_TOKEN_EXPIARY_DURATION" http://$OIDCENDPOINT/realms/master/protocol/openid-connect/token | jq -r ".access_token"`
  if [ "$OIDC_USER_ACCESS_TOKEN" == "null" ]; then
    echo ""
    echo "ERROR: Failed to fetch PX-Central-Onprem OIDC admin user access token."
    echo "Check keycloak pod logs, to get keycloak pod: kubectl --kubeconfig=$KC get po -lapp.kubernetes.io/name=keycloak --namespace $PXCNAMESPACE"
    echo "Check keycloak backend pod logs, to get keycloak backend pod: kubectl --kubeconfig=$KC get po -lapp=postgresql --namespace $PXCNAMESPACE"
    logError "Failed to fetch PX-Central-Onprem OIDC admin user access token."
    echo "Contact: support@portworx.com"
    echo ""
    exit 1
  fi

  if [ "$EXTERNAL_OIDC_ENABLED" == "true" ]; then
    logInfo "External OIDC endpoint: $EXTERNAL_OIDCENDPOINT"
    logInfo "External OIDC client ID: $EXTERNAL_OIDCCLIENTID"
    logInfo "External OIDC client secret: $EXTERNAL_OIDCSECRET"
    http_substring='http'
    if [[ "$EXTERNAL_OIDCENDPOINT" == *"$http_substring"* ]]; then
      logInfo "No need to update External OIDC endpoint"
    else
      EXTERNAL_OIDCENDPOINT="https://$EXTERNAL_OIDCENDPOINT"
      logInfo "Updated External OIDC endpoint $EXTERNAL_OIDCENDPOIN"
    fi
    EXTERNAL_OIDCENDPOINT=$(echo $EXTERNAL_OIDCENDPOINT | sed 's:/*$::')
    logInfo "Removed end / from External OIDC endpoint: $EXTERNAL_OIDCENDPOINT"
    authorization_endpoint=`curl -s -X GET "$EXTERNAL_OIDCENDPOINT/.well-known/openid-configuration" --insecure | jq ".authorization_endpoint" | sed 's/\"//g'`
    token_endpoint=`curl -s -X GET "$EXTERNAL_OIDCENDPOINT/.well-known/openid-configuration" --insecure | jq ".token_endpoint" | sed 's/\"//g'`
    logout_endpoint=`curl -s -X GET "$EXTERNAL_OIDCENDPOINT/.well-known/openid-configuration" --insecure | jq ".end_session_endpoint" | sed 's/\"//g'`
    logInfo "Authorization Endpoint: $authorization_endpoint"
    logInfo "Token Endpoint: $token_endpoint"
    logInfo "Logout Endpoint: $logout_endpoint"
    if [ "$logout_endpoint" == "null" ]; then
      logout_endpoint="$EXTERNAL_OIDCENDPOINT/v2/logout"
      logInfo "Updated Logout Endpoint: $logout_endpoint"
    fi
    curl -s -X POST "http://$OIDCENDPOINT/admin/realms/master/identity-provider/instances" \
  -H "Authorization: Bearer $KEYCLOAK_TOKEN" \
  -H 'Content-Type: application/json' \
  --data '    {
        "alias": "oidc",
        "displayName": "PX-Central-External-OIDC",
        "internalId": "d4fe10a1-f363-400f-a526-860b909c39d9",
        "providerId": "oidc",
        "enabled": true,
        "updateProfileFirstLoginMode": "on",
        "trustEmail": false,
        "storeToken": true,
        "addReadTokenRoleOnCreate": false,
        "authenticateByDefault": false,
        "linkOnly": false,
        "firstBrokerLoginFlowAlias": "first broker login",
        "config": {
          "loginHint": "true",
          "uiLocales": "true",
          "clientId": '\"$EXTERNAL_OIDCCLIENTID\"',
          "tokenUrl": '\"$token_endpoint\"',
          "clientAuthMethod": "client_secret_post",
          "authorizationUrl": '\"$authorization_endpoint\"',
          "logoutUrl": '\"$logout_endpoint\"',
          "clientSecret": '\"$EXTERNAL_OIDCSECRET\"',
          "backchannelSupported": "true",
          "prompt": "login",
          "useJwksUrl": "true"
        }
      }'

      configuredIdentityProviderInstance=`curl -s -X GET "http://$OIDCENDPOINT/admin/realms/master/identity-provider/instances" \
      -H "Authorization: Bearer $KEYCLOAK_TOKEN" | jq ".[].config.clientId"`
      logInfo "Identity provider instance: $configuredIdentityProviderInstance"
      if [ ${configuredIdentityProviderInstance} ]; then
        echo ""
        echo  "External OIDC Identity provider configured in PX-Central-Onprem keycloak"
        logInfo "External OIDC Identity provider configured in PX-Central-Onprem keycloak"
      else
        echo ""
        echo  "Failed to setup external OIDC Identity provider in PX-Central-Onprem keycloak"
        logInfo "Failed to setup external OIDC Identity provider in PX-Central-Onprem keycloak"
      fi
  fi    
fi

deploymentready="0"
timecheck=0
count=0
while [ $deploymentready -ne "1" ]
  do
    onpremdeployment=`kubectl --kubeconfig=$KC get deployment pxcentral-onprem-operator --namespace $PXCNAMESPACE 2>&1 | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
    onpremdeploymentocp=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "pxcentral-onprem-operator" | awk '{print $2}' | grep -v READY | grep "2/2" | wc -l 2>&1`
    if [ "$OPENSHIFTCLUSTER" == "true" ]; then
      if [ "$onpremdeploymentocp" -eq "1" ]; then
        deploymentready="1"
        break
      fi
    elif [ "$onpremdeployment" -eq "1" ]; then
      deploymentready="1"
      break
    fi
    showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Operator-- to be ready (4/7)"
    logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Operator-- to be ready (4/7)"
    kubectl --kubeconfig=$KC get po -lname=pxcentral-onprem-operator --namespace $PXCNAMESPACE >> "$LOGFILE"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      operatorPodName=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "pxcentral-onprem-operator" | awk '{print $1}' | grep -v NAME 2>&1`
      echo ""
      kubectl --kubeconfig=$KC logs $operatorPodName --namespace $PXCNAMESPACE -c pxcentral-onprem-operator >> "$LOGFILE"
      echo "Check the logs of onprem operator pod using command: kubectl --kubeconfig=$KC logs $operatorPodName --namespace $PXCNAMESPACE -c pxcentral-onprem-operator"
      echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
      logError "PX-Central deployment is not ready, Contact: support@portworx.com"
      echo ""
      exit 1
    fi
  done

showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Operator-- to be ready (5/7)"
logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Operator-- to be ready (5/7)"
kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE >> "$LOGFILE"
if [ "$PX_BACKUP_DEPLOY" == "true" ]; then
  kubectl --kubeconfig=$KC create secret generic $BACKUP_OIDC_ADMIN_SECRET_NAME --from-literal=PX_BACKUP_ORG_TOKEN=$OIDC_USER_ACCESS_TOKEN --namespace $PX_BACKUP_NAMESPACE &>/dev/null
  backupready="0"
  timecheck=0
  count=0
  while [ $backupready -ne "1" ]
    do
      pxcbackupdeploymentready=`kubectl --kubeconfig=$KC get deployment --namespace $PXCNAMESPACE px-backup 2>&1 | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
      pxcbackupdeploymentreadyocp=`kubectl --kubeconfig=$KC get deployment --namespace $PXCNAMESPACE px-backup 2>&1 | awk '{print $3}' | grep -v CURRENT | grep "1" | wc -l 2>&1`
      logInfo "PX-Backup ETCD pods:"
      kubectl --kubeconfig=$KC get po -lapp.kubernetes.io/name=etcd --namespace $PXCNAMESPACE >> "$LOGFILE"
      logInfo "PX-Backup pod:"
      kubectl --kubeconfig=$KC get po -lapp=px-backup --namespace $PXCNAMESPACE >> "$LOGFILE"
      if [ "$OPENSHIFTCLUSTER" == "true" ]; then
        if [ "$pxcbackupdeploymentreadyocp" -eq "1" ]; then
          backupready="1"
          break
        fi 
      elif [ "$pxcbackupdeploymentready" -eq "1" ]; then
        backupready="1"
        break
      fi
      showMessage "Waiting for PX-Central required components --PX-Central-Onprem-PX-Backup-- to be ready (5/7)"
      logInfo "Waiting for PX-Central required components --PX-Central-Onprem-PX-Backup-- to be ready (5/7)"
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $TIMEOUT ]; then
        echo ""
        echo "ERROR: PX-Central PX-Backup is not ready, Contact: support@portworx.com"
        echo "Check PX-Backup pod logs, to get pod name: kubectl --kubeconfig=$KC get po -lapp=px-backup --namespace $PXCNAMESPACE"
        logInfo "PX-Central PX-Backup is not ready, Contact: support@portworx.com"
        echo ""
        exit 1
      fi
    done
  backup_pod=`kubectl --kubeconfig=$KC get po -lapp=px-backup --namespace $PXCNAMESPACE 2>&1 | grep px-backup | awk '{print $1}' 2>&1`
  logInfo "Backup pod name: $backup_pod"
  orgIDCheck=0
  echo ""
  if [ "$OIDCENABLED" == "false" ]; then
    kubectl --kubeconfig=$KC exec -it $backup_pod --namespace $PXCNAMESPACE -- bash -c "./pxbackupctl/linux/pxbackupctl create organization --name $PX_BACKUP_ORGANIZATION"
    orgIDCheck=`kubectl --kubeconfig=$KC exec -it $backup_pod --namespace $PXCNAMESPACE -- bash -c "./pxbackupctl/linux/pxbackupctl get organization --name $PX_BACKUP_ORGANIZATION" 2>&1 | awk '{print $2}' | grep -v NAME | grep $PX_BACKUP_ORGANIZATION | grep -v "exit code 1" | wc -l 2>&1`
  else
    kubectl --kubeconfig=$KC exec -it $backup_pod --namespace $PXCNAMESPACE -- bash -c "./pxbackupctl/linux/pxbackupctl create organization --name $PX_BACKUP_ORGANIZATION --authtoken $OIDC_USER_ACCESS_TOKEN"
    orgIDCheck=`kubectl --kubeconfig=$KC exec -it $backup_pod --namespace $PXCNAMESPACE -- bash -c "./pxbackupctl/linux/pxbackupctl get organization --name $PX_BACKUP_ORGANIZATION --authtoken $OIDC_USER_ACCESS_TOKEN" 2>&1 | awk '{print $2}' | grep -v NAME | grep $PX_BACKUP_ORGANIZATION | grep -v "exit code 1" | wc -l 2>&1`
  fi
  logInfo "Backup Organization ID check: $orgIDCheck"
  if [ $orgIDCheck -eq 1 ]; then
    echo "PX-Backup organization ID: $PX_BACKUP_ORGANIZATION created successfully."
    logInfo "PX-Backup organization ID: $PX_BACKUP_ORGANIZATION created successfully."
  else
    echo "ERROR: PX-Central-Onprem failed to create organization ID: $PX_BACKUP_ORGANIZATION for PX-Backup. Contact: support@portworx.com"
    logError "PX-Central-Onprem failed to create organization ID: $PX_BACKUP_ORGANIZATION for PX-Backup. Contact: support@portworx.com"
    echo ""
    exit 1
  fi
fi

backendready="0"
timecheck=0
count=0
while [ $backendready -ne "1" ]
  do
    backend_pod=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "pxc-central-backend" | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
    kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE -lrun=pxc-central-backend >> "$LOGFILE"
    if [ "$backend_pod" -eq "1" ]; then
      backendready="1"
      break
    fi 
    showMessage "Waiting for PX-Central required components --PX-Central-Onprem-PX-Backend-- to be ready (5/7)"
    logInfo "Waiting for PX-Central required components --PX-Central-Onprem-PX-Backend-- to be ready (5/7)"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      echo ""
      echo "Check PX-Central-Backend pod logs, to get pod name use command: kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE -lrun=pxc-central-backend"
      echo "ERROR: PX-Central PX-Backend is not ready, Contact: support@portworx.com"
      logInfo "PX-Central PX-Backend is not ready, Contact: support@portworx.com"
      echo ""
      exit 1
    fi
  done
pxcdbready="0"
POD=$(kubectl --kubeconfig=$KC get pod -l app=pxc-mysql --namespace $PXCNAMESPACE -o jsonpath='{.items[0].metadata.name}' 2>&1);
timecheck=0
count=0
while [ $pxcdbready -ne "1" ]
  do
    kubectl --kubeconfig=$KC get po -lrun=pxc-mysql --namespace $PXCNAMESPACE >> "$LOGFILE"
    dbpodready=`kubectl --kubeconfig=$KC get pods -lrun=pxc-mysql --namespace $PXCNAMESPACE 2>&1 | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
    if [ "$dbpodready" -eq "1" ]; then
      dbrunning=`kubectl --kubeconfig=$KC exec -it $POD --namespace $PXCNAMESPACE -- /etc/init.d/mysql status 2>&1 | grep "running" | wc -l 2>&1`
      if [ "$dbrunning" -eq "1" ]; then
        logInfo "PX-Central-DB is ready to accept connections. Starting Initialization.."
        backendPodName=`kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE -lrun=pxc-central-backend 2>&1 | grep -v NAME | awk '{print $1}'`
        logInfo "PX-Central-Backend pod name: $backendPodName"
        kubectl --kubeconfig=$KC exec -it $backendPodName --namespace $PXCNAMESPACE -- bash -c "cd /var/www/centralApi/ && /var/www/centralApi/install.sh" >> "$LOGFILE"
        pxcdbready="1"
        break
      fi
    fi
    showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Cluster-Store-- to be ready (5/7)"
    logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Cluster-Store-- to be ready (5/7)"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      podName=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "pxc-mysql" | awk '{print $1}' | grep -v NAME 2>&1`
      echo ""
      echo "Check PX-Central database pod logs, to get pod name use command: kubectl --kubeconfig=$KC get po -lrun=pxc-mysql --namespace $PXCNAMESPACE"
      echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
      logError "PX-Central deployment is not ready, Contact: support@portworx.com"
      echo ""
      exit 1
    fi
  done

showMessage "Waiting for PX-Central required components --PX-Central-Cluster-Store-- to be ready (6/7)"
logInfo "Waiting for PX-Central required components --PX-Central-Cluster-Store-- to be ready (6/7)"
postsetupjob="0"
timecheck=0
count=0
while [ $postsetupjob -ne "1" ]
  do
    showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Post-Install-Checks-- to be ready (6/7)"
    logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Post-Install-Checks-- to be ready (6/7)"
    count=$[$count+1]
    if [ "$count" -eq "1" ]; then
      kubectl --kubeconfig=$KC delete job pxc-post-setup --namespace $PXCNAMESPACE >> "$LOGFILE"
      sleep 5
    fi
    kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE | grep "pxc-post-setup" >> "$LOGFILE"
    pxcpostsetupjob=`kubectl --kubeconfig=$KC get jobs --namespace $PXCNAMESPACE pxc-post-setup 2>&1 | awk '{print $2}' | grep -v COMPLETIONS | grep "1/1" | wc -l 2>&1`
    pxcpostsetupjobocp=`kubectl --kubeconfig=$KC get jobs --namespace $PXCNAMESPACE pxc-post-setup 2>&1 | awk '{print $2}' | grep -v SUCCESSFUL | grep "1" | wc -l 2>&1`
    backend=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep -i "pxc-central-backend" | awk '{print $2}' | grep "1/1" | wc -l 2>&1`
    frontend=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep -i "pxc-central-frontend" | awk '{print $2}' | grep "1/1" | wc -l 2>&1`
    CHECKOIDCENABLE=`kubectl --kubeconfig=$KC get cm --namespace $PXCENTRALNAMESPACE pxc-admin-user -o jsonpath={.data.oidc} 2>&1`
    if [ "$OPENSHIFTCLUSTER" == "true" ]; then
      if [[ "$CHECKOIDCENABLE" == "true" && "$pxcpostsetupjobocp" -eq "1" && "$backend" -eq "1" && "$frontend" -eq "1" ]]; then
        break
      fi
    elif [[ "$CHECKOIDCENABLE" == "true" && "$pxcpostsetupjob" -eq "1" && "$backend" -eq "1" && "$frontend" -eq "1" ]]; then
      break
    fi
    if [ "$OPENSHIFTCLUSTER" == "true" ]; then
      if [[ "$pxcpostsetupjobocp" -eq "1" && "$backend" -eq "1" && "$frontend" -eq "1" ]]; then
        postsetupjob="1"
        showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Post-Install-Checks-- to be ready (7/7)"
        logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Post-Install-Checks-- to be ready (7/7)"
        break
      fi
    elif [[ "$pxcpostsetupjob" -eq "1" && "$backend" -eq "1" && "$frontend" -eq "1" ]]; then
      postsetupjob="1"
      showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Post-Install-Checks-- to be ready (7/7)"
      logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Post-Install-Checks-- to be ready (7/7)"
      break
    fi
    showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Post-Install-Checks-- to be ready (6/7)"
    logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Post-Install-Checks-- to be ready (6/7)"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      echo ""
      echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
      logInfo "PX-Central deployment is not ready, Contact: support@portworx.com"
      echo ""
      exit 1
    fi
  done
logInfo "PX-Central configuration jobs:"
kubectl --kubeconfig=$KC get jobs --namespace $PXCNAMESPACE >> "$LOGFILE"
echo ""
echo -e -n "PX-Central cluster deployment complete."
logInfo "PX-Central cluster deployment complete."
echo ""
echo ""
echo "+================================================+"
echo "SAVE THE FOLLOWING DETAILS FOR FUTURE REFERENCES"
echo "+================================================+"
FORWARDING_PROXY_URL=""
if [ "$DOMAIN_SETUP_REQUIRED" == "true" ]; then
  url="http://$PXC_FRONTEND"
  FORWARDING_PROXY_URL="http://$PXC_PROXY_FORWARDING/host"
elif [ "$INGRESS_SETUP_REQUIRED" == "true" ]; then
  url="http://$INGRESS_ENDPOINT/pxcentral"
  FORWARDING_PROXY_URL="http://$INGRESS_ENDPOINT/proxy/host"
else
  url="http://$PXENDPOINT:$PXC_UI_EXTERNAL_PORT/pxcentral"
  FORWARDING_PROXY_URL="http://$PXENDPOINT:$PXC_UI_EXTERNAL_PORT/proxy/host"
fi
echo "PX-Central User Interface Access URL : $url"
logInfo "PX-Central User Interface Access URL : $url"
if [ "$ENABLE_PROXY_FORWARDING" == "true" ]; then
  echo "Proxy forwarding enabled on this PX-Central-Onprem cluster. URL: $FORWARDING_PROXY_URL"
  logInfo "Proxy forwarding enabled on this PX-Central-Onprem cluster. URL: $FORWARDING_PROXY_URL"
fi
timecheck=0
while true
  do
    status_code=$(curl --write-out %{http_code} --silent --output /dev/null $url)
    if [[ "$status_code" -eq 200 ]] ; then
      echo -e -n ""
      break
    fi
    showMessage "Validating PX-Central endpoint access."
    logInfo "Validating PX-Central endpoint access."
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $LBSERVICETIMEOUT ]; then
      echo ""
      echo "Check all onprem-central deployed pods are up and running into given namespace: $PXCNAMESPACE"
      echo "Check PX-Central-Onprem UI URL [$url] is accessible."
      echo "ERROR: Failed to check PX-Central endpoint accessible, Contact: support@portworx.com"
      logError "Failed to check PX-Central endpoint accessible, Contact: support@portworx.com"
      echo ""
      break
    fi
  done
echo ""
echo -e -n ""

if [ "$OIDCENABLED" == "false" ]; then
    echo "PX-Central admin user name: $ADMINEMAIL"
    echo "PX-Central admin user password: $ADMINPASSWORD"
    logInfo "PX-Central admin user name: $ADMINEMAIL"
    logInfo "PX-Central admin user password: $ADMINPASSWORD"
    echo ""
    if [ "$PX_METRICS_DEPLOY" == "true" ]; then
      echo "PX-Central grafana admin user name: $ADMINEMAIL"
      echo "PX-Central grafana admin user password: $ADMINPASSWORD"
      logInfo "PX-Central grafana admin user name: $ADMINEMAIL"
      logInfo "PX-Central grafana admin user password: $ADMINPASSWORD"
    fi
    if [ "$PX_BACKUP_DEPLOY" == "true" ]; then
      echo ""
      echo "PX-Central PX-Backup Organization ID: $PX_BACKUP_ORGANIZATION"
      logInfo "PX-Central PX-Backup Organization ID: $PX_BACKUP_ORGANIZATION"
    fi
else
  echo ""
  if [ "$PX_BACKUP_DEPLOY" == "true" ]; then
    echo "PX-Central PX-Backup Organization ID: $PX_BACKUP_ORGANIZATION"
    logInfo "PX-Central PX-Backup Organization ID: $PX_BACKUP_ORGANIZATION"
  fi
  if [ "$PXCPROVISIONEDOIDC" == "true" ]; then
    echo "Keycloak Endpoint: http://$OIDCENDPOINT"
    echo "Keycloak admin user: $KEYCLOAK_FRONTEND_USERNAME"
    echo "Keycloak admin password: $KEYCLOAK_FRONTEND_PASSWORD"
    echo "OIDC CLIENT ID: $PXC_OIDC_CLIENT_ID, OIDC CLIENT SECRET: $PXC_OIDC_CLIENT_SECRET, OIDC ENDPOINT: $OIDCENDPOINT"
    logInfo "Keycloak Endpoint: http://$OIDCENDPOINT"
    logInfo "Keycloak admin user: $KEYCLOAK_FRONTEND_USERNAME"
    logInfo "Keycloak admin password: $KEYCLOAK_FRONTEND_PASSWORD"
    logInfo "OIDC CLIENT ID: $PXC_OIDC_CLIENT_ID, OIDC CLIENT SECRET: $PXC_OIDC_CLIENT_SECRET, OIDC ENDPOINT: $OIDCENDPOINT"
    if [ "$EXTERNAL_OIDC_ENABLED" == "true" ]; then
      echo ""
      CALLBACK_URL="http://$OIDCENDPOINT/realms/master/broker/oidc/endpoint"
      DOC_URL="https://docs.portworx.com/portworx-install-with-kubernetes/operate-and-maintain-on-kubernetes/pxcentral-onprem/set-up-login-redirects/"
      echo "Configure following endpoint as login redirect/callback URL in External OIDC provider: $CALLBACK_URL"
      echo "Please, refer doc url: $DOC_URL"
      logInfo "Configure following endpoint as login redirect/callback URL in External OIDC provider: $CALLBACK_URL"
      logInfo "Please, refer doc url: $DOC_URL"
    fi
  fi
fi
echo "+================================================+"
echo ""

central_deployment_time=$((($(date +%s)-$start_time)/60))
echo "PX-Central-Onprem cluster deployment time taken: $central_deployment_time minutes."
logInfo "PX-Central-Onprem cluster deployment time taken: $central_deployment_time minutes."
logInfo "===========PX-Central-Onprem Installation Done============"
logInfo "+================================================+"
echo ""
