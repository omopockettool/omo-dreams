# Changelog

All notable changes to OMO Dreams will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-07-04

### Added
- **Pattern Category Management System**:
  - Long press gesture on pattern chips to open category editor
  - CategoryEditorSheet with bottom sheet presentation for easy category changes
  - Visual category indicators with color-coded circles and checkmarks
  - Support for 8 different pattern categories: action, place, character, object, emotion, color, sound, other
- **Advanced Pattern Administration**:
  - PatternManagementSheet accessible via gear icon for comprehensive pattern control
  - Patterns grouped by category with usage counts and color-coded headers
  - Individual pattern deletion with confirmation dialogs for patterns in use
  - Bulk cleanup functionality for orphaned/unused patterns
  - Real-time pattern usage analytics showing "Apariciones: X" for each pattern
- **Lucid Dream System**:
  - Dedicated toggle for marking lucid dreams with eye icon
  - Recognition clue system for patterns to help identify dream states
  - Visual indicators in dream list for lucid dreams
- **Debug and Management Tools**:
  - Comprehensive database inspection via info icon button
  - Detailed logging of dreams, patterns, dream patterns, and orphaned data
  - Automatic detection and cleanup of data inconsistencies
  - Statistics display showing total patterns, categories, and unused patterns

### Changed
- **Enhanced User Interface**:
  - Unified gray color scheme for better visual hierarchy (eye icon, calendar, section titles)
  - Maintained purple accent color only for primary actions (Cancelar/Guardar buttons)
  - Removed "(cambiar)" text from date button for cleaner appearance
  - Improved navigation bar title with consistent gray color that doesn't change on scroll
- **Improved Dream List Interaction**:
  - Full row tappable areas with ZStack implementation for better touch targets
  - Enhanced visual separation with gray background (Color(.systemGray6))
  - Better tap detection using .onTapGesture instead of Button wrapper
  - Smooth animations for dream additions and deletions
- **Pattern Input Experience**:
  - Increased vertical spacing between pattern input field and selected chips
  - Better visual organization with .padding(.top, 16).padding(.bottom, 8)
  - Enhanced pattern chip layout with proper row-based wrapping
- **Data Management**:
  - Robust SwiftData context handling to prevent "store went missing" errors
  - Separated database operations from animations for better stability
  - Explicit save operations with proper sequencing in updateDream() function
  - Safer pattern handling with existence verification before insertion

### Fixed
- **Critical Bug Resolutions**:
  - Resolved pattern duplication issues when editing dreams
  - Fixed pattern category update problems for new patterns before saving
  - Eliminated SwiftData context errors through improved object reference management
  - Corrected pattern persistence inconsistencies in database operations
- **User Experience Issues**:
  - Fixed navigation bar title color changes during scroll
  - Resolved pattern chip visibility and updating problems
  - Improved pattern selection state management
  - Enhanced dream row touch responsiveness across entire row area

### Technical
- **Architecture Improvements**:
  - PatternSelection struct for better UI state management with Identifiable and Equatable conformance
  - Enhanced SwiftData model relationships between Dream, Pattern, and DreamPattern
  - Improved error handling and context management for all database operations
  - Better separation of concerns between UI animations and data persistence
- **Code Quality**:
  - Comprehensive debug logging system for troubleshooting
  - Safer pattern object handling with reference maintenance
  - Enhanced state synchronization between UI and database
  - Modular pattern management with reusable components

### Security & Stability
- **Data Integrity**:
  - Automatic detection and cleanup of orphaned patterns
  - Verification logic to prevent duplicate pattern insertion
  - Robust error handling for all database transactions
  - Safe pattern deletion with usage validation

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