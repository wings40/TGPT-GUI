#!/bin/bash

# Configuración de diálogos
BACKTITLE="TGPT GUI - Interfaz de Terminal"
WIDTH=70
HEIGHT=20

# Comprobar si tgpt está instalado
if ! command -v tgpt &> /dev/null; then
    dialog --backtitle "$BACKTITLE" --title "Error" --msgbox "La herramienta tgpt no está instalada.\nPor favor, instálala con 'pip install tgpt'" 8 50
    exit 1
fi

# Comprobar si dialog está instalado
if ! command -v dialog &> /dev/null; then
    echo "Error: dialog no está instalado. Por favor, instálalo con tu gestor de paquetes."
    echo "Por ejemplo: sudo apt install dialog"
    exit 1
fi

# Configuración por defecto
PROVIDER="phind"
MODEL=""
API_KEY=""
FLAGS=""
TEMP=""
TOP_P=""
MAX_LENGTH=""
PREPROMPT=""
URL=""

# Función para guardar la configuración
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

# Función para cargar la configuración
load_config() {
    if [ -f ~/.config/tgpt-gui/config ]; then
        source ~/.config/tgpt-gui/config
    fi
}

# Cargar configuración guardada
load_config

# Función para el menú principal
main_menu() {
    while true; do
        choice=$(dialog --clear --backtitle "$BACKTITLE" --title "Menú Principal" \
                --ok-label "Seleccionar" --cancel-label "Salir" \
                --menu "Selecciona una opción:" $HEIGHT $WIDTH 10 \
                "1" "Consultar IA" \
                "2" "Generar Imagen" \
                "3" "Modo Código" \
                "4" "Modo Interactivo" \
                "5" "Modo Multilinea" \
                "6" "Configurar" \
                "7" "Actualizar tgpt" \
                "8" "Ayuda" \
                "0" "Salir" 3>&1 1>&2 2>&3)
        
        # Si el usuario cancela o cierra el diálogo
        if [ $? -ne 0 ]; then
            break
        fi
        
        case $choice in
            1) hacer_consulta ;;
            2) generar_imagen ;;
            3) modo_codigo ;;
            4) modo_interactivo ;;
            5) modo_multilinea ;;
            6) configurar ;;
            7) actualizar_tgpt ;;
            8) mostrar_ayuda ;;
            0) break ;;
        esac
    done
    
    clear
    echo "Gracias por usar TGPT GUI"
    exit 0
}

