#!/usr/bin/env bash
usage()
{
cat <<EOEG
Usage: $0 
Optional:
    --kubeconfig <Kubeconfig file>
    --pxcentral-namespace <PX-Central-Onprem cluster namespace>
Examples:
    ./cleanup.sh --kubeconfig /root/.kube/config
EOEG
exit 1
}

while [ "$1" != "" ]; do
    case $1 in
    --kubeconfig)     shift
                      KC=$1
                      ;;
    --pxcentral-namespace)    shift
                              PXCNAMESPACE=$1
                              ;;
    -h | --help )   usage
                    ;;
    * )             usage
    esac
    shift
done

TIMEOUT=1800
SLEEPINTERVAL=5
PXCNAMESPACE_DEFAULT="portworx"
PX_BACKUP_NAMESPACE="px-backup"
PXCENTRALCRDNAME="pxcentralonprems.pxcentral.com"
ONPREMDEPLOYMENT="pxcentral-onprem-operator"
PXOPERATORDEPLOYMENT="portworx-operator"
PXCENTRALONPREMCR="pxcentralonprem"
ISOCP311CLUSTER="false"

mysqlDeploymentName="pxc-mysql"
grafanaDeploymentName="pxc-grafana"
cassandraStsName="pxc-cortex-cassandra"
postgresqlStsName="pxc-keycloak-postgresql"
keycloakStsName="pxc-keycloak"
etcdStsName="pxc-backup-etcd"
ingressName="pxc-onprem-central-ingress"
cortexDeploymentName="pxc-cortex-ingester"

start_time=`date +%s`
if [ -z ${PXCNAMESPACE} ]; then
  PXCNAMESPACE=$PXCNAMESPACE_DEFAULT
fi

if [ -z ${KC} ]; then
  KC=$KUBECONFIG
fi

if [ -z ${KC} ]; then
    KC="$HOME/.kube/config"
fi
echo ""
echo "Using Kubeconfig: $KC"
checkK8sVersion=`kubectl --kubeconfig=$KC version --short | awk -Fv '/Server Version: / {print $3}' 2>&1`
echo "Kubernetes cluster version: $checkK8sVersion"
k8sVersion111Validate=`echo -n $checkK8sVersion | grep -E '1.11'`
k8sVersion112Validate=`echo -n $checkK8sVersion | grep -E '1.12'`
k8sVersion113Validate=`echo -n $checkK8sVersion | grep -E '1.13'`
k8sVersion114Validate=`echo -n $checkK8sVersion | grep -E '1.14'`
k8sVersion115Validate=`echo -n $checkK8sVersion | grep -E '1.15'`
k8sVersion116Validate=`echo -n $checkK8sVersion | grep -E '1.16'`
k8sVersion117Validate=`echo -n $checkK8sVersion | grep -E '1.17'`
if [[ -z "$k8sVersion112Validate" && -z "$k8sVersion113Validate" && -z "$k8sVersion114Validate" && -z "$k8sVersion115Validate" && -z "$k8sVersion116Validate" && -z "$k8sVersion117Validate" ]]; then
  ISOCP311CLUSTER="true"
fi

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

echo ""
crdstatus=`kubectl --kubeconfig=$KC get crd $PXCENTRALCRDNAME 2>&1 | grep -v NAME | grep -v "error" | awk '{print $1}' | wc -l 2>&1`
if [ $crdstatus -eq 0 ]; then
    echo "PX-Central is not running on this k8s cluster."
    exit 1
fi

pxcentralnamespacestatus=`kubectl --kubeconfig=$KC get ns $PXCNAMESPACE 2>&1 | grep -v NAME | grep -v "error" | awk '{print $1}' | wc -l 2>&1`
if [ $pxcentralnamespacestatus -eq 0 ]; then
    echo "Input cluster does not have $PXCNAMESPACE namespace."
    exit 1
fi

storageclusterstatus=`kubectl --kubeconfig=$KC get storagecluster --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | grep -v "error" | grep -v "No resources found" | awk '{print $1}' | wc -l 2>&1`
if [ $storageclusterstatus -eq 0 ]; then
    echo "No storage cluster available to delete in $PXCNAMESPACE namespace."
fi

