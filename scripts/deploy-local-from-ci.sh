#!/bin/bash
# エラーが発生した時点でスクリプトを終了する
set -e

# GitHub リポジトリ名（CI が動作しているリポジトリ）
REPO="ivis-sunqianshu/nextjs-localstack-cicd"
# GitHub Actions で生成された Artifact 名
ARTIFACT="nextjs-static"
# CI からダウンロードした Artifact を一時的に保存するディレクトリ
TMP="/tmp/ci-artifact"
# 展開後の静的ファイル配置先（Next.js の out ディレクトリ）
OUT="web/out"

# 既存の Artifact / out ディレクトリを削除（クリーンな状態にする）
rm -rf "$TMP" "$OUT"
# 必要なディレクトリを作成
mkdir -p "$TMP" "$OUT"

# 最新の成功した GitHub Actions の Artifact をダウンロード
gh run download \
  --repo "$REPO" \
  --name "$ARTIFACT" \
  --dir "$TMP"

# Artifact の中身をそのまま out にコピー
cp -r "$TMP/." "$OUT/"

# LocalStack 用のダミー AWS 認証情報を設定
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=ap-northeast-1

# LocalStack 上に S3 バケットを作成（既に存在する場合は無視）
aws --endpoint-url=http://localstack:4566 s3 mb s3://next-static || true
# CI で生成された静的ファイルを LocalStack の S3 にデプロイ
aws --endpoint-url=http://localstack:4566 s3 sync "$OUT" s3://next-static
