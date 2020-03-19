#!/usr/bin/env bash
usage()
{
cat <<EOEG

Usage: $0 
    --admin-password <Admin user password>

Optional:
    --kubeconfig <Kubeconfig file>

Examples:
    ./reset-password.sh --admin-password Admin@123 --kubeconfig /root/.kube/config

EOEG
exit 1
}

while [ "$1" != "" ]; do
    case $1 in
    --admin-password) shift
                      ADMINPASSWORD=$1
                      ;;
    --kubeconfig)     shift
                      KC=$1
                      ;;
    -h | --help )   usage
                    ;;
    * )             usage
    esac
    shift
done

echo ""
if [ -z ${ADMINPASSWORD} ]; then
    echo "ERROR: Admin password is required."
    usage
    exit 1
fi

validate_password=`echo -n $ADMINPASSWORD | grep -E '[0-9]'| grep -E '[!@#$%]'`
if [ -z $validate_password ]; then
  echo "ERROR: Password should contain one lower case, one upper case, one number and one special character."
  echo ""
  usage
fi


if [ -z ${KC} ]; then
  KC=$KUBECONFIG
fi

if [ -z ${KC} ]; then
    KC="$HOME/.kube/config"
fi

PXCENTRALNAMESPACE="kube-system"

CHECKOIDCENABLE=`kubectl --kubeconfig=$KC get cm --namespace $PXCENTRALNAMESPACE pxc-admin-user -o jsonpath={.data.oidc} 2>&1`
if [ ${CHECKOIDCENABLE} ]; then
    if [ "$CHECKOIDCENABLE" == "true" ]; then
        echo "OIDC is enabled, Admin password can't be reset from here."
        echo ""
        exit 0
    fi
fi

backendRunning=`kubectl --kubeconfig=$KC get po --namespace $PXCENTRALNAMESPACE -lrun=pxc-central-backend 2>&1 | grep -v NAME | awk '{print $3}' | wc -l`
if [ $backendRunning -eq "1" ]; then 
    backupPodName=`kubectl --kubeconfig=$KC get po --namespace $PXCENTRALNAMESPACE -lrun=pxc-central-backend 2>&1 | grep -v NAME | awk '{print $1}'`
    if [ ${backupPodName} ]; then 
        passwordUpdateStatus=`kubectl --kubeconfig=$KC exec -it $backupPodName --namespace $PXCENTRALNAMESPACE -- bash -c "cd /var/www/centralApi && php artisan central:changeAdminPassword $ADMINPASSWORD $ADMINPASSWORD" 2>&1`
        echo "Password update status : $passwordUpdateStatus"
    fi
else
    echo "Can't reset PX-Central admin user password."
    exit 1
fi

