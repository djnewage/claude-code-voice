# claude-code-voice

# Claude Voice 🎤

> Voice interface for Claude Code CLI - speak your prompts and hear intelligent responses

Transform your coding workflow with hands-free Claude Code interactions. Speak naturally to Claude Code and receive spoken responses with smart summarization for long outputs.

## ✨ Features

- 🎤 **Natural Voice Input** - Speak your Claude Code prompts naturally
- 🔊 **Intelligent Audio Responses** - Hear responses with smart summarization
- 🖥️ **VS Code Integration** - Works seamlessly in VS Code terminal
- ⚡ **Background Daemon** - Global hotkey activation from anywhere
- 🛠️ **Smart Processing** - Automatically summarizes long code outputs
- 🎛️ **Customizable** - Configurable voice, speed, and response settings

## 🚀 Quick Start

### Prerequisites

- macOS 10.15+ (for speech recognition)
- [Claude Code CLI](https://claude.ai) installed and configured
- VS Code (recommended) or any terminal

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/claude-voice.git
cd claude-voice

# Run the installer
./install.sh

# Verify installation
claude-voice --version
```

### Basic Usage

```bash
# Interactive mode - press SPACE to speak
claude-voice

# Direct prompt
claude-voice "Create a React component for user authentication"

# With background daemon (global hotkey)
claude-voice-daemon start
# Now use Cmd+Shift+Space in any terminal
```

## 📖 Documentation

- [User Guide](docs/user-guide.md) - Complete usage instructions
- [Development Guide](docs/development-guide.md) - Technical implementation details
- [Troubleshooting](docs/troubleshooting.md) - Common issues and solutions
- [Examples](examples/) - Sample prompts and use cases

## 🎯 Use Cases

- **Hands-free Coding** - Code while walking or away from keyboard
- **Accessibility** - Voice-driven development for physical limitations
- **Flow State** - Reduce context switching during complex implementations
- **Code Review** - Verbal discussions with AI about your code
- **Learning** - Hear explanations while reading unfamiliar code

## 🔧 Configuration

Customize your voice experience:

```bash
# Edit configuration
vim ~/.config/claude-voice/claude-voice.conf
```

Available settings:

- `TTS_VOICE="Alex"` - macOS voice selection
- `TTS_RATE="200"` - Words per minute
- `SUMMARIZE_THRESHOLD="50"` - Lines before summarization kicks in
- `GLOBAL_HOTKEY="cmd+shift+space"` - Activation key combination

## 🛠️ Development Status

### Current Features

- [x] Core voice input/output
- [x] Claude Code CLI integration
- [x] Response summarization
- [ ] Background daemon
- [ ] Global hotkey support
- [ ] VS Code extension

### Contributing

We welcome contributions! Please see our [Contributing Guide](docs/contributing.md).

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Local Development

```bash
# Clone and setup
git clone https://github.com/yourusername/claude-voice.git
cd claude-voice

# Install development dependencies
brew install bash coreutils jq

# Run tests
./tests/run-tests.sh

# Install locally for testing
./install.sh --dev
```

## 📝 Examples

### Basic Code Generation

```
🎤 "Create a Python function to validate email addresses"
🔊 "I've created a Python email validation function using regex with comprehensive
    checking for valid email formats. The function is saved as email_validator.py"
```

### Code Explanation

```
🎤 "Explain how this sorting algorithm works"
🔊 "This implements quicksort, a divide-and-conquer algorithm. It selects a pivot
    element, partitions the array around it, then recursively sorts the subarrays..."
```

### File Operations

```
🎤 "Set up a new React project with TypeScript and testing"
🔊 "I've created a React TypeScript project with 8 files including components,
    tests, and configuration. Check your editor for the complete project structure."
```

## 🔊 Voice Response Types

The system intelligently handles different types of Claude Code responses:

- **Short Responses** - Read in full for maximum clarity
- **Long Code Outputs** - Summarized with key features and file locations
- **File Operations** - Lists created/modified files with brief descriptions
- **Error Messages** - Full error message plus brief solution hints
- **Explanations** - Key concepts with option to hear more details

## 🎙️ Voice Commands

### Common Patterns

- `"Create a [language] [type] for [purpose]"`
- `"Explain this [code/function/algorithm]"`
- `"Debug the [problem] in [file]"`
- `"Optimize this [code/query] for [performance/readability]"`
- `"Convert this from [language] to [language]"`

### Project Management

- `"What files did I work on today?"`
- `"Show me the TODO comments in this project"`
- `"Generate tests for [component/function]"`

## 🔧 Technical Details

### Architecture

- **Voice Input**: macOS Speech Recognition API
- **Processing**: Direct Claude Code CLI integration
- **Output**: macOS Text-to-Speech with intelligent summarization
- **Integration**: Shell scripts with VS Code terminal support

### System Requirements

- macOS 10.15 or later
- Microphone access permissions
- Claude Code CLI properly configured
- Terminal or VS Code with integrated terminal

## 🤝 Support

- 📖 [Documentation](docs/)
- 🐛 [Issue Tracker](https://github.com/djnewage/claude-voice/issues)
- 💬 [Discussions](https://github.com/djnewage/claude-voice/discussions)

## 📄 License

MIT License
