# Triton Inference Server + vLLM Backend

docker pull nvcr.io/nvidia/tritonserver:<xx.yy>-vllm-python-py3

docker run --rm -it --net host --shm-size=2g \
    --ulimit memlock=-1 --ulimit stack=67108864 --gpus all \
    -v $PWD/vllm_model:/opt/tritonserver/model_repository/vllm_model \
    nvcr.io/nvidia/tritonserver:<xx.yy>-vllm-python-py3

huggingface-cli login --token <your token>

tritonserver --model-repository model_repository

+------------+---------+--------+
| Model      | Version | Status |
+------------+---------+--------+
| vllm_model | model_v1| READY  |
| ..         | .       | ..     |
| ..         | .       | ..     |
+------------+---------+--------+
...
...
...
I1002 21:58:57.891440 62 grpc_server.cc:3914] Started GRPCInferenceService at 0.0.0.0:8001
I1002 21:58:57.893177 62 http_server.cc:2717] Started HTTPService at 0.0.0.0:8000
I1002 21:58:57.935518 62 http_server.cc:2736] Started Metrics Service at 0.0.0.0:8002

curl -X POST localhost:8000/v2/models/vllm_model/generate -d \
  '{
      "text_input": "How would you describe the taste of rainbow to someone who has never seen one?",
      "parameters": 
            {
              "stream": false,
              "max_tokens": 256
            }
  }'

  {
   "model_name":"vllm_model",
   "model_version":"model_v1",
   "text_output":"What a fascinating and imaginative question!\nI think I would describe the taste of rainbow as a symphony of flavors that evoke the senses and emotions associated with the colors of the rainbow. For instance, the taste of red would be like a crimson cherry explosion on the palate, with a bold, juicy flavor that's both sweet and tangy. Orange would be like a blend of citrus freshensers and floral notes , leaving the mouth feeling revitalized and refreshed. Yellow would be like a burst of sunshine, with a bright and upwardly sunny citrus flavor that lifts the mood and transports you to a happy place.\n\nGreen would be like a gentle leafy tea, with the subtlest hint of mint and a soothing, calming effect. Blue would be like a refreshing ocean breeze, with a smooth and calming flavor th at washes over the palate, like the sound of waves gently lapping against the shore. Indigo would be like a rich, velvety dark chocolate with subtle hints of berry and a deep, alleyway mystery. And violet would be like the crush of a ripened, succulent raspberry..."
}

NVIDIA Triton Inference Server and the vLLM backend to serve large language models.
- Triton takes care of the heavy lifting while vLLM boosts performance, giving you a straightforward way to handle inference requests efficiently.

nvcr.io/nvidia/tritonserver:24.09-py3