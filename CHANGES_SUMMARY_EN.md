# Generalization Changes Summary

## Project Information

- **Project Name**: `ai_workflow_builder`
- **Location**: `/Users/februarysnow/Desktop/ai_workflow_builder`
- **Original Project**: `shipflow_ai`

## Implemented Generalization Features

### 1. New Model Classes

#### `lib/models/workflow.dart`
- Workflow definition model
- Integrated management of prompt templates, categories, data sources, and output formats
- Includes method to create default ship roster workflow

#### `lib/models/category.dart`
- Category definition model (generalization of "Islanders" and "Returnees")
- Category filter functionality
- Excluded/added item management

#### `lib/models/prompt_template.dart`
- Prompt template model
- Automatic placeholder detection
- Placeholder replacement functionality
- JSON encode/decode

#### `lib/models/output_format.dart`
- Output format model
- Support for Markdown, JSON, CSV, and custom templates
- Data rendering functionality

### 2. New Providers

#### `lib/providers/workflow_provider.dart`
- `WorkflowNotifier`: Workflow management
- `PromptTemplateNotifier`: Prompt template management
- `OutputFormatNotifier`: Output format management
- `CategoryNotifier`: Category management (per workflow)

### 3. Data Source Abstraction

#### `lib/data_sources/data_source.dart`
- Data source abstract interface
- `DataItem` model

#### `lib/data_sources/local_roster_data_source.dart`
- Local roster data source implementation
- Uses existing `LocalRoster` model

### 4. Workflow Processor

#### `lib/utils/workflow_processor.dart`
- Prompt processing based on workflows
- Application of exclusion/addition rules per category
- Output format processing

### 5. Workflow View Model

#### `lib/features/workflow/view_models/workflow_view_model.dart`
- Generalized workflow execution management
- Image selection, workflow execution, LINE sending functionality

## Backward Compatibility

Existing code continues to work:

- ✅ `SettingsNotifier`: Existing methods are maintained
- ✅ `PromptProcessor`: Existing methods are maintained
- ✅ `ShipRoasterViewModel`: Existing functionality is maintained
- ✅ Existing UI: Continues to work

## Key Improvements

### 1. Category Abstraction
- **Before**: "Islanders" and "Returnees" were hardcoded
- **Generalized**: Any category can be defined

### 2. Prompt Template Management
- **Before**: 2 fixed prompts
- **Generalized**: Unlimited templates can be saved and managed

### 3. Output Format
- **Before**: Fixed Markdown format
- **Generalized**: Markdown, JSON, CSV, custom templates

### 4. Data Source
- **Before**: Local roster only
- **Generalized**: Support for multiple data sources (extensible)

## Usage

### Creating Workflows

```dart
final workflowNotifier = ref.read(workflowProvider.notifier);
final workflow = Workflow.createDefaultShipRosterWorkflow();
await workflowNotifier.addWorkflow(workflow);
```

### Using Prompt Templates

```dart
final templateNotifier = ref.read(promptTemplateProvider.notifier);
final template = PromptTemplate(
  id: 'my-template',
  name: 'My Template',
  description: 'Description',
  content: 'Prompt content...',
);
await templateNotifier.addTemplate(template);
```

### Executing Workflows

```dart
final workflowViewModel = ref.read(workflowViewModelProvider.notifier);
await workflowViewModel.executeWorkflow(
  masterRoster: masterRoster,
  sheetName: sheetName,
);
```

## Next Steps

1. **UI Updates**: Implement UI for workflow management, prompt template management, and category management
2. **Existing UI Migration**: Gradually migrate existing UI to the new system
3. **Data Migration**: Migrate existing settings data to the new system
4. **Testing**: Verify existing functionality and test new features

## File Structure

```
lib/
├── models/
│   ├── workflow.dart          # New: Workflow model
│   ├── category.dart          # New: Category model
│   ├── prompt_template.dart   # New: Prompt template
│   ├── output_format.dart     # New: Output format
│   └── local_roster.dart      # Existing: Local roster
├── providers/
│   ├── workflow_provider.dart # New: Workflow management
│   └── settings_provider.dart # Existing: Settings management (backward compatible)
├── data_sources/
│   ├── data_source.dart       # New: Data source abstraction
│   └── local_roster_data_source.dart # New: Local roster implementation
├── features/
│   └── workflow/
│       └── view_models/
│           └── workflow_view_model.dart # New: Workflow view model
└── utils/
    └── workflow_processor.dart # New: Workflow processor
```

## Notes

- Existing functionality is maintained for backward compatibility
- New features are being added gradually
- Complete migration is planned for the future