# Función para hacer una consulta
hacer_consulta() {
    # Obtener la consulta del usuario
    dialog --backtitle "$BACKTITLE" --title "Consulta" --inputbox "Escribe tu pregunta o instrucción para la IA:" $HEIGHT $WIDTH 2> /tmp/tgpt_query.txt
    
    if [ $? -ne 0 ]; then
        return
    fi
    
    consulta=$(cat /tmp/tgpt_query.txt)
    rm -f /tmp/tgpt_query.txt
    
    # Si no escribió nada
    if [ -z "$consulta" ]; then
        dialog --backtitle "$BACKTITLE" --title "Error" --msgbox "La consulta no puede estar vacía." 6 50
        return
    fi
    
    # Opciones de visualización
    dialog --backtitle "$BACKTITLE" --title "Opciones de visualización" \
        --ok-label "Seleccionar" --cancel-label "Volver" \
        --radiolist "¿Cómo quieres ver la respuesta?" $HEIGHT $WIDTH 3 \
        "1" "Normal (con animación)" "on" \
        "2" "Quiet (sin animación)" "off" \
        "3" "Whole (texto completo)" "off" 2> /tmp/tgpt_display.txt
    
    if [ $? -ne 0 ]; then
        return
    fi
    
    display_opt=$(cat /tmp/tgpt_display.txt)
    rm -f /tmp/tgpt_display.txt
    
    # Configurar flags basado en selección
    display_flag=""
    case $display_opt in
        2) display_flag="-q" ;;
        3) display_flag="-w" ;;
    esac
    
    # Construir comando base
    cmd="tgpt $display_flag"
    
    # Añadir provider si está configurado
    if [ ! -z "$PROVIDER" ]; then
        cmd="$cmd --provider $PROVIDER"
    fi
    
    # Añadir model si está configurado
    if [ ! -z "$MODEL" ]; then
        cmd="$cmd --model $MODEL"
    fi
    
    # Añadir API key si está configurada
    if [ ! -z "$API_KEY" ]; then
        cmd="$cmd --key $API_KEY"
    fi
    
    # Añadir URL si está configurada
    if [ ! -z "$URL" ]; then
        cmd="$cmd --url $URL"
    fi
    
    # Añadir temperatura si está configurada
    if [ ! -z "$TEMP" ]; then
        cmd="$cmd --temperature $TEMP"
    fi
    
    # Añadir top_p si está configurado
    if [ ! -z "$TOP_P" ]; then
        cmd="$cmd --top_p $TOP_P"
    fi
    
    # Añadir max_length si está configurado
    if [ ! -z "$MAX_LENGTH" ]; then
        cmd="$cmd --max_length $MAX_LENGTH"
    fi
    
    # Añadir preprompt si está configurado
    if [ ! -z "$PREPROMPT" ]; then
        cmd="$cmd --preprompt $PREPROMPT"
    fi
    
    # Añadir flags adicionales
    if [ ! -z "$FLAGS" ]; then
        cmd="$cmd $FLAGS"
    fi
    
    # Añadir la consulta entre comillas
    cmd="$cmd \"$consulta\""
    
    # Modo de visualización
    if [ "$display_opt" == "1" ]; then
        # Mostrar animación directamente en la terminal
        clear
        echo "Ejecutando: $cmd"
        echo "---"
        eval $cmd
        echo "---"
        echo "Presiona ENTER para continuar..."
        read
    else
        # Ejecutar el comando y mostrar resultado en dialog
        dialog --backtitle "$BACKTITLE" --title "Procesando" --infobox "Procesando consulta...\nEsto puede tardar unos segundos." 5 50
        
        # Ejecutar el comando y capturar la salida
        resultado=$(eval $cmd 2>&1)
        
        # Mostrar la respuesta
        dialog --backtitle "$BACKTITLE" --title "Respuesta de $PROVIDER" --msgbox "$resultado" 0 0
    fi
}

# Función para generar una imagen
generar_imagen() {
    # Obtener la descripción de la imagen
    dialog --backtitle "$BACKTITLE" --title "Generación de Imagen" --inputbox "Describe la imagen que quieres generar:" $HEIGHT $WIDTH 2> /tmp/tgpt_img.txt
    
    if [ $? -ne 0 ]; then
        return
    fi
    
    prompt=$(cat /tmp/tgpt_img.txt)
    rm -f /tmp/tgpt_img.txt
    
    # Si no escribió nada
    if [ -z "$prompt" ]; then
        dialog --backtitle "$BACKTITLE" --title "Error" --msgbox "La descripción no puede estar vacía." 6 50
        return
    fi
    
    # Dialog para seleccionar proveedor de imágenes
    selected_img_provider=$(dialog --clear --backtitle "$BACKTITLE" --title "Seleccionar Proveedor de Imágenes" \
                        --ok-label "Seleccionar" --cancel-label "Volver" \
                        --menu "Selecciona un proveedor para generar imágenes:" $HEIGHT $WIDTH 4 \
                        "pollinations" "Pollinations (no requiere API key)" \
                        "openai" "OpenAI DALL-E (requiere API key)" \
                        "deepseek" "DeepSeek (requiere API key)" \
                        "gemini" "Google Gemini (requiere API key)" 3>&1 1>&2 2>&3)
    
    if [ $? -ne 0 ]; then
        return
    fi
    
    img_provider=$selected_img_provider
    img_model=""
    
    # Configurar modelo según el proveedor seleccionado
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
    
    # Pedir API key si es necesario y no está configurada
    if [[ "$img_provider" != "pollinations" && -z "$API_KEY" ]]; then
        dialog --backtitle "$BACKTITLE" --title "API Key Requerida" \
            --inputbox "Este proveedor requiere una API key.\nPor favor, ingresa tu API key para $img_provider:" $HEIGHT $WIDTH "" 2> /tmp/tgpt_temp_key.txt
        
        if [ $? -ne 0 ]; then
            return
        fi
        
        temp_api_key=$(cat /tmp/tgpt_temp_key.txt)
        rm -f /tmp/tgpt_temp_key.txt
        
        if [ -z "$temp_api_key" ]; then
            dialog --backtitle "$BACKTITLE" --title "Error" --msgbox "No se puede continuar sin una API key." 6 50
            return
        fi
    else
        temp_api_key=$API_KEY
    fi
    
    # Construir comando
    cmd="tgpt --img --provider $img_provider"
    
    # Añadir modelo si corresponde
    if [ ! -z "$img_model" ]; then
        cmd="$cmd --model $img_model"
    fi
    
    # Añadir API key temporal o configurada
    if [ ! -z "$temp_api_key" ]; then
        cmd="$cmd --key $temp_api_key"
    fi
    
    # Añadir la descripción entre comillas
    cmd="$cmd \"$prompt\""
    
    # Mostrar mensaje de procesamiento
    dialog --backtitle "$BACKTITLE" --title "Procesando" --infobox "Generando imagen con $img_provider...\nEsto puede tardar varios segundos." 5 60
    
    # Ejecutar el comando y capturar la salida
    resultado=$(eval $cmd 2>&1)
    
    # Mostrar la respuesta
    dialog --backtitle "$BACKTITLE" --title "Resultado de la Generación" --msgbox "$resultado" 0 0
}

