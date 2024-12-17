# 🌐 Domain Enumeration Automation Tool

## 🚀 Overview
This comprehensive domain enumeration script automates the process of discovering and mapping subdomains using multiple powerful reconnaissance tools.

## ✨ Features
- Multi-tool domain identification
- Automatic dependency management
- Supports single and multiple domain enumeration
- Multiple output format support (txt, csv, json, xml)
- Detailed logging
- Resume functionality
- Error handling and colorful console output

## 📋 Prerequisites
- Linux environment (Ubuntu recommended)
- Bash shell
- Internet connection
- Basic networking tools

## 🛠 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/backcoc/domain-enum-tool.git
cd domain-enum-tool
```

### 2. Make Script Executable
```bash
chmod +x domain_enum.sh
```

## 🔧 Usage Modes

### Single Domain Enumeration
```bash
./domain_enum.sh target.com
```

### Multiple Domains Enumeration
1. Create a text file (e.g., `domains.txt`) with domains:
```
target1.com
target2.com
target3.com
```

2. Run the script with the domains file:
```bash
./domain_enum.sh -f domains.txt
```

## 📂 Output Structure
- Results stored in `~/domain_enum_logs/`
- Timestamped folders for each enumeration session
- Formats: .txt, .csv, .json, .xml

## 🛡 Supported Tools
- Amass
- Subfinder
- Assetfinder
- HttpX
- Anew

## 💡 Tips
- Ensure stable internet connection during first run
- Script will prompt for dependency installation
- Check logs for detailed enumeration information

## 🔒 Legal Disclaimer
- Use only on domains you have permission to test
- Respect legal and ethical boundaries
- Not responsible for misuse

## 🤝 Contributing
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📜 License
MIT License

## 🐛 Troubleshooting
- Ensure Go is installed (version 1.16+)
- Check internet connectivity
- Verify domain list formatting
- Review log files for specific errors

## 📞 Support
Open an issue on GitHub or contact maintainer for support.
```
