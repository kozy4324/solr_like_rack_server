#!/usr/bin/env ruby

require "pathname"
p_dir = Pathname.new("#{__FILE__}/../../").realpath.to_s
$LOAD_PATH << "#{p_dir}/lib"
require "solr_like_rack_server"

$CLASSPATH << "#{p_dir}/test/localsearch-client-1.0.13-jar-with-dependencies.jar"
java_import Java::jp.co.mapion.solr.client.core.LocalSearchClient

data = YAML.load <<EOM
numFound: 1234
docs:
  - poi_code: G0123456789
    category1_code:
      - M01
EOM

SolrLikeRackServer.server(
  "/search/map_mini/select"=>data
) {
  client = LocalSearchClient.new "map_mini"
  client.executeQuery
  puts client.getBeans(Java::jp.co.mapion.solr.client.beans.Phone.java_class).get(0).poi_code
  puts client.getNumFound
}
