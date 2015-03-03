#!/usr/bin/env ruby

require "pathname"
p_dir = Pathname.new("#{__FILE__}/../../").realpath.to_s
$LOAD_PATH << "#{p_dir}/lib"
require "solr_like_rack_server"

$CLASSPATH << "#{p_dir}/test/localsearch-client-1.0.13-jar-with-dependencies.jar"
java_import Java::jp.co.mapion.solr.client.core.LocalSearchClient

SolrLikeRackServer.server(
  "/search/map_mini/select"=>YAML.load_file("#{p_dir}/test/data.yml")
) {
  client = LocalSearchClient.new "map_mini"
  client.executeQuery
  puts client.getBeans(Java::jp.co.mapion.solr.client.beans.Phone.java_class).get(0).poi_code
  puts client.getNumFound
}
