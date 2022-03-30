#!/bin/bash

function checkenv
{
if [[ $(kubectl get po --selector="app=testing-green") ]]
then
    return 0
elif [[ $(kubectl get po --selector="app=testing-blue") ]]
then
    return 1
else
    return 2
fi
}

function checkdeployment
{

  if [[ $(kubectl get deployment -l 'app in (testing-green, testing-blue)') ]]; then
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
    kubectl scale deployment/testing-green --replicas=0
    if [[ $(kubectl get deployment -l 'app=testing-blue') ]]; then
      echo deploymnet blue is present
      kubectl scale deployment/testing-blue --replicas=1
    else
      echo deployment blu is not present
      kubectl create deployment testing-blue --image=shivai/prediction:latest
    fi
cat >> loadbalancer.yaml <<-EOF
apiVersion: v1
kind: Service
metadata:
  name: service-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: testing-blue
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF
    kubectl apply -f loadbalancer.yaml
  elif [[ $? -eq 1 ]]; then
    echo pod blue is present
    kubectl scale deployment/testing-blue --replicas=0
    if [[ $(kubectl get deployment -l 'app=testing-green') ]]; then
      echo deployment green is present
      kubectl scale deployment/testing-green --replicas=1
    else
      echo po green is not present
      kubectl create deployment testing-green --image=shivai/prediction:latest
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
    app: testing-green
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF
  kubectl apply -f loadbalancer.yaml
else
  echo there is no deployment
  kubectl create deploy testing-blue --image=shivai/prediction:latest
cat >> loadbalancer.yaml <<-EOF
apiVersion: v1
kind: Service
metadata:
  name: service-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: testing-blue
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF
  kubectl apply -f loadbalancer.yaml
fi
kubectl get svc service-loadbalancer -o json | jq .status.loadBalancer.ingress[0].hostname