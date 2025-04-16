#!/bin/bash

# Dialog configuration
BACKTITLE="TGPT GUI - Terminal Interface"
WIDTH=70
HEIGHT=20

# Check if tgpt is installed
if ! command -v tgpt &> /dev/null; then
    dialog --backtitle "$BACKTITLE" --title "Error" --msgbox "The tgpt tool is not installed.\nPlease install it with 'pip install tgpt'" 8 50
    exit 1
fi

# Check if dialog is installed
if ! command -v dialog &> /dev/null; then
    echo "Error: dialog is not installed. Please install it with your package manager."
    echo "For example: sudo apt install dialog"
    exit 1
fi

# Default configuration
PROVIDER="phind"
MODEL=""
API_KEY=""
FLAGS=""
TEMP=""
TOP_P=""
MAX_LENGTH=""
PREPROMPT=""
URL=""

# Function to save configuration
save_config() {
    mkdir -p ~/.config/tgpt-gui/
    {
        echo "PROVIDER=\"$PROVIDER\""
        echo "MODEL=\"$MODEL\""
        echo "API_KEY=\"$API_KEY\""
        echo "FLAGS=\"$FLAGS\""
        echo "TEMP=\"$TEMP\""
        echo "TOP_P=\"$TOP_P\""
        echo "MAX_LENGTH=\"$MAX_LENGTH\""
        echo "PREPROMPT=\"$PREPROMPT\""
        echo "URL=\"$URL\""
    } > ~/.config/tgpt-gui/config
}

# Function to load configuration
load_config() {
    if [ -f ~/.config/tgpt-gui/config ]; then
        source ~/.config/tgpt-gui/config
    fi
}

# Load saved configuration
load_config

# Function for main menu
main_menu() {
    while true; do
        choice=$(dialog --clear --backtitle "$BACKTITLE" --title "Main Menu" \
                --ok-label "Select" --cancel-label "Exit" \
                --menu "Select an option:" $HEIGHT $WIDTH 10 \
                "1" "Ask AI" \
                "2" "Generate Image" \
                "3" "Code Mode" \
                "4" "Interactive Mode" \
                "5" "Multiline Mode" \
                "6" "Configure" \
                "7" "Update tgpt" \
                "8" "Help" \
                "0" "Exit" 3>&1 1>&2 2>&3)
        
        # If user cancels or closes the dialog
        if [ $? -ne 0 ]; then
            break
        fi
        
        case $choice in
            1) make_query ;;
            2) generate_image ;;
            3) code_mode ;;
            4) interactive_mode ;;
            5) multiline_mode ;;
            6) configure ;;
            7) update_tgpt ;;
            8) show_help ;;
            0) break ;;
        esac
    done
    
    clear
    echo "Thank you for using TGPT GUI"
    exit 0
}

