# Generalization Implementation Guide

## Overview

This guide explains the implementation steps to convert the current ship roster management app into a universal "AI Image Analysis & Data Processing App".

## Phase 1: Basic Generalization

### Step 1: Category Abstraction

#### 1-1. Model Creation
✅ Completed: `lib/models/category.dart` has been created

#### 1-2. SettingsProvider Extension

```dart
// Add to lib/providers/settings_provider.dart

// Category management
Future<List<Category>> getCategories(String workflowId) async {
  // Implementation
}

Future<void> saveCategories(String workflowId, List<Category> categories) async {
  // Implementation
}

// Exclusion/addition lists per category
Future<List<String>> getExcludedItems(String categoryId) async {
  // Implementation
}

Future<void> setExcludedItems(String categoryId, List<String> items) async {
  // Implementation
}
```

#### 1-3. UI Updates

Replace existing "Islanders" and "Returnees" UI with dynamic category list:

```dart
// lib/features/ship_roaster/widgets/category_section.dart (new file)

class CategorySection extends StatelessWidget {
  final Category category;
  final List<String> excludedItems;
  final List<String> addedItems;
  final Function(List<String>) onExcludedChanged;
  final Function(List<String>) onAddedChanged;
  
  // Implementation
}
```

### Step 2: Prompt Template Management Enhancement

#### 2-1. Model Creation

```dart
// lib/models/prompt_template.dart (new file)

class PromptTemplate {
  final String id;
  final String name;
  final String description;
  final String content;
  final List<String> placeholders; // Auto-detected
  final Map<String, String> defaultValues;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Implementation
}
```

#### 2-2. Automatic Placeholder Detection

```dart
// Add to lib/utils/prompt_processor.dart

static List<String> detectPlaceholders(String template) {
  final regex = RegExp(r'\{(\w+)\}|%@');
  return regex.allMatches(template)
      .map((m) => m.group(1) ?? '%@')
      .toSet()
      .toList();
}
```

#### 2-3. UI Addition

Create prompt template management screen:

```dart
// lib/features/settings/prompt_templates_screen.dart (new file)

class PromptTemplatesScreen extends StatelessWidget {
  // Template list
  // Template creation/editing
  // Template deletion
  // Template import/export
}
```

### Step 3: Output Format Customization

#### 3-1. Model Creation

```dart
// lib/models/output_format.dart (new file)

class OutputFormat {
  final String id;
  final String name;
  final String template;
  final OutputType type; // markdown, json, csv, custom
  final Map<String, String> placeholders;
  
  String render(Map<String, dynamic> data) {
    // Render template
  }
}

enum OutputType {
  markdown,
  json,
  csv,
  custom,
}
```

#### 3-2. Formatter Implementation

```dart
// lib/utils/output_formatter.dart (new file)

class OutputFormatter {
  static String format(OutputFormat format, Map<String, dynamic> data) {
    switch (format.type) {
      case OutputType.markdown:
        return _formatMarkdown(format.template, data);
      case OutputType.json:
        return _formatJson(data);
      case OutputType.csv:
        return _formatCsv(data);
      case OutputType.custom:
        return _formatCustom(format.template, data);
    }
  }
}
```

## Phase 2: Data Source Extension

### Step 4: Data Source Abstraction

#### 4-1. Interface Definition

```dart
// lib/data_sources/data_source.dart (new file)

abstract class DataSource {
  String get id;
  String get name;
  String get type;
  
  Future<List<DataItem>> fetch();
  Future<void> save(List<DataItem> items);
}

class DataItem {
  final Map<String, dynamic> data;
  // Implementation
}
```

#### 4-2. Implementation Classes

```dart
// lib/data_sources/local_roster_data_source.dart
class LocalRosterDataSource extends DataSource { ... }

// lib/data_sources/api_data_source.dart
class ApiDataSource extends DataSource { ... }

// lib/data_sources/file_data_source.dart
class FileDataSource extends DataSource { ... }
```

## Migration Steps

### Step 1: Ensure Backward Compatibility

1. Wrap existing code with new system
2. Maintain existing behavior by default
3. Gradually enable new features

### Step 2: Settings Migration

1. Convert existing settings to new models
2. Create migration scripts
3. Verify migration

### Step 3: UI Updates

1. Maintain existing UI
2. Add new settings screens
3. Gradually migrate features

## Implementation Priority

### Should Implement Immediately (Phase 1)
1. ✅ Category abstraction model creation
2. ✅ Workflow model creation
3. Prompt template management enhancement
4. Output format customization

### Should Implement Next (Phase 2)
5. Data source abstraction
6. Settings profile feature

### Future Implementation (Phase 3)
7. Workflow management system
8. Plugin system

## Notes

- Be careful not to break existing functionality
- Implement gradually and test at each stage
- Collect user feedback
- Update documentation

