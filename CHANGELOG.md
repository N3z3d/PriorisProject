# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Enhanced cache service with LRU/LFU strategies and compression
- Focus management service for improved accessibility
- Animation lifecycle mixin for better performance
- Glassmorphism UI effects with fluid animations
- Micro-interactions system for better UX
- Elevation system with multi-layer shadows
- Paginated repository pattern for efficient data loading
- Error handling service with categorized errors
- Quick add dialog for simplified task creation

### Changed
- Simplified navigation from 6 to 4 tabs
- Separated Habits and Insights into distinct tabs
- Improved ELO scoring system with immutable updates
- Replaced GestureDetector with InkWell for keyboard accessibility
- Optimized DuelPage performance by removing didChangeDependencies

### Fixed
- Critical ELO score update issue in ListItem
- Performance issues on Prioriser page
- Compilation errors in multiple services
- Import placement issues in animation files
- Nested class declarations causing build failures
- Animation controller lifecycle management

### Security
- Added proper error handling and validation
- Implemented secure cache strategies

## [0.1.0] - 2024-01-01

### Added
- Initial release of Prioris Project
- Core task management functionality
- ELO-based prioritization system
- Habit tracking features
- Insights and analytics
- Custom list management
- Duel system for task comparison