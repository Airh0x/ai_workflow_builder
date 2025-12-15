# Application Generalization Proposal

## Current Issues

The current app is specialized for "ship roster management" and has the following hardcoded elements:

1. **Fixed Categories**: Classifications like "Islanders" and "Returnees" are embedded in the code
2. **Fixed Prompts**: Ship roster management-specific prompt templates
3. **Fixed Data Structure**: Specific data structures like rosters and location names
4. **Fixed Output Format**: Specific report formats

## Generalization Approach

### 1. Workflow/Template Management System

#### Proposal
- Enable definition and saving of multiple "workflows"
- Each workflow includes:
  - Prompt template
  - Category definitions (Islanders/Returnees → customizable classifications)
  - Data source settings (roster, API, files, etc.)
  - Output format definitions
  - Exclusion/addition rule settings

#### Implementation Example
```dart
class Workflow {
  final String id;
  final String name;
  final String description;
  final PromptTemplate promptTemplate;
  final List<Category> categories;
  final DataSourceConfig dataSource;
  final OutputFormat outputFormat;
  final List<FilterRule> filterRules;
}
```

### 2. Category/Classification Abstraction

#### Proposal
- Make fixed categories like "Islanders" and "Returnees" configurable
- Allow users to define their own categories
- Enable exclusion/addition rules per category

#### Implementation Example
```dart
class Category {
  final String id;
  final String name;
  final String description;
  final CategoryFilter filter; // Conditions for this category
  final List<String> excludedItems;
  final List<String> addedItems;
}
```

### 3. Data Source Abstraction

#### Proposal
- Support various data sources beyond rosters:
  - Local files (CSV, JSON, Excel)
  - APIs (REST, GraphQL)
  - Databases
  - Cloud storage

#### Implementation Example
```dart
abstract class DataSource {
  Future<List<DataItem>> fetch();
}

class LocalRosterDataSource extends DataSource { ... }
class ApiDataSource extends DataSource { ... }
class FileDataSource extends DataSource { ... }
```

### 4. Output Format Customization

#### Proposal
- Template-based output formats
- Support for Markdown, JSON, CSV, and custom templates
- Flexible customization through placeholder system

#### Implementation Example
```dart
class OutputFormat {
  final String template;
  final Map<String, String> placeholders;
  final OutputType type; // markdown, json, csv, custom
}
```

### 5. Prompt Template Management Enhancement

#### Proposal
- Save and manage multiple prompt templates
- Template versioning
- Template import/export functionality
- Automatic placeholder detection and replacement

#### Implementation Example
```dart
class PromptTemplate {
  final String id;
  final String name;
  final String content;
  final List<String> placeholders; // Auto-detected
  final Map<String, String> defaultValues;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 6. Settings Profile Feature

#### Proposal
- Save settings per use case as "profiles"
- Profile switching functionality
- Profile import/export

#### Implementation Example
```dart
class Profile {
  final String id;
  final String name;
  final Workflow workflow;
  final DataSourceConfig dataSource;
  final NotificationConfig notification;
  final Map<String, dynamic> customSettings;
}
```

### 7. Plugin/Extension System

#### Proposal
- Plugin system for adding new features
- Enable addition of custom data sources, output formats, notification methods, etc.

#### Implementation Example
```dart
abstract class Plugin {
  String get name;
  String get version;
  void initialize();
  void dispose();
}

abstract class DataSourcePlugin extends Plugin implements DataSource { ... }
abstract class OutputFormatPlugin extends Plugin implements OutputFormat { ... }
```

## Implementation Priority

### Phase 1: Basic Generalization (High Priority)
1. ✅ **Prompt Template Management Enhancement**
   - Save and switch between multiple templates
   - Automatic placeholder detection

2. ✅ **Category Abstraction**
   - Make fixed categories (Islanders/Returnees) configurable
   - Exclusion/addition rules per category

3. ✅ **Output Format Customization**
   - Template-based output
   - Support for multiple formats

### Phase 2: Data Source Extension (Medium Priority)
4. **Data Source Abstraction**
   - Interface definition
   - Support for multiple data sources

5. **Settings Profile Feature**
   - Profile save/load
   - Switching functionality

### Phase 3: Advanced Features (Low Priority)
6. **Workflow Management System**
   - Complete workflow definitions
   - Workflow save/share

7. **Plugin System**
   - Plugin architecture
   - Extension addition

## Specific Implementation Examples

### Example 1: Category Abstraction

**Current:**
```dart
// Hardcoded categories
final excludedIslanders = await settingsNotifier.getExcludedIslanders();
final excludedReturnees = await settingsNotifier.getExcludedReturnees();
```

**After Generalization:**
```dart
// Configurable categories
final categories = await settingsNotifier.getCategories();
for (final category in categories) {
  final excluded = await settingsNotifier.getExcludedItems(category.id);
  final added = await settingsNotifier.getAddedItems(category.id);
}
```

### Example 2: Prompt Template Management

**Current:**
```dart
// Two fixed prompts
const String _defaultShipRoasterPrompt = "...";
const String _defaultBoardingPassPrompt = "...";
```

**After Generalization:**
```dart
// Manage multiple templates
class PromptTemplateManager {
  Future<List<PromptTemplate>> getAllTemplates();
  Future<PromptTemplate?> getTemplate(String id);
  Future<void> saveTemplate(PromptTemplate template);
  Future<void> deleteTemplate(String id);
}
```

### Example 3: Output Format Customization

**Current:**
```dart
// Fixed output format
final output = """
【離島】
...
【帰島】
...
""";
```

**After Generalization:**
```dart
// Template-based output
class OutputFormatter {
  String format(OutputTemplate template, Map<String, dynamic> data) {
    return template.render(data);
  }
}
```

## Migration Strategy

### Step 1: Maintain Backward Compatibility
- Gradually introduce new system without breaking existing functionality
- Maintain existing behavior by default

### Step 2: Settings Migration
- Automatically migrate existing settings to new system
- Provide migration tools

### Step 3: Gradual UI Updates
- Maintain existing UI while adding new features
- Enable new features in settings screen

## Expected Effects

1. **Improved Reusability**: Applicable to various use cases
2. **Improved Maintainability**: Changes possible through settings, no code modifications needed
3. **Improved Extensibility**: Easier to add new features
4. **Improved Usability**: Users can customize themselves

## Next Steps

1. Start Phase 1 implementation
2. Verify existing functionality
3. Gradually add new features
4. Collect user feedback

