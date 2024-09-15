#!/bin/bash

BASE_DIR=$(dirname "$(realpath "$0")")/..

cd $BASE_DIR/metallb

kubectl apply -f metallb-namespace.yml
kubectl apply -f metallb-config.yaml
kubectl apply -f metallb-controller.yml

cd $BASE_DIR/nginx/deployment

kubectl apply -f nginx-deployment.yaml

cd $BASE_DIR/nginx/ingress

kubectl apply -f ingress-controller.yml

cd $BASE_DIR/helm

kubectl apply -f rbac-config.yaml

cd $BASE_DIR/pihole

kubectl apply -f pihole.yaml
kubectl apply -f $BASE_DIR/nginx/ingress/pihole-ingress.yaml

cd $BASE_DIR/dashboard

kubectl apply -f dashboard-adminuser.yaml
kubectl apply -f recommended.yaml
kubectl apply -f $BASE_DIR/nginx/ingress/dashboard-ingress.yaml

cd $BASE_DIR/trello-groomer

kubectl apply -f trello-groomer.deploy.yml



