## Validation

Lets run some tests to perform cluster validation.

Create a `busybox` deployment:

```
kubectl run busybox --image=busybox:1.28 --command -- sleep 3600
```

List the pod created by the `busybox` deployment:

```
kubectl get pods -l run=busybox
```

> output

```
NAME                      READY   STATUS    RESTARTS   AGE
busybox                   1/1     Running   0          10s
```
Retrieve the full name of the `busybox` pod:

```
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
```

Execute a DNS lookup for the `kubernetes` service inside the `busybox` pod:

```
kubectl exec -ti $POD_NAME -- nslookup kubernetes
```

> output

```
Server:    169.254.25.10
Address 1: 169.254.25.10

Name:      kubernetes
Address 1: 10.233.0.1 kubernetes.default.svc.cluster.local
```
Create a deployment for the [nginx](https://nginx.com) web server:

```shell
kubectl create deployment nginx --image=nginx
```

List the pod created by the `nginx` deployment:

```shell
kubectl get pods
```

> output

```shell
NAME                    READY   STATUS    RESTARTS   AGE
busybox                 1/1     Running   0          4m37s
nginx-f89759699-qc2qr   1/1     Running   0          9s
```
### Port Forwarding

In this section you will verify the ability to access applications remotely using [port forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/).

Retrieve the full name of the `nginx` pod:

```shell
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")
```

Forward port `8080` on your local machine to port `80` of the `nginx` pod:

```shell
kubectl port-forward $POD_NAME 8082:80
```

> output

```shell
Forwarding from 127.0.0.1:8082 -> 80
Forwarding from [::1]:8082 -> 80
```

In a new terminal make an HTTP request using the forwarding address:

```shell
curl --head http://127.0.0.1:8082
```

> output

```shell
HTTP/1.1 200 OK
Server: nginx/1.19.2
Date: Thu, 17 Sep 2020 15:22:15 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 11 Aug 2020 14:50:35 GMT
Connection: keep-alive
ETag: "5f32b03b-264"
Accept-Ranges: bytes
```

Switch back to the previous terminal and stop the port forwarding to the `nginx` pod:

```shell
Forwarding from 127.0.0.1:8082 -> 80
Forwarding from [::1]:8082 -> 80
Handling connection for 8082
```

### Logs

In this section you will verify the ability to [retrieve container logs](https://kubernetes.io/docs/concepts/cluster-administration/logging/).

Print the `nginx` pod logs:

```shell
kubectl logs $POD_NAME
```

> output

```shell
127.0.0.1 - - [17/Sep/2020:15:22:15 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.29.0" "-"
```

### Exec

In this section you will verify the ability to [execute commands in a container](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/#running-individual-commands-in-a-container).

Print the nginx version by executing the `nginx -v` command in the `nginx` container:

```shell
kubectl exec -ti $POD_NAME -- nginx -v
```

> output

```shell
nginx version: nginx/1.19.3
```

## Services

In this section you will verify the ability to expose applications using a [Service](https://kubernetes.io/docs/concepts/services-networking/service/).

Expose the `nginx` deployment using a [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport) service:

```shell
kubectl expose deployment nginx --port 80 --type NodePort
```

Retrieve the node port assigned to the `nginx` service and the host where the pod is running.

```shell
NODE_PORT=$(kubectl get svc nginx \
  --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
```
```shell
kubectl get pods -l app=nginx --output=jsonpath='{.items[*].spec.nodeName}'
```

Assign the public IP of worker node assigned to nginx pod.

```shell
EXTERNAL_IP="${IPS[2]}"
```

Make an HTTP request using the external IP address and the `nginx` node port:

```shell
curl -I http://$EXTERNAL_IP:$NODE_PORT
```

> output

```shell
HTTP/1.1 200 OK
Server: nginx/1.19.3
Date: Thu, 17 Sep 2020 15:35:00 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 11 Aug 2020 14:50:35 GMT
Connection: keep-alive
ETag: "5f32b03b-264"
Accept-Ranges: bytes
```

Next: [Clean up](06-Cleanup.md)
