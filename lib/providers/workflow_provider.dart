import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_workflow_builder/models/workflow.dart';
import 'package:ai_workflow_builder/models/prompt_template.dart';
import 'package:ai_workflow_builder/models/category.dart';
import 'package:ai_workflow_builder/models/output_format.dart';

/// ワークフロー管理プロバイダー
///
/// 汎用化のためのワークフロー管理
class WorkflowNotifier extends StateNotifier<List<Workflow>> {
  WorkflowNotifier() : super([]) {
    _loadWorkflows();
  }

  SharedPreferences? _prefs;
  static const String _workflowsKey = 'workflows';

  Future<void> _ensurePrefsInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadWorkflows() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return;

    final workflowsJson = _prefs!.getString(_workflowsKey);
    if (workflowsJson != null && workflowsJson.isNotEmpty) {
      try {
        final List<dynamic> decoded =
            json.decode(workflowsJson) as List<dynamic>;
        state = decoded
            .map((item) => Workflow.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        state = [];
      }
    } else {
      // デフォルトワークフローを作成
      state = [Workflow.createDefaultWorkflow()];
      await _saveWorkflows();
    }
  }

  Future<void> _saveWorkflows() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return;

    final jsonString = json.encode(state.map((w) => w.toJson()).toList());
    await _prefs!.setString(_workflowsKey, jsonString);
  }

  /// ワークフローを追加
  Future<void> addWorkflow(Workflow workflow) async {
    state = [...state, workflow];
    await _saveWorkflows();
  }

  /// ワークフローを更新
  Future<void> updateWorkflow(Workflow workflow) async {
    state = state.map((w) => w.id == workflow.id ? workflow : w).toList();
    await _saveWorkflows();
  }

  /// ワークフローを削除
  Future<void> deleteWorkflow(String workflowId) async {
    state = state.where((w) => w.id != workflowId).toList();
    await _saveWorkflows();
  }

  /// ワークフローを取得
  Workflow? getWorkflow(String workflowId) {
    try {
      return state.firstWhere((w) => w.id == workflowId);
    } catch (e) {
      return null;
    }
  }

  /// 現在のワークフローを取得（デフォルトは最初のワークフロー）
  Workflow getCurrentWorkflow() {
    if (state.isEmpty) {
      return Workflow.createDefaultWorkflow();
    }
    return state.first;
  }
}

/// プロンプトテンプレート管理プロバイダー
class PromptTemplateNotifier extends StateNotifier<List<PromptTemplate>> {
  PromptTemplateNotifier() : super([]) {
    _loadTemplates();
  }

  SharedPreferences? _prefs;
  static const String _templatesKey = 'promptTemplates';

  Future<void> _ensurePrefsInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadTemplates() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return;

    final templatesJson = _prefs!.getString(_templatesKey);
    if (templatesJson != null && templatesJson.isNotEmpty) {
      state = PromptTemplate.decode(templatesJson);
    }
  }

  Future<void> _saveTemplates() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return;

    final jsonString = PromptTemplate.encode(state);
    await _prefs!.setString(_templatesKey, jsonString);
  }

  /// テンプレートを追加
  Future<void> addTemplate(PromptTemplate template) async {
    state = [...state, template];
    await _saveTemplates();
  }

  /// テンプレートを更新
  Future<void> updateTemplate(PromptTemplate template) async {
    state = state.map((t) => t.id == template.id ? template : t).toList();
    await _saveTemplates();
  }

  /// テンプレートを削除
  Future<void> deleteTemplate(String templateId) async {
    state = state.where((t) => t.id != templateId).toList();
    await _saveTemplates();
  }

  /// テンプレートを取得
  PromptTemplate? getTemplate(String templateId) {
    try {
      return state.firstWhere((t) => t.id == templateId);
    } catch (e) {
      return null;
    }
  }
}

/// 出力フォーマット管理プロバイダー
class OutputFormatNotifier extends StateNotifier<List<OutputFormat>> {
  OutputFormatNotifier() : super([]) {
    _loadFormats();
  }

  SharedPreferences? _prefs;
  static const String _formatsKey = 'outputFormats';

  Future<void> _ensurePrefsInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadFormats() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return;

