### Useful Helm Commands:

`helm install --debug --dry-run prereqs-config .`

`helm install prereqs-config .`

`helm upgrade -i prereqs-config .`

`helm rollback prereqs-config 0`

`helm get manifest prereqs-config`

`helm uninstall prereqs-config`

`helm dependency update`

### Using the dashboard with 'kubectl proxy':

When running 'kubectl proxy', the address localhost:8001/ui automatically expands to:

http://localhost:8001/api/v1/namespaces/my-namespace/services/https:kubernetes-dashboard:https/proxy/
For this to reach the dashboard, the name of the service must be 'kubernetes-dashboard', not any other value as set by Helm. You can manually specify this using the value 'fullnameOverride':

- `fullnameOverride: 'kubernetes-dashboard'`