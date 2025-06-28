# Changelog

All notable changes to OMO Dreams will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.3] - 2025-06-28

### Added
- **Enhanced Pattern Chips System**: 
  - Visual chip-based pattern input with remove functionality
  - Real-time pattern suggestions with horizontal scrolling
  - Automatic pattern addition on Enter key press
  - Improved pattern input field with better UX

### Changed
- **Pattern Input Experience**:
  - Moved autocomplete suggestions above pattern chips for better visibility
  - Implemented horizontal wrapping for pattern chips (4 per row)
  - Added immediate scroll-to-view when adding new patterns
  - Enhanced pattern chip layout with proper spacing and organization
- **Dream List Display**:
  - Fixed pattern display in dream list to wrap horizontally instead of vertical stacking
  - Consistent pattern chip styling across list and input views
  - Improved readability with proper row-based layout
- **Input Field Behavior**:
  - Better focus management between description and pattern fields
  - Improved keyboard navigation with up/down buttons
  - Enhanced pattern initialization when editing existing dreams
- **Visual Consistency**:
  - Unified pattern chip design across all views
  - Consistent purple color scheme for patterns
  - Better visual hierarchy in pattern sections

### Fixed
- **Pattern Display Issues**:
  - Resolved vertical stacking of patterns in dream list
  - Fixed pattern chips not showing immediately when editing dreams
  - Corrected pattern parsing consistency across the app
- **User Experience**:
  - Fixed scroll behavior when adding first pattern
  - Resolved pattern chip visibility issues in edit mode
  - Improved pattern input field responsiveness

### Technical
- **Code Improvements**:
  - Added Array extension for chunking patterns into rows
  - Enhanced state management for pattern chips
  - Improved pattern parsing and validation
  - Better ScrollViewReader integration for smooth scrolling

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