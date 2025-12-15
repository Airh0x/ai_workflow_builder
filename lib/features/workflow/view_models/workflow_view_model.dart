import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ai_workflow_builder/models/workflow.dart';
import 'package:ai_workflow_builder/providers/workflow_provider.dart';
import 'package:ai_workflow_builder/services/gemini_api_service.dart';
import 'package:ai_workflow_builder/utils/workflow_processor.dart';
import 'package:ai_workflow_builder/utils/status_type.dart';
import 'package:ai_workflow_builder/services/line_messaging_api_service.dart';
import 'package:ai_workflow_builder/providers/settings_provider.dart';

/// ワークフロー実行状態
class WorkflowState {
  final bool isProcessing;
  final String statusMessage;
  final StatusType statusType;
  final String? resultText;
  final String? errorMessage;
  final bool isShowingErrorAlert;
  final List<XFile> selectedImages;
  final Workflow? currentWorkflow;

  WorkflowState({
    this.isProcessing = false,
    this.statusMessage = '',
    this.statusType = StatusType.info,
    this.resultText,
    this.errorMessage,
    this.isShowingErrorAlert = false,
    List<XFile>? selectedImages,
    this.currentWorkflow,
  }) : selectedImages = selectedImages ?? [];

  WorkflowState copyWith({
    bool? isProcessing,
    String? statusMessage,
    StatusType? statusType,
    String? resultText,
    String? errorMessage,
    bool? isShowingErrorAlert,
    List<XFile>? selectedImages,
    Workflow? currentWorkflow,
  }) {
    return WorkflowState(
      isProcessing: isProcessing ?? this.isProcessing,
      statusMessage: statusMessage ?? this.statusMessage,
      statusType: statusType ?? this.statusType,
      resultText: resultText ?? this.resultText,
      errorMessage: errorMessage ?? this.errorMessage,
      isShowingErrorAlert: isShowingErrorAlert ?? this.isShowingErrorAlert,
      selectedImages: selectedImages ?? this.selectedImages,
      currentWorkflow: currentWorkflow ?? this.currentWorkflow,
    );
  }
}

/// ワークフロービューモデル
///
/// 汎用化のためのワークフロー実行管理
class WorkflowViewModel extends StateNotifier<WorkflowState> {
  WorkflowViewModel(this.ref) : super(WorkflowState()) {
    _initialize();
  }

  final Ref ref;

  Future<void> _initialize() async {
    // デフォルトワークフローを読み込み
    final workflowNotifier = ref.read(workflowProvider.notifier);
    final workflows = ref.read(workflowProvider);

    if (workflows.isNotEmpty) {
      state = state.copyWith(currentWorkflow: workflows.first);
    } else {
      // デフォルトワークフローを作成
      final defaultWorkflow = Workflow.createDefaultWorkflow();
      await workflowNotifier.addWorkflow(defaultWorkflow);
      state = state.copyWith(currentWorkflow: defaultWorkflow);
    }
  }

  /// ワークフローを切り替え
  Future<void> switchWorkflow(String workflowId) async {
    final workflowNotifier = ref.read(workflowProvider.notifier);
    final workflow = workflowNotifier.getWorkflow(workflowId);

    if (workflow != null) {
      state = state.copyWith(currentWorkflow: workflow);
    }
  }

