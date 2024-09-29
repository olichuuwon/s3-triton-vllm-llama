# Use the base Triton server image
FROM nvcr.io/nvidia/tritonserver:23.11-vllm-python-py3

# Set the working directory inside the container
WORKDIR /work

# Copy the local model repository into the image
COPY ./model_repository /work/model_repository

# Create a .cache directory in the root and set appropriate permissions
RUN mkdir -p /.cache && chmod -R 777 /.cache

# Expose the required port
EXPOSE 8000

# Command to start the Triton server with the model repository
CMD ["tritonserver", "--model-repository", "/work/model_repository"]
