# AWSでなんかつくるかんじのリポジトリ

![GitHub Actions status](https://github.com/answer-d/modernite/workflows/dev-env.terraform.ci/badge.svg)  
![GitHub Actions status](https://github.com/answer-d/modernite/workflows/dev-env.terraform.cd/badge.svg)  

## How to Use (in local)

- 環境変数
    - *AWS_ACCESS_KEY_ID*
    - *AWS_SECRET_ACCESS_KEY*
        - IAMの作成権限が必要なのでPowerUserAccessのみでは動かない
- 事前作成するAWSリソース
    - VPC
    - キーペア
    - tfstate格納用S3
        - `main.tf` にバケット名を記載
    - SSM Parameter Store
        - Teams Incoming Webhook URLをSecure Stringで
- `vars.tf` 用の変数ファイルに環境ごと設定値を記載している
    - `vars/prod.tfvars` 参照
- tfstateを置くバケット名は `main.tf` に記載
    - 変数参照できなかった