# Function to make a query
make_query() {
    # Get user query
    dialog --backtitle "$BACKTITLE" --title "Query" --inputbox "Type your question or instruction for the AI:" $HEIGHT $WIDTH 2> /tmp/tgpt_query.txt
    
    if [ $? -ne 0 ]; then
        return
    fi
    
    query=$(cat /tmp/tgpt_query.txt)
    rm -f /tmp/tgpt_query.txt
    
    # If nothing was written
    if [ -z "$query" ]; then
        dialog --backtitle "$BACKTITLE" --title "Error" --msgbox "The query cannot be empty." 6 50
        return
    fi
    
    # Display options
    dialog --backtitle "$BACKTITLE" --title "Display Options" \
        --ok-label "Select" --cancel-label "Back" \
        --radiolist "How do you want to see the response?" $HEIGHT $WIDTH 3 \
        "1" "Normal (with animation)" "on" \
        "2" "Quiet (no animation)" "off" \
        "3" "Whole (full text)" "off" 2> /tmp/tgpt_display.txt
    
    if [ $? -ne 0 ]; then
        return
    fi
    
    display_opt=$(cat /tmp/tgpt_display.txt)
    rm -f /tmp/tgpt_display.txt
    
    # Configure flags based on selection
    display_flag=""
    case $display_opt in
        2) display_flag="-q" ;;
        3) display_flag="-w" ;;
    esac
    
    # Build base command
    cmd="tgpt $display_flag"
    
    # Add provider if configured
    if [ ! -z "$PROVIDER" ]; then
        cmd="$cmd --provider $PROVIDER"
    fi
    
    # Add model if configured
    if [ ! -z "$MODEL" ]; then
        cmd="$cmd --model $MODEL"
    fi
    
    # Add API key if configured
    if [ ! -z "$API_KEY" ]; then
        cmd="$cmd --key $API_KEY"
    fi
    
    # Add URL if configured
    if [ ! -z "$URL" ]; then
        cmd="$cmd --url $URL"
    fi
    
    # Add temperature if configured
    if [ ! -z "$TEMP" ]; then
        cmd="$cmd --temperature $TEMP"
    fi
    
    # Add top_p if configured
    if [ ! -z "$TOP_P" ]; then
        cmd="$cmd --top_p $TOP_P"
    fi
    
    # Add max_length if configured
    if [ ! -z "$MAX_LENGTH" ]; then
        cmd="$cmd --max_length $MAX_LENGTH"
    fi
    
    # Add preprompt if configured
    if [ ! -z "$PREPROMPT" ]; then
        cmd="$cmd --preprompt $PREPROMPT"
    fi
    
    # Add additional flags
    if [ ! -z "$FLAGS" ]; then
        cmd="$cmd $FLAGS"
    fi
    
    # Add the query in quotes
    cmd="$cmd \"$query\""
    
    # Display mode
    if [ "$display_opt" == "1" ]; then
        # Show animation directly in terminal
        clear
        echo "Executing: $cmd"
        echo "---"
        eval $cmd
        echo "---"
        echo "Press ENTER to continue..."
        read
    else
        # Execute command and show result in dialog
        dialog --backtitle "$BACKTITLE" --title "Processing" --infobox "Processing query...\nThis may take a few seconds." 5 50
        
        # Execute command and capture output
        result=$(eval $cmd 2>&1)
        
        # Show the response
        dialog --backtitle "$BACKTITLE" --title "Response from $PROVIDER" --msgbox "$result" 0 0
    fi
}

# Function to generate an image
generate_image() {
    # Get image description
    dialog --backtitle "$BACKTITLE" --title "Image Generation" --inputbox "Describe the image you want to generate:" $HEIGHT $WIDTH 2> /tmp/tgpt_img.txt
    
    if [ $? -ne 0 ]; then
        return
    fi
    
    prompt=$(cat /tmp/tgpt_img.txt)
    rm -f /tmp/tgpt_img.txt
    
    # If nothing was written
    if [ -z "$prompt" ]; then
        dialog --backtitle "$BACKTITLE" --title "Error" --msgbox "The description cannot be empty." 6 50
        return
    fi
    
    # Dialog to select image provider
    selected_img_provider=$(dialog --clear --backtitle "$BACKTITLE" --title "Select Image Provider" \
                        --ok-label "Select" --cancel-label "Back" \
                        --menu "Select a provider to generate images:" $HEIGHT $WIDTH 4 \
                        "pollinations" "Pollinations (no API key required)" \
                        "openai" "OpenAI DALL-E (API key required)" \
                        "deepseek" "DeepSeek (API key required)" \
                        "gemini" "Google Gemini (API key required)" 3>&1 1>&2 2>&3)
    
    if [ $? -ne 0 ]; then
        return
    fi
    
    img_provider=$selected_img_provider
    img_model=""
    
    # Configure model according to selected provider
    case $img_provider in
        "openai")
            img_model="dall-e-3"
            ;;
        "deepseek")
            img_model="deepseek-vis-image-v1.5"
            ;;
        "gemini")
            img_model="gemini-1.5-flash"
            ;;
    esac
    
    # Ask for API key if needed and not configured
    if [[ "$img_provider" != "pollinations" && -z "$API_KEY" ]]; then
        dialog --backtitle "$BACKTITLE" --title "API Key Required" \
            --inputbox "This provider requires an API key.\nPlease enter your API key for $img_provider:" $HEIGHT $WIDTH "" 2> /tmp/tgpt_temp_key.txt
        
        if [ $? -ne 0 ]; then
            return
        fi
        
        temp_api_key=$(cat /tmp/tgpt_temp_key.txt)
        rm -f /tmp/tgpt_temp_key.txt
        
        if [ -z "$temp_api_key" ]; then
            dialog --backtitle "$BACKTITLE" --title "Error" --msgbox "Cannot continue without an API key." 6 50
            return
        fi
    else
        temp_api_key=$API_KEY
    fi
    
    # Build command
    cmd="tgpt --img --provider $img_provider"
    
    # Add model if applicable
    if [ ! -z "$img_model" ]; then
        cmd="$cmd --model $img_model"
    fi
    
    # Add temporary or configured API key
    if [ ! -z "$temp_api_key" ]; then
        cmd="$cmd --key $temp_api_key"
    fi
    
    # Add the description in quotes
    cmd="$cmd \"$prompt\""
    
    # Show processing message
    dialog --backtitle "$BACKTITLE" --title "Processing" --infobox "Generating image with $img_provider...\nThis may take several seconds." 5 60
    
    # Execute command and capture output
    result=$(eval $cmd 2>&1)
    
    # Show the response
    dialog --backtitle "$BACKTITLE" --title "Generation Result" --msgbox "$result" 0 0
}

