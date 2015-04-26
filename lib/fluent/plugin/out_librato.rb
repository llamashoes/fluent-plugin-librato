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

    def invalid_characters?(value)
      /^[A-Za-z0-9.:\-_]+$/.match(value).nil?
    end

    def validate_fields(record)
      if record[@source_key].length > 63
          log.warn "Source value is longer than 63 characters and will be truncated in Librato."
      end

      if invalid_characters? record[@source_key]
          log.error "Source value may only contain characters 'A-Za-z0-9.:-_'."
      end

      if record[@measurement_key].length > 63
          log.warn "Measurement value is longer than 63 characters and will be truncated in Librato."
      end

      if invalid_characters? record[@measurement_key]
          log.error "Measurement value may only contain characters 'A-Za-z0-9.:-_'."
      end
    end

    def write(chunk)
      chunk.msgpack_each { |tag, time, record|
        record[@source_key] ||= tag
        missing_keys = [@measurement_key, @value_key, @source_key].select { |k| !record[k] }
        if missing_keys.length > 0
          log.warn "missing the required field(s) " + missing_keys.join(",")
          next
        end

        validate_fields record

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
