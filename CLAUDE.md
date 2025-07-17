# CLAUDE.md - Instructions for Claude Code

## Project Overview

You are building **Claude Voice** - a voice-enabled interface for Claude Code CLI that allows developers to speak prompts and hear intelligent responses. This transforms the coding workflow by enabling hands-free interaction with Claude Code directly in the VS Code terminal.

## Project Goal

Create a macOS shell script system that:

1. **Captures voice input** using macOS Speech Recognition
2. **Sends prompts to Claude Code CLI** and processes responses
3. **Speaks responses back** using macOS Text-to-Speech with intelligent summarization
4. **Integrates seamlessly** with VS Code terminal workflow

## Architecture

```
Voice Input → Speech Recognition → Claude Code CLI → Response Processing → Text-to-Speech
```

## Core Components

### Primary Scripts

- `src/bin/claude-voice` - Main entry point and CLI interface
- `src/bin/claude-voice-daemon` - Background process for global hotkey support
- `src/bin/response-processor` - Standalone response analysis tool

### Libraries

- `src/lib/voice-input.applescript` - macOS speech recognition integration
- `src/lib/speech-utils.sh` - Text-to-speech utilities and optimization
- `src/lib/config.sh` - Configuration loading and validation

### Configuration

- `src/config/claude-voice.conf` - Default configuration template
- `~/.config/claude-voice/claude-voice.conf` - User configuration

## Development Phases

### Phase 1: Foundation (Prompts 1-4)

Build the core voice input → Claude Code → basic output pipeline

### Phase 2: Intelligence (Prompts 5-7)

Add response analysis, smart summarization, and quality TTS

### Phase 3: User Experience (Prompts 8-10)

Polish the interface, add configuration, and robust error handling

### Phase 4: Production Ready (Prompts 11-13)

Installation system, background daemon, and comprehensive testing

### Phase 5: Polish (Prompts 14-16)

Documentation, CLI refinement, and final integration

## Technical Requirements

### Platform

- **macOS 10.15+** (required for speech recognition APIs)
- **Bash 5.0+** (install via Homebrew if needed)
- **Claude Code CLI** (must be installed and configured)

### Dependencies

```bash
# Install these via Homebrew
brew install bash coreutils jq
```

### Key Technologies

- **macOS Speech Recognition** - for voice input capture
- **macOS Text-to-Speech** (`say` command) - for audio responses
- **AppleScript** - bridge between shell and macOS speech APIs
- **Bash scripting** - core system implementation
- **Claude Code CLI** - the AI assistant being voice-enabled

## Implementation Guidelines

### Code Quality Standards

- **Follow bash best practices** - proper error handling, quoting, etc.
- **Make scripts executable** - `chmod +x` for all scripts
- **Use proper shebang** - `#!/usr/bin/env bash` for compatibility
- **Comment thoroughly** - especially for complex logic
- **Handle errors gracefully** - never crash unexpectedly

### Voice Processing Principles

- **Keep prompts natural** - users should speak normally
- **Handle speech recognition errors** - provide helpful retry mechanisms
- **Optimize for TTS** - clean up responses for better speech synthesis
- **Smart summarization** - don't speak 100 lines of code verbatim

### User Experience Focus

- **Minimal cognitive load** - simple commands, clear feedback
- **Fast response times** - optimize for interactive use
- **Graceful degradation** - work even with basic speech recognition
- **Professional feel** - polished interface and error messages

## Response Summarization Rules

### Long Code Outputs (>50 lines)

Convert to: "I've created a [language] [type] with [key features]. Check your editor for the complete code."

### File Operations

Convert to: "I've [action] [count] files: [list key files]"

### Error Messages

Keep full error message but add: "Here's how to fix it: [brief solution]"

### Explanations

Speak first few sentences, then: "Would you like me to continue with more details?"

## Configuration System

### Default Settings

```bash
# Voice & TTS
TTS_VOICE="Alex"                    # macOS voice name
TTS_RATE="200"                      # Words per minute
TTS_VOLUME="0.7"                    # Volume level (0.0-1.0)

# Recognition
SPEECH_TIMEOUT="10"                 # Seconds to wait for speech
MIN_CONFIDENCE="0.7"                # Recognition confidence threshold

# Response Processing
MAX_SPOKEN_LINES="10"               # Lines before summarization
SUMMARIZE_THRESHOLD="50"            # Line count trigger for summaries
ENABLE_INTERRUPTION="true"          # Allow Ctrl+C to stop TTS

# Interface
GLOBAL_HOTKEY="cmd+shift+space"     # Activation key combination
SHOW_PROGRESS="true"                # Display processing indicators
```

