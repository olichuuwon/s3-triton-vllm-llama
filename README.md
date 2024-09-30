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
