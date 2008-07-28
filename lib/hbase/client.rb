require 'net/http'
require 'hbase/operation/mix_operation'
require 'hbase/operation/table_operation'
require 'hbase/operation/row_operation'
require 'hbase/operation/scanner_operation'

module HBase
  class Client
    include Operation::MixOperation
    include Operation::TableOperation
    include Operation::RowOperation
    include Operation::ScannerOperation

    attr_reader :url, :connection

    def initialize(url = "http://localhost:60010/api", opts = {})
      @url = URI.parse(url)
      unless @url.kind_of? URI::HTTP
        raise "invalid http url: #{url}"
      end

      # Not actually opening the connection yet, just setting up the persistent connection.
      @connection = Net::HTTP.new(@url.host, @url.port)
      @connection.read_timeout = opts[:timeout] if opts[:timeout]
    end

    def get(request)
      safe_request { @connection.get(@url.path + request.path) }
    end

    def post(request)
      safe_request { @connection.post(@url.path + request.path, request.data, {'Content-Type' => 'text/xml'}) }
    end

    private
    def safe_request(&block)
      response = yield
      case response
        when Net::HTTPSuccess then response.body
      else
        response.error!
      end
    end
  end
end