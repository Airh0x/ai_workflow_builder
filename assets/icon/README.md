# アプリアイコンの配置

このディレクトリにアプリアイコンを配置してください。

## 対応プラットフォーム

- ✅ **iOS**: `flutter_launcher_icons`で自動生成
- ✅ **Android**: `flutter_launcher_icons`で自動生成
- ✅ **Web**: スクリプトで自動生成（手動設定も可能）
- ✅ **macOS**: スクリプトで自動生成（手動設定も可能）

## 必要なファイル

### 基本アイコン（必須）
- `app_icon.png` - 1024x1024pxのPNG画像（ライトモード用）
  - 全プラットフォームで使用されます
  - 透明背景（アルファチャンネル）に対応

### ダークモード用アイコン（オプション、推奨）
- `app_icon_dark.png` - 1024x1024pxのPNG画像（ダークモード用）
  - iOS、Android、Web、macOSでダークモード時に自動的に使用されます
  - ライトモード用アイコンと同じサイズ・形式

### アダプティブアイコン（Android、オプション）
- `app_icon_foreground.png` - 1024x1024pxのPNG画像
  - Androidのアダプティブアイコンの前景部分
  - 中央の安全領域（432x432px）に重要な要素を配置

## アイコン生成方法

### 方法1: 自動生成スクリプト（推奨）

1. デザインツール（Figma、Photoshop、Illustratorなど）で1024x1024pxのアイコンを作成
   - ライトモード用: `app_icon.png`
   - ダークモード用: `app_icon_dark.png`（オプション）
2. PNG形式で保存（透明背景可）
3. `assets/icon/` ディレクトリに配置
4. `pubspec.yaml`の`flutter_launcher_icons`セクションのコメントを外す
5. 以下のコマンドを実行:
   ```bash
   # ライトモードのみ
   ./scripts/generate_icons.sh assets/icon/app_icon.png
   
   # ライトモード + ダークモード
   ./scripts/generate_icons.sh assets/icon/app_icon.png assets/icon/app_icon_dark.png
   ```

これで、iOS、Android、Web、macOSの全プラットフォーム用アイコンが自動生成されます。

### 方法2: 手動生成

#### iOS/Androidのみ
```bash
flutter pub run flutter_launcher_icons
```

#### Web用（手動）
`web/icons/`ディレクトリに以下のサイズのアイコンを配置:
- `Icon-192.png` (192x192px)
- `Icon-512.png` (512x512px)
- `Icon-maskable-192.png` (192x192px, maskable)
- `Icon-maskable-512.png` (512x512px, maskable)
- `favicon.png` (32x32px, ルートディレクトリ)

#### macOS用（手動）
`macos/Runner/Assets.xcassets/AppIcon.appiconset/`ディレクトリに以下のサイズを配置:
- `app_icon_16.png` (16x16px)
- `app_icon_32.png` (32x32px)
- `app_icon_64.png` (64x64px)
- `app_icon_128.png` (128x128px)
- `app_icon_256.png` (256x256px)
- `app_icon_512.png` (512x512px)
- `app_icon_1024.png` (1024x1024px)

## 注意事項

- アイコンは正方形（1024x1024px）を推奨
- 角丸は自動的に適用されます（iOS/Androidの仕様に合わせて）
- 透明背景を使用する場合は、アルファチャンネルを含むPNG形式を使用
- 自動生成スクリプトにはImageMagickまたはmacOSのsipsが必要です

