#!/bin/bash
# エラーが発生した時点でスクリプトを終了
set -e

# ===== 設定 =====
# LocalStack のエンドポイント
ENDPOINT_URL="http://localhost:4566"

# デプロイ先 S3 バケット名
BUCKET_NAME="next-static"

# Next.js の静的ビルド成果物ディレクトリ
BUILD_DIR="web/out"

# ===== 前提チェック =====
# ビルド成果物が存在するか確認
if [ ! -d "$BUILD_DIR" ]; then
  echo "❌ ビルド成果物が存在しません: $BUILD_DIR"
  echo "npm run build が実行されているか確認してください"
  exit 1
fi

# ===== LocalStack 用のダミー AWS 認証情報 =====
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=ap-northeast-1

# ===== S3 バケット作成（既存の場合は無視）=====
aws --endpoint-url="$ENDPOINT_URL" s3 mb "s3://$BUCKET_NAME" || true

# ===== 静的ファイルを S3 にデプロイ =====
aws --endpoint-url="$ENDPOINT_URL" s3 sync "$BUILD_DIR" "s3://$BUCKET_NAME"

echo "::notice::デプロイ完了"
echo "::notice::URL: $ENDPOINT_URL/$BUCKET_NAME/index.html"

