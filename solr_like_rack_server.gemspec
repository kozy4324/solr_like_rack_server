# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'solr_like_rack_server/version'

Gem::Specification.new do |spec|
  spec.name          = "solr_like_rack_server"
  spec.version       = SolrLikeRackServer::VERSION
  spec.authors       = ["Koji NAKAMURA"]
  spec.email         = ["kozy4324@mapion.co.jp"]
  spec.summary       = %q{JRuby + Rackサーバー でSolr Web APIのjavabin形式でレスポンスする簡易テスト用サーバー}
  spec.description   = %q{JRuby + Rackサーバー でSolr Web APIのjavabin形式でレスポンスする簡易テスト用サーバー}
  spec.homepage      = "https://github.com/kozy4324/solr_like_rack_server"
  spec.license       = "MIT"

  spec.platform      = "java"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
