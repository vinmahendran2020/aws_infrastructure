#!/bin/bash

function helmUpgrade {
    echo "Release is found..so updating the release"
    # Upgrade release on k8s
    case $RELEASE in
      "prereqs-config")
        echo "prereqs-config release"
        helm upgrade $RELEASE $CODEBUILD_SRC_DIR/charts/$RELEASE --set namespace=$APP_NAMESPACE --set ingress.namespace=$APP_NAMESPACE --set aws-load-balancer-controller.clusterName=$CLUSTER --set ingress.annotations."alb\.ingress\.kubernetes\.io/certificate-arn"=$SSL_CERT_ARN --set ingress.annotations."alb\.ingress\.kubernetes\.io/wafv2-acl-arn"=$WAF_ARN -n $NAMESPACE
        ;;

      "cloudwatch-config")
        echo "cloudwatch-config release"
        helm upgrade $RELEASE $CODEBUILD_SRC_DIR/charts/$RELEASE --set clusterName=$CLUSTER -n $NAMESPACE
        ;;

      "prometheus-config")
        echo "prometheus-config release"
        helm upgrade $RELEASE $CODEBUILD_SRC_DIR/charts/$RELEASE -n $NAMESPACE
        ;;

      "jaeger")
        echo "jaeger release"
        helm upgrade $RELEASE $CODEBUILD_SRC_DIR/charts/$RELEASE -n $NAMESPACE
        ;;

      *)
        echo "No Release Specified"
        exit 1;
        ;;
    esac
}

function helmInstall {
    echo "Release is not found..so installing new release"
    # Install release on k8s
    case $RELEASE in
      "prereqs-config")
        echo "prereqs-config release"
        helm install $RELEASE $CODEBUILD_SRC_DIR/charts/$RELEASE --set namespace=$APP_NAMESPACE --set ingress.namespace=$APP_NAMESPACE --set aws-load-balancer-controller.clusterName=$CLUSTER --set ingress.annotations."alb\.ingress\.kubernetes\.io/certificate-arn"=$SSL_CERT_ARN --set ingress.annotations."alb\.ingress\.kubernetes\.io/wafv2-acl-arn"=$WAF_ARN -n $NAMESPACE
        ;;

      "cloudwatch-config")
        echo "cloudwatch-config release"
        helm install $RELEASE $CODEBUILD_SRC_DIR/charts/$RELEASE --set clusterName=$CLUSTER -n $NAMESPACE
        ;;

      "prometheus-config")
        echo "prometheus-config release"
        helm install $RELEASE $CODEBUILD_SRC_DIR/charts/$RELEASE -n $NAMESPACE
        ;;

      "jaeger")
        echo "jaeger release"
        helm install $RELEASE $CODEBUILD_SRC_DIR/charts/$RELEASE -n $NAMESPACE
        ;;

      *)
        echo "No Release Specified"
        exit 1;
        ;;
    esac
}

source $CODEBUILD_SRC_DIR/scripts/parse_variables.sh
which kubectl >& /dev/null
KUBE=$?
which helm >& /dev/null
HELM=$?

if [ ${KUBE}${HELM} == 00 ]
    then
    echo "1. Starting deployment..."

    # Parse input build json file for parameters
    parseInput
    echo cluster=$CLUSTER deployment=$RELEASE region=$REGION namespace=$NAMESPACE app_namespace=$APP_NAMESPACE

    # Update kubeconfig
    aws eks --region $REGION update-kubeconfig --name $CLUSTER

    # Check existence of the release on k8s
    DEPSTATUS=$(echo $(helm status $RELEASE -n $NAMESPACE) | awk '{print $1;}')
    if [ $DEPSTATUS == 'NAME:' ]
    then
        helmUpgrade || exit 1
    else 
        helmInstall || exit 1
    fi

    # Fail if helm errored out
    if [ $? == 1 ]; 
    then
      exit 1;
    fi
  else
    echo "========================================================="
    echo "KUBECTL & HELM not installed"
    echo "========================================================="
    exit 1
  fi