echo "PX-Central cluster cleanup started:"
echo ""
echo "This process may take several minutes. Please wait for it to complete..."
kubectl --kubeconfig=$KC scale deployment $ONPREMDEPLOYMENT --namespace $PXCNAMESPACE --replicas=0 &>/dev/null
sleep $SLEEPINTERVAL
echo "PX-Central components cleanup:"
kubectl --kubeconfig=$KC scale deployment $mysqlDeploymentName --namespace $PXCNAMESPACE --replicas=0 &>/dev/null
kubectl --kubeconfig=$KC scale deployment $grafanaDeploymentName --namespace $PXCNAMESPACE --replicas=0 &>/dev/null
kubectl --kubeconfig=$KC scale deployment $cortexDeploymentName --namespace $PXCNAMESPACE --replicas=0 &>/dev/null
kubectl --kubeconfig=$KC scale sts $cassandraStsName --namespace $PXCNAMESPACE --replicas=0 &>/dev/null
kubectl --kubeconfig=$KC scale sts $postgresqlStsName --namespace $PXCNAMESPACE --replicas=0 &>/dev/null
kubectl --kubeconfig=$KC scale sts $keycloakStsName --namespace $PXCNAMESPACE --replicas=0 &>/dev/null
kubectl --kubeconfig=$KC scale sts $etcdStsName --namespace $PXCNAMESPACE --replicas=0 &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete deployment --grace-period=0 --force --namespace $PXCNAMESPACE  $(kubectl --kubeconfig=$KC get deployment --namespace $PXCNAMESPACE | awk '{print $1}' | grep -v NAME | grep -v portworx-operator 2>&1) &>/dev/null
kubectl --kubeconfig=$KC delete sts --grace-period=0 --force --namespace $PXCNAMESPACE  $(kubectl --kubeconfig=$KC get sts --namespace $PXCNAMESPACE | awk '{print $1}' | grep -v NAME 2>&1) &>/dev/null
sleep $SLEEPINTERVAL
echo ""
pxPodsCount=`kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE -lname=portworx 2>&1 | grep -v "NAME" | grep -v "error" | grep -v "No resources found" | wc -l 2>&1`
echo "Portworx pods count: $pxPodsCount"
if [ $storageclusterstatus -eq 1 ]; then
    echo "Portworx cluster cleanup:"
    echo "Wait for storage cluster to delete"
    storageclustername=`kubectl --kubeconfig=$KC get storagecluster --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | grep -v "error" | grep -v "No resources found" | awk '{print $1}' 2>&1`
    kubectl --kubeconfig=$KC delete storagecluster $storageclustername --namespace $PXCNAMESPACE &>/dev/null

    storageclusterstatus=`kubectl --kubeconfig=$KC get storagecluster --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | grep -v "error" | grep -v "No resources found" | awk '{print $1}' | wc -l 2>&1`
    if [ $storageclusterstatus -eq 0 ]; then
        echo "No storage cluster available to delete in $PXCNAMESPACE namespace."
    fi
    echo "Storage cluster deleted."
    echo ""
elif [ $pxPodsCount -gt 0 ]; then
    echo "Portworx cluster cleanup:"
    curl -fsL https://install.portworx.com/px-wipe | bash #-s -- --force
fi

pxcentralobject=`kubectl --kubeconfig=$KC get $PXCENTRALONPREMCR --namespace $PXCNAMESPACE 2>&1 |  grep -v NAME | grep -v "error" | grep -v "No resources found" | awk '{print $1}'`
kubectl --kubeconfig=$KC patch $pxcentralobject -p '{"metadata":{"finalizers": []}}' --type=merge $pxcentralobject --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC  delete $pxcentralobject $pxcentralobject --namespace $PXCNAMESPACE &>/dev/null
stackcheck=0
timecheck=0
while [ $stackcheck -eq 1 ]
    do
        pod_count=`kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | awk '{print $1}' | grep "px" | wc -l`
        px_pod_count=`kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | awk '{print $1}' | grep "portworx" | wc -l`
        stork_pod_count=`kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | awk '{print $1}' | grep "stork" | wc -l`
        if [[ $pod_count -lt 1 && $px_pod_count -lt 1 && $stork_pod_count -lt 1 ]]; then
            stackcheck=1
            break
        fi
        showMessage "PX-Central cluster cleanup is in progress..."
        timecheck=$[$timecheck+$SLEEPINTERVAL]
        if [ $timecheck -gt $TIMEOUT ]; then
            echo "Failed to cleanup PX-Central cluster, TIMEOUT: $TIMEOUT"
            exit 1
        fi
        sleep $SLEEPINTERVAL
        kubectl --kubeconfig=$KC delete pod  --grace-period=0 --force $(kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE  2>&1 | grep -i "px" | awk '{print $1}') --namespace $PXCNAMESPACE &>/dev/null
        kubectl --kubeconfig=$KC delete pod  --grace-period=0 --force $(kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE  2>&1 | grep -i "portworx" | awk '{print $1}') --namespace $PXCNAMESPACE &>/dev/null
        kubectl --kubeconfig=$KC delete pod  --grace-period=0 --force $(kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE  2>&1 | grep -i "stork" | awk '{print $1}') --namespace $PXCNAMESPACE &>/dev/null
    done

kubectl --kubeconfig=$KC delete ingress $ingressName --namespace $PXCNAMESPACE &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete crd $PXCENTRALCRDNAME --namespace $PXCNAMESPACE &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC patch pvc -p '{"metadata":{"finalizers": []}}' --type=merge --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC get pvc --namespace $PXCNAMESPACE 2>&1 | awk '{print $1}' | grep -v NAME) &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete pvc --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get pvc --namespace $PXCNAMESPACE 2>&1 | grep pxc | awk '{print $1}') &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete svc --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get svc --namespace $PXCNAMESPACE 2>&1 | grep px | awk '{print $1}') &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete cm --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get cm --namespace $PXCNAMESPACE 2>&1 | grep pxc | awk '{print $1}') &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete clusterrole --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get clusterrole --namespace $PXCNAMESPACE 2>&1 | grep px | awk '{print $1}') &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete clusterrolebinding --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get clusterrolebinding --namespace $PXCNAMESPACE 2>&1 | grep px | awk '{print $1}') &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete secrets --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get secrets --namespace $PXCNAMESPACE 2>&1 | grep px | awk '{print $1}') &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete ns $PX_BACKUP_NAMESPACE &>/dev/null
sleep $SLEEPINTERVAL
echo ""
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete sc $(kubectl --kubeconfig=$KC get sc --namespace $PXCNAMESPACE 2>&1 | grep pxc  | awk '{print $1}') &>/dev/null
echo "PX-Central cluster successfully wiped."
echo ""
central_cleanup_time=$((($(date +%s)-$start_time)/60))
echo "PX-Central-Onprem cluster cleanup time taken: $central_cleanup_time minutes."
echo ""