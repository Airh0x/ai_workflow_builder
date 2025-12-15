# ダークモード用アイコンの設定方法

## 手順

1. **ダークモード用アイコン画像を準備**
   - `app_icon_dark.png` (1024x1024px) を作成
   - `assets/icon/` ディレクトリに配置

2. **`pubspec.yaml`の設定を有効化**
   ```yaml
   flutter_launcher_icons:
     # ... 既存の設定 ...
     image_path_dark: "assets/icon/app_icon_dark.png"  # コメントを外す
     adaptive_icon_background_dark: "#000000"  # コメントを外す
   ```

3. **アイコンを再生成**
   ```bash
   ./scripts/generate_icons.sh assets/icon/app_icon.png assets/icon/app_icon_dark.png
   ```

## 対応プラットフォーム

- ✅ **iOS**: `image_path_dark`でダークモード用アイコンを設定
- ✅ **Android**: `adaptive_icon_background_dark`でダークモード背景色を設定
- ✅ **Web**: `prefers-color-scheme`メディアクエリで自動切り替え
- ✅ **macOS**: ダークモード用アイコンセットを自動生成

## 注意事項

- `flutter_launcher_icons`のバージョンによっては`image_path_dark`がサポートされていない場合があります
- その場合は、iOS/Androidのアイコンは手動で設定する必要があります
- WebとmacOSはスクリプトで自動生成されます





