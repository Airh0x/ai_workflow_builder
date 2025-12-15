/// マスター名簿から名前を抽出するユーティリティクラス
class RosterParser {
  RosterParser._(); // インスタンス化を防ぐ

  /// マスター名簿のテキストから名前のリストを抽出する
  /// 
  /// 改行、カンマ、タブ、スペースなどで区切られた名前を抽出します。
  /// 空行や空白のみの行は除外されます。
  static List<String> extractNames(String? rosterText) {
    if (rosterText == null || rosterText.trim().isEmpty) {
      return [];
    }

    // 改行で分割
    final lines = rosterText.split('\n');
    final names = <String>[];

    for (final line in lines) {
      // 行をカンマ、タブ、スペース（複数）で分割
      final parts = line
          .split(RegExp(r'[,、\t\s]+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      for (final part in parts) {
        // 名前として有効な文字列かチェック（ひらがな、カタカナ、漢字、英数字を含む）
        if (part.isNotEmpty && _isValidName(part)) {
          // 重複を避ける
          if (!names.contains(part)) {
            names.add(part);
          }
        }
      }
    }

    // アルファベット順または五十音順でソート
    names.sort();

    return names;
  }

  /// 名前として有効かどうかをチェック
  /// ひらがな、カタカナ、漢字、英数字を含む文字列を有効とみなす
  static bool _isValidName(String text) {
    // 数字のみ、記号のみは除外
    if (RegExp(r'^[\d\s\-_\.]+$').hasMatch(text)) {
      return false;
    }

    // ひらがな、カタカナ、漢字、英数字を含むかチェック
    return RegExp(r'[ぁ-んァ-ヶ一-龠a-zA-Z0-9]').hasMatch(text);
  }
}


