# Copyright (c) 2004-2008 David Heinemeier Hansson
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'yaml'
require 'strscan'

module Crack
  
  # <refactor>
  #
  def self.use_standard_json_time_format
    @@use_standard_json_time_format
  end
  def self.use_standard_json_time_format=(val)
    @@use_standard_json_time_format = val
  end
  def self.parse_json_times
    @@parse_json_times
  end
  def self.parse_json_times=(val)
    @@parse_json_times = val
  end
  # If true, use ISO 8601 format for dates and times. Otherwise, fall back to the Active Support legacy format.
  @@use_standard_json_time_format = true
  # Look for and parse json strings that look like ISO 8601 times.
  @@parse_json_times = true
  #
  # </refactor>

  module JSON
    # matches YAML-formatted dates
    DATE_REGEX = /^(?:\d{4}-\d{2}-\d{2}|\d{4}-\d{1,2}-\d{1,2}[ \t]+\d{1,2}:\d{2}:\d{2}(\.[0-9]*)?(([ \t]*)Z|[-+]\d{2}?(:\d{2})?))$/

    class << self
      attr_reader :backend
      # delegate :decode, :to => :backend
      
      def decode(json)
        @backend.decode(json)
      end
      alias :parse :decode

      def backend=(name)
        if name.is_a?(Module)
          @backend = name
        else
          require "crack/json/backends/#{name.to_s.downcase}.rb"
          @backend = Crack::JSON::Backends::const_get(name)
        end
      end

      def with_backend(name)
        old_backend, self.backend = backend, name
        yield
      ensure
        self.backend = old_backend
      end
    end
  end

  class << self
    def escape_html_entities_in_json
      @escape_html_entities_in_json
    end

    def escape_html_entities_in_json=(value)
      Crack::JSON::Encoding.escape_regex = \
      if value
        /[\010\f\n\r\t"\\><&]/
      else
        /[\010\f\n\r\t"\\]/
      end
      @escape_html_entities_in_json = value
    end
  end

  JSON.backend = 'Yaml'
end