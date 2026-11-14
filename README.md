# grpc_helloworld

Go で書いた gRPC の最小サンプルです。`Greeter` サービスの `SayHello` を呼ぶサーバーとクライアントを、1 つの CLI（Cobra）にまとめています。サーバーには OpenTelemetry（otelgrpc）を組み込み、トレースを標準出力に出します。

## 概要

- `server` サブコマンドで gRPC サーバーを起動（ポート `:50051`）
- `client` サブコマンドで `SayHello` を呼び出す
- TODO: 作った目的（学習用など）を一言追記

## 構成

| パス | 内容 |
| --- | --- |
| `main.go` | CLI のエントリーポイント（`server` / `client`） |
| `server/` | gRPC サーバー実装（`Greeter` を登録、OTel ハンドラ付き） |
| `client/` | gRPC クライアント。環境変数 `SERVER_HOST` / `SERVER_PORT` で接続先を指定 |
| `proto/` | `helloworld.proto` と生成済みコード（Git 管理対象） |
| `config/` | OpenTelemetry の stdout エクスポータ初期化 |
| `Dockerfile` | 静的リンクのバイナリ `appctl` をビルドするイメージ |

## 必要なもの

- Go（`go.mod` は 1.26.1）
- `golangci-lint`（lint 用）
- `protoc`、`protoc-gen-go`、`protoc-gen-go-grpc`（`.proto` を変更するときだけ）
- Docker（イメージをビルドするとき）

## 動かし方

```bash
make run-server              # サーバーを起動 (:50051)
make run-client              # クライアントを実行
go run main.go client Bob    # 送る名前を引数で指定
make lint                    # golangci-lint run ./...
go test ./...                # TODO: 現状テストファイルは見当たらない
make build                   # Linux 向け静的バイナリ appctl を生成
make genproto                # .proto 変更後に生成コードを更新
```

## デプロイ

`.github/workflows/cicd.yml` が lint と Docker イメージのビルドを行います。push（master / `v*` タグ）と手動実行のときだけ DockerHub に `grpc_helloworld` イメージを push し、PR ではビルド確認のみです。クラスタへのデプロイ定義はこのリポジトリにはありません（TODO: 別リポジトリで管理しているか確認）。

## ライセンス

TODO: LICENSE ファイルがありません。
