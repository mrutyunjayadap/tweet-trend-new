#!/bin/sh
kubectl apply -f namespace.yaml
kubectl apply -f jfrogsecret.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
