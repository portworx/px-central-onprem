#!/usr/bin/env bash
usage()
{
cat <<EOEG
Usage: $0 
Optional:
    --kubeconfig <Kubeconfig file>
    --pxcentral-namespace <PX-Central-Onprem cluster namespace>
    --pxcentral-upgrade-version <Version to upgrade PX-Central-Onprem>
    --pxcentral-image-repo <Image repo for air-gapped deployment>

Examples:
    # Upgrade PX-Central cluster to latest stable version
    ./upgrade.sh

    # Upgrade PX-Central cluster using kubeconfig present into different path
    ./upgrade.sh --kubeconfig /root/.kube/config

    # Upgrade PX-Central running into other than default(portworx) namespace
    ./upgrade.sh --pxcentral-namespace kube-system

    # Upgrade PX-Central to specific version 
    ./upgrade.sh --pxcentral-upgrade-version 1.0.2

    # Upgrade PX-Central to specific version running into air-gapped env with different image repo
    ./upgrade.sh --pxcentral-upgrade-version 1.0.2 --pxcentral-image-repo docker.portworx.com/portworx

EOEG
exit 1
}

while [ "$1" != "" ]; do
    case $1 in
    --kubeconfig)                   shift
                                    KC=$1
                                    ;;
    --pxcentral-namespace)          shift
                                    PXCNAMESPACE=$1
                                    ;;
    --pxcentral-image-repo)         shift
                                    PXCENTRAL_IMAGE_REPO=$1
                                    ;;
    --pxcentral-upgrade-version)    shift
                                    PXCENTRAL_ONPREM_UPGRADE_VERSION=$1
                                    ;;
    -h | --help )                   usage
                                    ;;
    * )             usage
    esac
    shift
done

TIMEOUT=1800
SLEEPINTERVAL=5
PXCNAMESPACE_DEFAULT="portworx"
PXCENTRAL_IMAGE_REPO_DEFAULT="portworx"
PXC_BACKUP_DEPLOYMENT_NAME="px-backup"
PXC_FRONTEND_DEPLOYMENT_NAME="pxc-central-frontend"
PXC_BACKEND_DEPLOYMENT_NAME="pxc-central-backend"
PXC_MIDDLEWARE_DEPLOYMENT_NAME="pxc-central-lh-middleware"
PXC_API_SERVER_DEPLOYMENT_NAME="pxc-apiserver"
PXCENTRAL_ONPREM_UPGRADE_VERSION_DEFAULT="1.0.2"

if [ -z ${PXCENTRAL_IMAGE_REPO} ]; then
    PXCENTRAL_IMAGE_REPO=$PXCENTRAL_IMAGE_REPO_DEFAULT
fi
if [ -z ${PXCENTRAL_ONPREM_UPGRADE_VERSION} ]; then
    PXCENTRAL_ONPREM_UPGRADE_VERSION=$PXCENTRAL_ONPREM_UPGRADE_VERSION_DEFAULT
fi
if [ "$PXCENTRAL_ONPREM_UPGRADE_VERSION" == "1.0.2" ]; then
    PXC_ONPREM_UPGRADE_VERSION="1.0.2"
    PXC_API_SERVER_IMAGE="pxcentral-onprem-api:1.0.2"
    PXC_BACKUP_IMAGE="px-backup:1.0.1"
    PXC_FRONTEND_IMAGE="pxcentral-onprem-ui-frontend:1.1.1"
    PXC_BACKEND_IMAGE="pxcentral-onprem-ui-backend:1.1.1"
    PXC_MIDDLEWARE_IMAGE="pxcentral-onprem-ui-lhbackend:1.1.1"
elif [ "$PXCENTRAL_ONPREM_UPGRADE_VERSION" == "1.0.1" ]; then
    PXC_ONPREM_UPGRADE_VERSION="1.0.1"
    PXC_API_SERVER_IMAGE="pxcentral-onprem-api:1.0.1"
    PXC_FRONTEND_IMAGE="pxcentral-onprem-ui-frontend:1.1.0"
    PXC_BACKEND_IMAGE="pxcentral-onprem-ui-backend:1.1.0"
    PXC_MIDDLEWARE_IMAGE="pxcentral-onprem-ui-lhbackend:1.1.0"
