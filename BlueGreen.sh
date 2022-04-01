#!/bin/bash

function checkenv
{
if [[ $(kubectl get po --selector="app=prediction-green") ]]
then
    return 0
elif [[ $(kubectl get po --selector="app=prediction-blue") ]]
then
    return 1
else
    return 2
fi
}

function checkdeployment
{

  if [[ $(kubectl get deployment -l 'app in (prediction-green, prediction-blue)') ]]; then
    echo deployment is here
    return 0
  else
    echo no deployment
    return 1
  fi
}

checkdeployment
if [[ $? -eq 0 ]]; then
  checkenv
  if [[ $? -eq 0 ]]; then
    echo green pod is present
    kubectl scale deployment/prediction-green --replicas=0
    if [[ $(kubectl get deployment -l 'app=prediction-blue') ]]; then
      echo deploymnet blue is present
      kubectl scale deployment/prediction-blue --replicas=1
    else
      echo deployment blu is not present
      kubectl create deployment prediction-blue --image=shivai/prediction:latest-$1
    fi
cat >> loadbalancer.yaml <<-EOF
apiVersion: v1
kind: Service
metadata:
  name: service-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: prediction-blue
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF
    kubectl apply -f loadbalancer.yaml
  elif [[ $? -eq 1 ]]; then
    echo pod blue is present
    kubectl scale deployment/prediction-blue --replicas=0
    if [[ $(kubectl get deployment -l 'app=prediction-green') ]]; then
      echo deployment green is present
      kubectl scale deployment/prediction-green --replicas=1
    else
      echo po green is not present
      kubectl create deployment prediction-green --image=shivai/prediction:latest-$1
    fi
  fi
cat >> loadbalancer.yaml <<-EOF
apiVersion: v1
kind: Service
metadata:
  name: service-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: prediction-green
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF
  kubectl apply -f loadbalancer.yaml
else
  echo there is no deployment
  kubectl create deployment prediction-blue --image=shivai/prediction:latest-$1
cat >> loadbalancer.yaml <<-EOF
apiVersion: v1
kind: Service
metadata:
  name: service-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: prediction-blue
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF
  kubectl apply -f loadbalancer.yaml
fi