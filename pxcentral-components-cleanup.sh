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

cassandraStsName="pxc-cortex-cassandra"
postgresqlStsName="pxc-keycloak-postgresql"
keycloakStsName="pxc-keycloak"
etcdStsName="pxc-backup-etcd"

LOGFILE="/tmp/pxcentral-onprem-cleanup.log"
logInfo() {
    echo "$(date): level=info msg=$@" >> "$LOGFILE"
}
logError() {
    echo "$(date): level=error msg=$@" >> "$LOGFILE"
}
logWarning() {
    echo "$(date): level=warning msg=$@" >> "$LOGFILE"
}

start_time=`date +%s`
logInfo "+================================================+"
logInfo "===========PX-Central-Onprem Cleanup Started============"
echo ""
echo "Cleanup script logs will be available here: $LOGFILE"
if [ -z ${PXCNAMESPACE} ]; then
  PXCNAMESPACE=$PXCNAMESPACE_DEFAULT
fi
logInfo "PX-Central-Onprem namespace: $PXCNAMESPACE"
if [ -z ${KC} ]; then
  KC=$KUBECONFIG
fi

if [ -z ${KC} ]; then
    KC="$HOME/.kube/config"
fi

echo ""
echo "This process may take several minutes. Please wait for it to complete..."
logInfo "This process may take several minutes. Please wait for it to complete..."
crdstatus=`kubectl --kubeconfig=$KC get crd $PXCENTRALCRDNAME 2>&1 | grep -v NAME | grep -v "error" | awk '{print $1}' | wc -l 2>&1`
if [ $crdstatus -eq 0 ]; then
    echo "PX-Central is not running on this k8s cluster."
    logWarning "PX-Central is not running on this k8s cluster."
    exit 1
fi

pxcentralnamespacestatus=`kubectl --kubeconfig=$KC get ns $PXCNAMESPACE 2>&1 | grep -v NAME | grep -v "error" | awk '{print $1}' | wc -l 2>&1`
if [ $pxcentralnamespacestatus -eq 0 ]; then
    echo "Input cluster does not have $PXCNAMESPACE namespace."
    logWarning "Input cluster does not have $PXCNAMESPACE namespace."
    exit 1
fi

kubectl --kubeconfig=$KC scale deployment $ONPREMDEPLOYMENT --replicas=0 --namespace $PXCNAMESPACE &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC scale sts $etcdStsName --replicas=0 --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC scale sts $postgresqlStsName --replicas=0 --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC scale sts $cassandraStsName --replicas=0 --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC scale sts $keycloakStsName --replicas=0 --namespace $PXCNAMESPACE &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete sts $etcdStsName --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC delete sts $postgresqlStsName --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC delete sts $cassandraStsName --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC delete sts $keycloakStsName --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC delete deployment $(kubectl --kubeconfig=$KC get deployment --namespace $PXCNAMESPACE 2>&1 | grep -iv portworx | grep -iv stork | grep -iv operator | awk '{print $1}') --namespace $PXCNAMESPACE &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete job ingress-nginx-admission-create --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC delete job ingress-nginx-admission-patch --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC delete job pxc-post-setup --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC delete job pxc-pre-setup --namespace $PXCNAMESPACE &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete ingress $(kubectl --kubeconfig=$KC get ingress --namespace $PXCNAMESPACE 2>&1 | grep pxc | awk '{print $1}' | grep -v NAME 2>&1) --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC patch pvc -p '{"metadata":{"finalizers": []}}' --type=merge --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC get pvc --namespace $PXCNAMESPACE 2>&1 | grep pxc | awk '{print $1}' | grep -v NAME) &>/dev/null
kubectl --kubeconfig=$KC delete pvc --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get pvc --namespace $PXCNAMESPACE 2>&1 | grep pxc | awk '{print $1}') &>/dev/null
kubectl --kubeconfig=$KC delete svc --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get svc --namespace $PXCNAMESPACE 2>&1 | grep -iv portworx | grep -v stork | awk '{print $1}') &>/dev/null
kubectl --kubeconfig=$KC delete cm --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get cm --namespace $PXCNAMESPACE 2>&1 | grep -iv stork | awk '{print $1}') &>/dev/null
kubectl --kubeconfig=$KC delete sc $(kubectl --kubeconfig=$KC get sc --namespace $PXCNAMESPACE 2>&1 | grep pxc | awk '{print $1}') &>/dev/null
kubectl --kubeconfig=$KC delete secrets --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get secrets --namespace $PXCNAMESPACE 2>&1 | grep -iv portworx | grep -iv stork | awk '{print $1}') &>/dev/null
kubectl --kubeconfig=$KC delete serviceaccount --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get serviceaccount --namespace $PXCNAMESPACE 2>&1 | grep -iv portworx | grep -iv stork | awk '{print $1}') &>/dev/null
kubectl --kubeconfig=$KC delete deployment $ONPREMDEPLOYMENT --namespace $PXCNAMESPACE &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC get ns | grep "$PXCNAMESPACE" >> "$LOGFILE"
kubectl --kubeconfig=$KC get ns | grep "$PX_BACKUP_NAMESPACE" >> "$LOGFILE"
logInfo "After cleanup pods list:"
kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE >> "$LOGFILE"
logInfo "After cleanup services list:"
kubectl --kubeconfig=$KC get svc --namespace $PXCNAMESPACE >> "$LOGFILE"
logInfo "After cleanup pvc's list:"
kubectl --kubeconfig=$KC get pvc --namespace $PXCNAMESPACE >> "$LOGFILE"
echo "PX-Central cluster successfully wiped."
logInfo "PX-Central cluster successfully wiped."
echo ""
central_cleanup_time=$((($(date +%s)-$start_time)/60))
echo "PX-Central-Onprem cluster cleanup time taken: $central_cleanup_time minutes."
logInfo "PX-Central-Onprem cluster cleanup time taken: $central_cleanup_time minutes."
logInfo "===========PX-Central-Onprem Cleanup Done============"
logInfo "+================================================+"
echo ""