# Triton Inference Server + vLLM Backend

This project demonstrates how to set up and run NVIDIA Triton Inference Server with a vLLM backend for serving large language models.

## Quick Start

### 1. Pull the Docker Image

```bash
docker pull nvcr.io/nvidia/tritonserver:<xx.yy>-vllm-python-py3
```

### 2. Run the Docker Container

```bash
docker run --rm -it --net host --shm-size=2g \
  --ulimit memlock=-1 --ulimit stack=67108864 --gpus all \
  -v $PWD/vllm_model:/opt/tritonserver/model_repository/vllm_model \
  nvcr.io/nvidia/tritonserver:<xx.yy>-vllm-python-py3
```

### Server Logs

```bash
I1002 21:58:57.891440 62 grpc_server.cc:3914] Started GRPCInferenceService at 0.0.0.0:8001
I1002 21:58:57.893177 62 http_server.cc:2717] Started HTTPService at 0.0.0.0:8000
I1002 21:58:57.935518 62 http_server.cc:2736] Started Metrics Service at 0.0.0.0:8002
```

---

## About

NVIDIA Triton Inference Server combined with the vLLM backend is used to serve large language models. Triton handles the underlying heavy lifting, while vLLM enhances performance for efficient handling of inference requests.

---

## Phase 1: Local Inference Example

### 1. Send an Inference Request

```bash
curl -X POST http://example-triton-jes.apps.nebula.sl/v2/models/vllm_model/generate \
  -d '{
        "text_input": "How would you describe the taste of rainbow to someone who has never seen one?",
        "parameters": {
          "stream": false,
          "max_tokens": 256
        }
      }'
```

### 2. Example Response

```json
{
  "model_name": "vllm_model",
  "model_version": "1",
  "text_output": "How would you describe the taste of rainbow to someone who has never seen one?\nNice, I've not had one. I'd suggest it to people who don't know a massive amount about it. I sent them an ad that read \"G makes way more rainbow beers than jags\" and I'm surprised they throw that out. Moist flavoured beers usually have BS flavor as the name implies."
}
```

---

- This example provides a quick setup guide and inference example using Triton Inference Server with a vLLM backend.
- Make sure to adjust the placeholders (`<xx.yy>`) in the commands to the correct version numbers, version used in testing was 23.11.

---

- Amazon SageMaker is a cloud-based machine-learning platform that allows the creation, training, and deployment by developers of machine-learning models on the cloud.
- It can be used to deploy ML models on embedded systems and edge-devices.

---

## Phase 2: Local Mount JuiceFS

---

https://juicefs.com/docs/community/getting-started/for_distributed
https://juicefs.com/en/blog/usage-tips/juicefs-24-qas-for-beginners

### MinIO
MinIO is an open source lightweight object storage, compatible with Amazon S3 API.

It is easy to run a MinIO instance locally using Docker. For example, the following command sets and maps port 9900 for the console with --console-address ":9900" and also maps the data path for the MinIO to the minio-data folder in the current directory, which can be modified if needed.

sudo docker run -d --name minio \
    -p 9000:9000 \
    -p 9900:9900 \
    -e "MINIO_ROOT_USER=minioadmin" \
    -e "MINIO_ROOT_PASSWORD=minioadmin" \
    -v $PWD/minio-data:/data \
    --restart unless-stopped \
    minio/minio server /data --console-address ":9900"

After container is up and running, you can access:

MinIO API: http://127.0.0.1:9000, this is the object storage service address used by JuiceFS
MinIO UI: http://127.0.0.1:9900, this is used to manage the object storage itself, not related to JuiceFS
The initial Access Key and Secret Key of the object storage are both minioadmin.

When using MinIO as data storage for JuiceFS, set the option --storage to minio.

juicefs format \
    --storage minio \
    --bucket http://127.0.0.1:9000/<bucket> \
    --access-key minioadmin \
    --secret-key minioadmin \
    ... \
    myjfs

note
Currently, JuiceFS only supports path-style MinIO URI addresses, e.g., http://127.0.0.1:9000/myjfs.
The MINIO_REGION environment variable can be used to set the region of MinIO, if not set, the default is us-east-1.
When using Multi-Node MinIO deployment, consider setting using a DNS address in the service endpoint, resolving to all MinIO Node IPs, as a simple load-balancer, e.g. http://minio.example.com:9000/myjfs

Deploy JuiceFS Gateway in Kubernetes
Install via kubectl
Create a secret (take Amazon S3 as an example):

export NAMESPACE=default

