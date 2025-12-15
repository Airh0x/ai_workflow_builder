# AI Workflow Builder

Universal AI Image Analysis & Data Processing Workflow Builder

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📖 Overview

AI Workflow Builder is a universal Flutter application that enables customizable workflows for image analysis and data processing using Google Gemini API.

### Development Background

This project was originally developed to solve a practical problem: managing passenger rosters for island departures and returns. The need to automate manual roster management and information extraction from images led to the implementation of an AI-powered solution.

After generalization, it can now be applied to various use cases:

- 📋 **Roster Management**: Participant lists, attendance management, membership management, etc.
- 📊 **Data Extraction**: Information extraction from images, OCR processing, form reading, etc.
- 🏷️ **Classification & Filtering**: Automatic classification based on conditions, category-based management, etc.
- 📝 **Report Generation**: Customizable format report creation
- 🔔 **Notification Integration**: Automatic notifications to LINE, Slack, email, etc.

### Use Cases

**Ship Roster Management (Original Use Case)**
- Managing passenger rosters for island departures and returns
- Extracting passenger information from images
- Cross-referencing with master rosters
- Automatic calculation of meeting times and locations
- Automatic notifications to LINE groups

**Other Applications**
- Event participant management
- Shipping and delivery management
- Inventory management
- Survey aggregation
- Form processing

### ✨ Key Features

- 🤖 **AI Image Analysis**: High-precision image analysis using Gemini API
- 🔄 **Workflow Management**: Define, save, and switch between multiple workflows
- 📝 **Prompt Templates**: Customizable prompt template management
- 🏷️ **Category Management**: Flexible category definition and filtering
- 📊 **Output Formats**: Support for Markdown, JSON, CSV, and custom templates
- 📱 **Cross-Platform**: iOS, Android, and Web support
- 🔔 **LINE Notifications**: Result notifications via LINE Messaging API

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Google Gemini API key
- (Optional) LINE Messaging API configuration

### Installation

1. **Clone the repository**

```bash
git clone <repository-url>
cd ai_workflow_builder
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure environment variables**

Create a `.env` file in the project root:

```env
# Required: Gemini API key
GEMINI_API_KEY=your_gemini_api_key_here

# Optional: Roster API (Google Sheets integration, etc.)
ROSTER_API_URL=your_roster_api_url_here
ROSTER_API_KEY=your_roster_api_key_here

# Optional: LINE Messaging API
LINE_CHANNEL_ID=your_line_channel_id
LINE_CHANNEL_SECRET=your_line_channel_secret
LINE_CHANNEL_ACCESS_TOKEN=your_line_access_token
LINE_GROUP_ID=your_line_group_id
```

4. **Generate environment variable files**

```bash
dart run build_runner build --delete-conflicting-outputs
```

5. **Run the app**

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web
flutter run -d chrome
```

## 📱 User Guide

### Basic Features

The app consists of three main tabs:

1. **Ship Roster Management**: Analyzes images to generate passenger lists
   - Use case: Managing passenger rosters for island departures and returns, automatic meeting time calculation
   - General use: Participant management, attendance management, membership management, etc.

2. **Boarding Pass Reader**: Reads handwritten applications and generates reports
   - Use case: Automatic reading of handwritten applications, report generation
   - General use: Form processing, OCR, form reading, etc.

3. **Workflow Management**: Manage and customize workflows
   - Create and edit workflows
   - Manage prompt templates
   - Configure categories and output formats

### 1. Ship Roster Management Usage

> **💡 Use Case**: Managing passenger rosters for island departures and returns  
> This feature was developed for managing passenger rosters but can be applied to various uses such as participant management and attendance tracking.

#### Step 1: Select Images

1. Open the "Ship Roster Management" tab
2. Tap the "Select Screenshots" button
3. Select one or more images to analyze
4. Selected images will be displayed in the preview

#### Step 2: Configure Roster

**Using Offline Roster:**

1. Select "Offline Roster"
2. Select an existing roster from "Roster Management" or create a new one
3. Enter and edit roster content

**Fetching from Google Sheets:**

1. Select "Google Sheets"
2. Enter the sheet name
3. Fetch roster data from the API

#### Step 3: Pre-exclusion/Addition Settings (Optional)

1. Expand the "Pre-exclusion Settings" section
2. Set exclusion lists for **Islanders** or **Returnees**
3. Set addition lists in the "Pre-addition Settings" section
4. Select from roster or enter manually

