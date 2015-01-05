require 'spec_helper'

describe Arr::RObject do

  describe '.factory' do

    subject { Arr::RObject.factory(json) }

    #
    # Basic types:
    # - Numbers (type = double, integer, numeric)
    # - Chars (type = character)
    # - Booleans (type = logical)
    # - NULL (type = NULL)
    # Special values:
    # - NA (Will have to do sth here...) (type = logical, value = nil)
    # - NaN (use Float::NAN) (type = double, value = "NaN")
    # - -Inf and Inf (use Float::INFINITY) (type = double, value = "-Inf")
    # Arrays:
    # - Arrays (type = whatever basic type)
    # - Named arrays (the same but with attributes->names; need to encapsulate!) (TODO)
    # Matrices:
    # - Matrices (type = whatever basic type; they have dim) (TODO)
    # Complex types:
    # - Lists (type = list with attributes and multiple values)
    # - Tables (type = list but class = table) (TODO)
    # - Data frames (sophisticate it a little) (TODO)
    # - Other types are generated from these
    #

    context 'with basic types' do
      context 'when input is a double' do
        let(:json) { "{\"type\":\"double\",\"attributes\":{},\"value\":[#{value}]}" }
        
        context 'and is a real number' do
          let(:value) { 1.5 }

          it('returns a float') { expect(subject.first).to be_a Float }
          it('returns the correct value') { expect(subject).to eq([1.5]) }
        end

        context 'and is NaN' do
          let(:value) { '"NaN"' }

          it('returns Float::NAN') { expect(subject).to eq([Float::NAN]) }
        end

        context 'and is -Inf' do
          let(:value) { '"-Inf"' }

          it('returns -Float::Infinity') { expect(subject).to eq([-Float::INFINITY]) }
        end

        context 'and is Inf' do
          let(:value) { '"Inf"' }

          it('returns Float::Infinity') { expect(subject).to eq([Float::INFINITY]) }
        end
      end

      context 'when input is a numeric' do
        let(:json) { "{\"type\":\"numeric\",\"attributes\":{},\"value\":[1.5]}" }

        it('returns a float') { expect(subject.first).to be_a Float }
        it('returns the correct value') { expect(subject).to eq([1.5]) }
      end

      context 'when input is an integer' do
        let(:json) { "{\"type\":\"integer\",\"attributes\":{},\"value\":[3]}" }

        it('returns an integer') { expect(subject.first).to be_a Integer }
        it('returns the correct value') { expect(subject).to eq([3]) }
      end

      context 'when input is a string' do
        let(:json) { "{\"type\":\"character\",\"attributes\":{},\"value\":[\"hello\"]}" }

        it('returns a string') { expect(subject).to eq(["hello"]) }
      end

      context 'when input is a logical' do
        let(:json) { "{\"type\":\"logical\",\"attributes\":{},\"value\":[#{value}]}" }
        
        context 'and is TRUE or FALSE' do
          let(:value) { "true" }
          it('returns a boolean') { expect(subject).to eq([true]) }
        end

        context 'and is NA' do
          let(:value) { "null" }

          it('returns Arr::NA') { expect(subject).to eq([Arr::NA]) }
        end
      end

      context 'when input is NULL' do
        let(:json) { "{\"type\":\"NULL\",\"attributes\":{},\"value\":{}}" }

        it('returns nil') { expect(subject).to eq(nil) }
      end
    end

    context 'when input is an array' do
      let(:json) { "{\"type\":\"double\",\"attributes\":{},\"value\":[1,2,3,4,5]}" }

      it('returns an array with all the values') { expect(subject).to eq([1.0,2.0,3.0,4.0,5.0]) }
    end


    context 'with lists' do
      context 'when input is a simple list' do
        let(:json) { load_data('r_object/simple_list.json') }

        it('returns a hash with all the keys and values') { expect(subject).to eq({'a' => [1], 'b' => [2], 'c' => ['asd']}) }
      end

      context 'when input is a nested list' do
        let(:json) { load_data('r_object/nested_list.json') }

        it('returns a hash with all the keys and values') { expect(subject).to eq({'a' => {'b' => [2], 'c' => [3]}, 'd' => [4]}) }
      end
    end

    context 'with R classes' do
      context 'when input is a R class' do
        let(:json) { load_data('r_object/simple_r_object.json') }

        it("returns a RObject") { expect(subject).to be_a(Arr::RObject) }
        it("has correct attributes") { expect(subject.attributes).to eq({"statistic"=>[1.27951069], "parameter"=>[9.0], "p.value"=>[0.23271649], "conf.int"=>[-0.25841773, 0.93139272], "estimate"=>[0.33648749], "null.value"=>[0.0], "alternative"=>["two.sided"], "method"=>["One Sample t-test"], "data.name"=>["rnorm(10)"]}) }
      end
    end
  end

  # METHODS

  let(:attributes) { {'a' => 1, 'b' => 2, 'c.d' => 3} }
  let(:r_object) { Arr::RObject.new('blah', attributes) }

  describe '#[]' do

    subject { r_object[attribute] }

    context 'when accessing an existing element' do
      let(:attribute) { 'a' }

      it('returns attribute value') { expect(subject).to eq(1) }
    end

    context 'when accessing an existing element that has .' do
      let(:attribute) { 'c.d' }

      it('returns attribute value') { expect(subject).to eq(3) }
    end

    context 'when accessing a non existant element' do
      let(:attribute) { 'error' }

      it('returns nil') { expect(subject).to eq(nil) }
    end
  end

  describe '#method_missing' do
    subject { r_object.send(method) }

    context 'when calling a method that an attribute has the same name' do
      let(:method) { 'a' }

      it('returns attribute value') { expect(subject).to eq(1) }
    end

    context 'when calling a method that doesnt exist' do
      let(:method) { 'error' }

      it('raises a NoMethodError') { expect { subject }.to raise_error(NoMethodError) }
    end

    context 'when calling for a method that matches to an attribute with all . -> _' do
      let(:method) { 'c_d' }

      it('returns attribute value') { expect(subject).to eq(3) }
    end

    context 'when calling for a method that matches to an attribute with .' do
      let(:method) { 'c.d' }

      it('returns attribute value') { expect(subject).to eq(3) }
    end
  end
end