# Function for code mode
code_mode() {
    # Get code description
    dialog --backtitle "$BACKTITLE" --title "Code Mode" --inputbox "Describe what code you need:" $HEIGHT $WIDTH 2> /tmp/tgpt_code.txt
    
    if [ $? -ne 0 ]; then
        return
    fi
    
    description=$(cat /tmp/tgpt_code.txt)
    rm -f /tmp/tgpt_code.txt
    
    # If nothing was written
    if [ -z "$description" ]; then
        dialog --backtitle "$BACKTITLE" --title "Error" --msgbox "The description cannot be empty." 6 50
        return
    fi
    
    # Build command
    cmd="tgpt -c"
    
    # Add provider if configured
    if [ ! -z "$PROVIDER" ]; then
        cmd="$cmd --provider $PROVIDER"
    fi
    
    # Add model if configured
    if [ ! -z "$MODEL" ]; then
        cmd="$cmd --model $MODEL"
    fi
    
    # Add API key if configured
    if [ ! -z "$API_KEY" ]; then
        cmd="$cmd --key $API_KEY"
    fi
    
    # Add the description in quotes
    cmd="$cmd \"$description\""
    
    # Execute directly in terminal
    clear
    echo "Executing: $cmd"
    echo "---"
    eval $cmd
    echo "---"
    echo "Press ENTER to continue..."
    read
}

# Function for interactive mode
interactive_mode() {
    # Build command
    cmd="tgpt -i"
    
    # Add provider if configured
    if [ ! -z "$PROVIDER" ]; then
        cmd="$cmd --provider $PROVIDER"
    fi
    
    # Add model if configured
    if [ ! -z "$MODEL" ]; then
        cmd="$cmd --model $MODEL"
    fi
    
    # Add API key if configured
    if [ ! -z "$API_KEY" ]; then
        cmd="$cmd --key $API_KEY"
    fi
    
    # Show message before executing
    dialog --backtitle "$BACKTITLE" --title "Interactive Mode" --msgbox "Starting interactive mode.\n\nPress OK to continue." 8 50
    
    # Execute directly in terminal
    clear
    echo "Executing: $cmd"
    echo "---"
    eval $cmd
    echo "---"
    echo "Press ENTER to continue..."
    read
}