# Función para modo código
modo_codigo() {
    # Obtener la descripción del código
    dialog --backtitle "$BACKTITLE" --title "Modo Código" --inputbox "Describe qué código necesitas:" $HEIGHT $WIDTH 2> /tmp/tgpt_code.txt
    
    if [ $? -ne 0 ]; then
        return
    fi
    
    descripcion=$(cat /tmp/tgpt_code.txt)
    rm -f /tmp/tgpt_code.txt
    
    # Si no escribió nada
    if [ -z "$descripcion" ]; then
        dialog --backtitle "$BACKTITLE" --title "Error" --msgbox "La descripción no puede estar vacía." 6 50
        return
    fi
    
    # Construir comando
    cmd="tgpt -c"
    
    # Añadir provider si está configurado
    if [ ! -z "$PROVIDER" ]; then
        cmd="$cmd --provider $PROVIDER"
    fi
    
    # Añadir model si está configurado
    if [ ! -z "$MODEL" ]; then
        cmd="$cmd --model $MODEL"
    fi
    
    # Añadir API key si está configurada
    if [ ! -z "$API_KEY" ]; then
        cmd="$cmd --key $API_KEY"
    fi
    
    # Añadir la descripción entre comillas
    cmd="$cmd \"$descripcion\""
    
    # Ejecutar directamente en la terminal
    clear
    echo "Ejecutando: $cmd"
    echo "---"
    eval $cmd
    echo "---"
    echo "Presiona ENTER para continuar..."
    read
}

# Función para modo interactivo
modo_interactivo() {
    # Construir comando
    cmd="tgpt -i"
    
    # Añadir provider si está configurado
    if [ ! -z "$PROVIDER" ]; then
        cmd="$cmd --provider $PROVIDER"
    fi
    
    # Añadir model si está configurado
    if [ ! -z "$MODEL" ]; then
        cmd="$cmd --model $MODEL"
    fi
    
    # Añadir API key si está configurada
    if [ ! -z "$API_KEY" ]; then
        cmd="$cmd --key $API_KEY"
    fi
    
    # Mostrar mensaje antes de ejecutar
    dialog --backtitle "$BACKTITLE" --title "Modo Interactivo" --msgbox "Iniciando modo interactivo.\n\nPresiona OK para continuar." 8 50
    
    # Ejecutar directamente en la terminal
    clear
    echo "Ejecutando: $cmd"
    echo "---"
    eval $cmd
    echo "---"
    echo "Presiona ENTER para continuar..."
    read
}

