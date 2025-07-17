#!/usr/bin/env bash

# speech-utils.sh - Text-to-Speech utilities and optimization
#
# This library provides functions for:
# 1. Converting text responses to speech using macOS 'say' command
# 2. Intelligent response summarization for long outputs
# 3. Speech rate and voice configuration
# 4. Interruption handling for long responses
#
# Functions:
#   - process_and_speak_response(): Main entry point for speaking responses
#   - summarize_response(): Intelligently summarize long responses
#   - speak_text(): Low-level TTS wrapper with configuration
#   - is_code_response(): Detect if response contains code
#   - count_response_lines(): Count lines in response
#   - cleanup_for_speech(): Clean text for better TTS output

# Default TTS settings (can be overridden by config)
: ${TTS_VOICE:="Samantha"}
: ${TTS_RATE:="200"}
: ${TTS_VOLUME:="0.7"}
: ${MAX_SPOKEN_LINES:="10"}
: ${SUMMARIZE_THRESHOLD:="50"}
: ${ENABLE_INTERRUPTION:="true"}

# Process and speak a Claude Code response
process_and_speak_response() {
    local response="$1"
    local line_count
    local processed_text
    
    # Count lines in response
    line_count=$(count_response_lines "$response")
    
    # Determine if summarization is needed
    if [[ $line_count -gt $SUMMARIZE_THRESHOLD ]]; then
        # Summarize long responses
        processed_text=$(summarize_response "$response")
        [[ "$VERBOSE" == "true" ]] && echo "📊 Summarized $line_count lines of output"
    else
        # Clean up response for speech
        processed_text=$(cleanup_for_speech "$response")
    fi
    
    # Speak the response
    speak_text "$processed_text"
}

# Summarize long responses intelligently
summarize_response() {
    local response="$1"
    local summary=""
    
    # Check if this is a code response
    if is_code_response "$response"; then
        # Summarize code output
        local language=$(detect_code_language "$response")
        local file_count=$(count_files_in_response "$response")
        
        if [[ $file_count -gt 0 ]]; then
            summary="I've created $file_count files with $language code. "
        else
            summary="I've generated $language code. "
        fi
        
        summary+="Check your editor for the complete implementation."
        
    elif is_error_response "$response"; then
        # Summarize error messages
        local error_msg=$(extract_error_message "$response")
        local solution=$(suggest_error_solution "$error_msg")
        
        summary="Error: $error_msg. $solution"
        
    elif is_explanation_response "$response"; then
        # Extract key points from explanation
        local first_paragraph=$(extract_first_paragraph "$response")
        summary="$first_paragraph. Would you like me to continue with more details?"
        
    else
        # Generic summarization
        local first_lines=$(echo "$response" | head -n "$MAX_SPOKEN_LINES")
        local remaining_lines=$((line_count - MAX_SPOKEN_LINES))
        
        summary="$first_lines... and $remaining_lines more lines. Check your terminal for the complete response."
    fi
    
    echo "$summary"
}

# Speak text using macOS 'say' command
speak_text() {
    local text="$1"
    local say_cmd="say"
    
    # Build say command with options
    [[ -n "$TTS_VOICE" ]] && say_cmd+=" -v $TTS_VOICE"
    [[ -n "$TTS_RATE" ]] && say_cmd+=" -r $TTS_RATE"
    
    # Handle interruption
    if [[ "$ENABLE_INTERRUPTION" == "true" ]]; then
        # Run in background and save PID for potential interruption
        echo "$text" | eval "$say_cmd" &
        local say_pid=$!
        
        # Set up interrupt handler
        trap "kill $say_pid 2>/dev/null; echo '🛑 Speech interrupted'" INT
        
        # Wait for completion
        wait $say_pid
        
        # Remove interrupt handler
        trap - INT
    else
        # Run synchronously
        echo "$text" | eval "$say_cmd"
    fi
}