  /// 画像を選択
  Future<void> selectImages() async {
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage();

      if (images != null && images.isNotEmpty) {
        state = state.copyWith(selectedImages: images);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('画像選択エラー: $e');
      }
    }
  }

  /// ワークフローを実行
  Future<void> executeWorkflow({
    String? masterRoster,
    String? sheetName,
    Map<String, String>? additionalData,
  }) async {
    if (state.currentWorkflow == null) {
      state = state.copyWith(
        statusMessage: 'ワークフローが選択されていません',
        statusType: StatusType.error,
      );
      return;
    }

    if (state.selectedImages.isEmpty) {
      state = state.copyWith(
        statusMessage: '画像が選択されていません',
        statusType: StatusType.error,
      );
      return;
    }

    state = state.copyWith(
      isProcessing: true,
      statusMessage: '処理中...',
      statusType: StatusType.info,
    );

    try {
      final workflow = state.currentWorkflow!;

      // データを準備
      final data = <String, String>{};
      if (masterRoster != null) {
        data['MASTER_ROSTER'] = masterRoster;
      }
      if (sheetName != null) {
        data['SHEET_NAME'] = sheetName;
      }
      if (additionalData != null) {
        data.addAll(
          additionalData.map((key, value) => MapEntry(key, value.toString())),
        );
      }

      // プロンプトを処理
      final prompt = await WorkflowProcessor.processWorkflowPrompt(
        ref,
        workflow,
        data: data,
      );

      // Gemini APIでコンテンツ生成
      final settingsNotifier = ref.read(settingsProvider.notifier);
      final modelName = settingsNotifier.getGeminiModel();

      final result = await GeminiApiService().generateContent(
        prompt,
        state.selectedImages,
        modelName: modelName,
      );

      state = state.copyWith(
        resultText: result,
        statusMessage: '処理が完了しました',
        statusType: StatusType.success,
        isProcessing: false,
      );
    } catch (e) {
      state = state.copyWith(
        statusMessage: 'エラーが発生しました: $e',
        statusType: StatusType.error,
        errorMessage: e.toString(),
        isShowingErrorAlert: true,
        isProcessing: false,
      );
    }
  }

  /// LINEに送信
  Future<void> sendToLine() async {
    if (state.resultText == null || state.resultText!.isEmpty) {
      state = state.copyWith(
        statusMessage: '送信する結果がありません',
        statusType: StatusType.error,
      );
      return;
    }

    state = state.copyWith(
      isProcessing: true,
      statusMessage: 'LINEに送信中...',
      statusType: StatusType.info,
    );

    try {
      final settingsNotifier = ref.read(settingsProvider.notifier);
      final token = await settingsNotifier.getLineMessagingApiToken();

      if (token == null || token.isEmpty) {
        state = state.copyWith(
          statusMessage: 'LINE Messaging APIのトークンが設定されていません',
          statusType: StatusType.error,
          isProcessing: false,
        );
        return;
      }

      // メッセージを整形
      final message = _formatLineMessage(state.resultText!);

      // グループIDが設定されている場合はグループメッセージを優先
      final groupId = await settingsNotifier.getLineMessagingApiGroupId();

      bool success;
      String? errorMessage;

      if (groupId != null && groupId.isNotEmpty) {
        final result = await LineMessagingApiService.sendGroupMessageWithError(
          channelAccessToken: token,
          groupId: groupId,
          message: message,
        );
        success = result['success'] as bool;
        errorMessage = result['error'] as String?;
      } else {
        final useBroadcast = await settingsNotifier
            .isLineMessagingApiUseBroadcast();

        if (useBroadcast) {
          success = await LineMessagingApiService.sendBroadcastMessage(
            channelAccessToken: token,
            message: message,
          );
        } else {
          final userId = await settingsNotifier.getLineMessagingApiUserId();
          if (userId != null && userId.isNotEmpty) {
            success = await LineMessagingApiService.sendPushMessage(
              channelAccessToken: token,
              userId: userId,
              message: message,
            );
          } else {
            success = await LineMessagingApiService.sendBroadcastMessage(
              channelAccessToken: token,
              message: message,
            );
          }
        }
      }

      if (success) {
        state = state.copyWith(
          statusMessage: 'LINEへの送信が完了しました',
          statusType: StatusType.success,
          isProcessing: false,
        );
      } else {
        state = state.copyWith(
          statusMessage: errorMessage != null
              ? 'LINE送信エラー: $errorMessage'
              : 'LINEへの送信に失敗しました',
          statusType: StatusType.error,
          isProcessing: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        statusMessage: 'LINE送信エラー: $e',
        statusType: StatusType.error,
        isProcessing: false,
      );
    }
  }

  /// LINEメッセージを整形
  String _formatLineMessage(String text) {
    // 1000文字を超える場合は切り詰め
    final maxLength = 1000;
    final truncated = text.length > maxLength
        ? '${text.substring(0, maxLength)}...'
        : text;

    return '🚢 明日の乗船関係のお知らせ\n\n$truncated';
  }

  /// 結果をクリア
  void clearResult() {
    state = state.copyWith(
      resultText: null,
      statusMessage: '',
      statusType: StatusType.info,
    );
  }

  /// 画像をクリア
  void clearImages() {
    state = state.copyWith(selectedImages: []);
  }
}

// プロバイダー定義
final workflowViewModelProvider =
    StateNotifierProvider<WorkflowViewModel, WorkflowState>((ref) {
      return WorkflowViewModel(ref);
    });