# Función para modo multilinea
modo_multilinea() {
    # Construir comando
    cmd="tgpt -m"
    
    # Añadir provider si está configurado
    if [ ! -z "$PROVIDER" ]; then
        cmd="$cmd --provider $PROVIDER"
    fi
    
    # Añadir model si está configurado
    if [ ! -z "$MODEL" ]; then
        cmd="$cmd --model $MODEL"
    fi
    
    # Añadir API key si está configurada
    if [ ! -z "$API_KEY" ]; then
        cmd="$cmd --key $API_KEY"
    fi
    
    # Mostrar mensaje antes de ejecutar
    dialog --backtitle "$BACKTITLE" --title "Modo Multilinea" --msgbox "Iniciando modo interactivo multilinea.\n\nPresiona OK para continuar." 8 50
    
    # Ejecutar directamente en la terminal
    clear
    echo "Ejecutando: $cmd"
    echo "---"
    eval $cmd
    echo "---"
    echo "Presiona ENTER para continuar..."
    read
}

# Función para configurar las opciones
configurar() {
    while true; do
        config_choice=$(dialog --clear --backtitle "$BACKTITLE" --title "Configuración" \
                    --ok-label "Seleccionar" --cancel-label "Volver" \
                    --menu "Selecciona una opción para configurar:" $HEIGHT $WIDTH 10 \
                    "1" "Cambiar Proveedor (actual: $PROVIDER)" \
                    "2" "Configurar API Key" \
                    "3" "Cambiar Modelo (actual: $MODEL)" \
                    "4" "Configurar URL (para OpenAI)" \
                    "5" "Configurar Temperatura ($TEMP)" \
                    "6" "Configurar Top P ($TOP_P)" \
                    "7" "Configurar Longitud Máxima ($MAX_LENGTH)" \
                    "8" "Configurar Pre-prompt" \
                    "9" "Guardar Configuración" \
                    "0" "Volver al Menú Principal" 3>&1 1>&2 2>&3)
        
        if [ $? -ne 0 ] || [ "$config_choice" == "0" ]; then
            break
        fi
        
        case $config_choice in
            1) configurar_provider ;;
            2) configurar_api_key ;;
            3) configurar_modelo ;;
            4) configurar_url ;;
            5) configurar_temperatura ;;
            6) configurar_top_p ;;
            7) configurar_max_length ;;
            8) configurar_preprompt ;;
            9) 
                save_config
                dialog --backtitle "$BACKTITLE" --title "Configuración" --msgbox "Configuración guardada correctamente." 6 50
                ;;
        esac
    done
}

# Función para configurar proveedor
configurar_provider() {
    # Lista de proveedores disponibles con indicación de API key
    proveedores=(
        "phind" "Phind (no requiere API key)" 
        "deepseek" "DeepSeek (requiere API key)" 
        "gemini" "Google Gemini (requiere API key)" 
        "groq" "Groq (requiere API key)" 
        "isou" "Isou (requiere API key)" 
        "koboldai" "KoboldAI (requiere API key)" 
        "ollama" "Ollama (local)" 
        "openai" "OpenAI (requiere API key)" 
        "pollinations" "Pollinations (no requiere API key)"
    )
    
    selected_provider=$(dialog --backtitle "$BACKTITLE" --title "Seleccionar Proveedor" \
                        --ok-label "Seleccionar" --cancel-label "Volver" \
                        --menu "Selecciona un proveedor de IA:" $HEIGHT $WIDTH 10 \
                        "${proveedores[@]}" 3>&1 1>&2 2>&3)
    
    if [ $? -eq 0 ]; then
        PROVIDER=$selected_provider
        
        # Si el proveedor requiere API key y no está configurada, sugerir configurarla
        if [[ "$PROVIDER" != "phind" && "$PROVIDER" != "pollinations" && "$PROVIDER" != "ollama" && -z "$API_KEY" ]]; then
            dialog --backtitle "$BACKTITLE" --title "Información" \
                --yesno "El proveedor $PROVIDER requiere una API key.\n¿Deseas configurar la API key ahora?" 7 60
                
            if [ $? -eq 0 ]; then
                configurar_api_key
            fi
        fi
        
        # Sugerir cambiar el modelo según el proveedor seleccionado
        dialog --backtitle "$BACKTITLE" --title "Información" \
            --yesno "Has seleccionado el proveedor $PROVIDER.\n¿Deseas seleccionar un modelo específico para este proveedor?" 7 60
            
        if [ $? -eq 0 ]; then
            configurar_modelo
        fi
    fi
}

