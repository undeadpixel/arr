
require 'arr/r_object/builder'

module Arr
  class RObject

    attr_accessor :r_classes, :attributes

    def self.factory(hash_or_json)
      hash = hash_or_json
      hash = JSON.parse(hash) unless hash.is_a? Hash

      Builder.build(hash)
    end

    def initialize(r_classes, attributes)
      @r_classes = r_classes

      initialize_attributes(attributes)
    end

    def is_r_class?(r_class)
      @r_classes.include?(r_class)
    end

    def [](attr)
      value_for_key(attr)
    end

    def method_missing(method, *args, &block)
      value_for_key(method.to_s) || super
    end

    private

    def initialize_attributes(attributes)
      @attributes = attributes
      @stringified_attributes = attributes.keys.each_with_object({}) do |attribute,hash|
        hash[attribute.to_s.gsub('.', '_')] = attribute
      end
    end

    def value_for_key(key)
      key = @stringified_attributes[key] if @stringified_attributes.keys.include?(key)
      @attributes[key]
    end

  end
end
