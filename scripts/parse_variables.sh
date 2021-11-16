#!/bin/bash
function parseInput {
    echo "2. parsing input build file"

    RELEASE=$(echo `jq '.release' $CODEBUILD_SRC_DIR/build.json` | sed -e 's/^"//' -e 's/"$//')
    CLUSTER=$(echo `jq '.cluster' $CODEBUILD_SRC_DIR/build.json` | sed -e 's/^"//' -e 's/"$//')
    REGION=$(echo `jq '.region' $CODEBUILD_SRC_DIR/build.json` | sed -e 's/^"//' -e 's/"$//')
    NAMESPACE=$(echo `jq '.namespace' $CODEBUILD_SRC_DIR/build.json` | sed -e 's/^"//' -e 's/"$//')
    SSL_CERT_ARN=$(echo `jq '.ssl_cert_arn' $CODEBUILD_SRC_DIR/build.json` | sed -e 's/^"//' -e 's/"$//')
    WAF_ARN=$(echo `jq '.waf_arn' $CODEBUILD_SRC_DIR/build.json` | sed -e 's/^"//' -e 's/"$//')
    APP_NAMESPACE=$(echo `jq '.app_namespace' $CODEBUILD_SRC_DIR/build.json` | sed -e 's/^"//' -e 's/"$//')
}
