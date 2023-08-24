# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::RingBuffer do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '.new' do
    it 'creates a buffer with given capacity' do
      buf = described_class.new(5)
      expect(buf.capacity).to eq(5)
    end

    it 'raises for zero capacity' do
      expect { described_class.new(0) }.to raise_error(described_class::Error)
    end

    it 'raises for negative capacity' do
      expect { described_class.new(-1) }.to raise_error(described_class::Error)
    end

    it 'raises for non-integer capacity' do
      expect { described_class.new('abc') }.to raise_error(described_class::Error)
    end
  end

  describe '#push' do
    it 'adds elements' do
      buf = described_class.new(3)
      buf.push(1)
      buf.push(2)
      expect(buf.to_a).to eq([1, 2])
    end

    it 'overwrites oldest when full' do
      buf = described_class.new(3)
      buf.push(1)
      buf.push(2)
      buf.push(3)
      buf.push(4)
      expect(buf.to_a).to eq([2, 3, 4])
    end

    it 'returns self for chaining' do
      buf = described_class.new(3)
      expect(buf.push(1)).to be(buf)
    end
  end

  describe '#to_a' do
    it 'returns empty array for empty buffer' do
      expect(described_class.new(3).to_a).to eq([])
    end

    it 'returns elements in insertion order' do
      buf = described_class.new(5)
      [1, 2, 3].each { |v| buf.push(v) }
      expect(buf.to_a).to eq([1, 2, 3])
    end

    it 'returns elements in correct order after wrap' do
      buf = described_class.new(3)
      [1, 2, 3, 4, 5].each { |v| buf.push(v) }
      expect(buf.to_a).to eq([3, 4, 5])
    end
  end

  describe '#size' do
    it 'returns 0 for empty buffer' do
      expect(described_class.new(3).size).to eq(0)
    end

    it 'returns number of elements' do
      buf = described_class.new(5)
      buf.push(1)
      buf.push(2)
      expect(buf.size).to eq(2)
    end

    it 'does not exceed capacity' do
      buf = described_class.new(3)
      5.times { |i| buf.push(i) }
      expect(buf.size).to eq(3)
    end
  end

  describe '#full?' do
    it 'returns false when not full' do
      buf = described_class.new(3)
      buf.push(1)
      expect(buf.full?).to be false
    end

    it 'returns true when full' do
      buf = described_class.new(2)
      buf.push(1)
      buf.push(2)
      expect(buf.full?).to be true
    end
  end

  describe '#empty?' do
    it 'returns true for new buffer' do
      expect(described_class.new(3).empty?).to be true
    end

    it 'returns false after push' do
      buf = described_class.new(3)
      buf.push(1)
      expect(buf.empty?).to be false
    end
  end

  describe '#average' do
    it 'calculates average' do
      buf = described_class.new(5)
      [2, 4, 6].each { |v| buf.push(v) }
      expect(buf.average).to eq(4.0)
    end

    it 'raises for empty buffer' do
      expect { described_class.new(3).average }.to raise_error(described_class::Error)
    end
  end

  describe '#sum' do
    it 'calculates sum' do
      buf = described_class.new(5)
      [1, 2, 3].each { |v| buf.push(v) }
      expect(buf.sum).to eq(6)
    end

    it 'raises for empty buffer' do
      expect { described_class.new(3).sum }.to raise_error(described_class::Error)
    end
  end

  describe '#min' do
    it 'returns minimum' do
      buf = described_class.new(5)
      [3, 1, 2].each { |v| buf.push(v) }
      expect(buf.min).to eq(1)
    end

    it 'raises for empty buffer' do
      expect { described_class.new(3).min }.to raise_error(described_class::Error)
    end
  end

  describe '#max' do
    it 'returns maximum' do
      buf = described_class.new(5)
      [3, 1, 2].each { |v| buf.push(v) }
      expect(buf.max).to eq(3)
    end

    it 'raises for empty buffer' do
      expect { described_class.new(3).max }.to raise_error(described_class::Error)
    end
  end

  describe '#last' do
    it 'returns the last n elements' do
      buf = described_class.new(5)
      [1, 2, 3, 4].each { |v| buf.push(v) }
      expect(buf.last(2)).to eq([3, 4])
    end

    it 'returns single element by default' do
      buf = described_class.new(5)
      buf.push(1)
      buf.push(2)
      expect(buf.last).to eq([2])
    end

    it 'handles wrapped buffer' do
      buf = described_class.new(3)
      [1, 2, 3, 4, 5].each { |v| buf.push(v) }
      expect(buf.last(2)).to eq([4, 5])
    end
  end

  describe '#[]' do
    it 'accesses elements by positive index (0 = oldest)' do
      buf = described_class.new(5)
      [10, 20, 30].each { |v| buf.push(v) }
      expect(buf[0]).to eq(10)
      expect(buf[1]).to eq(20)
      expect(buf[2]).to eq(30)
    end

    it 'accesses elements by negative index (-1 = newest)' do
      buf = described_class.new(5)
      [10, 20, 30].each { |v| buf.push(v) }
      expect(buf[-1]).to eq(30)
      expect(buf[-2]).to eq(20)
      expect(buf[-3]).to eq(10)
    end

    it 'returns nil for out-of-bounds positive index' do
      buf = described_class.new(5)
      [10, 20].each { |v| buf.push(v) }
      expect(buf[5]).to be_nil
    end

    it 'returns nil for out-of-bounds negative index' do
      buf = described_class.new(5)
      [10, 20].each { |v| buf.push(v) }
      expect(buf[-3]).to be_nil
    end

    it 'returns nil for empty buffer' do
      expect(described_class.new(3)[0]).to be_nil
    end

    it 'works after wrap-around' do
      buf = described_class.new(3)
      [1, 2, 3, 4, 5].each { |v| buf.push(v) }
      expect(buf[0]).to eq(3)
      expect(buf[-1]).to eq(5)
    end
  end

  describe '#first' do
    it 'returns single oldest element when n=1' do
      buf = described_class.new(5)
      [10, 20, 30].each { |v| buf.push(v) }
      expect(buf.first).to eq(10)
    end

    it 'returns array of oldest n elements when n>1' do
      buf = described_class.new(5)
      [10, 20, 30].each { |v| buf.push(v) }
      expect(buf.first(2)).to eq([10, 20])
    end

    it 'returns nil for empty buffer with default n' do
      expect(described_class.new(3).first).to be_nil
    end

    it 'returns empty array for empty buffer with n>1' do
      expect(described_class.new(3).first(2)).to eq([])
    end

    it 'works after wrap-around' do
      buf = described_class.new(3)
      [1, 2, 3, 4, 5].each { |v| buf.push(v) }
      expect(buf.first).to eq(3)
      expect(buf.first(2)).to eq([3, 4])
    end
  end

  describe '#clear' do
    it 'removes all elements' do
      buf = described_class.new(5)
      [1, 2, 3].each { |v| buf.push(v) }
      buf.clear
      expect(buf.to_a).to eq([])
      expect(buf.size).to eq(0)
      expect(buf.empty?).to be true
    end

    it 'preserves capacity' do
      buf = described_class.new(5)
      [1, 2, 3].each { |v| buf.push(v) }
      buf.clear
      expect(buf.capacity).to eq(5)
    end

    it 'returns self for chaining' do
      buf = described_class.new(3)
      expect(buf.clear).to be(buf)
    end

    it 'allows reuse after clearing' do
      buf = described_class.new(3)
      [1, 2, 3, 4].each { |v| buf.push(v) }
      buf.clear
      buf.push(10)
      buf.push(20)
      expect(buf.to_a).to eq([10, 20])
      expect(buf.size).to eq(2)
    end

    it 'resets internal head pointer' do
      buf = described_class.new(3)
      [1, 2, 3, 4, 5].each { |v| buf.push(v) }
      buf.clear
      buf.push(100)
      expect(buf.to_a).to eq([100])
      expect(buf[0]).to eq(100)
    end
  end

  describe '#variance' do
    it 'calculates population variance' do
      buf = described_class.new(5)
      [2, 4, 4, 4, 5, 5, 7, 9].last(5).each { |v| buf.push(v) }
      # values: [4, 5, 5, 7, 9], mean = 6.0, variance = (4+1+1+1+9)/5 = 3.2
      expect(buf.variance).to be_within(0.0001).of(3.2)
    end

    it 'returns 0.0 for empty buffer' do
      expect(described_class.new(3).variance).to eq(0.0)
    end

    it 'returns 0.0 for single element' do
      buf = described_class.new(5)
      buf.push(42)
      expect(buf.variance).to eq(0.0)
    end

    it 'returns 0.0 when all elements are equal' do
      buf = described_class.new(5)
      [3, 3, 3].each { |v| buf.push(v) }
      expect(buf.variance).to eq(0.0)
    end

    it 'works after wrap-around' do
      buf = described_class.new(3)
      [1, 2, 3, 4, 5].each { |v| buf.push(v) }
      # values: [3, 4, 5], mean = 4.0, variance = (1+0+1)/3
      expect(buf.variance).to be_within(0.0001).of(0.6667)
    end
  end

  describe '#stddev' do
    it 'calculates population standard deviation' do
      buf = described_class.new(5)
      [2, 4, 4, 4, 5].each { |v| buf.push(v) }
      expected_var = buf.variance
      expect(buf.stddev).to be_within(0.0001).of(Math.sqrt(expected_var))
    end

    it 'returns 0.0 for empty buffer' do
      expect(described_class.new(3).stddev).to eq(0.0)
    end

    it 'returns 0.0 for single element' do
      buf = described_class.new(5)
      buf.push(42)
      expect(buf.stddev).to eq(0.0)
    end
  end

  describe '#median' do
    it 'returns median for odd count' do
      buf = described_class.new(5)
      [3, 1, 2].each { |v| buf.push(v) }
      expect(buf.median).to eq(2.0)
    end

    it 'returns median for even count' do
      buf = described_class.new(5)
      [3, 1, 2, 4].each { |v| buf.push(v) }
      expect(buf.median).to eq(2.5)
    end

    it 'returns nil for empty buffer' do
      expect(described_class.new(3).median).to be_nil
    end

    it 'returns value for single element' do
      buf = described_class.new(5)
      buf.push(42)
      expect(buf.median).to eq(42.0)
    end

    it 'works after wrap-around' do
      buf = described_class.new(3)
      [1, 2, 3, 4, 5].each { |v| buf.push(v) }
      # values: [3, 4, 5], median = 4.0
      expect(buf.median).to eq(4.0)
    end
  end

  describe 'Enumerable' do
    it 'supports map' do
      buf = described_class.new(5)
      [1, 2, 3].each { |v| buf.push(v) }
      expect(buf.map { |v| v * 2 }).to eq([2, 4, 6])
    end

    it 'supports select' do
      buf = described_class.new(5)
      [1, 2, 3, 4].each { |v| buf.push(v) }
      expect(buf.select(&:even?)).to eq([2, 4])
    end
  end

  describe '#shift' do
    it 'returns nil when empty' do
      expect(described_class.new(3).shift).to be_nil
    end

    it 'removes and returns the oldest element' do
      buf = described_class.new(3)
      [1, 2, 3].each { |v| buf.push(v) }
      expect(buf.shift).to eq(1)
      expect(buf.size).to eq(2)
      expect(buf.to_a).to eq([2, 3])
    end

    it 'returns the correct element after wrap-around' do
      buf = described_class.new(3)
      [1, 2, 3, 4, 5].each { |v| buf.push(v) }
      # buffer now holds [3, 4, 5]
      expect(buf.shift).to eq(3)
      expect(buf.to_a).to eq([4, 5])
    end
  end

  describe '#pop' do
    it 'returns nil when empty' do
      expect(described_class.new(3).pop).to be_nil
    end

    it 'removes and returns the newest element' do
      buf = described_class.new(3)
      [1, 2, 3].each { |v| buf.push(v) }
      expect(buf.pop).to eq(3)
      expect(buf.size).to eq(2)
      expect(buf.to_a).to eq([1, 2])
    end

    it 'preserves order across pop then push' do
      buf = described_class.new(3)
      [1, 2, 3].each { |v| buf.push(v) }
      buf.pop
      buf.push(99)
      expect(buf.to_a).to eq([1, 2, 99])
    end
  end

  describe '#oldest and #newest' do
    it 'return nil when empty' do
      buf = described_class.new(3)
      expect(buf.oldest).to be_nil
      expect(buf.newest).to be_nil
    end

    it 'return the oldest and newest without mutating' do
      buf = described_class.new(3)
      [10, 20, 30].each { |v| buf.push(v) }
      expect(buf.oldest).to eq(10)
      expect(buf.newest).to eq(30)
      expect(buf.size).to eq(3)
    end

    it 'reflect wrap-around correctly' do
      buf = described_class.new(3)
      [1, 2, 3, 4, 5].each { |v| buf.push(v) }
      expect(buf.oldest).to eq(3)
      expect(buf.newest).to eq(5)
    end
  end

  describe 'mixed mutation' do
    it 'keeps to_a consistent across push/shift/pop sequences' do
      buf = described_class.new(4)
      [1, 2, 3, 4, 5].each { |v| buf.push(v) } # [2, 3, 4, 5]
      expect(buf.shift).to eq(2)                  # [3, 4, 5]
      expect(buf.pop).to eq(5)                    # [3, 4]
      buf.push(6)                                 # [3, 4, 6]
      buf.push(7)                                 # [3, 4, 6, 7]
      buf.push(8)                                 # [4, 6, 7, 8]
      expect(buf.to_a).to eq([4, 6, 7, 8])
      expect(buf.oldest).to eq(4)
      expect(buf.newest).to eq(8)
    end
  end
end