# Función para configurar API Key
configurar_api_key() {
    dialog --backtitle "$BACKTITLE" --title "Configurar API Key" \
        --inputbox "Ingresa la API Key para $PROVIDER:" $HEIGHT $WIDTH "$API_KEY" 2> /tmp/tgpt_api_key.txt
    
    if [ $? -eq 0 ]; then
        API_KEY=$(cat /tmp/tgpt_api_key.txt)
        rm -f /tmp/tgpt_api_key.txt
    fi
}

# Función para configurar modelo según el proveedor
configurar_modelo() {
    # Configurar los modelos disponibles según el proveedor
    case $PROVIDER in
        "openai")
            modelos=(
                "gpt-4o" "GPT-4o (último modelo)" 
                "gpt-4-turbo" "GPT-4-Turbo" 
                "gpt-4" "GPT-4" 
                "gpt-3.5-turbo" "GPT-3.5-Turbo" 
                "gpt-3.5-turbo-instruct" "GPT-3.5-Turbo-Instruct" 
                "dall-e-3" "DALL-E 3 (imágenes)"
            )
            ;;
        "gemini")
            modelos=(
                "gemini-1.5-pro" "Gemini 1.5 Pro" 
                "gemini-1.5-flash" "Gemini 1.5 Flash" 
                "gemini-pro" "Gemini Pro"
            )
            ;;
        "phind")
            modelos=(
                "phind-model" "Modelo predeterminado" 
                "phind-model-llama3" "Phind-Model-LLama3"
            )
            ;;
        "deepseek")
            modelos=(
                "deepseek-coder" "DeepSeek Coder" 
                "deepseek-chat" "DeepSeek Chat" 
                "deepseek-vis-image-v1.5" "DeepSeek Imágenes v1.5"
            )
            ;;
        "groq")
            modelos=(
                "llama3-8b-8192" "LLama3 8B (rápido)" 
                "llama3-70b-8192" "LLama3 70B (potente)" 
                "mixtral-8x7b-32768" "Mixtral 8x7B" 
                "gemma-7b-it" "Gemma 7B IT"
            )
            ;;
        "ollama")
            modelos=(
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
            modelos=(
                "default" "Modelo por defecto (imágenes)"
            )
            ;;
        *)
            # Para otros proveedores, permitir entrada manual
            dialog --backtitle "$BACKTITLE" --title "Configurar Modelo" \
                --inputbox "Ingresa el nombre del modelo para $PROVIDER:" $HEIGHT $WIDTH "$MODEL" 2> /tmp/tgpt_model.txt
            
            if [ $? -eq 0 ]; then
                MODEL=$(cat /tmp/tgpt_model.txt)
                rm -f /tmp/tgpt_model.txt
            fi
            return
            ;;
    esac
    
    # Si hay modelos disponibles para mostrar
    if [ ${#modelos[@]} -gt 0 ]; then
        selected_model=$(dialog --backtitle "$BACKTITLE" --title "Seleccionar Modelo" \
                        --ok-label "Seleccionar" --cancel-label "Volver" \
                        --menu "Selecciona un modelo para $PROVIDER:" $HEIGHT $WIDTH 10 \
                        "${modelos[@]}" 3>&1 1>&2 2>&3)
        
        if [ $? -eq 0 ]; then
            MODEL=$selected_model
        fi
    else
        dialog --backtitle "$BACKTITLE" --title "Información" \
            --msgbox "No hay modelos específicos predefinidos para $PROVIDER.\nUtilizando el modelo por defecto." 7 60
    fi
}

# Función para configurar URL
configurar_url() {
    dialog --backtitle "$BACKTITLE" --title "Configurar URL" \
        --inputbox "Ingresa la URL de la API (para OpenAI):" $HEIGHT $WIDTH "$URL" 2> /tmp/tgpt_url.txt
    
    if [ $? -eq 0 ]; then
        URL=$(cat /tmp/tgpt_url.txt)
        rm -f /tmp/tgpt_url.txt
    fi
}

# Función para configurar temperatura
configurar_temperatura() {
    dialog --backtitle "$BACKTITLE" --title "Configurar Temperatura" \
        --inputbox "Ingresa la temperatura (0-1):" $HEIGHT $WIDTH "$TEMP" 2> /tmp/tgpt_temp.txt
    
    if [ $? -eq 0 ]; then
        TEMP=$(cat /tmp/tgpt_temp.txt)
        rm -f /tmp/tgpt_temp.txt
    fi
}

# Función para configurar top_p
configurar_top_p() {
    dialog --backtitle "$BACKTITLE" --title "Configurar Top P" \
        --inputbox "Ingresa el valor de Top P (0-1):" $HEIGHT $WIDTH "$TOP_P" 2> /tmp/tgpt_top_p.txt
    
    if [ $? -eq 0 ]; then
        TOP_P=$(cat /tmp/tgpt_top_p.txt)
        rm -f /tmp/tgpt_top_p.txt
    fi
}

# Función para configurar max_length
configurar_max_length() {
    dialog --backtitle "$BACKTITLE" --title "Configurar Longitud Máxima" \
        --inputbox "Ingresa la longitud máxima de respuesta:" $HEIGHT $WIDTH "$MAX_LENGTH" 2> /tmp/tgpt_max_length.txt
    
    if [ $? -eq 0 ]; then
        MAX_LENGTH=$(cat /tmp/tgpt_max_length.txt)
        rm -f /tmp/tgpt_max_length.txt
    fi
}

# Función para configurar preprompt
configurar_preprompt() {
    dialog --backtitle "$BACKTITLE" --title "Configurar Pre-prompt" \
        --inputbox "Ingresa el pre-prompt:" $HEIGHT $WIDTH "$PREPROMPT" 2> /tmp/tgpt_preprompt.txt
    
    if [ $? -eq 0 ]; then
        PREPROMPT=$(cat /tmp/tgpt_preprompt.txt)
        rm -f /tmp/tgpt_preprompt.txt
    fi
}

# Función para actualizar tgpt
actualizar_tgpt() {
    dialog --backtitle "$BACKTITLE" --title "Actualización" \
        --yesno "¿Deseas actualizar tgpt a la última versión?" 6 50
    
    if [ $? -ne 0 ]; then
        return
    fi
    
    # Mostrar progreso de actualización
    dialog --backtitle "$BACKTITLE" --title "Actualizando" --infobox "Actualizando tgpt...\nEsto puede tardar unos segundos." 5 50
    
    # Ejecutar actualización
    resultado=$(tgpt -u 2>&1)
    
    # Mostrar resultado
    dialog --backtitle "$BACKTITLE" --title "Actualización Completada" --msgbox "Resultado de la actualización:\n\n$resultado" 12 60
}

# Función para mostrar ayuda
mostrar_ayuda() {
    # Texto de ayuda en español
    ayuda_texto="
AYUDA DE TGPT GUI

MODOS DE USO:
1. Consultar IA - Realiza preguntas o peticiones a la IA.
2. Generar Imagen - Crea imágenes a partir de descripciones textuales.
3. Modo Código - Genera código basado en tus descripciones.
4. Modo Interactivo - Inicia una conversación continua con la IA.
5. Modo Multilinea - Permite escribir consultas en múltiples líneas.

CONFIGURACIÓN:
- Proveedor: Selecciona entre diferentes servicios de IA.
- API Key: Configura las claves de API necesarias.
- Modelo: Especifica el modelo de IA a utilizar.
- Temperatura: Controla la creatividad (0-1).
- Top P: Define la diversidad de respuestas (0-1).

PROVEEDORES DISPONIBLES:
- phind: Especializado en programación (no requiere API key).
- pollinations: Óptimo para generación de imágenes (no requiere API key).
- openai: Servicio de OpenAI (requiere clave de API).
- gemini: Solución de Google (requiere clave de API).
- deepseek: Modelos avanzados (requiere clave de API).
- groq: Alta velocidad (requiere clave de API).
- ollama: Para uso local (no requiere API key).

Para más información, consulta la documentación oficial de tgpt.
"
    
    # Mostrar la ayuda en español
    dialog --backtitle "$BACKTITLE" --title "Ayuda de TGPT GUI" --msgbox "$ayuda_texto" 0 0
}

# Pantalla de bienvenida
dialog --backtitle "$BACKTITLE" --title "Bienvenido" \
    --msgbox "Bienvenido a TGPT GUI\n\nEsta interfaz te permite utilizar tgpt de forma interactiva desde la terminal.\n\nPresiona OK para continuar." 10 60

# Iniciar el menú principal
main_menu
