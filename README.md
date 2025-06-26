# OMO Dreams

A beautiful and intuitive dream journal app built with SwiftUI and SwiftData, designed to help users track, categorize, and analyze their dreams for lucid dreaming development.

## 🌙 Features

- **Dream Journaling**: Record and organize your dreams with rich text descriptions
- **Smart Tagging**: Categorize dreams with custom tags and autocomplete suggestions
- **Date Tracking**: Keep track of when each dream occurred
- **Clean Interface**: Modern, intuitive design optimized for iOS
- **Data Persistence**: Secure local storage using SwiftData
- **Edit & Delete**: Full CRUD operations for dream management

## 📱 Screenshots

*Screenshots will be added here*

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 17.0+
- macOS 14.0+ (for development)

### Installation

1. Clone the repository
```bash
git clone https://github.com/omoconcept/omo-dreams.git
cd omo-dreams
```

2. Open the project in Xcode
```bash
open "OMO Dreams.xcodeproj"
```

3. Build and run the project
- Select your target device or simulator
- Press `Cmd + R` to build and run

## 🏗️ Architecture

- **Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Pattern**: MVVM (Model-View-ViewModel)
- **Minimum iOS Version**: 17.0

### Project Structure

```
OMO Dreams/
├── OMO Dreams/
│   ├── ContentView.swift          # Main app interface
│   ├── OMO_DreamsApp.swift        # App entry point
│   ├── Item.swift                 # Dream data model
│   └── Assets.xcassets/           # App assets
├── OMO DreamsTests/
│   └── DreamTests.swift           # Unit tests
└── OMO DreamsUITests/             # UI tests
```

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
xcodebuild test -scheme "OMO Dreams" -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test file
xcodebuild test -scheme "OMO Dreams" -only-testing:OMODreamsTests/DreamTests
```

## 📦 Build & Deploy

### Development Build
```bash
xcodebuild build -scheme "OMO Dreams" -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Archive for App Store
```bash
xcodebuild archive -scheme "OMO Dreams" -archivePath build/OMO_Dreams.xcarchive
```

## 🔧 Configuration

### SwiftData Model
The app uses SwiftData for local data persistence. The `Dream` model includes:
- `dream_date`: Date of the dream
- `dream_text`: Description of the dream
- `dream_tags`: Comma-separated tags for categorization

### Color Scheme
- **Primary**: Purple (#8B5CF6)
- **Text**: System Gray for readability
- **Background**: System background colors

## 📈 Roadmap

### Version 0.1.0 (Next Release)
- [ ] Search and filtering functionality
- [ ] Dream statistics and analytics
- [ ] Export functionality
- [ ] Custom themes

### Future Features
- [ ] Cloud sync
- [ ] Dream pattern analysis
- [ ] Lucid dreaming techniques
- [ ] Notifications and reminders
- [ ] Social features

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Development

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Maintain consistent naming conventions
- Add comments for complex logic

### Git Workflow
- Use conventional commits
- Create feature branches for new functionality
- Write descriptive commit messages
- Keep commits atomic and focused

## 📞 Support

- **Email**: omopockettool@gmail.com
- **Issues**: [GitHub Issues](https://github.com/omoconcept/omo-dreams/issues)
- **Documentation**: [Wiki](https://github.com/omoconcept/omo-dreams/wiki)

## 🙏 Acknowledgments

- Built with ❤️ using SwiftUI and SwiftData
- Inspired by the lucid dreaming community
- Thanks to all contributors and beta testers

---

**OMO Dreams** - Your journey to lucid dreaming starts here 🌙 