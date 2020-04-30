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
- `vars.tf` 用の変数ファイルを作成
    - `vars/prod.tfvars` 参照
