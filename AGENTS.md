# Repository Guidelines

## プロジェクト構成とモジュール構成
- `main.go`: Cobra ベースの CLI エントリーポイントで server と client サブコマンドを束ねます。
- `server/server.go`: gRPC サーバー実装。OTel ハンドラを組み込み `Greeter` サービスを登録します。
- `client/client.go`: 環境変数 `SERVER_HOST` `SERVER_PORT` を読み取り gRPC クライアントを起動します。
- `proto/`: `helloworld.proto` と生成済みの `*_pb.go` を管理します。生成ファイルも Git 管理対象です。
- `config/config.go`: OpenTelemetry stdout エクスポータ初期化ロジックを提供します。
- `Makefile`: `run-server` など開発コマンドを集約します。CI と同じビルド条件も確認できます。
- `Dockerfile`: 静的リンク済みバイナリをビルドしコンテナ配布を容易にします。

## ビルド・テスト・開発コマンド
- `make run-server`: ローカルで gRPC サーバーを起動します (ポート `:50051`)。
- `make run-client name=Alice`: クライアントを実行し任意の名前で `SayHello` を呼び出します。
- `go run main.go client Bob`: 引数経由で送信名を指定するサンプルです。
- `make lint`: `golangci-lint run ./...` を実行し静的解析を通します。
- `go test ./...`: すべてのパッケージテストを実行します。新規テストはこのコマンドで検証してください。
- `make build`: Linux 向け静的バイナリ `appctl` を生成します。
- `make genproto`: `.proto` 変更後に gRPC/Protobuf の生成ファイルを更新します。

## コーディングスタイルと命名規則
- すべての Go コードはコミット前に `gofmt` と `goimports` を適用します。タブインデントを維持してください。
- 公開 API は PascalCase、パッケージ内部は camelCase、定数は PascalCase を推奨します。
- ログは `log` パッケージを使用し、入力値は `log.Printf` で明示的にフォーマットします。
- gRPC ハンドラやクライアントのタイムアウト値は `time.Second` 単位で明示し、マジックナンバーを避けます。

## テストガイドライン
- Go 標準の `testing` パッケージを用い、ファイル名は `*_test.go` で対象パッケージ直下に置きます。
- サーバーテストは `grpc/test/bufconn` を使ったインメモリ検証を推奨します。
- クライアントテストは `context.WithTimeout` を短めに設定しネットワーク依存を排除します。
- 新機能は正パスとエラーケースを最低 1 件ずつ追加し、`go test -race ./...` でデータ競合を確認します。
- カバレッジは 70% 以上を目標とし、`go test -cover ./...` で計測します。

## コミットとプルリクエストの指針
- 履歴は「fix lint」など短い英語命令形が主流です。同様に 50 文字以内で要点を表現します。
- コミットボディには背景、再現手順、影響範囲、フォローアップを記載し、Issue は `Closes #123` 形式で紐付けます。
- PR では概要、テスト結果 (`make lint`, `go test ./...`)、ログやスクリーンショットを箇条書きで提示します。
- 仕様変更や外部インターフェース追加時は `proto/` 変更と後方互換性を明記してください。

## プロトコルバッファと観測のヒント
- `.proto` を更新したら必ず `make genproto` を実行し生成ファイルを再コミットします。
- サーバー終了時は `TracerProvider.Shutdown` を呼び出し OpenTelemetry の送信を確実に完了させます。
- 追加サービスを実装する際は `pb.Register<YourService>Server` の呼び出しを `server/server.go` に追加し、クライアントは `grpc.NewClient` で接続します。
