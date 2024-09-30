# Triton Inference Server + vLLM Backend

- docker pull nvcr.io/nvidia/tritonserver:<xx.yy>-vllm-python-py3

- docker run --rm -it --net host --shm-size=2g \
    --ulimit memlock=-1 --ulimit stack=67108864 --gpus all \
    -v $PWD/vllm_model:/opt/tritonserver/model_repository/vllm_model \
    nvcr.io/nvidia/tritonserver:<xx.yy>-vllm-python-py3

'''
I1002 21:58:57.891440 62 grpc_server.cc:3914] Started GRPCInferenceService at 0.0.0.0:8001
I1002 21:58:57.893177 62 http_server.cc:2717] Started HTTPService at 0.0.0.0:8000
I1002 21:58:57.935518 62 http_server.cc:2736] Started Metrics Service at 0.0.0.0:8002
'''

## NVIDIA Triton Inference Server and the vLLM backend to serve large language models.
- Triton takes care of the heavy lifting while vLLM boosts performance, giving you a straightforward way to handle inference requests efficiently.

## Phase 1
'''
  curl -X POST http://example-triton-jes.apps.nebula.sl/v2/models/vllm_model/generate -d   '{
      "text_input": "How would you describe the taste of rainbow to someone who has never seen one?",
      "parameters":
            {
              "stream": false,
              "max_tokens": 256
            }
  }'
'''

'''
{"model_name":"vllm_model","model_version":"1","text_output":"How would you describe the taste of rainbow to someone who has never seen one?\nnice, i've not had one. i'd suggest it to people who dont know a massive amount about it. i sent them an ad that read \"G makes way more rainbow beers than jags\" and i'm surprised they throw that out. Moist flavoured beers usually have bs flavor as the name implies."}
'''
