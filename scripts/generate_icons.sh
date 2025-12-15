#!/bin/bash

# アプリアイコン生成スクリプト（ライトモード・ダークモード対応）
# 使用方法: 
#   ./scripts/generate_icons.sh assets/icon/app_icon.png [assets/icon/app_icon_dark.png]

set -e

ICON_SOURCE="$1"
ICON_DARK_SOURCE="$2"

if [ -z "$ICON_SOURCE" ]; then
    echo "エラー: アイコン画像のパスを指定してください"
    echo "使用方法: ./scripts/generate_icons.sh assets/icon/app_icon.png [assets/icon/app_icon_dark.png]"
    exit 1
fi

if [ ! -f "$ICON_SOURCE" ]; then
    echo "エラー: アイコン画像が見つかりません: $ICON_SOURCE"
    exit 1
fi

if [ -n "$ICON_DARK_SOURCE" ] && [ ! -f "$ICON_DARK_SOURCE" ]; then
    echo "警告: ダークモード用アイコン画像が見つかりません: $ICON_DARK_SOURCE"
    echo "      ライトモード用アイコンのみを使用します"
    ICON_DARK_SOURCE=""
fi

echo "アプリアイコンを生成しています..."
if [ -n "$ICON_DARK_SOURCE" ]; then
    echo "  📱 ライトモード: $ICON_SOURCE"
    echo "  🌙 ダークモード: $ICON_DARK_SOURCE"
else
    echo "  📱 ライトモード: $ICON_SOURCE"
    echo "  ⚠️  ダークモード用アイコンが指定されていません"
fi

# 1. iOS/Android用アイコンを生成（flutter_launcher_icons）
echo "📱 iOS/Android用アイコンを生成中..."
flutter pub run flutter_launcher_icons

# 2. Web用アイコンを生成
echo "🌐 Web用アイコンを生成中..."
mkdir -p web/icons

# ImageMagickまたはsipsを使用してアイコンをリサイズ
if command -v convert &> /dev/null; then
    # ImageMagickを使用
    convert "$ICON_SOURCE" -resize 192x192 web/icons/Icon-192.png
    convert "$ICON_SOURCE" -resize 512x512 web/icons/Icon-512.png
    convert "$ICON_SOURCE" -resize 192x192 -background white -alpha remove web/icons/Icon-maskable-192.png
    convert "$ICON_SOURCE" -resize 512x512 -background white -alpha remove web/icons/Icon-maskable-512.png
    convert "$ICON_SOURCE" -resize 32x32 web/favicon.png
    
    # ダークモード用アイコン（オプション）
    if [ -n "$ICON_DARK_SOURCE" ]; then
        convert "$ICON_DARK_SOURCE" -resize 192x192 web/icons/Icon-192-dark.png
        convert "$ICON_DARK_SOURCE" -resize 512x512 web/icons/Icon-512-dark.png
        convert "$ICON_DARK_SOURCE" -resize 32x32 web/favicon-dark.png
    fi
elif command -v sips &> /dev/null; then
    # macOSのsipsを使用
    sips -z 192 192 "$ICON_SOURCE" --out web/icons/Icon-192.png
    sips -z 512 512 "$ICON_SOURCE" --out web/icons/Icon-512.png
    sips -z 192 192 "$ICON_SOURCE" --out web/icons/Icon-maskable-192.png
    sips -z 512 512 "$ICON_SOURCE" --out web/icons/Icon-maskable-512.png
    sips -z 32 32 "$ICON_SOURCE" --out web/favicon.png
    
    # ダークモード用アイコン（オプション）
    if [ -n "$ICON_DARK_SOURCE" ]; then
        sips -z 192 192 "$ICON_DARK_SOURCE" --out web/icons/Icon-192-dark.png
        sips -z 512 512 "$ICON_DARK_SOURCE" --out web/icons/Icon-512-dark.png
        sips -z 32 32 "$ICON_DARK_SOURCE" --out web/favicon-dark.png
    fi
else
    echo "⚠️  ImageMagickまたはsipsが見つかりません。Web用アイコンは手動で生成してください。"
    echo "   必要なサイズ: 192x192, 512x512 (web/icons/) と 32x32 (web/favicon.png)"
fi

# 3. macOS用アイコンを生成
echo "💻 macOS用アイコンを生成中..."
MACOS_ICON_DIR="macos/Runner/Assets.xcassets/AppIcon.appiconset"
MACOS_ICON_DARK_DIR="macos/Runner/Assets.xcassets/AppIcon-dark.appiconset"
mkdir -p "$MACOS_ICON_DIR"

