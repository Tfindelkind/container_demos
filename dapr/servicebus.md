# Dapr using ServiceBus

KUBE_GROUP=appconfig
SB_NAMESPACE=dzdapr$RANDOM
LOCATION=westeurope

az servicebus namespace create --resource-group $KUBE_GROUP --name $SB_NAMESPACE --location $LOCATION
az servicebus namespace authorization-rule keys list --name RootManageSharedAccessKey --namespace-name $SB_NAMESPACE --resource-group $KUBE_GROUP --query "primaryConnectionString" | tr -d '"'
SB_CONNECTIONSTRING=$(az servicebus namespace authorization-rule keys list --name RootManageSharedAccessKey --namespace-name $SB_NAMESPACE --resource-group $KUBE_GROUP --query "primaryConnectionString" | tr -d '"')


kubectl delete component messagebus

cat <<EOF | kubectl apply -f -
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: dzpubsub
spec:
  type: pubsub.azure.servicebus
  version: v1
  metadata:
  - name: connectionString
    value: '$SB_CONNECTIONSTRING'
  - name: timeoutInSec
    value: 80
  - name: maxDeliveryCount
    value: 15
  - name: lockDurationInSec
    value: 5
  - name: defaultMessageTimeToLiveInSec
    value: 2
EOF

kubectl delete component messagebus
kubectl delete component pubsub-azure-service-bus
kubectl delete pod -l app=dapr-operator -n dapr-system

kubectl logs -l app=dapr-operator
kubectl logs -l demo=pubsub


curl -X POST http://localhost:3500/v1.0/publish/deathStarStatus \
	-H "Content-Type: application/json" \
	-d '{
       	     "status": "completed"
      	}'