fi

LOGFILE="/tmp/pxcentral-onprem-upgrade.log"
logInfo() {
    echo "$(date): level=info msg=$@" >> "$LOGFILE"
}
logError() {
    echo "$(date): level=error msg=$@" >> "$LOGFILE"
}
logWarning() {
    echo "$(date): level=warning msg=$@" >> "$LOGFILE"
}

export dotCount=0
export maxDots=10
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

start_time=`date +%s`
logInfo "+================================================+"
logInfo "===========PX-Central-Onprem Upgrade Started============"
if [ -z ${PXCNAMESPACE} ]; then
  PXCNAMESPACE=$PXCNAMESPACE_DEFAULT
fi
logInfo "PX-Central-Onprem namespace: $PXCNAMESPACE"
logInfo "PX-Central-Onprem upgrade version request : $PXCENTRAL_ONPREM_UPGRADE_VERSION"
if [[ "$PXCENTRAL_ONPREM_UPGRADE_VERSION" != "1.0.1" && "$PXCENTRAL_ONPREM_UPGRADE_VERSION" != "1.0.2" ]]; then
  echo ""
  echo "ERROR: Latest stable PX-Central-Onprem version is: 1.0.2 and supported upgrade versions are 1.0.1 and 1.0.2"
  echo ""
  logInfo "Latest stable PX-Central-Onprem version is: 1.0.2 and supported upgrade versions are 1.0.1 and 1.0.2"
  exit 1
fi
if [ -z ${KC} ]; then
  KC=$KUBECONFIG
fi

if [ -z ${KC} ]; then
    KC="$HOME/.kube/config"
fi
echo ""
echo "Using Kubeconfig: $KC"
logInfo "Using Kubeconfig: $KC"
checkK8sVersion=`kubectl --kubeconfig=$KC version --short | awk -Fv '/Server Version: / {print $3}' 2>&1`
echo "Kubernetes cluster version: $checkK8sVersion"
logInfo "Kubernetes cluster version: $checkK8sVersion"
if [ "$PXCENTRAL_ONPREM_UPGRADE_VERSION" == "1.0.2" ]; then
  kubectl --kubeconfig=$KC patch cm --namespace $PXCNAMESPACE pxc-central-ui-configmap --type merge -p '{"data":{"APP_LOG": "errorlog"}}' &> "$LOGFILE"
  kubectl --kubeconfig=$KC patch cm --namespace $PXCNAMESPACE pxc-central-ui-configmap --type merge -p '{"data":{"LOG_CHANNEL": "errorlog"}}' &> "$LOGFILE"
  
  kubectl --kubeconfig=$KC set image deployment/$PXC_BACKUP_DEPLOYMENT_NAME px-backup=$PXCENTRAL_IMAGE_REPO/$PXC_BACKUP_IMAGE --namespace $PXCNAMESPACE &> "$LOGFILE"
  logInfo "Set the PX-Backup image: $PXCENTRAL_IMAGE_REPO/$PXC_BACKUP_IMAGE"
  backupdeploymentready="0"
  timecheck=0
  count=0
  while [ $backupdeploymentready -ne "1" ]
    do
      kubectl --kubeconfig=$KC get po -lapp=px-backup --namespace $PXCNAMESPACE &> "$LOGFILE"
      backuppodready=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep -v "Terminating" | grep -v "ContainerCreating" | grep "$PXC_BACKUP_DEPLOYMENT_NAME" | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
      if [ "$backuppodready" -eq "1" ]; then
          backupdeploymentready="1"
          break
      fi
      showMessage "Waiting for --PX-Central-PX-Backup-- to be ready (0/6)"
      logInfo "Waiting for PX-Central required components --PX-Central-PX-Backup-- to be ready (0/6)"
      kubectl --kubeconfig=$KC get po -lapp=px-backup --namespace $PXCNAMESPACE >> "$LOGFILE"
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $TIMEOUT ]; then
        echo ""
        echo "PX-Central onprem $PXC_BACKUP_DEPLOYMENT_NAME deployment not ready... Timeout: $TIMEOUT seconds"
        logError "PX-Central onprem $PXC_BACKUP_DEPLOYMENT_NAME deployment not ready... Timeout: $TIMEOUT seconds"
        echo "ERROR: PX-Central $PXC_BACKUP_DEPLOYMENT_NAME deployment is not ready, Contact: support@portworx.com"
        logError "PX-Central $PXC_BACKUP_DEPLOYMENT_NAME deployment is not ready, check  Contact: support@portworx.com"
        echo ""
        exit 1
      fi
    done
