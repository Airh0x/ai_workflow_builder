# Generalization Migration Guide

## Overview

This document explains how to migrate from the original "Ship Roster Management" app to the generalized "AI Workflow Builder".

## Major Changes

### 1. Package Name Change

- **Old**: `package:shipflow_ai`
- **New**: `package:ai_workflow_builder`

All import statements have been automatically updated.

### 2. App Name Change

- **Old**: "ShipFlow AI"
- **New**: "AI Workflow Builder"

### 3. New Model Classes

The following new model classes have been added:

- `Workflow`: Workflow definition
- `Category`: Category definition (generalization of "Islanders" and "Returnees")
- `PromptTemplate`: Prompt template
- `OutputFormat`: Output format
- `DataSource`: Data source abstraction

### 4. New Providers

- `WorkflowNotifier`: Workflow management
- `PromptTemplateNotifier`: Prompt template management
- `OutputFormatNotifier`: Output format management
- `CategoryNotifier`: Category management

### 5. Backward Compatibility

The existing `SettingsNotifier` is maintained for backward compatibility, and existing code continues to work.

## Migration Steps

### Step 1: Verify Existing Functionality

Existing features (ship roster management, boarding pass reader) continue to work.

### Step 2: Using New Features

To use new generalization features:

1. **Creating Workflows**
   ```dart
   final workflowNotifier = ref.read(workflowProvider.notifier);
   final workflow = Workflow.createDefaultShipRosterWorkflow();
   await workflowNotifier.addWorkflow(workflow);
   ```

2. **Using Prompt Templates**
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

3. **Using Workflow Processor**
   ```dart
   final prompt = await WorkflowProcessor.processWorkflowPrompt(
     ref,
     workflow,
     data: {
       'MASTER_ROSTER': masterRoster,
       'SHEET_NAME': sheetName,
     },
   );
   ```

## Compatibility with Existing Code

### Existing SettingsNotifier

Existing `SettingsNotifier` methods continue to be available:

- `getExcludedIslanders()` → Can migrate to new `CategoryNotifier`
- `getExcludedReturnees()` → Can migrate to new `CategoryNotifier`
- `getAddedIslanders()` → Can migrate to new `CategoryNotifier`
- `getAddedReturnees()` → Can migrate to new `CategoryNotifier`

### Existing PromptProcessor

The existing `PromptProcessor.processPrompt()` continues to work, but using the new `WorkflowProcessor` is recommended.

## Gradual Migration

### Phase 1: Maintain Existing Functionality (Completed)

- ✅ Verified that existing code works
- ✅ Ensured backward compatibility

### Phase 2: Add New Features (In Progress)

- ✅ Workflow management implementation
- ✅ Prompt template management implementation
- ✅ Category management implementation
- ⏳ UI updates (to be implemented)

### Phase 3: Complete Migration (Future)

- ⏳ Migrate existing UI to new system
- ⏳ Data migration
- ⏳ Complete generalization

## Notes

1. **Existing Settings Data**: Existing settings data continues to be available
2. **Gradual Migration**: New features are being added gradually without breaking existing functionality
3. **Testing**: Please verify that existing functionality works correctly

## Next Steps

1. Implement new workflow management UI
2. Implement prompt template management UI
3. Implement category management UI
4. Gradually migrate existing UI

