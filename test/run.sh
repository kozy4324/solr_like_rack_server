#!/bin/sh

cd ${0/run.sh}
ruby -I ../lib -rsolr_like_rack_server -e 'SolrLikeRackServer.server({"/search/map_mini/select"=>YAML.load_file("data.yml")}).start'
