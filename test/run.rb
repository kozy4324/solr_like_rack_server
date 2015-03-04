#!/usr/bin/env ruby
# coding: utf-8

require "pathname"
p_dir = Pathname.new("#{__FILE__}/../../").realpath.to_s
$LOAD_PATH << "#{p_dir}/lib"
require "solr_like_rack_server"

$CLASSPATH << "#{p_dir}/test/localsearch-client-1.0.13-jar-with-dependencies.jar"
java_import Java::jp.co.mapion.solr.client.core.LocalSearchClient

map_mini = YAML.load <<EOM
numFound: 1234
docs:
  - poi_code: G0123456789
    category1_code:
      - M01
facets:
  pref_ddd:
    - "13:東京都": 12039
  area_code:
    - "002": 24849
EOM
reco_city = YAML.load <<EOM
- pref_code: "13"
  pref_name: 東京都
  city_code: "13101"
  city_name: 東京都千代田区
  category2_code: M01001
  category2_name: M01001の名前
  station_code: ST12345
  station_name: 東京駅
  poi_num: 100
EOM

SolrLikeRackServer.start(
  "/search/map_mini/select"=>map_mini,
  "/search/reco_city/select"=>reco_city,
) {
  client = LocalSearchClient.new "map_mini"
  client.executeQuery
  puts client.getBeans(Java::jp.co.mapion.solr.client.beans.Phone.java_class).get(0).poi_code
  puts client.getNumFound
  facet = client.getFacetList("pref_ddd")[0]
  puts facet.code
  puts facet.name
  puts facet.count

  client = LocalSearchClient.new "reco_city"
  client.executeQuery
  puts client.getBeans(Java::jp.co.mapion.solr.client.beans.Recommendation.java_class).get(0).pref_code
  puts client.getNumFound
}

SolrLikeRackServer.start(
  "/search/map_mini2/select"=>map_mini,
) {
  client = LocalSearchClient.new "map_mini2"
  client.executeQuery
  puts client.getBeans(Java::jp.co.mapion.solr.client.beans.Phone.java_class).get(0).poi_code
  puts client.getNumFound
}