if command -v convert &> /dev/null; then
    # ImageMagickを使用
    convert "$ICON_SOURCE" -resize 16x16 "$MACOS_ICON_DIR/app_icon_16.png"
    convert "$ICON_SOURCE" -resize 32x32 "$MACOS_ICON_DIR/app_icon_32.png"
    convert "$ICON_SOURCE" -resize 64x64 "$MACOS_ICON_DIR/app_icon_64.png"
    convert "$ICON_SOURCE" -resize 128x128 "$MACOS_ICON_DIR/app_icon_128.png"
    convert "$ICON_SOURCE" -resize 256x256 "$MACOS_ICON_DIR/app_icon_256.png"
    convert "$ICON_SOURCE" -resize 512x512 "$MACOS_ICON_DIR/app_icon_512.png"
    convert "$ICON_SOURCE" -resize 1024x1024 "$MACOS_ICON_DIR/app_icon_1024.png"
    
    # ダークモード用アイコン（オプション）
    if [ -n "$ICON_DARK_SOURCE" ]; then
        mkdir -p "$MACOS_ICON_DARK_DIR"
        convert "$ICON_DARK_SOURCE" -resize 16x16 "$MACOS_ICON_DARK_DIR/app_icon_16.png"
        convert "$ICON_DARK_SOURCE" -resize 32x32 "$MACOS_ICON_DARK_DIR/app_icon_32.png"
        convert "$ICON_DARK_SOURCE" -resize 64x64 "$MACOS_ICON_DARK_DIR/app_icon_64.png"
        convert "$ICON_DARK_SOURCE" -resize 128x128 "$MACOS_ICON_DARK_DIR/app_icon_128.png"
        convert "$ICON_DARK_SOURCE" -resize 256x256 "$MACOS_ICON_DARK_DIR/app_icon_256.png"
        convert "$ICON_DARK_SOURCE" -resize 512x512 "$MACOS_ICON_DARK_DIR/app_icon_512.png"
        convert "$ICON_DARK_SOURCE" -resize 1024x1024 "$MACOS_ICON_DARK_DIR/app_icon_1024.png"
    fi
elif command -v sips &> /dev/null; then
    # macOSのsipsを使用
    sips -z 16 16 "$ICON_SOURCE" --out "$MACOS_ICON_DIR/app_icon_16.png"
    sips -z 32 32 "$ICON_SOURCE" --out "$MACOS_ICON_DIR/app_icon_32.png"
    sips -z 64 64 "$ICON_SOURCE" --out "$MACOS_ICON_DIR/app_icon_64.png"
    sips -z 128 128 "$ICON_SOURCE" --out "$MACOS_ICON_DIR/app_icon_128.png"
    sips -z 256 256 "$ICON_SOURCE" --out "$MACOS_ICON_DIR/app_icon_256.png"
    sips -z 512 512 "$ICON_SOURCE" --out "$MACOS_ICON_DIR/app_icon_512.png"
    sips -z 1024 1024 "$ICON_SOURCE" --out "$MACOS_ICON_DIR/app_icon_1024.png"
    
    # ダークモード用アイコン（オプション）
    if [ -n "$ICON_DARK_SOURCE" ]; then
        mkdir -p "$MACOS_ICON_DARK_DIR"
        sips -z 16 16 "$ICON_DARK_SOURCE" --out "$MACOS_ICON_DARK_DIR/app_icon_16.png"
        sips -z 32 32 "$ICON_DARK_SOURCE" --out "$MACOS_ICON_DARK_DIR/app_icon_32.png"
        sips -z 64 64 "$ICON_DARK_SOURCE" --out "$MACOS_ICON_DARK_DIR/app_icon_64.png"
        sips -z 128 128 "$ICON_DARK_SOURCE" --out "$MACOS_ICON_DARK_DIR/app_icon_128.png"
        sips -z 256 256 "$ICON_DARK_SOURCE" --out "$MACOS_ICON_DARK_DIR/app_icon_256.png"
        sips -z 512 512 "$ICON_DARK_SOURCE" --out "$MACOS_ICON_DARK_DIR/app_icon_512.png"
        sips -z 1024 1024 "$ICON_DARK_SOURCE" --out "$MACOS_ICON_DARK_DIR/app_icon_1024.png"
    fi
else
    echo "⚠️  ImageMagickまたはsipsが見つかりません。macOS用アイコンは手動で生成してください。"
fi

echo "✅ アイコン生成が完了しました！"
echo ""
echo "生成されたアイコン:"
echo "  📱 iOS/Android: flutter_launcher_iconsで自動生成（ライト/ダークモード対応）"
echo "  🌐 Web: web/icons/ と web/favicon.png"
if [ -n "$ICON_DARK_SOURCE" ]; then
    echo "    - ダークモード用アイコンも生成されました"
fi
echo "  💻 macOS: $MACOS_ICON_DIR"
if [ -n "$ICON_DARK_SOURCE" ]; then
    echo "    - ダークモード用アイコン: $MACOS_ICON_DARK_DIR"
fi

