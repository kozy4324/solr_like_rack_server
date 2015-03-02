# SolrLikeRackServer

JRuby + Rackサーバー でSolr Web APIのjavabin形式でレスポンスする簡易テスト用サーバー

## Usage

```ruby
SolrLikeRackServer.start({"/search/map_mini/select"=>YAML.load_file("data.yml")}) {
  # ここでjavabin形式でAPIリクエストする処理のテストを記述する
}
```
