# What is TGPT
Tgpt is a cross-platform command-line interface (CLI) tool that allows you to use an AI chatbot in your Terminal without needing API keys.

# TGPT GUI

A terminal-based graphical interface for [tgpt](https://github.com/aandrew-me/tgpt), which allows access to artificial intelligence models directly from the command line.

## Prerequisites

- Have `tgpt` installed
- Have `dialog` installed (for example, with `sudo apt install dialog`)

## TGPT Installation

### On GNU/Linux or MacOS
```bash
curl -sSL https://raw.githubusercontent.com/aandrew-me/tgpt/main/install | bash -s /usr/local/bin
```

### On Arch Linux
```bash
pacman -S tgpt
```
For more installation methods, visit the [official tgpt repository](https://github.com/aandrew-me/tgpt).

## TGPT GUI Installation

1. Download the `tgpt-gui-en.sh` script
2. Give it execution permissions: `chmod +x tgpt-gui-en.sh`
3. Run it: `./tgpt-gui-en.sh`

## User Manual

### Main Menu

When starting TGPT GUI, you'll find a menu with the following options:

1. **Query AI**: To ask direct questions to the artificial intelligence.
2. **Generate Image**: To create images from textual descriptions.
3. **Code Mode**: Specialized in generating code according to your needs.
4. **Interactive Mode**: To maintain a continuous conversation with the AI.
5. **Multiline Mode**: Allows writing queries in multiple lines of text.
6. **Configure**: To adjust providers, models, and parameters.
7. **Update tgpt**: To get the latest version of tgpt.
8. **Help**: Shows information about using the application.

### Query AI

This option allows you to ask direct questions to the AI. After writing your query, you can choose between three display modes:

- **Normal**: Shows the response with typing animation.
- **Quiet**: Shows the response without animation.
- **Whole**: Shows the complete response at once.

### Generate Image

Allows creating images from textual descriptions. You can choose between various providers:

- **Pollinations**: Does not require API key.
- **OpenAI DALL-E**: Requires OpenAI API key.
- **DeepSeek**: Requires DeepSeek API key.
- **Google Gemini**: Requires Google API key.

### Code Mode

Specialized in code generation. You just need to describe what code you need and the AI will generate it, using a format optimized for code.

### Interactive Mode

Starts an interactive session with the AI where you can maintain a continuous conversation, similar to a chat. The AI will remember the context of previous questions.

### Multiline Mode

Similar to interactive mode, but allows writing queries in multiple lines, ideal for longer texts or with special formatting.

## Configuration

The configuration menu allows you to customize various aspects:

### Change Provider

You can select from various AI providers:

- **phind**: Specialized in programming (does not require API key).
- **deepseek**: Advanced models (requires API key).
- **gemini**: Google Gemini (requires API key).
- **groq**: High speed (requires API key).
- **isou**: Isou (requires API key).
- **koboldai**: KoboldAI (requires API key).
- **ollama**: For local use.
- **openai**: OpenAI (requires API key).
- **pollinations**: For images (does not require API key).

### Configure API Key

Here you can enter the API key necessary for the selected provider. This configuration is saved for future sessions.

### Change Model

Each provider offers different AI models. This option allows you to select the most suitable one for your needs. For example:

- **OpenAI**: GPT-4o, GPT-4-Turbo, GPT-3.5-Turbo, etc.
- **Gemini**: Gemini 1.5 Pro, Gemini 1.5 Flash, etc.
- **Phind**: Phind-Model, Phind-Model-LLama3, etc.

### Other Configurations

- **URL**: To configure custom API endpoints (mainly for OpenAI).
- **Temperature**: Controls the creativity of responses (0-1).
- **Top P**: Defines the diversity of responses (0-1).
- **Maximum Length**: Limits the size of responses.
- **Pre-prompt**: Establishes an initial context for all queries.

### Save Configuration

This option saves all settings in `~/.config/tgpt-gui/config` so they persist between sessions.

## Tips and Tricks

1. **Initial Setup**: For optimal use, first configure the provider and model you want to use.
2. **Pre-prompt**: Use this function to establish a style or context for all your queries.
3. **Code Mode**: Ideal for programmers, returns better formatted responses for code.
4. **API Keys**: Consider initially using providers that don't require API keys (phind, pollinations, ollama) if you don't have keys available.

## Troubleshooting

- **"tgpt is not installed" error**: Run `pip install tgpt` to install it.
- **"dialog is not installed" error**: Install it with your package manager (e.g., `sudo apt install dialog`).
- **Invalid API Key**: Verify that you have correctly entered the API key in the configuration.
- **No response from provider**: Some providers may be temporarily unavailable. Try another provider.

## Final Note

TGPT GUI is an interface that simplifies the use of tgpt, but all queries and generations depend on the underlying AI services. Usage limits, response quality, and other features depend on the selected provider.

For more information about tgpt, visit the [official repository](https://github.com/aandrew-me/tgpt).

---

Enjoy using TGPT GUI to access the power of artificial intelligence directly from your terminal!
