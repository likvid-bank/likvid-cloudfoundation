resource "stackit_modelserving_token" "this" {
  project_id  = var.stackit_project_id
  name        = "ske-starterkit-${var.template_name}"
  description = "ske-starterkit-${var.template_name}"
}

locals {
  ai_kubernetes_secrets = {
    "stackit-ai" = {
      STACKIT_AI_BASE_URL = "https://api.openai-compat.model-serving.${stackit_modelserving_token.this.region}.onstackit.cloud/v1"
      STACKIT_AI_API_KEY  = stackit_modelserving_token.this.token

      # Model below picked from the live /v1/models endpoint after sourcing ske/setup.sh:
      # curl -sS -H "Authorization: Bearer $STACKIT_AI_API_KEY" "https://api.openai-compat.model-serving.eu01.onstackit.cloud/v1/models" | jq -r '.data[].id'
      #
      # Output:
      #
      # neuralmagic/Mistral-Nemo-Instruct-2407-FP8
      # Qwen/Qwen3-VL-Embedding-8B
      # Qwen/Qwen3-VL-235B-A22B-Instruct-FP8
      # openai/gpt-oss-20b
      # neuralmagic/Meta-Llama-3.1-8B-Instruct-FP8
      # cortecs/Llama-3.3-70B-Instruct-FP8-Dynamic
      # openai/gpt-oss-120b
      # intfloat/e5-mistral-7b-instruct
      # google/gemma-3-27b-it
      #
      STACKIT_AI_MODEL = "openai/gpt-oss-120b"
    }
  }
}