### Configuration Loading Priority

1. Command line arguments
2. User config (`~/.config/claude-voice/claude-voice.conf`)
3. Default config (`src/config/claude-voice.conf`)
4. Built-in defaults

## Error Handling Strategy

### Common Error Scenarios

- **Speech recognition timeout** - "Didn't catch that, press SPACE to try again"
- **Claude Code not found** - "Claude Code CLI not installed. Please install first."
- **Audio device issues** - "No microphone detected. Check audio settings."
- **Network timeouts** - "Claude Code is taking longer than usual. Try again."

### Recovery Mechanisms

- **Automatic retries** for transient failures
- **Graceful fallbacks** when features unavailable
- **Helpful error messages** that suggest solutions
- **Diagnostic mode** for troubleshooting system issues

## Testing Strategy

### Manual Testing Checklist

- [ ] Voice recognition works with various accents/speech patterns
- [ ] Claude Code integration handles different prompt types
- [ ] Response summarization works for different output types
- [ ] TTS is clear and natural sounding
- [ ] Error handling provides helpful guidance
- [ ] Configuration changes take effect properly

### Automated Testing

- **Unit tests** for core functions (response processing, config loading)
- **Integration tests** for complete voice → Claude Code → TTS flow
- **Mock responses** for consistent testing without API calls
- **Performance benchmarks** for response time validation

## File Naming Conventions

### Executables

- `claude-voice` - Main user-facing command
- `claude-voice-daemon` - Background process
- `response-processor` - Standalone utility

### Libraries

- `*.sh` - Bash libraries (sourced, not executed)
- `*.applescript` - AppleScript files for macOS integration

### Configuration

- `*.conf` - Configuration files with bash-compatible syntax

## CLI Interface Standards

### Argument Parsing

```bash
# Support standard patterns
claude-voice --help                 # Show usage help
claude-voice --version              # Show version info
claude-voice --verbose              # Enable detailed output
claude-voice --quiet                # Minimal output
claude-voice "direct prompt"        # Direct prompt mode
claude-voice                        # Interactive mode
```

### Exit Codes

- `0` - Success
- `1` - General error
- `2` - Configuration error
- `3` - Dependency missing
- `124` - Timeout error

## Security Considerations

### Voice Data

- **Process locally** when possible (use macOS APIs, not cloud services)
- **No persistent storage** of voice recordings
- **Respect user privacy** settings and permissions

### File System

- **Proper permissions** on configuration files (600)
- **Safe temporary file handling** with cleanup
- **Validate user input** before file operations

## Integration Points

### VS Code Terminal

- **Detect VS Code environment** using `$VSCODE_PID`
- **Respect VS Code workspace** context when available
- **Work with integrated terminal** seamlessly

### Claude Code CLI

- **Use existing authentication** and configuration
- **Preserve file context** from current directory
- **Handle Claude Code updates** gracefully

## Success Metrics

### Functionality

- Voice recognition accuracy >90% for clear speech
- Claude Code integration success rate >95%
- End-to-end response time <30 seconds average

### User Experience

- Intuitive voice commands that feel natural
- Clear audio responses that are easy to understand
- Robust error handling that helps users succeed

### Performance

- Minimal resource usage when idle
- Fast startup time (<2 seconds)
- Responsive voice activation (<1 second delay)

## Development Notes

### When Working on This Project

1. **Test frequently** - voice interfaces need lots of real-world testing
2. **Keep backups** - voice recognition can be finicky during development
3. **Use version control** - commit working states before major changes
4. **Document discoveries** - note what works well for voice recognition
5. **Think about edge cases** - background noise, different accents, etc.

### Common Pitfalls to Avoid

- **Don't make TTS too fast** - users need time to process spoken code explanations
- **Don't ignore audio device changes** - handle microphone switching gracefully
- **Don't assume perfect speech recognition** - always provide recovery options
- **Don't speak code syntax literally** - "backtick" instead of "`"

## Final Goal

Create a production-ready voice interface that makes Claude Code dramatically more accessible and productive for developers. The end result should feel magical - speak naturally about your coding needs and hear intelligent, helpful responses that keep you in the flow state.

---

**Remember**: You're building a tool that will transform how developers interact with AI. Focus on making it feel natural, reliable, and genuinely useful in real coding workflows.
