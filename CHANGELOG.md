# Changelog

All notable changes to OMO Dreams will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.2] - 2025-06-26

### Added
- **Tags System**: Implementation of tags for categorizing dreams
- **Tag Autocomplete**: Automatic suggestions based on existing tags
- **Improved User Interface**: 
  - Empty state with motivational message
  - Cleaner and more modern design
  - Enhanced icons and visual elements
- **Edit Functionality**: Ability to edit existing dreams
- **Date Selector**: Graphical interface for selecting dream date
- **Color System**: Consistent purple color scheme

### Changed
- **List Design**: 
  - Removed duplicate date in each item
  - Date aligned to the left with numeric format
  - Dream text in light gray for better readability
- **Navigation**: 
  - Navigation title in inline mode
  - Add icon in purple color
- **Add/Edit Interface**:
  - Improved form with organized sections
  - Required field validation
  - Better user experience

### Technical
- **SwiftData Integration**: Complete use of SwiftData for persistence
- **SwiftUI Best Practices**: Implementation of recommended patterns
- **State Management**: Efficient application state management
- **Code Organization**: Modular and maintainable structure

## [0.0.1] - 2025-06-26

### Added
- **Basic Functionality**: 
  - Create new dreams
  - List existing dreams
  - Delete dreams
- **Data Persistence**: Local storage with SwiftData
- **Basic Interface**: Initial navigation and forms
- **Data Model**: Dream structure with date, text and tags

### Technical
- **Base Project**: Initial SwiftUI project configuration
- **SwiftData Setup**: Data model configuration
- **Basic Navigation**: NavigationView implementation

---

## Development Notes

### Planned Next Features
- Search and filtering of dreams
- Statistics and pattern analysis
- Data export
- Customizable themes
- Notifications to remind users to record dreams

### Technologies Used
- **SwiftUI**: User interface framework
- **SwiftData**: Data persistence
- **iOS 17+**: Target platform

### Architecture
- **MVVM Pattern**: Model-View-ViewModel
- **SwiftData Models**: Dream entity
- **View Composition**: Reusable components 