# Use the base Triton server image
FROM nvcr.io/nvidia/tritonserver:24.08-vllm-python-py3

# Set the working directory inside the container
WORKDIR /work

# Copy the local model repository into the image
COPY ./model_repository /work/model_repository

# Expose the required port
EXPOSE 8001

# Command to start the Triton server with the model repository
CMD ["tritonserver", "--model-repository", "/work/model_repository"]
