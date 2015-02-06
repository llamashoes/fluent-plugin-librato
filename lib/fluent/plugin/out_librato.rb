module Fluent
  class LibratoOutput < BufferedOutput
    Plugin.register_output('librato', self)

    config_param :email, :string
    config_param :apikey, :string
    config_param :value_key, :string, :default => "value"
    config_param :measurement_key, :string, :default => "key"
    config_param :source_key, :string, :default => "source"
    config_param :type_key, :string, :default => "type"

    def configure(conf)
      super
      require 'librato/metrics'
      Librato::Metrics.authenticate @email, @apikey
      @queue = Librato::Metrics::Queue.new
    end

    def start
      # This is where you instantiate resources specific to the output, e.g.
      # database connections, client library, etc.
      super
    end

    def shutdown
      super
      @queue.submit
    end

    def write(chunk)
      chunk.msgpack_each { |tag, time, record|
        record[@source_key] ||= tag
        missing_keys = [@measurement_key, @value_key, @source_key].select { |k| !record[k] }
        if missing_keys.length > 0
          log.warn "missing the required field(s) " + missing_keys.join(",")
          next
        end

        if record[@source_key].length > 63
          log.warn "source key is longer than 63 characters and will be truncated in Librato."
        end

        @queue.add(
          record[@measurement_key].to_s =>
            {
              :source => record[@source_key],
              :value => record[@value_key],
              :type => record[@type_key] || "gauge"
            })
      }
      
      @queue.submit
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end
  end
end
