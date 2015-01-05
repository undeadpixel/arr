module Arr
  class RObject
    class Builder

      BASIC_TYPES = {
        'double' => lambda {|value| process_double(value)},
        'numeric' => lambda {|value| value.to_f},
        'integer' => lambda {|value| value.to_i},
        'character' => lambda {|value| value.to_s},
        'logical' => lambda {|value| process_logical(value)}
      }

      def initialize(hash)
        @type = hash['type']
        @values = hash['value']
        @attributes = hash['attributes']
      end

      def process
        if is_basic_type?
          process_basic_type
        elsif @type == 'list'
          process_list_or_class
        # elsif @type == 'NULL'
        #   nil
        else
          nil
        end
      end

      def self.build(hash)
        builder = Builder.new(hash)
        builder.process
      end

      private

      def is_basic_type?
        BASIC_TYPES.keys.include?(@type)
      end

      def process_basic_type
        @values.map {|value| BASIC_TYPES[@type].call(value) }
      end

      def self.process_double(value)
        if value == 'NaN'
          Float::NAN
        elsif value == 'Inf'
          Float::INFINITY
        elsif value == '-Inf'
          -Float::INFINITY
        else
          value.to_f
        end
      end

      def self.process_logical(value)
        if value.nil?
          Arr::NA
        else
          value === true
        end
      end

      def process_list_or_class
        list = process_list
        @attributes['class'] ? process_class(@attributes['class']['value'], list) : list
      end

      def process_list
        keys = Builder.build(@attributes['names'])
        values = @values.map {|value| Builder.build(value)}
        Hash[keys.zip(values)]
      end

      def process_class(name, list)
        RObject.new(name, list)
      end
    end
  end
end
