#!/bin/bash

# テスト実行スクリプト
# tests_backupフォルダ内のテストを実行します

set -e

# カラー出力用の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# プロジェクトのルートディレクトリに移動
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${GREEN}🧪 テスト実行スクリプト${NC}"
echo ""

# tests_backupフォルダが存在するか確認
if [ ! -d "tests_backup" ]; then
    echo -e "${RED}❌ エラー: tests_backupフォルダが見つかりません${NC}"
    exit 1
fi

# Flutterがインストールされているか確認
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ エラー: Flutterがインストールされていません${NC}"
    exit 1
fi

# テストファイルを一時的にtestフォルダにコピー
echo -e "${YELLOW}📁 テストファイルを準備中...${NC}"
rm -rf test
cp -r tests_backup test
echo -e "${GREEN}✅ テストファイルの準備が完了しました${NC}"
echo ""

# テストを実行
echo -e "${YELLOW}🚀 テストを実行中...${NC}"
echo ""

# オプションの処理
COVERAGE=false
VERBOSE=false
SPECIFIC_TEST=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --coverage|-c)
            COVERAGE=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --test|-t)
            SPECIFIC_TEST="$2"
            shift 2
            ;;
        --help|-h)
            echo "使用方法: $0 [オプション]"
            echo ""
            echo "オプション:"
            echo "  -c, --coverage    カバレッジレポートを生成"
            echo "  -v, --verbose     詳細な出力を表示"
            echo "  -t, --test FILE   特定のテストファイルを実行"
            echo "  -h, --help        このヘルプを表示"
            echo ""
            echo "例:"
            echo "  $0                    # すべてのテストを実行"
            echo "  $0 --coverage         # カバレッジ付きで実行"
            echo "  $0 --test test/utils/date_formatter_test.dart  # 特定のテストを実行"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ 不明なオプション: $1${NC}"
            echo "ヘルプを表示するには: $0 --help"
            exit 1
            ;;
    esac
done

# Flutterの依存関係を取得
echo -e "${YELLOW}📦 依存関係を取得中...${NC}"
flutter pub get > /dev/null 2>&1
echo -e "${GREEN}✅ 依存関係の取得が完了しました${NC}"
echo ""

# テスト実行
if [ -n "$SPECIFIC_TEST" ]; then
    # 特定のテストファイルを実行
    if [ ! -f "test/$SPECIFIC_TEST" ]; then
        echo -e "${RED}❌ エラー: テストファイルが見つかりません: test/$SPECIFIC_TEST${NC}"
        rm -rf test
        exit 1
    fi
    TEST_COMMAND="flutter test test/$SPECIFIC_TEST"
else
    # すべてのテストを実行
    TEST_COMMAND="flutter test"
fi

if [ "$COVERAGE" = true ]; then
    TEST_COMMAND="$TEST_COMMAND --coverage"
fi

if [ "$VERBOSE" = true ]; then
    TEST_COMMAND="$TEST_COMMAND --reporter expanded"
fi

# テスト実行
echo -e "${YELLOW}実行コマンド: $TEST_COMMAND${NC}"
echo ""

if eval $TEST_COMMAND; then
    echo ""
    echo -e "${GREEN}✅ すべてのテストが成功しました！${NC}"
    
    if [ "$COVERAGE" = true ]; then
        echo ""
        echo -e "${YELLOW}📊 カバレッジレポートが生成されました: coverage/lcov.info${NC}"
    fi
    
    # 一時的なtestフォルダを削除
    rm -rf test
    exit 0
else
    echo ""
    echo -e "${RED}❌ テストが失敗しました${NC}"
    # 一時的なtestフォルダを削除
    rm -rf test
    exit 1
fi

