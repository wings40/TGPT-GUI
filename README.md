# Que es TGPT
Tgpt es una herramienta de interfaz de línea de comandos (CLI) multiplataforma que te permite usar un chatbot de IA en tu Terminal sin necesidad de claves API.
# TGPT GUI

Una interfaz gráfica basada en terminal para [tgpt](https://github.com/aandrew-me/tgpt), que permite acceder a modelos de inteligencia artificial directamente desde la línea de comandos.

## Requisitos Previos

- Tener instalado `tgpt`
- Tener instalado `dialog` (por ejemplo, con `sudo apt install dialog`)

## Instalación de TGPT

### En GNU/Linux o macOS
```bash
curl -sSL https://raw.githubusercontent.com/aandrew-me/tgpt/main/install | bash -s /usr/local/bin
```

### En Arch Linux
```bash
pacman -S tgpt
```
Para más métodos de instalación, visita el [repositorio oficial de tgpt](https://github.com/aandrew-me/tgpt).

## Instalación de TGPT GUI

1. Descarga el script `tgpt-gui.sh`
2. Dale permisos de ejecución: `chmod +x tgpt-gui.sh`
3. Ejecútalo: `./tgpt-gui.sh`

## Manual de Uso

### Menú Principal

Al iniciar TGPT GUI, encontrarás un menú con las siguientes opciones:

1. **Consultar IA**: Para hacer preguntas directas a la inteligencia artificial.
2. **Generar Imagen**: Para crear imágenes a partir de descripciones textuales.
3. **Modo Código**: Especializado en generar código según tus necesidades.
4. **Modo Interactivo**: Para mantener una conversación continua con la IA.
5. **Modo Multilinea**: Permite escribir consultas en múltiples líneas de texto.
6. **Configurar**: Para ajustar proveedores, modelos y parámetros.
7. **Actualizar tgpt**: Para obtener la última versión de tgpt.
8. **Ayuda**: Muestra información sobre el uso de la aplicación.

### Consultar IA

Esta opción te permite hacer preguntas directas a la IA. Después de escribir tu consulta, puedes elegir entre tres modos de visualización:

- **Normal**: Muestra la respuesta con animación de escritura.
- **Quiet**: Muestra la respuesta sin animación.
- **Whole**: Muestra la respuesta completa de una vez.

### Generar Imagen

Permite crear imágenes a partir de descripciones textuales. Puedes elegir entre varios proveedores:

- **Pollinations**: No requiere API key.
- **OpenAI DALL-E**: Requiere API key de OpenAI.
- **DeepSeek**: Requiere API key de DeepSeek.
- **Google Gemini**: Requiere API key de Google.

### Modo Código

Especializado en la generación de código. Solo necesitas describir qué código necesitas y la IA lo generará, utilizando un formato optimizado para código.

### Modo Interactivo

Inicia una sesión interactiva con la IA donde puedes mantener una conversación continua, similar a un chat. La IA recordará el contexto de las preguntas anteriores.

### Modo Multilinea

Similar al modo interactivo, pero permite escribir consultas en múltiples líneas, ideal para textos más extensos o con formato especial.

## Configuración

El menú de configuración te permite personalizar varios aspectos:

### Cambiar Proveedor

Puedes seleccionar entre diversos proveedores de IA:

- **phind**: Especializado en programación (no requiere API key).
- **deepseek**: Modelos avanzados (requiere API key).
- **gemini**: Google Gemini (requiere API key).
- **groq**: Alta velocidad (requiere API key).
- **isou**: Isou (requiere API key).
- **koboldai**: KoboldAI (requiere API key).
- **ollama**: Para uso local.
- **openai**: OpenAI (requiere API key).
- **pollinations**: Para imágenes (no requiere API key).

### Configurar API Key

Aquí puedes ingresar la API key necesaria para el proveedor seleccionado. Esta configuración se guarda para sesiones futuras.

### Cambiar Modelo

Cada proveedor ofrece diferentes modelos de IA. Esta opción te permite seleccionar el más adecuado para tus necesidades. Por ejemplo:

- **OpenAI**: GPT-4o, GPT-4-Turbo, GPT-3.5-Turbo, etc.
- **Gemini**: Gemini 1.5 Pro, Gemini 1.5 Flash, etc.
- **Phind**: Phind-Model, Phind-Model-LLama3, etc.

### Otras Configuraciones

- **URL**: Para configurar endpoints de API personalizados (principalmente para OpenAI).
- **Temperatura**: Controla la creatividad de las respuestas (0-1).
- **Top P**: Define la diversidad de respuestas (0-1).
- **Longitud Máxima**: Limita el tamaño de las respuestas.
- **Pre-prompt**: Establece un contexto inicial para todas las consultas.

### Guardar Configuración

Esta opción guarda todos los ajustes en `~/.config/tgpt-gui/config` para que persistan entre sesiones.

## Trucos y Consejos

1. **Configuración Inicial**: Para un uso óptimo, configura primero el proveedor y el modelo que deseas utilizar.
2. **Pre-prompt**: Utiliza esta función para establecer un estilo o contexto para todas tus consultas.
3. **Modo Código**: Ideal para programadores, devuelve respuestas mejor formateadas para código.
4. **API Keys**: Considera utilizar inicialmente proveedores que no requieren API key (phind, pollinations, ollama) si no dispones de claves.

## Solución de Problemas

- **Error "tgpt no está instalado"**: Ejecuta `pip install tgpt` para instalarlo.
- **Error "dialog no está instalado"**: Instálalo con tu gestor de paquetes (ej: `sudo apt install dialog`).
- **API Key inválida**: Verifica que has introducido correctamente la API key en la configuración.
- **Sin respuesta del proveedor**: Algunos proveedores pueden estar temporalmente no disponibles. Prueba con otro proveedor.

## Nota Final

TGPT GUI es una interfaz que simplifica el uso de tgpt, pero todas las consultas y generaciones dependen de los servicios subyacentes de IA. Los límites de uso, la calidad de las respuestas y otras características dependen del proveedor seleccionado.

Para más información sobre tgpt, visita el [repositorio oficial](https://github.com/aandrew-me/tgpt).

---

¡Disfruta utilizando TGPT GUI para acceder al poder de la inteligencia artificial directamente desde tu terminal!