    final formatsJson = _prefs!.getString(_formatsKey);
    if (formatsJson != null && formatsJson.isNotEmpty) {
      state = OutputFormat.decode(formatsJson);
    }
  }

  Future<void> _saveFormats() async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return;

    final jsonString = OutputFormat.encode(state);
    await _prefs!.setString(_formatsKey, jsonString);
  }

  /// フォーマットを追加
  Future<void> addFormat(OutputFormat format) async {
    state = [...state, format];
    await _saveFormats();
  }

  /// フォーマットを更新
  Future<void> updateFormat(OutputFormat format) async {
    state = state.map((f) => f.id == format.id ? format : f).toList();
    await _saveFormats();
  }

  /// フォーマットを削除
  Future<void> deleteFormat(String formatId) async {
    state = state.where((f) => f.id != formatId).toList();
    await _saveFormats();
  }

  /// フォーマットを取得
  OutputFormat? getFormat(String formatId) {
    try {
      return state.firstWhere((f) => f.id == formatId);
    } catch (e) {
      return null;
    }
  }
}

/// カテゴリ管理プロバイダー（ワークフローごと）
class CategoryNotifier extends StateNotifier<Map<String, List<Category>>> {
  CategoryNotifier() : super({});

  SharedPreferences? _prefs;
  static const String _categoriesKey = 'categories';

  Future<void> _ensurePrefsInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// ワークフローのカテゴリを読み込み
  Future<void> loadCategories(String workflowId) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return;

    final categoriesJson = _prefs!.getString('$_categoriesKey-$workflowId');
    if (categoriesJson != null && categoriesJson.isNotEmpty) {
      try {
        final List<dynamic> decoded =
            json.decode(categoriesJson) as List<dynamic>;
        final categories = decoded
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();
        state = {...state, workflowId: categories};
      } catch (e) {
        // エラー時は空リスト
      }
    }
  }

  /// ワークフローのカテゴリを保存
  Future<void> saveCategories(
    String workflowId,
    List<Category> categories,
  ) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return;

    final jsonString = json.encode(categories.map((c) => c.toJson()).toList());
    await _prefs!.setString('$_categoriesKey-$workflowId', jsonString);
    state = {...state, workflowId: categories};
  }

  /// カテゴリの除外リストを取得
  Future<List<String>> getExcludedItems(
    String workflowId,
    String categoryId,
  ) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return [];

    final excludedJson = _prefs!.getString('excluded-$workflowId-$categoryId');
    if (excludedJson != null && excludedJson.isNotEmpty) {
      try {
        final List<dynamic> decoded =
            json.decode(excludedJson) as List<dynamic>;
        return decoded.map((e) => e.toString()).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  /// カテゴリの除外リストを設定
  Future<void> setExcludedItems(
    String workflowId,
    String categoryId,
    List<String> items,
  ) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return;

    final jsonString = json.encode(items);
    await _prefs!.setString('excluded-$workflowId-$categoryId', jsonString);
  }

  /// カテゴリの追加リストを取得
  Future<List<String>> getAddedItems(
    String workflowId,
    String categoryId,
  ) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return [];

    final addedJson = _prefs!.getString('added-$workflowId-$categoryId');
    if (addedJson != null && addedJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(addedJson) as List<dynamic>;
        return decoded.map((e) => e.toString()).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  /// カテゴリの追加リストを設定
  Future<void> setAddedItems(
    String workflowId,
    String categoryId,
    List<String> items,
  ) async {
    await _ensurePrefsInitialized();
    if (_prefs == null) return;

    final jsonString = json.encode(items);
    await _prefs!.setString('added-$workflowId-$categoryId', jsonString);
  }
}

// プロバイダー定義
final workflowProvider =
    StateNotifierProvider<WorkflowNotifier, List<Workflow>>((ref) {
      return WorkflowNotifier();
    });

final promptTemplateProvider =
    StateNotifierProvider<PromptTemplateNotifier, List<PromptTemplate>>((ref) {
      return PromptTemplateNotifier();
    });

final outputFormatProvider =
    StateNotifierProvider<OutputFormatNotifier, List<OutputFormat>>((ref) {
      return OutputFormatNotifier();
    });

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, Map<String, List<Category>>>((ref) {
      return CategoryNotifier();
    });
