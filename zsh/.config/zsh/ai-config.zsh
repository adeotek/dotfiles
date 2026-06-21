# =============================================================================
# Headroom LLM proxy — automatic context compression
# =============================================================================
# Headroom runs on localhost:8787 and compresses LLM context before sending
# to the provider. It supports OpenAI, Anthropic, OpenRouter, OpenCode Zen,
# Google Gemini/Vertex AI, and GitHub Copilot (via wrap).
#
# To switch providers, edit ~/.config/headroom/proxy.env and restart:
#   systemctl --user restart headroom-proxy
#
# For multiple providers simultaneously, run additional proxy instances:
#   headroom proxy --port 8788 --backend openrouter
# =============================================================================
if (( ${+commands[headroom]} )); then
  # Default: proxy to OpenAI + Anthropic
  export OPENAI_BASE_URL=http://localhost:8787/v1
  export ANTHROPIC_BASE_URL=http://localhost:8787

  # Provider-specific target URLs (override in ~/.config/headroom/proxy.env)
  # export OPENAI_TARGET_API_URL=https://api.openai.com
  # export OPENAI_TARGET_API_URL=https://openrouter.ai/api/v1
  # export OPENAI_TARGET_API_URL=https://opencode.ai/zen/v1
  # export OPENAI_TARGET_API_URL=https://generativelanguage.googleapis.com/v1beta
fi