# Function for multiline mode
multiline_mode() {
    # Build command
    cmd="tgpt -m"
    
    # Add provider if configured
    if [ ! -z "$PROVIDER" ]; then
        cmd="$cmd --provider $PROVIDER"
    fi
    
    # Add model if configured
    if [ ! -z "$MODEL" ]; then
        cmd="$cmd --model $MODEL"
    fi
    
    # Add API key if configured
    if [ ! -z "$API_KEY" ]; then
        cmd="$cmd --key $API_KEY"
    fi
    
    # Show message before executing
    dialog --backtitle "$BACKTITLE" --title "Multiline Mode" --msgbox "Starting multiline interactive mode.\n\nPress OK to continue." 8 50
    
    # Execute directly in terminal
    clear
    echo "Executing: $cmd"
    echo "---"
    eval $cmd
    echo "---"
    echo "Press ENTER to continue..."
    read
}

# Function to configure options
configure() {
    while true; do
        config_choice=$(dialog --clear --backtitle "$BACKTITLE" --title "Configuration" \
                    --ok-label "Select" --cancel-label "Back" \
                    --menu "Select an option to configure:" $HEIGHT $WIDTH 10 \
                    "1" "Change Provider (current: $PROVIDER)" \
                    "2" "Configure API Key" \
                    "3" "Change Model (current: $MODEL)" \
                    "4" "Configure URL (for OpenAI)" \
                    "5" "Configure Temperature ($TEMP)" \
                    "6" "Configure Top P ($TOP_P)" \
                    "7" "Configure Maximum Length ($MAX_LENGTH)" \
                    "8" "Configure Pre-prompt" \
                    "9" "Save Configuration" \
                    "0" "Back to Main Menu" 3>&1 1>&2 2>&3)
        
        if [ $? -ne 0 ] || [ "$config_choice" == "0" ]; then
            break
        fi
        
        case $config_choice in
            1) configure_provider ;;
            2) configure_api_key ;;
            3) configure_model ;;
            4) configure_url ;;
            5) configure_temperature ;;
            6) configure_top_p ;;
            7) configure_max_length ;;
            8) configure_preprompt ;;
            9) 
                save_config
                dialog --backtitle "$BACKTITLE" --title "Configuration" --msgbox "Configuration saved successfully." 6 50
                ;;
        esac
    done
}

# Function to configure provider
configure_provider() {
    # List of available providers with API key indication
    providers=(
        "phind" "Phind (no API key required)" 
        "deepseek" "DeepSeek (API key required)" 
        "gemini" "Google Gemini (API key required)" 
        "groq" "Groq (API key required)" 
        "isou" "Isou (API key required)" 
        "koboldai" "KoboldAI (API key required)" 
        "ollama" "Ollama (local)" 
        "openai" "OpenAI (API key required)" 
        "pollinations" "Pollinations (no API key required)"
    )
    
    selected_provider=$(dialog --backtitle "$BACKTITLE" --title "Select Provider" \
                        --ok-label "Select" --cancel-label "Back" \
                        --menu "Select an AI provider:" $HEIGHT $WIDTH 10 \
                        "${providers[@]}" 3>&1 1>&2 2>&3)
    
    if [ $? -eq 0 ]; then
        PROVIDER=$selected_provider
        
        # If the provider requires an API key and it's not configured, suggest configuring it
        if [[ "$PROVIDER" != "phind" && "$PROVIDER" != "pollinations" && "$PROVIDER" != "ollama" && -z "$API_KEY" ]]; then
            dialog --backtitle "$BACKTITLE" --title "Information" \
                --yesno "The $PROVIDER provider requires an API key.\nDo you want to configure the API key now?" 7 60
                
            if [ $? -eq 0 ]; then
                configure_api_key
            fi
        fi
        
        # Suggest changing the model according to the selected provider
        dialog --backtitle "$BACKTITLE" --title "Information" \
            --yesno "You've selected the $PROVIDER provider.\nDo you want to select a specific model for this provider?" 7 60
            
        if [ $? -eq 0 ]; then
            configure_model
        fi
    fi
}

