java_import Java::java.io.ByteArrayOutputStream
java_import Java::java.io.OutputStreamWriter
java_import Java::java.util.HashMap
java_import Java::org.apache.solr.common.SolrDocument
java_import Java::org.apache.solr.common.SolrDocumentList
java_import Java::org.apache.solr.common.params.SolrParams
java_import Java::org.apache.solr.common.util.NamedList
java_import Java::org.apache.solr.request.SolrQueryRequestBase
java_import Java::org.apache.solr.response.SolrQueryResponse
java_import Java::org.apache.solr.response.XMLResponseWriter
java_import Java::org.apache.solr.response.BinaryResponseWriter

module SolrLikeRackServer
  # Abstractなクラスを継承
  class MySolrQueryRequest < SolrQueryRequestBase; end
  class MySolrParams < SolrParams
    def get param
      nil
    end
    def getParams param
      []
    end
    def getParameterNamesIterator
      HashMap.new.keySet.iterator
    end
  end

  class ResponseWriterWrapper
    # SolrQueryRequest
    def request
      MySolrQueryRequest.new nil, MySolrParams.new
    end

    # SolrQueryResponse
    def response data
      docList = SolrDocumentList.new
      # docs
      data["docs"].each {|d|
        doc = SolrDocument.new
        d.each {|k,v|
          v = Java::java.lang.Integer.new(v) if Fixnum === v
          doc.setField k, v
        }
        docList.add doc
      }
      docList.setNumFound data["numFound"] || data["docs"].size
      docList.setStart 0
      docList.setMaxScore 1.0
      res = SolrQueryResponse.new
      res.add "response", docList
      # facets
      if data.has_key? "facets"
        facet_counts = NamedList.new
        res.add "facet_counts", facet_counts
        facet_fields = NamedList.new
        facet_counts.add "facet_fields", facet_fields
        data["facets"].each {|facet_key, facet_data|
          facet = NamedList.new
          facet_fields.add facet_key, facet
          facet_data.each {|f| f.each {|k, v| facet.add k, v } }
        }
      end
      res
    end

    def responseWriter
      BinaryResponseWriter.new
    end

    def write data
      outputStream = ByteArrayOutputStream.new
      responseWriter.write outputStream, request, response(data)
      byteArray = outputStream.toByteArray
      String.from_java_bytes byteArray
    end
  end
end
