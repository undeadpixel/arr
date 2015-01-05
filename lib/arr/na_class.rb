
require 'singleton'

module Arr
  class NAClass
    
    include Singleton

    UNARY_OPERATORS = %w{+@ -@ ~@ !}
    UNARY_OPERATORS.each do |operator|
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{operator}
          self
        end
      RUBY
    end

    BINARY_OPERATORS = %w{+ - * / % ** >> << & ^ |}
    BINARY_OPERATORS.each do |operator|
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{operator}(other)
          self
        end
      RUBY
    end

    # comparisons

    def ==(other)
      other.is_a? Arr::NAClass
    end

    def <=>(other)
      (other.is_a? Arr::NAClass) ? 0 : nil
    end

    %w{< <= > >=}.each do |operator|
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{operator}(other)
          false
        end
      RUBY
    end

    # else num*NA would give an error
    def coerce(other)
      [self, other]
    end

    # some nice visualisation
    def inspect
      "NA"
    end
  end

  NA = NAClass.instance
end

# monkey patching!!! (YAY!!!)
class Object
  def na?
    self.is_a?(Arr::NAClass)
  end
end
