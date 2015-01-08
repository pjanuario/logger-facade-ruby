module LoggerFacade::Middleware
  class Rack < Rack::CommonLogger
    def initialize(app, logger=nil)
      log = LoggerFacade::Manager.get_logger("RackLogger")
      @format = '%s "%s %s" %d %s %0.4f'
      super(app, log)
    end

    private

    def log(env, status, header, began_at)
      metadata = get_metadata(env, status, header, began_at)

      msg = @format % [
        metadata["clientip"] || "-",
        metadata["verb"],
        metadata["request"],
        metadata["response"].to_s[0..3],
        metadata["bytes"],
        metadata["request_time"] ]

      @logger.info(msg, metadata)
    end

    def get_metadata(env, status, header, began_at)
      length = extract_content_length(header)
      qs = env["QUERY_STRING"].empty? ? "" : "?#{env["QUERY_STRING"]}"
      {
        'clientip'     => env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"],
        'verb'        => env["REQUEST_METHOD"],
        'request'          => "#{env["PATH_INFO"]}#{qs}",
        'http_version'  => env["HTTP_VERSION"],
        'response'        => status.to_s,
        'bytes'          => (length || "").to_i,
        'referrer'          => env["HTTP_REFERER"],
        'agent'         => env['HTTP_USER_AGENT'],
        'request_time' => Time.now - began_at,
        'request_full_url' => env['REQUEST_URI']
      }
    end

  end
end
