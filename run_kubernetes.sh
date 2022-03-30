#!/usr/bin/env bash
 
# This tags and uploads an image to Docker Hub
 
# Step 1:
# This is your Docker ID/path
dockerpath=shivai/prediction
 
# Step 2
# Run the Docker Hub container with kubernetes
kubectl create deploy prediction --image=shivai/prediction:latest
 
# Step 3:
# List kubernetes pods
sleep 30
kubectl get po --selector='app=prediction'
podname=$(kubectl get po --selector='app=prediction' | grep -v NAME | awk '{print $1}')
 
# Step 4:
# Forward the container port to a host
kubectl port-forward $podname --address 0.0.0.0 5000:80