# Function to configure API Key
configure_api_key() {
    dialog --backtitle "$BACKTITLE" --title "Configure API Key" \
        --inputbox "Enter the API Key for $PROVIDER:" $HEIGHT $WIDTH "$API_KEY" 2> /tmp/tgpt_api_key.txt
    
    if [ $? -eq 0 ]; then
        API_KEY=$(cat /tmp/tgpt_api_key.txt)
        rm -f /tmp/tgpt_api_key.txt
    fi
}

# Function to configure model according to provider
configure_model() {
    # Configure available models according to provider
    case $PROVIDER in
        "openai")
            models=(
                "gpt-4o" "GPT-4o (latest model)" 
                "gpt-4-turbo" "GPT-4-Turbo" 
                "gpt-4" "GPT-4" 
                "gpt-3.5-turbo" "GPT-3.5-Turbo" 
                "gpt-3.5-turbo-instruct" "GPT-3.5-Turbo-Instruct" 
                "dall-e-3" "DALL-E 3 (images)"
            )
            ;;
        "gemini")
            models=(
                "gemini-1.5-pro" "Gemini 1.5 Pro" 
                "gemini-1.5-flash" "Gemini 1.5 Flash" 
                "gemini-pro" "Gemini Pro"
            )
            ;;
        "phind")
            models=(
                "phind-model" "Default model" 
                "phind-model-llama3" "Phind-Model-LLama3"
            )
            ;;
        "deepseek")
            models=(
                "deepseek-coder" "DeepSeek Coder" 
                "deepseek-chat" "DeepSeek Chat" 
                "deepseek-vis-image-v1.5" "DeepSeek Images v1.5"
            )
            ;;
        "groq")
            models=(
                "llama3-8b-8192" "LLama3 8B (fast)" 
                "llama3-70b-8192" "LLama3 70B (powerful)" 
                "mixtral-8x7b-32768" "Mixtral 8x7B" 
                "gemma-7b-it" "Gemma 7B IT"
            )
            ;;
        "ollama")
            models=(
                "llama3" "LLama3" 
                "llama3:8b" "LLama3 8B" 
                "llama3:70b" "LLama3 70B" 
                "mistral" "Mistral" 
                "mistral-medium" "Mistral Medium" 
                "mixtral" "Mixtral 8x7B" 
                "gemma:7b" "Gemma 7B" 
                "gemma:2b" "Gemma 2B"
            )
            ;;
        "pollinations")
            models=(
                "default" "Default model (images)"
            )
            ;;
        *)
            # For other providers, allow manual entry
            dialog --backtitle "$BACKTITLE" --title "Configure Model" \
                --inputbox "Enter the model name for $PROVIDER:" $HEIGHT $WIDTH "$MODEL" 2> /tmp/tgpt_model.txt
            
            if [ $? -eq 0 ]; then
                MODEL=$(cat /tmp/tgpt_model.txt)
                rm -f /tmp/tgpt_model.txt
            fi
            return
            ;;
    esac
    
    # If there are models available to show
    if [ ${#models[@]} -gt 0 ]; then
        selected_model=$(dialog --backtitle "$BACKTITLE" --title "Select Model" \
                        --ok-label "Select" --cancel-label "Back" \
                        --menu "Select a model for $PROVIDER:" $HEIGHT $WIDTH 10 \
                        "${models[@]}" 3>&1 1>&2 2>&3)
        
        if [ $? -eq 0 ]; then
            MODEL=$selected_model
        fi
    else
        dialog --backtitle "$BACKTITLE" --title "Information" \
            --msgbox "There are no specific predefined models for $PROVIDER.\nUsing the default model." 7 60
    fi
}

# Function to configure URL
configure_url() {
    dialog --backtitle "$BACKTITLE" --title "Configure URL" \
        --inputbox "Enter the API URL (for OpenAI):" $HEIGHT $WIDTH "$URL" 2> /tmp/tgpt_url.txt
    
    if [ $? -eq 0 ]; then
        URL=$(cat /tmp/tgpt_url.txt)
        rm -f /tmp/tgpt_url.txt
    fi
}

# Function to configure temperature
configure_temperature() {
    dialog --backtitle "$BACKTITLE" --title "Configure Temperature" \
        --inputbox "Enter the temperature (0-1):" $HEIGHT $WIDTH "$TEMP" 2> /tmp/tgpt_temp.txt
    
    if [ $? -eq 0 ]; then
        TEMP=$(cat /tmp/tgpt_temp.txt)
        rm -f /tmp/tgpt_temp.txt
    fi
}

# Function to configure top_p
configure_top_p() {
    dialog --backtitle "$BACKTITLE" --title "Configure Top P" \
        --inputbox "Enter the Top P value (0-1):" $HEIGHT $WIDTH "$TOP_P" 2> /tmp/tgpt_top_p.txt
    
    if [ $? -eq 0 ]; then
        TOP_P=$(cat /tmp/tgpt_top_p.txt)
        rm -f /tmp/tgpt_top_p.txt
    fi
}

# Function to configure max_length
configure_max_length() {
    dialog --backtitle "$BACKTITLE" --title "Configure Maximum Length" \
        --inputbox "Enter the maximum response length:" $HEIGHT $WIDTH "$MAX_LENGTH" 2> /tmp/tgpt_max_length.txt
    
    if [ $? -eq 0 ]; then
        MAX_LENGTH=$(cat /tmp/tgpt_max_length.txt)
        rm -f /tmp/tgpt_max_length.txt
    fi
}

# Function to configure preprompt
configure_preprompt() {
    dialog --backtitle "$BACKTITLE" --title "Configure Pre-prompt" \
        --inputbox "Enter the pre-prompt:" $HEIGHT $WIDTH "$PREPROMPT" 2> /tmp/tgpt_preprompt.txt
    
    if [ $? -eq 0 ]; then
        PREPROMPT=$(cat /tmp/tgpt_preprompt.txt)
        rm -f /tmp/tgpt_preprompt.txt
    fi
}

# Function to update tgpt
update_tgpt() {
    dialog --backtitle "$BACKTITLE" --title "Update" \
        --yesno "Do you want to update tgpt to the latest version?" 6 50
    
    if [ $? -ne 0 ]; then
        return
    fi
    
    # Show update progress
    dialog --backtitle "$BACKTITLE" --title "Updating" --infobox "Updating tgpt...\nThis may take a few seconds." 5 50
    
    # Execute update
    result=$(tgpt -u 2>&1)
    
    # Show result
    dialog --backtitle "$BACKTITLE" --title "Update Completed" --msgbox "Update result:\n\n$result" 12 60
}

# Function to show help
show_help() {
    # Help text in English
    help_text="
TGPT GUI HELP

USAGE MODES:
1. Ask AI - Ask questions or make requests to the AI.
2. Generate Image - Create images from text descriptions.
3. Code Mode - Generate code based on your descriptions.
4. Interactive Mode - Start a continuous conversation with the AI.
5. Multiline Mode - Write queries in multiple lines.

CONFIGURATION:
- Provider: Select from different AI services.
- API Key: Configure the necessary API keys.
- Model: Specify the AI model to use.
- Temperature: Control creativity (0-1).
- Top P: Define response diversity (0-1).

AVAILABLE PROVIDERS:
- phind: Specialized in programming (no API key required).
- pollinations: Optimal for image generation (no API key required).
- openai: OpenAI service (requires API key).
- gemini: Google's solution (requires API key).
- deepseek: Advanced models (requires API key).
- groq: High speed (requires API key).
- ollama: For local use (no API key required).

For more information, check the official tgpt documentation.
"
    
    # Show help in English
    dialog --backtitle "$BACKTITLE" --title "TGPT GUI Help" --msgbox "$help_text" 0 0
}

# Welcome screen
dialog --backtitle "$BACKTITLE" --title "Welcome" \
    --msgbox "Welcome to TGPT GUI\n\nThis interface allows you to use tgpt interactively from the terminal.\n\nPress OK to continue." 10 60

# Start the main menu
main_menu
