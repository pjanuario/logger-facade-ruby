module LoggerFacade::Middleware
  class Rack < Rack::CommonLogger
    def initialize(app, logger=nil)
      log = LoggerFacade::Manager.get_logger("RackLogger")
      @format = '%s "%s %s%s" %d %s %0.4f'
      super(app, log)
    end

    private

    def log(env, status, header, began_at)
      length = extract_content_length(header)

      json = {
        'client_ip'=> env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"],
        'method'   => env["REQUEST_METHOD"],
        'path'     => env["PATH_INFO"],
        'query_string'     => env["QUERY_STRING"],
        'status'   => status,
        'size'     => length,
        'response_time' => Time.now - began_at
      }

      msg = @format % [
        json["client_ip"] || "-",
        json["method"],
        json["path"],
        json["query_string"].empty? ? "" : "?" + json["query_string"],
        json["status"].to_s[0..3],
        json["size"],
        json["response_time"] ]

      @logger.info(msg)
    end
  end
end