# Clean up text for better speech synthesis
cleanup_for_speech() {
    local text="$1"
    
    # Replace code-specific symbols with spoken equivalents
    text=$(echo "$text" | sed -E '
        s/`/backtick /g
        s/\$/dollar /g
        s/#/hash /g
        s/\*/asterisk /g
        s/\|/pipe /g
        s/\\/backslash /g
        s/~/tilde /g
        s/\^/caret /g
        s/&/ampersand /g
        s/@/at /g
        s/\[/open bracket /g
        s/\]/close bracket /g
        s/{/open brace /g
        s/}/close brace /g
        s/</less than /g
        s/>/greater than /g
        s/==/equals equals /g
        s/!=/not equals /g
        s/<=/less than or equal to /g
        s/>=/greater than or equal to /g
    ')
    
    # Remove excessive whitespace
    text=$(echo "$text" | tr -s ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    echo "$text"
}

# Detect if response contains code
is_code_response() {
    local response="$1"
    
    # Check for code indicators
    if echo "$response" | grep -qE '```|^\s*(function|class|def|import|const|let|var|public|private)'; then
        return 0
    fi
    
    # Check for file creation messages
    if echo "$response" | grep -qE '(created|generated|saved|wrote).*\.(js|py|sh|ts|jsx|tsx|java|cpp|c|go|rs|rb)'; then
        return 0
    fi
    
    return 1
}

# Detect if response is an error
is_error_response() {
    local response="$1"
    echo "$response" | grep -qiE '^(error|exception|failed|failure):'
}

# Detect if response is an explanation
is_explanation_response() {
    local response="$1"
    local word_count=$(echo "$response" | wc -w)
    
    # Explanations tend to be longer prose without code
    if [[ $word_count -gt 100 ]] && ! is_code_response "$response"; then
        return 0
    fi
    
    return 1
}

# Count lines in response
count_response_lines() {
    local response="$1"
    echo "$response" | wc -l | tr -d ' '
}

# Detect programming language from code
detect_code_language() {
    local response="$1"
    
    # Check for language indicators
    if echo "$response" | grep -qE '\.(js|jsx)"|function.*{|const.*=|let.*=|var.*='; then
        echo "JavaScript"
    elif echo "$response" | grep -qE '\.py"|def.*:|import.*from|class.*:'; then
        echo "Python"
    elif echo "$response" | grep -qE '\.sh"|#!/bin/bash|#!/usr/bin/env bash'; then
        echo "Bash"
    elif echo "$response" | grep -qE '\.(ts|tsx)"|interface.*{|type.*='; then
        echo "TypeScript"
    elif echo "$response" | grep -qE '\.java"|public class|private.*void'; then
        echo "Java"
    elif echo "$response" | grep -qE '\.go"|func.*{|package main'; then
        echo "Go"
    elif echo "$response" | grep -qE '\.rs"|fn.*{|impl.*{|use std'; then
        echo "Rust"
    else
        echo "code"
    fi
}

# Count files mentioned in response
count_files_in_response() {
    local response="$1"
    echo "$response" | grep -cE '(created|generated|saved|wrote).*\.[a-zA-Z]+' || echo "0"
}

# Extract error message
extract_error_message() {
    local response="$1"
    echo "$response" | grep -i "error:" | head -1 | sed 's/^.*error://i' | sed 's/^[[:space:]]*//'
}

# Suggest solution for common errors
suggest_error_solution() {
    local error_msg="$1"
    
    if echo "$error_msg" | grep -qi "command not found"; then
        echo "Check if the command is installed and in your PATH."
    elif echo "$error_msg" | grep -qi "permission denied"; then
        echo "Try running with appropriate permissions or check file ownership."
    elif echo "$error_msg" | grep -qi "no such file"; then
        echo "Verify the file path is correct."
    elif echo "$error_msg" | grep -qi "syntax error"; then
        echo "Review the syntax and fix any typos."
    else
        echo "Check the error details above for more information."
    fi
}

# Extract first paragraph of text
extract_first_paragraph() {
    local response="$1"
    echo "$response" | awk '/^$/{exit} {print}' | tr '\n' ' ' | sed 's/  */ /g'
}