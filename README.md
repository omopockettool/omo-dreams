# OMO Dreams

A beautiful and intuitive dream journal app built with SwiftUI and SwiftData, designed to help users track, categorize, and analyze their dreams for lucid dreaming development.

## 🌙 Features

- **Dream Journaling**: Record and organize your dreams with rich text descriptions
- **Lucid Dream Toggle**: Mark each dream as lucid or not with a simple switch
- **Smart Pattern Recognition**: Categorize dreams with custom patterns and autocomplete suggestions
- **Pattern Categories**: Organize patterns by type (action, place, character, object, emotion, color, sound)
- **Recognition Clues**: Mark patterns as recognition clues for lucid dreaming
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
│   ├── Dream.swift                # Dream data model
│   ├── DreamPattern.swift         # Dream-Pattern relationship model
│   ├── Pattern.swift              # Pattern data model
│   └── Assets.xcassets/           # App assets
├── OMO DreamsTests/
│   └── DreamTests.swift           # Unit tests
└── OMO DreamsUITests/             # UI tests
```

## 🗄️ Data Model

The app uses a relational data structure with three main entities:

### Dream Entity
- `id`: Unique identifier (UUID)
- `dream_date`: Date of the dream
- `dream_text`: Description of the dream
- `isLucid`: Boolean indicating if it was a lucid dream
- `dreamPatterns`: Relationship to DreamPattern entities

### Pattern Entity
- `label`: Unique pattern name (e.g., "flying", "river")
- `category`: Pattern category (action, place, character, object, emotion, color, sound, other)
- `dreamPatterns`: Relationship to DreamPattern entities

### DreamPattern Entity (Junction Table)
- `dreamId`: Reference to the dream
- `isRecognitionClue`: Boolean indicating if this pattern is a recognition clue
- `pattern`: Relationship to Pattern entity
- `dream`: Relationship to Dream entity

### Pattern Categories
- **Action**: Physical activities (flying, running, swimming)
- **Place**: Locations (river, house, forest)
- **Character**: People or beings (brother, stranger, animal)
- **Object**: Items or things (car, book, phone)
- **Emotion**: Feelings (fear, joy, anxiety)
- **Color**: Visual elements (red, blue, bright)
- **Sound**: Auditory elements (music, voices, silence)
- **Other**: Miscellaneous patterns

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
The app uses SwiftData for local data persistence with three main models:
- `Dream`: Core dream data with lucid tracking
- `Pattern`: Reusable pattern definitions with categories
- `DreamPattern`: Junction table for dream-pattern relationships

### Bundle Identifier
- **Bundle ID**: `com.omo.OMO-Dreams`
- **Team**: Configured for Apple Developer distribution

### Color Scheme
- **Primary**: Purple (#8B5CF6)
- **Pattern Colors**: Category-based colors for easy identification
  - Action: Blue
  - Place: Green
  - Character: Orange
  - Object: Purple
  - Emotion: Red
  - Color: Pink
  - Sound: Indigo
- **Text**: System Gray for readability
- **Background**: System background colors

## 📈 Roadmap

### Version 0.2.0 (Current)
- [x] New data structure with separate entities
- [x] Lucid dream toggle for each dream
- [x] Pattern categorization
- [x] Recognition clue marking
- [x] Enhanced UI with category colors

### Version 0.3.0 (Next Release)
- [ ] Search and filtering functionality
- [ ] Dream statistics and analytics
- [ ] Pattern frequency analysis
- [ ] Export functionality
- [ ] Custom themes

### Future Features
- [ ] Cloud sync
- [ ] Advanced dream pattern analysis
- [ ] Lucid dreaming techniques guide
- [ ] Notifications and reminders
- [ ] Social features
- [ ] Dream sharing

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