fi
kubectl --kubeconfig=$KC set image deployment/$PXC_BACKEND_DEPLOYMENT_NAME px-central-backend=$PXCENTRAL_IMAGE_REPO/$PXC_BACKEND_IMAGE --namespace $PXCNAMESPACE &> "$LOGFILE"
logInfo "Set the PX-Central-Backend image: $PXCENTRAL_IMAGE_REPO/$PXC_BACKEND_IMAGE"
backenddeploymentready="0"
timecheck=0
count=0
while [ $backenddeploymentready -ne "1" ]
  do
    kubectl --kubeconfig=$KC get po -lrun=pxc-central-backend --namespace $PXCNAMESPACE &> "$LOGFILE"
    backuppodready=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep -v "Terminating" | grep -v "ContainerCreating" | grep "$PXC_BACKEND_DEPLOYMENT_NAME" | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
    if [ "$backuppodready" -eq "1" ]; then
        backenddeploymentready="1"
        break
    fi
    showMessage "Waiting for --PX-Central-Backend-- to be ready (1/6)"
    logInfo "Waiting for PX-Central required components --PX-Central-Backend-- to be ready (1/6)"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      echo ""
      echo "PX-Central onprem $PXC_BACKEND_DEPLOYMENT_NAME deployment not ready... Timeout: $TIMEOUT seconds"
      logError "PX-Central onprem $PXC_BACKEND_DEPLOYMENT_NAME deployment not ready... Timeout: $TIMEOUT seconds"
      echo "ERROR: PX-Central $PXC_BACKEND_DEPLOYMENT_NAME deployment is not ready, Contact: support@portworx.com"
      logError "PX-Central $PXC_BACKEND_DEPLOYMENT_NAME deployment is not ready, Contact: support@portworx.com"
      echo ""
      exit 1
    fi
  done
kubectl --kubeconfig=$KC set image deployment/$PXC_API_SERVER_DEPLOYMENT_NAME pxc-apiserver=$PXCENTRAL_IMAGE_REPO/$PXC_API_SERVER_IMAGE --namespace $PXCNAMESPACE &> "$LOGFILE"
logInfo "Set the PX-API-Server image: $PXCENTRAL_IMAGE_REPO/$PXC_API_SERVER_IMAGE"
apiserverdeploymentready="0"
timecheck=0
count=0
while [ $apiserverdeploymentready -ne "1" ]
  do
    kubectl --kubeconfig=$KC get po -lapp=pxc-apiserver --namespace $PXCNAMESPACE &> "$LOGFILE"
    apiserverpodready=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep -v "Terminating" | grep -v "ContainerCreating" | grep "$PXC_API_SERVER_DEPLOYMENT_NAME" | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
    if [ "$apiserverpodready" -eq "1" ]; then
        apiserverdeploymentready="1"
        break
    fi
    showMessage "Waiting for --PX-Central-API-Server-- to be ready (2/6)"
    logInfo "Waiting for PX-Central required components --PX-Central-API-Server-- to be ready (2/6)"
    kubectl --kubeconfig=$KC get po -lapp=pxc-apiserver --namespace $PXCNAMESPACE >> "$LOGFILE"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      echo ""
      echo "PX-Central onprem $PXC_API_SERVER_DEPLOYMENT_NAME deployment not ready... Timeout: $TIMEOUT seconds"
      logError "PX-Central onprem $PXC_API_SERVER_DEPLOYMENT_NAME deployment not ready... Timeout: $TIMEOUT seconds"
      echo "ERROR: PX-Central $PXC_API_SERVER_DEPLOYMENT_NAME deployment is not ready, Contact: support@portworx.com"
      logError "PX-Central $PXC_API_SERVER_DEPLOYMENT_NAME deployment is not ready, Contact: support@portworx.com"
      echo ""
      exit 1
    fi
  done
