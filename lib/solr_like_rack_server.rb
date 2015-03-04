Dir.glob("#{__FILE__}/jars/*.jar".sub("/solr_like_rack_server.rb", "")).each {|jar| $CLASSPATH << jar }

require "webrick"
require "yaml"
require "solr_like_rack_server/version"
require "solr_like_rack_server/response_writer_wrapper"

module SolrLikeRackServer
  class << self
    def server
      @server ||= create_server
    end

    def create_server
      opt = {
        Port: 12345,
        Logger: WEBrick::Log.new('/dev/null'),
        AccessLog: [],
        StartCallback: Proc.new {
          Thread.main.wakeup
        }
      }
      unless ENV["SOLR_LIKE_RACK_SERVER_VERBOSE"].nil?
        opt.delete :Logger
        opt.delete :AccessLog
      end
      server = WEBrick::HTTPServer.new opt
      Thread.new do
        server.start
      end
      Thread.stop
      at_exit {
        server.shutdown
      }
      server
    end

    def start mount_procs
      mounted = []
      mount_procs.each {|dir, proc|
        server.mount_proc(dir) {|req, res|
          res["Content-Type"] = "application/octet-stream"
          data = if Proc === proc
            if proc.arity == 0
              proc.call
            else
              proc.call req.query
            end
          else
            proc
          end
          data = if Array === data
            {"docs"=>data}
          elsif Hash === data
            data["docs"] = [] unless data.has_key? "docs"
            data["facets"] = {} unless data.has_key? "facets"
            data
          end
          res.body = SolrLikeRackServer::ResponseWriterWrapper.new.write data
        }
        mounted << dir
      }
      begin
        yield
      ensure
        mounted.each {|dir| server.unmount dir }
      end
    end
  end
end
