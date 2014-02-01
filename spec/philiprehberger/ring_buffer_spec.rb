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
end