kubectl --kubeconfig=$KC set image deployment/$PXC_FRONTEND_DEPLOYMENT_NAME px-central-frontend=$PXCENTRAL_IMAGE_REPO/$PXC_FRONTEND_IMAGE --namespace $PXCNAMESPACE &> "$LOGFILE"
logInfo "Set the PX-Central-Frontend image: $PXCENTRAL_IMAGE_REPO/$PXC_FRONTEND_IMAGE"
frontenddeploymentready="0"
timecheck=0
count=0
while [ $frontenddeploymentready -ne "1" ]
  do
    kubectl --kubeconfig=$KC get po -lrun=pxc-central-frontend --namespace $PXCNAMESPACE &> "$LOGFILE"
    frontendpodready=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep -v "Terminating" | grep -v "ContainerCreating" | grep "$PXC_FRONTEND_DEPLOYMENT_NAME" | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
    if [ "$frontendpodready" -eq "1" ]; then
        frontenddeploymentready="1"
        break
    fi
    showMessage "Waiting for --PX-Central-Frontend-- to be ready (3/6)"
    logInfo "Waiting for PX-Central required components --PX-Central-Frontend-- to be ready (3/6)"
    kubectl --kubeconfig=$KC get po -lrun=pxc-central-frontend --namespace $PXCNAMESPACE >> "$LOGFILE"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      echo ""
      echo "PX-Central onprem $PXC_FRONTEND_DEPLOYMENT_NAME deployment not ready... Timeout: $TIMEOUT seconds"
      logError "PX-Central onprem $PXC_FRONTEND_DEPLOYMENT_NAME deployment not ready... Timeout: $TIMEOUT seconds"
      echo "ERROR: PX-Central $PXC_FRONTEND_DEPLOYMENT_NAME deployment is not ready, Contact: support@portworx.com"
      logError "PX-Central $PXC_FRONTEND_DEPLOYMENT_NAME deployment is not ready, Contact: support@portworx.com"
      echo ""
      exit 1
    fi
  done
echo ""
backendready="0"
timecheck=0
count=0
while [ $backendready -ne "1" ]
  do
    backend_pod=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "pxc-central-backend" | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
    kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE -lrun=pxc-central-backend &> "$LOGFILE"
    if [ "$backend_pod" -eq "1" ]; then
      backendready="1"
      break
    fi 
    showMessage "Waiting for PX-Central required components --PX-Central-Onprem-PX-Backend-- to be ready (4/6)"
    logInfo "Waiting for PX-Central required components --PX-Central-Onprem-PX-Backend-- to be ready (4/6)"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      echo ""
      echo "ERROR: PX-Central PX-Backend is not ready, Contact: support@portworx.com"
      logInfo "PX-Central PX-Backend is not ready, Contact: support@portworx.com"
      echo ""
      exit 1
    fi
  done
