## ギガノトカップ〜インフラ〜

このプロジェクトは、ReactアプリケーションをGoogle Cloud Run + GitHub Actions CI/CDでデプロイするためのTerraformインフラストラクチャです。

## 🏗️ インフラ構成

- **Google Cloud Run**: コンテナ化されたReactアプリケーションのホスティング
- **Artifact Registry**: Dockerイメージの保存
- **Service Account**: GitHub Actions用の認証
- **IAM**: 適切な権限設定
- **GitHub Actions**: CI/CDパイプライン

## 📋 前提条件

1. **Google Cloud Platform アカウント**
   - プロジェクトの作成済み
   - 課金が有効化済み

2. **ローカル環境**
   ```bash
   # 必要なツール
   - Terraform >= 1.0
   - gcloud CLI
   - Docker
   - Node.js >= 18
   ```

3. **gcloud CLI 認証**
   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   gcloud auth application-default login
   ```

## 🚀 セットアップ手順

### 1. Terraform変数の設定

`terraform.tfvars`ファイルでプロジェクト設定を確認・編集：

```bash
# giganoto-infra/terraform.tfvars
project_id = "YOUR_PROJECT_ID"
region     = "asia-northeast1"
service_name = "giganoto-frontend"
```

### 2. Terraformインフラストラクチャのデプロイ

```bash
cd giganoto-infra
terraform init
terraform plan
terraform apply
```

### 3. GitHub Secretsの設定

GitHubリポジトリの Settings > Secrets and variables > Actions で以下を設定：

```bash
# サービスアカウントキーを取得（-rawフラグは使用不可）
terraform output github_actions_service_account_key

# 出力された値（ダブルクォート含む）をコピーして
# GitHubに以下のシークレットを追加
GCP_SA_KEY: [上記で取得したJSONキー（ダブルクォート含む）]
```

**注意**: キーは機密情報です。出力をコピーしたら、必ずターミナル履歴をクリアしてください。

### 4. 初回デプロイ（手動）

```bash
# プロジェクトのルートディレクトリに移動
cd ..

# Docker認証設定
gcloud auth configure-docker asia-northeast1-docker.pkg.dev --quiet

# Reactアプリのビルドとデプロイ
npm run build
docker build -t asia-northeast1-docker.pkg.dev/YOUR_PROJECT_ID/giganoto-repo/giganoto-frontend:latest .
docker push asia-northeast1-docker.pkg.dev/YOUR_PROJECT_ID/giganoto-repo/giganoto-frontend:latest

# Cloud Runサービスの更新
gcloud run services update giganoto-frontend \
  --image=asia-northeast1-docker.pkg.dev/YOUR_PROJECT_ID/giganoto-repo/giganoto-frontend:latest \
  --region=asia-northeast1 \
  --project=YOUR_PROJECT_ID

# デプロイ後のURL確認
gcloud run services describe giganoto-frontend \
  --region=asia-northeast1 \
  --project=YOUR_PROJECT_ID \
  --format="value(status.url)"
```

**実際の例（giganoto-463603プロジェクト）:**
```bash
docker build -t asia-northeast1-docker.pkg.dev/giganoto-463603/giganoto-repo/giganoto-frontend:latest .
docker push asia-northeast1-docker.pkg.dev/giganoto-463603/giganoto-repo/giganoto-frontend:latest
gcloud run services update giganoto-frontend \
  --image=asia-northeast1-docker.pkg.dev/giganoto-463603/giganoto-repo/giganoto-frontend:latest \
  --region=asia-northeast1 \
  --project=giganoto-463603
```

## 継続的デプロイ（CI/CD）

`main`ブランチへのプッシュで自動デプロイが実行されます：

1. **自動ビルド**: Reactアプリケーションのビルド
2. **Dockerイメージ作成**: マルチステージビルドでイメージ作成
3. **Artifact Registry**: イメージのプッシュ
4. **Cloud Run**: サービスの更新
5. **ヘルスチェック**: デプロイ後の動作確認

## ファイル構成

```
giganoto-infra/
├── main.tf              # メインのTerraform設定
├── terraform.tfvars     # 変数設定
└── modules/
    ├── apis.tf          # Google Cloud APIs
    ├── cloudrun.tf      # Cloud Run設定
    ├── iam.tf           # サービスアカウント・権限
    ├── variables.tf     # 変数定義
    └── outputs.tf       # 出力設定

.github/workflows/
└── deploy.yml           # GitHub Actionsワークフロー

nginx.conf               # Nginx設定（SPA対応）
Dockerfile              # マルチステージビルド設定
```

## 📊 現在のプロジェクト状態

このプロジェクトの現在の設定例：

```bash
# プロジェクトID
giganoto-463603

# デプロイ済みサービスURL
https://giganoto-frontend-267485109612.asia-northeast1.run.app/

# GitHub Actionsサービスアカウント
giganoto-frontend-github-sa@giganoto-463603.iam.gserviceaccount.com

# Artifact RegistryリポジトリURL
asia-northeast1-docker.pkg.dev/giganoto-463603/giganoto-repo
```

### 設定確認コマンド
```bash
# 現在のTerraform出力を確認
terraform output

# Cloud Runサービス状態確認
gcloud run services describe giganoto-frontend \
  --region=asia-northeast1 \
  --project=giganoto-463603

# Artifact Registryリポジトリ確認
gcloud artifacts repositories list \
  --location=asia-northeast1 \
  --project=giganoto-463603
```

## 🛠️ トラブルシューティング

### Terraform出力が見つからないエラー
```bash
# エラー例: Warning: No outputs found
# 解決方法1: Terraformの状態を確認
terraform show

# 解決方法2: リフレッシュ実行
terraform refresh

# 解決方法3: 再適用
terraform apply
```

### サービスアカウントキーの取得方法
```bash
# 正しい取得方法（-rawフラグは使用不可）
terraform output github_actions_service_account_key

# 出力例（Base64エンコードされたJSON）
"ewogICJ0eXBlIjogInNlcnZpY2VfYWNjb3VudCIsCiAg..."

# このダブルクォート含む全体をGitHub Secretsにコピー
```

### 静的アセットの404エラー
nginx.confが適切に設定されていることを確認：
- SPAルーティング対応 (`try_files $uri $uri/ /index.html`)
- 静的ファイルのキャッシュ設定
- 適切なMIMEタイプ設定

### GitHub Actions認証エラー
サービスアカウントキーが正しく設定されていることを確認：
```bash
# キーの確認
terraform output github_actions_service_account_key

# GitHubシークレットの確認
# 1. リポジトリ > Settings > Secrets and variables > Actions
# 2. GCP_SA_KEYが設定されているか確認
# 3. 値がダブルクォートを含む完全なJSON形式か確認
```

### Artifact Registry権限エラー
サービスアカウントに適切な権限があることを確認：
```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:SERVICE_ACCOUNT_EMAIL" \
  --role="roles/artifactregistry.writer"
```

### リソースの削除
```bash
# 全リソースの削除
terraform destroy

# 個別リソースの削除
terraform destroy -target=module.giganoto_infrastructure.google_cloud_run_v2_service.frontend
```