#### Step 4: Generate List

1. Tap the "Generate List" button
2. AI analyzes images and cross-references with the roster
3. Results are displayed

#### Step 5: Review and Edit Results

1. Review the generated results
2. Edit if necessary using the "Edit" button
3. Copy to clipboard with "Copy"
4. Share with other apps using "Share"

#### Step 6: Send to LINE (Optional)

1. Tap the "Send to LINE" button
2. If LINE Messaging API is configured, it will be sent automatically

### 2. Boarding Pass Reader Usage

> **💡 Use Case**: Reading handwritten applications  
> This feature was developed to read handwritten boarding applications but can be applied to various forms and documents.

#### Step 1: Capture or Select Image

1. Open the "Boarding Pass Reader" tab
2. Tap "Capture with Camera" or "Select Image"
3. Capture or select a handwritten application

#### Step 2: Execute Analysis

1. Tap the "Execute Analysis" button
2. AI reads the application and generates a report

#### Step 3: Review and Edit Results

1. Review the generated report
2. Edit if necessary
3. Copy or share

### 3. Settings Usage

#### Gemini Model Selection

1. Open the settings screen
2. Select "Gemini Model"
3. Choose the model to use:
   - `gemini-2.5-pro`: Standard model
   - `gemini-3-pro-preview`: Latest preview model

#### Prompt Customization

1. Open "Prompt Settings" in the settings screen
2. Edit "Ship Roster Prompt" or "Boarding Pass Prompt"
3. Use placeholders:
   - `%@`: Master roster (ship roster management only)
   - `{SHEET_NAME}`: Sheet name (ship roster management only)
   - `%@`: Date (boarding pass only)

## 🔧 Advanced Usage

### Creating Workflows (Generalization Feature)

> **💡 About Generalization**  
> Originally developed for ship roster management, the workflow feature now allows customization for various purposes.  
> You can customize prompt templates, categories, and output formats to suit your needs.

#### 1. Creating Prompt Templates

```dart
// Code example (executed from actual UI)
final template = PromptTemplate(
  id: 'my-template',
  name: 'My Template',
  description: 'Custom prompt template',
  content: '''
You are an image analysis assistant.
Please analyze the following images.

Master Roster:
{MASTER_ROSTER}

Categories:
- Category A: {CONDITION_A}
- Category B: {CONDITION_B}
''',
);
```

**Placeholder Formats:**

- `{PLACEHOLDER_NAME}`: Named placeholder (auto-detected)
- `%@`: Special placeholder (roster, date, etc.)

#### 2. Defining Categories

```dart
// Code example
final category = Category(
  id: 'category-a',
  name: 'Category A',
  description: 'Items matching condition A',
  filter: CategoryFilter(
    field: 'status',
    value: 'active',
    type: FilterType.equals,
  ),
);
```

**Filter Types:**

- `equals`: Exact match
- `contains`: Partial match
- `startsWith`: Prefix match
- `endsWith`: Suffix match
- `regex`: Regular expression

#### 3. Creating Workflows

```dart
// Code example
final workflow = Workflow(
  id: 'my-workflow',
  name: 'My Workflow',
  description: 'Custom workflow',
  promptTemplateId: 'my-template',
  categories: [category],
  outputFormatId: 'markdown-format',
);
```

#### 4. Defining Output Formats

```dart
// Markdown format
final markdownFormat = OutputFormat(
  id: 'markdown-format',
  name: 'Markdown',
  description: 'Output in Markdown format',
  template: '''
# {title}

## Category A
{category_a_items}

## Category B
{category_b_items}
''',
  type: OutputType.markdown,
);

// JSON format
final jsonFormat = OutputFormat(
  id: 'json-format',
  name: 'JSON',
  description: 'Output in JSON format',
  template: '',
  type: OutputType.json,
);
```

### Extending Data Sources

To add a new data source:

```dart
class MyCustomDataSource implements DataSource {
  @override
  final String id = 'my-custom-source';
  
  @override
  final String name = 'Custom Data Source';
  
  @override
  final String type = 'custom';
  
  @override
  final String description = 'Description of custom data source';
  
  @override
  Future<List<DataItem>> fetch() async {
    // Data fetching logic
    return [];
  }
  
  @override
  Future<void> save(List<DataItem> items) async {
    // Data saving logic
  }
  
  @override
  Map<String, dynamic> getConfig() {
    return {'type': type};
  }
  
  @override
  Future<void> updateConfig(Map<String, dynamic> config) async {
    // Configuration update logic
  }
}
```

