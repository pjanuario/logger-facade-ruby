module LoggerFacade::Middleware
  class Rack < Rack::CommonLogger
    def initialize(app, logger=nil)
      log = LoggerFacade::Manager.get_logger("RackLogger")
      @format = '%s "%s %s%s" %d %s %0.4f'
      super(app, log)
    end

    private

    def log(env, status, header, began_at)
      metadata = get_metadata(env, status, header, began_at)

      msg = @format % [
        metadata["client_ip"] || "-",
        metadata["method"],
        metadata["path"],
        metadata["query_string"].empty? ? "" : "?" + metadata["query_string"],
        metadata["status"].to_s[0..3],
        metadata["size"],
        metadata["response_time"] ]

      @logger.info(msg, metadata)
    end

    def get_metadata(env, status, header, began_at)
      length = extract_content_length(header)
      {
        'client_ip'     => env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"],
        'method'        => env["REQUEST_METHOD"],
        'path'          => env["PATH_INFO"],
        'query_string'  => env["QUERY_STRING"],
        'status'        => status,
        'size'          => length.to_i,
        'response_time' => Time.now - began_at
      }
    end

  end
end
