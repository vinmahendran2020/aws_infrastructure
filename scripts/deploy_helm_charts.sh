#!/bin/bash

while read -r metaname; do
    export FRONTEND_WORKSPACE=$metaname
    export SSL_CERT_ARN=$(jq .outputs.ssl_cert_arn.value $CODEBUILD_SRC_DIR/${FRONTEND_WORKSPACE}_terraform_output.json)
    export WAF_ARN=$(jq .outputs.waf_arn.value $CODEBUILD_SRC_DIR/${FRONTEND_WORKSPACE}_terraform_output.json)
    export AWS_CLUSTER_NAME=$(jq .outputs.cluster_id.value $CODEBUILD_SRC_DIR/${FRONTEND_WORKSPACE}_terraform_output.json)
    chmod +x $CODEBUILD_SRC_DIR/scripts/deploy.sh

    printf '{"release":"%s","cluster":%s,"region":"%s","namespace":"%s","ssl_cert_arn":%s,"waf_arn":%s,"app_namespace":"%s"}' "prereqs-config" $AWS_CLUSTER_NAME $AWS_REGION "kube-system" $SSL_CERT_ARN $WAF_ARN $FRONTEND_WORKSPACE > $CODEBUILD_SRC_DIR/build.json
    $CODEBUILD_SRC_DIR/scripts/deploy.sh

    printf '{"release":"%s","cluster":%s,"region":"%s","namespace":"%s"}' "cloudwatch-config" $AWS_CLUSTER_NAME $AWS_REGION "amazon-cloudwatch" > $CODEBUILD_SRC_DIR/build.json
    $CODEBUILD_SRC_DIR/scripts/deploy.sh

    printf '{"release":"%s","cluster":%s,"region":"%s","namespace":"%s"}' "prometheus-config" $AWS_CLUSTER_NAME $AWS_REGION "monitoring" > $CODEBUILD_SRC_DIR/build.json
    $CODEBUILD_SRC_DIR/scripts/deploy.sh

    printf '{"release":"%s","cluster":%s,"region":"%s","namespace":"%s"}' "jaeger" $AWS_CLUSTER_NAME $AWS_REGION "monitoring" > $CODEBUILD_SRC_DIR/build.json
    $CODEBUILD_SRC_DIR/scripts/deploy.sh

done < <(yq r $CODEBUILD_SRC_DIR/network_frontend.yml network.organizations[*].meta.name)
