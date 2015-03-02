Dir.glob("#{__FILE__}/jars/*.jar".sub("/solr_like_rack_server.rb", "")).each {|jar| $CLASSPATH << jar }

require "webrick"
require "yaml"
require "solr_like_rack_server/version"
require "solr_like_rack_server/response_writer_wrapper"

module SolrLikeRackServer
  class << self
    def start mount_procs
      wakeupProc = nil
      server = WEBrick::HTTPServer.new(
        Port: 12345,
        Logger: WEBrick::Log.new('/dev/null'),
        AccessLog: [],
        StartCallback: Proc.new {
          wakeupProc.call unless wakeupProc.nil?
        }
      )
      mount_procs.each {|path, proc|
        server.mount_proc(path) {|req, res|
          res["Content-Type"] = "application/octet-stream"
          data = if Array === proc
            proc
          elsif Hash === proc
            [proc]
          elsif proc.arity == 0
            proc.call
          else
            proc.call(req.query)
          end
          res.body = SolrLikeRackServer::ResponseWriterWrapper.new.write data
        }
      }
      if block_given?
        wakeupProc = Proc.new { Thread.main.wakeup }
        server_thread = Thread.new do
          Thread.current[:server] = server
          server.start
        end
        Thread.stop
        begin
          yield
        ensure
          server_thread[:server].shutdown
        end
      else
        server
      end
    end

    alias_method :server, :start
  end
end