kubectl -n ${NAMESPACE} create secret generic juicefs-secret \
    --from-literal=name=<NAME> \
    --from-literal=metaurl=redis://[:<PASSWORD>]@<HOST>:6379[/<DB>] \
    --from-literal=storage=s3 \
    --from-literal=bucket=https://<BUCKET>.s3.<REGION>.amazonaws.com \
    --from-literal=access-key=<ACCESS_KEY> \
    --from-literal=secret-key=<SECRET_KEY>

Here we have:

name: name of the JuiceFS file system.
metaurl: URL of the metadata engine (e.g. Redis). Read this document for more information.
storage: Object storage type, such as s3, gs, oss. Read this document to find all supported object storages.
bucket: Bucket URL. Read this document to learn how to set up different object storage.
access-key: Access key of object storage. Read this document for more information.
secret-key: Secret key of object storage. Read this document for more information.
Then download the S3 gateway deployment YAML and create the Deployment and Service resources with kubectl. The following points require special attention:

Please replace ${NAMESPACE} in the following command with the Kubernetes namespace of the actual S3 gateway deployment, which defaults to kube-system.
The replicas for Deployment defaults to 1. Please adjust as needed.
The latest version of juicedata/juicefs-csi-driver image is used by default, which has already integrated the latest version of JuiceFS client. Please check here for the specific integrated JuiceFS client version.
The initContainers of Deployment will first try to format the JuiceFS file system, if you have already formatted it in advance, this step will not affect the existing JuiceFS file system.
The default port number that the S3 gateway listens on is 9000
The startup options of S3 gateway will use default values if not specified.
The value of MINIO_ROOT_USER environment variable is access-key in Secret, and the value of MINIO_ROOT_PASSWORD environment variable is secret-key in Secret.
curl -sSL https://raw.githubusercontent.com/juicedata/juicefs/main/deploy/juicefs-s3-gateway.yaml | sed "s@kube-system@${NAMESPACE}@g" | kubectl apply -f -


Check if it's deployed successfully:

$ kubectl -n $NAMESPACE get po -o wide -l app.kubernetes.io/name=juicefs-s3-gateway
juicefs-s3-gateway-5c7d65c77f-gj69l         1/1     Running   0          37m     10.244.2.238   kube-node-3   <none>           <none>


$ kubectl -n $NAMESPACE get svc -l app.kubernetes.io/name=juicefs-s3-gateway
NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
juicefs-s3-gateway   ClusterIP   10.101.108.42   <none>        9000/TCP   142m

You can use juicefs-s3-gateway.${NAMESPACE}.svc.cluster.local:9000 or pod IP and port number of juicefs-s3-gateway (e.g. 10.244.2.238:9000) in the application pod to access JuiceFS S3 Gateway.

2024/09/30 10:17:17.219263 juicefs[699] <INFO>: Volume is formatted as {
  "Name": "my-juicefs-again",
  "UUID": "23f861b6-9cd8-4338-b28f-6e596b3c2eb7",
  "Storage": "minio",
  "Bucket": "http://s3.apps.nebula.sl/jes-vllm",
  "AccessKey": "SDukzf3okSYKiQTd",
  "SecretKey": "removed",
  "BlockSize": 4096,
  "Compression": "none",
  "EncryptAlgo": "aes256gcm-rsa",
  "KeyEncrypted": true,
  "TrashDays": 1,
  "MetaVersion": 1,
  "MinClientVersion": "1.1.0-A",
  "DirStats": true,
  "EnableACL": false
} [format.go:521]
root@2451e4f3614d:/#
root@2451e4f3614d:/# juicefs mount -d redis://localhost:6379 /tmp/mebucket
2024/09/30 10:17:50.231717 juicefs[714] <INFO>: Meta address: redis://localhost:6379 [interface.go:504]
2024/09/30 10:17:50.233281 juicefs[714] <WARNING>: AOF is not enabled, you may lose data if Redis is not shutdown properly. [info.go:84]
2024/09/30 10:17:50.233394 juicefs[714] <INFO>: Ping redis latency: 71.401µs [redis.go:3515]
2024/09/30 10:17:50.234909 juicefs[714] <INFO>: Data use minio://s3.apps.nebula.sl/jes-vllm/my-juicefs-again/ [mount.go:629]
.2024/09/30 10:17:51.236899 juicefs[714] <INFO>: OK, my-juicefs-again is ready at /tmp/mebucket [mount_unix.go:200]
root@2451e4f3614d:/#

Privileged mode required, not optimal for security.