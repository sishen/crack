require 'json' unless defined?(::JSON)
module Crack
  module JSON
    ParseError = ::JSON::ParserError
 
    module Backends
      module JSONGem
        extend self
 
        # Converts a JSON string into a Ruby object.
        def decode(json)
          data = ::JSON.parse(json)
          if Crack.parse_json_times
            convert_dates_from(data)
          else
            data
          end
        end
 
      private
        def convert_dates_from(data)
          case data
            when DATE_REGEX
              DateTime.parse(data)
            when Array
              data.map! { |d| convert_dates_from(d) }
            when Hash
              data.each do |key, value|
                data[key] = convert_dates_from(value)
              end
            else data
          end
        end
      end
    end
  end
end