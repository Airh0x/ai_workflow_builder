import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ai_workflow_builder/services/gemini_api_service.dart';
import 'package:ai_workflow_builder/utils/status_type.dart';
import 'package:ai_workflow_builder/providers/settings_provider.dart';
import 'package:ai_workflow_builder/utils/app_constants.dart';
import 'package:ai_workflow_builder/utils/prompt_processor.dart';

// MARK: - State Class
@immutable
class BoardingPassState {
  final List<XFile> selectedImages;
  final String resultText;
  final String statusMessage;
  final StatusType statusType;
  final bool isProcessing;
  final String? errorMessage;
  final bool isShowingErrorAlert;

  const BoardingPassState({
    this.selectedImages = const [],
    this.resultText = '',
    this.statusMessage = AppConstants.defaultBoardingPassStatusMessage,
    this.statusType = StatusType.info,
    this.isProcessing = false,
    this.errorMessage,
    this.isShowingErrorAlert = false,
  });

  BoardingPassState copyWith({
    List<XFile>? selectedImages,
    String? resultText,
    String? statusMessage,
    StatusType? statusType,
    bool? isProcessing,
    String? errorMessage,
    bool? isShowingErrorAlert,
  }) {
    return BoardingPassState(
      selectedImages: selectedImages ?? this.selectedImages,
      resultText: resultText ?? this.resultText,
      statusMessage: statusMessage ?? this.statusMessage,
      statusType: statusType ?? this.statusType,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
      isShowingErrorAlert: isShowingErrorAlert ?? this.isShowingErrorAlert,
    );
  }
}

// MARK: - ViewModel (StateNotifier)
class BoardingPassViewModel extends StateNotifier<BoardingPassState> {
  BoardingPassViewModel(this.ref) : super(const BoardingPassState());

  final Ref ref; // RiverpodのRefを保持
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      addImages(images);
    }
  }

  void addImages(List<XFile> newImages) {
    final totalCount = state.selectedImages.length + newImages.length;
    state = state.copyWith(
      selectedImages: [...state.selectedImages, ...newImages],
      statusMessage: AppConstants.successImagesPrepared.replaceAll(
        '%d',
        totalCount.toString(),
      ),
      statusType: StatusType.success,
    );
  }

  void resetInputs() {
    state = state.copyWith(
      selectedImages: [],
      resultText: '',
      statusMessage: AppConstants.defaultBoardingPassStatusMessage,
      statusType: StatusType.info,
    );
  }

  void dismissErrorAlert() {
    state = state.copyWith(isShowingErrorAlert: false, errorMessage: '');
  }

  Future<void> shareResult() async {
    if (state.resultText.isEmpty) return;
    // ignore: deprecated_member_use
    await Share.share(state.resultText);
  }

  void updateResultText(String newText) {
    state = state.copyWith(
      resultText: newText,
      statusMessage: '結果が編集されました',
      statusType: StatusType.success,
    );
  }

  Future<void> generateReport() async {
    if (state.selectedImages.isEmpty) {
      state = state.copyWith(
        statusMessage: AppConstants.errorNoImages,
        statusType: StatusType.error,
      );
      return;
    }

    state = state.copyWith(
      isProcessing: true,
      statusMessage: AppConstants.processingReading,
      statusType: StatusType.info,
    );

    try {
      // プロンプトテンプレートを処理
      final settingsNotifier = ref.read(settingsProvider.notifier);
      final promptKey = ref.read(boardingPassPromptKeyProvider);
      final prompt = await PromptProcessor.processPrompt(
        settingsNotifier,
        promptKey,
        isBoardingPass: true,
      );

      // 設定からモデル名を取得
      final modelName = settingsNotifier.getGeminiModel();

      final result = await GeminiApiService().generateContent(
        prompt,
        state.selectedImages,
        modelName: modelName,
      );
      state = state.copyWith(
        resultText: result,
        statusMessage: AppConstants.successReadingCompleted,
        statusType: StatusType.success,
      );
    } catch (e) {
      state = state.copyWith(
        statusMessage: AppConstants.errorApiFailed,
        statusType: StatusType.error,
        errorMessage: e.toString(),
        isShowingErrorAlert: true,
      );
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }
}

// MARK: - Provider
final boardingPassViewModelProvider =
    StateNotifierProvider<BoardingPassViewModel, BoardingPassState>((ref) {
      return BoardingPassViewModel(ref);
    });