## 🏗️ Architecture

### Directory Structure

```
lib/
├── models/              # Data models
│   ├── workflow.dart           # Workflow model
│   ├── category.dart          # Category model
│   ├── prompt_template.dart   # Prompt template
│   ├── output_format.dart      # Output format
│   └── local_roster.dart      # Local roster
├── providers/           # State management (Riverpod)
│   ├── workflow_provider.dart  # Workflow management
│   └── settings_provider.dart  # Settings management
├── data_sources/        # Data sources
│   ├── data_source.dart        # Data source abstraction
│   └── local_roster_data_source.dart
├── services/            # External services
│   ├── gemini_api_service.dart # Gemini API
│   └── line_messaging_api_service.dart
├── features/            # Feature-specific screens
│   ├── ship_roaster/          # Ship roster management
│   ├── boarding_pass/          # Boarding pass reader
│   ├── settings/               # Settings
│   └── workflow/               # Workflow (generalization)
├── utils/               # Utilities
│   ├── workflow_processor.dart # Workflow processing
│   ├── prompt_processor.dart   # Prompt processing
│   └── date_formatter.dart     # Date formatting
└── widgets/             # Common widgets
    └── ios_style_button.dart
```

### Data Flow

```
User Input
    ↓
ViewModel (State Management)
    ↓
Service (API Calls)
    ↓
Processor (Data Processing)
    ↓
Result Display
```

## 🔐 Security

### API Key Management

- Store API keys in `.env` file
- `.env` file is included in `.gitignore`
- Use `envied` package to manage environment variables
- Please manage environment variable files securely in production

### Data Storage

- Local data is stored in `SharedPreferences`
- It is recommended to encrypt sensitive information

## 🧪 Testing

### Running Unit Tests

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/utils/date_formatter_test.dart

# Run with coverage
flutter test --coverage
```

### Test File Location

Test files have been moved to the `tests_backup` directory. To run them:

```bash
./run_tests.sh
```

## ⚠️ Disclaimer

**This project's code has not undergone comprehensive testing for production use.**

- This project is a prototype developed to solve practical problems
- Comprehensive test suites such as unit tests, integration tests, and E2E tests are not implemented
- Some features have only been verified during development
- If using in production, we strongly recommend conducting thorough testing and verification
- The developers cannot be held responsible for any damages resulting from the use of this project

**Please use at your own risk.**

## 🐛 Troubleshooting

### Common Issues

#### 1. Gemini API Key Not Found

**Error**: `Gemini API key not found`

**Solution**:
1. Check if `GEMINI_API_KEY` is set in the `.env` file
2. Run `dart run build_runner build` to regenerate the environment variable file

#### 2. Image Analysis Fails

**Causes**: 
- Invalid API key
- Unsupported image format
- Network error

**Solution**:
1. Verify the API key
2. Check image format (JPEG, PNG recommended)
3. Check network connection

#### 3. LINE Sending Fails

**Error**: `LINE Messaging API token is not configured`

**Solution**:
1. Add LINE Messaging API configuration to the `.env` file
2. Obtain a channel access token
3. Verify that the group ID is correctly set

#### 4. Build Error

**Error**: `The sandbox is not in sync with the Podfile.lock`

**Solution** (iOS):
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
```

## 📚 Documentation

### English Version
- [Generalization Proposal](GENERALIZATION_PROPOSAL_EN.md)
- [Implementation Guide](IMPLEMENTATION_GUIDE_EN.md)
- [Migration Guide](MIGRATION_GUIDE_EN.md)
- [Changes Summary](CHANGES_SUMMARY_EN.md)

### 日本語版 (Japanese Version)
- [README (日本語)](README.md)
- [汎用化提案書](GENERALIZATION_PROPOSAL.md)
- [実装ガイド](IMPLEMENTATION_GUIDE.md)
- [移行ガイド](MIGRATION_GUIDE.md)
- [変更サマリー](CHANGES_SUMMARY.md)

## 🤝 Contributing

Contributions are welcome!

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Google Gemini API](https://ai.google.dev/)
- [Flutter](https://flutter.dev/)
- [LINE Messaging API](https://developers.line.biz/ja/docs/messaging-api/)

## 📧 Contact

If you have questions or issues, please create an Issue.

---

**AI Workflow Builder** - Customizable AI Image Analysis Workflow Builder