logInfo "Upgrading PX-Central-Cluster-Store:"
pxcdbready="0"
POD=$(kubectl --kubeconfig=$KC get pod -l app=pxc-mysql --namespace $PXCNAMESPACE -o jsonpath='{.items[0].metadata.name}' 2>&1);
timecheck=0
count=0
while [ $pxcdbready -ne "1" ]
  do
    kubectl --kubeconfig=$KC get po -lrun=pxc-mysql --namespace $PXCNAMESPACE &> "$LOGFILE"
    dbpodready=`kubectl --kubeconfig=$KC get pods -lrun=pxc-mysql --namespace $PXCNAMESPACE 2>&1 | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
    if [ "$dbpodready" -eq "1" ]; then
      dbrunning=`kubectl --kubeconfig=$KC exec -it $POD --namespace $PXCNAMESPACE -- /etc/init.d/mysql status 2>&1 | grep "running" | wc -l 2>&1`
      if [ "$dbrunning" -eq "1" ]; then
        logInfo "PX-Central-DB is ready to accept connections. Starting Initialization.."
        backendPodName=`kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE -lrun=pxc-central-backend 2>&1 | grep -v NAME | awk '{print $1}'`
        logInfo "PX-Central-Backend pod name: $backendPodName"
        kubectl --kubeconfig=$KC exec -it $backendPodName --namespace $PXCNAMESPACE -- bash -c "cd /var/www/centralApi/ && /var/www/centralApi/upgrade.sh" &> "$LOGFILE"
        pxcdbready="1"
        break
      fi
    fi
    showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Cluster-Store-- to be ready (4/6)"
    logInfo "Waiting for PX-Central required components --PX-Central-Onprem-Cluster-Store-- to be ready (4/6)"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      echo ""
      echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
      logError "PX-Central deployment is not ready, Contact: support@portworx.com"
      echo ""
      exit 1
    fi
  done
logInfo "PX-Central-Onprem-Cluster-Store updated successfully.."
kubectl --kubeconfig=$KC set image deployment/$PXC_MIDDLEWARE_DEPLOYMENT_NAME pxc-lighthouse-backend=$PXCENTRAL_IMAGE_REPO/$PXC_MIDDLEWARE_IMAGE --namespace $PXCNAMESPACE &> "$LOGFILE"
logInfo "Set the PX-Central-Middleware image: $PXCENTRAL_IMAGE_REPO/$PXC_MIDDLEWARE_IMAGE"
middlewaredeploymentready="0"
timecheck=0
count=0
while [ $middlewaredeploymentready -ne "1" ]
  do
    kubectl --kubeconfig=$KC get po -lrun=pxc-central-lh-middleware --namespace $PXCNAMESPACE &> "$LOGFILE"
    middlewarepodready=`kubectl --kubeconfig=$KC get pods -lrun=pxc-central-lh-middleware --namespace $PXCNAMESPACE 2>&1 | grep -v "Terminating" | grep -v "ContainerCreating" | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
    if [ "$middlewarepodready" -eq "1" ]; then
        middlewaredeploymentready="1"
        break
    fi
    showMessage "Waiting for --PX-Central-Middleware-- to be ready (5/6)"
    logInfo "Waiting for PX-Central required components --PX-Central-Middleware-- to be ready (5/6)"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      echo ""
      echo "PX-Central onprem $PXC_MIDDLEWARE_DEPLOYMENT_NAME deployment not ready... Timeout: $TIMEOUT seconds"
      logError "PX-Central onprem $PXC_MIDDLEWARE_DEPLOYMENT_NAME deployment not ready... Timeout: $TIMEOUT seconds"
      echo "ERROR: PX-Central $PXC_MIDDLEWARE_DEPLOYMENT_NAME deployment is not ready, Contact: support@portworx.com"
      logError "PX-Central $PXC_MIDDLEWARE_DEPLOYMENT_NAME deployment is not ready, Contact: support@portworx.com"
      echo ""
      exit 1
    fi    
  done
showMessage "Waiting for --PX-Central-Middleware-- to be ready (6/6)"
echo ""
echo "PX-Central-Onprem upgrade to $PXC_ONPREM_UPGRADE_VERSION completed."
echo ""
central_upgrade_time=$((($(date +%s)-$start_time)/60))
echo "PX-Central-Onprem cluster upgrade time taken: $central_upgrade_time minutes."
logInfo "PX-Central-Onprem cluster upgrade time taken: $central_upgrade_time minutes."
logInfo "===========PX-Central-Onprem Upgrade Done============"
logInfo "+================================================+"
echo ""