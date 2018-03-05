require 'settei/base'

RSpec.describe Settei::Base do
  subject {
    described_class.new(
      foo: {
        bar: {
          baz: 42
        }
      }
    )
  }

  describe '#initialize' do
    it 'initializes when hash is supplied' do
      expect {
        described_class.new({a:1})
      }.not_to raise_error
    end

    it 'raises error if config is not a hash' do
      expect {
        described_class.new(1)
      }.to raise_error(ArgumentError)
    end
  end

  describe '#dig' do
    it 'returns dig value as is for the inner hash' do
      result = subject.dig(:foo, :bar)
      expect(result).to be_a Hash
      expect(result).to eq({'baz' => 42})
    end

    it 'returns dig value as is if it is not a hash' do
      result = subject.dig(:foo, :bar, :baz)
      expect(result).to eq(42)
    end
  end

  describe '#dig_and_wrap' do
    it 'returns a Settei::Base for the inner hash' do
      result = subject.dig_and_wrap(:foo, :bar)
      expect(result).to be_a described_class
      expect(result.to_h).to eq({'baz' => 42})
      expect(result.to_hash).to eq({'baz' => 42})
    end

    it 'returns dig value as is if it is not a hash' do
      result = subject.dig_and_wrap(:foo, :bar, :baz)
      expect(result).to eq(42)
    end
  end

  describe '#merge!' do
    it 'merge hash' do
      subject.merge!(foo: 2, bar: 3)
      expect(subject.fetch(:foo)).to eq(2)
      expect(subject.fetch(:bar)).to eq(3)
    end
  end

  describe '#merge' do
    it 'merge hash' do
      new_hash = {"foo" => 2, "bar" => 3}
      previous_hash = subject.to_h
      result = subject.merge(new_hash)
      expect(subject.to_h).to eq(previous_hash)
      expect(result.to_h).to eq(new_hash)
    end
  end
end