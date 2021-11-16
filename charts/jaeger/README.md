# Jaeger Operator for Kubernetes

The Jaeger Operator is an implementation of a [Kubernetes Operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/).

## Getting started

Firstly, ensure an [ingress-controller is deployed](https://kubernetes.github.io/ingress-nginx/deploy/). When using `minikube`, you can use the `ingress` add-on: `minikube start --addons=ingress`

A new namespace for the operator is also required:
```
kubectl create namespace observability
```

Once namespace `observability` is ready, create a Jaeger instance in the namespace, like:

```
helm install -n observability jaeger ../../charts/jaeger 
```

This first deploys an ElasticSearch service and then a production jaeger instace to which we can connect our sidecars to. It also exposes Jaeger Client UI on port 16686 of the pod.

## Agent Configuration
To attach a side car manually, update the helm charts deployment template with an additional container as follows:

```
- name: jaeger-agent
  image: jaegertracing/jaeger-agent:1.21
  imagePullPolicy: IfNotPresent
  ports:
    - containerPort: 5775
      name: zk-compact-trft
      protocol: UDP
    - containerPort: 5778
      name: config-rest
      protocol: TCP
    - containerPort: 6831
      name: jg-compact-trft
      protocol: UDP
    - containerPort: 6832
      name: jg-binary-trft
      protocol: UDP
    - containerPort: 14271
      name: admin-http
      protocol: TCP
  args:
    - --reporter.grpc.host-port=dns:///jaeger-collector.observability:14250
    - --reporter.type=grpc
  env: 
    - name: JAEGER_SAMPLER_TYPE
      value: const
    - name: JAEGER_SAMPLER_PARAM
      value: "1"
```

Where `--reporter.grpc.host-port` points to the Jaeger instances collector service.

## Connecting to UI
Connect to Jaegar UI by port-forwarding to the query service as follows:

```
export POD_NAME=$(kubectl get pods --namespace observability -l "app.kubernetes.io/instance=jaeger,app.kubernetes.io/component=query" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward --namespace observability $POD_NAME 8080:16686
```
Then access the UI via http://localhost:8080/
