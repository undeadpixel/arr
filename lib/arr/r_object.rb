
module Arr
  class RObject

    def self.factory(json)
      hash = JSON.parse(json)
      
      case hash['type']
      when 'double' then hash['value'].first.to_f
      when 'character' then hash['value'].first
      when 'logical' then hash['value'].first == 'true'
      else RObject.new(json, hash)
      end
    end

    def initialize(json, hash)
      @json = json
      @hash = hash
    end

    def type
      @hash['type']
    end

    def attributes
      @hash['attributes']
    end

    def value
      @hash['value']
    end
  end
end
