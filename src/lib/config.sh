#!/usr/bin/env bash

# config.sh - Configuration loading and validation
#
# This library handles:
# 1. Loading configuration from multiple sources (defaults, system, user)
# 2. Validating configuration values
# 3. Merging configuration with command-line overrides
# 4. Creating default configuration files for new users
#
# Configuration precedence (highest to lowest):
# 1. Command line arguments
# 2. Environment variables (CLAUDE_VOICE_*)
# 3. User config file (~/.config/claude-voice/claude-voice.conf)
# 4. System config file (/etc/claude-voice/claude-voice.conf)
# 5. Default config file (src/config/claude-voice.conf)
# 6. Built-in defaults

# Get the project root directory
readonly CONFIG_PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Configuration file paths
readonly DEFAULT_CONFIG="$CONFIG_PROJECT_ROOT/src/config/claude-voice.conf"
readonly SYSTEM_CONFIG="/etc/claude-voice/claude-voice.conf"
readonly USER_CONFIG_DIR="$HOME/.config/claude-voice"
readonly USER_CONFIG="$USER_CONFIG_DIR/claude-voice.conf"

# Load configuration from all sources
load_config() {
    # Start with built-in defaults
    set_builtin_defaults
    
    # Load configuration files in order of precedence
    [[ -f "$DEFAULT_CONFIG" ]] && source "$DEFAULT_CONFIG"
    [[ -f "$SYSTEM_CONFIG" ]] && source "$SYSTEM_CONFIG"
    [[ -f "$USER_CONFIG" ]] && source "$USER_CONFIG"
    
    # Override with environment variables
    load_env_overrides
    
    # Override with any command-line specified config file
    [[ -n "${CONFIG_FILE:-}" && -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
    
    # Validate configuration
    validate_config
    
    # Create necessary directories
    setup_directories
}

# Set built-in defaults (fallback values)
set_builtin_defaults() {
    # Voice & TTS
    : ${TTS_VOICE:="Samantha"}
    : ${TTS_RATE:="200"}
    : ${TTS_VOLUME:="0.7"}
    
    # Recognition
    : ${SPEECH_TIMEOUT:="10"}
    : ${MIN_CONFIDENCE:="0.7"}
    
    # Response Processing
    : ${MAX_SPOKEN_LINES:="10"}
    : ${SUMMARIZE_THRESHOLD:="50"}
    : ${ENABLE_INTERRUPTION:="true"}
    
    # Interface
    : ${GLOBAL_HOTKEY:="cmd+shift+space"}
    : ${SHOW_PROGRESS:="true"}
    : ${VERBOSE:="false"}
    : ${QUIET:="false"}
    
    # Claude Code Integration
    : ${CLAUDE_TIMEOUT:="30"}
    : ${CLAUDE_EXTRA_FLAGS:=""}
    
    # System
    : ${TEMP_DIR:="${TMPDIR:-/tmp}/claude-voice"}
    : ${LOG_FILE:="$USER_CONFIG_DIR/claude-voice.log"}
    : ${MAX_LOG_SIZE:="1024"}
    
    # Experimental
    : ${CONTINUOUS_MODE:="false"}
    : ${AUTO_CORRECT:="false"}
    : ${ENHANCED_RECOGNITION:="false"}
}

# Load environment variable overrides
load_env_overrides() {
    # Check for CLAUDE_VOICE_* environment variables
    local var_name
    local config_key
    
    for var_name in "${!CLAUDE_VOICE_@}"; do
        # Convert CLAUDE_VOICE_TTS_RATE to TTS_RATE
        config_key="${var_name#CLAUDE_VOICE_}"
        export "$config_key"="${!var_name}"
    done
}

# Validate configuration values
validate_config() {
    local errors=()
    
    # Validate TTS_RATE (90-720)
    if [[ ! "$TTS_RATE" =~ ^[0-9]+$ ]] || (( TTS_RATE < 90 || TTS_RATE > 720 )); then
        errors+=("TTS_RATE must be between 90 and 720 (current: $TTS_RATE)")
    fi
    
    # Validate TTS_VOLUME (0.0-1.0)
    if [[ ! "$TTS_VOLUME" =~ ^0*\.[0-9]+$|^1\.0*$|^[01]$ ]]; then
        errors+=("TTS_VOLUME must be between 0.0 and 1.0 (current: $TTS_VOLUME)")
    fi
    
    # Validate boolean values
    for var in ENABLE_INTERRUPTION SHOW_PROGRESS VERBOSE QUIET CONTINUOUS_MODE AUTO_CORRECT ENHANCED_RECOGNITION; do
        if [[ "${!var}" != "true" && "${!var}" != "false" ]]; then
            errors+=("$var must be 'true' or 'false' (current: ${!var})")
        fi
    done
    
    # Validate numeric values
    for var in SPEECH_TIMEOUT MAX_SPOKEN_LINES SUMMARIZE_THRESHOLD CLAUDE_TIMEOUT MAX_LOG_SIZE; do
        if [[ ! "${!var}" =~ ^[0-9]+$ ]]; then
            errors+=("$var must be a positive integer (current: ${!var})")
        fi
    done
    
    # Check for conflicting options
    if [[ "$VERBOSE" == "true" && "$QUIET" == "true" ]]; then
        errors+=("Cannot enable both VERBOSE and QUIET modes")
    fi
    
    # Report errors
    if [[ ${#errors[@]} -gt 0 ]]; then
        echo "Configuration errors:" >&2
        printf '%s\n' "${errors[@]}" >&2
        return 1
    fi
    
    return 0
}

# Create necessary directories
setup_directories() {
    # Create user config directory if it doesn't exist
    if [[ ! -d "$USER_CONFIG_DIR" ]]; then
        mkdir -p "$USER_CONFIG_DIR" || {
            echo "Warning: Could not create config directory: $USER_CONFIG_DIR" >&2
        }
    fi
    
    # Create temp directory if it doesn't exist
    if [[ ! -d "$TEMP_DIR" ]]; then
        mkdir -p "$TEMP_DIR" || {
            echo "Warning: Could not create temp directory: $TEMP_DIR" >&2
        }
    fi
}

# Create default user configuration file
create_default_user_config() {
    if [[ -f "$USER_CONFIG" ]]; then
        echo "User config already exists: $USER_CONFIG"
        return 0
    fi
    
    # Create config directory
    mkdir -p "$USER_CONFIG_DIR"
    
    # Copy default config with personalization hints
    cat > "$USER_CONFIG" << 'EOF'
# Claude Voice - User Configuration
#
# This is your personal configuration file for Claude Voice.
# Uncomment and modify any settings you want to change.
# Default values are shown in comments.

# ============================================================
# Voice & Text-to-Speech Settings
# ============================================================

# Choose your preferred voice (run 'say -v ?' to see options)
# TTS_VOICE="Alex"

# Adjust speech speed to your preference
# TTS_RATE="200"

# Set volume level
# TTS_VOLUME="0.7"

# ============================================================
# Behavior Settings
# ============================================================

# Increase timeout if you need more time to think
# SPEECH_TIMEOUT="10"

# Adjust summarization thresholds
# MAX_SPOKEN_LINES="10"
# SUMMARIZE_THRESHOLD="50"

# ============================================================
# Your Custom Settings
# ============================================================

# Add any custom settings below:

EOF
    
    echo "Created user configuration file: $USER_CONFIG"
    echo "Edit this file to customize your Claude Voice experience."
}

# Display current configuration (for debugging)
show_config() {
    echo "Current Claude Voice Configuration:"
    echo "==================================="
    echo "TTS_VOICE: $TTS_VOICE"
    echo "TTS_RATE: $TTS_RATE"
    echo "TTS_VOLUME: $TTS_VOLUME"
    echo "SPEECH_TIMEOUT: $SPEECH_TIMEOUT"
    echo "MAX_SPOKEN_LINES: $MAX_SPOKEN_LINES"
    echo "SUMMARIZE_THRESHOLD: $SUMMARIZE_THRESHOLD"
    echo "SHOW_PROGRESS: $SHOW_PROGRESS"
    echo "VERBOSE: $VERBOSE"
    echo "Config files loaded:"
    [[ -f "$DEFAULT_CONFIG" ]] && echo "  - $DEFAULT_CONFIG"
    [[ -f "$SYSTEM_CONFIG" ]] && echo "  - $SYSTEM_CONFIG"
    [[ -f "$USER_CONFIG" ]] && echo "  - $USER_CONFIG"
    [[ -n "${CONFIG_FILE:-}" && -f "$CONFIG_FILE" ]] && echo "  - $CONFIG_FILE"
}