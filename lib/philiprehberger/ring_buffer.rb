# frozen_string_literal: true

require_relative 'ring_buffer/version'

module Philiprehberger
  class RingBuffer
    include Enumerable

    class Error < StandardError; end

    attr_reader :capacity

    # Create a new ring buffer with fixed capacity
    #
    # @param capacity [Integer] maximum number of elements
    def initialize(capacity)
      raise Error, 'capacity must be a positive integer' unless capacity.is_a?(Integer) && capacity.positive?

      @capacity = capacity
      @buffer = Array.new(capacity)
      @head = 0
      @count = 0
    end

    # Push a value into the buffer, overwriting oldest if full
    #
    # @param value [Object]
    # @return [self]
    def push(value)
      @buffer[@head] = value
      @head = (@head + 1) % @capacity
      @count += 1 if @count < @capacity
      self
    end

    # Convert buffer contents to an array (oldest first)
    #
    # @return [Array]
    def to_a
      return [] if @count.zero?

      start = (@head - @count) % @capacity
      Array.new(@count) { |i| @buffer[(start + i) % @capacity] }
    end

    # Remove and return the oldest element
    #
    # @return [Object, nil]
    def shift
      return nil if empty?

      start = (@head - @count) % @capacity
      value = @buffer[start]
      @buffer[start] = nil
      @count -= 1
      value
    end

    # Remove and return the newest element
    #
    # @return [Object, nil]
    def pop
      return nil if empty?

      newest_idx = (@head - 1) % @capacity
      value = @buffer[newest_idx]
      @buffer[newest_idx] = nil
      @head = newest_idx
      @count -= 1
      value
    end

    # Return the oldest element without removing it
    #
    # @return [Object, nil]
    def oldest
      return nil if empty?

      @buffer[(@head - @count) % @capacity]
    end

    # Return the newest element without removing it
    #
    # @return [Object, nil]
    def newest
      return nil if empty?

      @buffer[(@head - 1) % @capacity]
    end

    # Number of elements currently in the buffer
    #
    # @return [Integer]
    def size
      @count
    end

    # Check if the buffer is full
    #
    # @return [Boolean]
    def full?
      @count == @capacity
    end

    # Check if the buffer is empty
    #
    # @return [Boolean]
    def empty?
      @count.zero?
    end

    # Calculate average of numeric elements
    #
    # @return [Float]
    def average
      raise Error, 'buffer is empty' if empty?

      sum.to_f / @count
    end

    # Calculate sum of numeric elements
    #
    # @return [Numeric]
    def sum
      raise Error, 'buffer is empty' if empty?

      to_a.sum
    end

    # Find minimum element
    #
    # @return [Object]
    def min
      raise Error, 'buffer is empty' if empty?

      to_a.min
    end

    # Find maximum element
    #
    # @return [Object]
    def max
      raise Error, 'buffer is empty' if empty?

      to_a.max
    end

    # Return the last n elements (most recent)
    #
    # @param n [Integer] number of elements
    # @return [Array]
    def last(n = 1)
      arr = to_a
      arr.last(n)
    end

    # Access element by index (0 = oldest, -1 = newest)
    #
    # @param index [Integer]
    # @return [Object, nil]
    def [](index)
      arr = to_a
      return nil if arr.empty?
      return nil if index >= arr.length || index < -arr.length

      arr[index]
    end

    # Return the oldest n elements
    #
    # @param n [Integer] number of elements (default 1)
    # @return [Object, Array]
    def first(n = 1)
      arr = to_a
      return arr.first if n == 1

      arr.first(n)
    end

    # Remove all elements and reset internal state
    #
    # @return [self]
    def clear
      @buffer = Array.new(@capacity)
      @head = 0
      @count = 0
      self
    end

    # Population variance of numeric elements
    #
    # @return [Float]
    def variance
      return 0.0 if @count <= 1

      avg = average
      arr = to_a
      arr.sum { |v| (v - avg)**2 } / arr.length.to_f
    end

    # Population standard deviation of numeric elements
    #
    # @return [Float]
    def stddev
      Math.sqrt(variance)
    end

    # Median value of numeric elements
    #
    # @return [Float, nil]
    def median
      return nil if empty?

      sorted = to_a.sort
      mid = sorted.length / 2

      if sorted.length.odd?
        sorted[mid].to_f
      else
        (sorted[mid - 1] + sorted[mid]) / 2.0
      end
    end

    # Change the buffer capacity, preserving elements
    #
    # If the new capacity is smaller than the current element count,
    # the oldest elements are discarded and only the most recent
    # new_capacity elements are kept.
    #
    # @param new_capacity [Integer] the new maximum number of elements
    # @return [self]
    def resize(new_capacity)
      raise Error, 'capacity must be a positive integer' unless new_capacity.is_a?(Integer) && new_capacity.positive?
      return self if new_capacity == @capacity

      elements = to_a
      elements = elements.last(new_capacity) if elements.length > new_capacity

      @capacity = new_capacity
      @buffer = Array.new(new_capacity)
      @head = 0
      @count = 0
      elements.each { |e| push(e) }
      self
    end

    # Push multiple values at once
    #
    # @param values [Array<Object>] values to push
    # @return [self]
    def concat(*values)
      values.each { |v| push(v) }
      self
    end

    # Calculate the p-th percentile of numeric elements
    #
    # Uses linear interpolation between nearest ranks.
    #
    # @param p [Numeric] percentile (0-100)
    # @return [Float, nil] the percentile value, or nil if empty
    # @raise [Error] if p is outside 0-100
    def percentile(p)
      raise Error, 'percentile must be between 0 and 100' unless p.is_a?(Numeric) && p >= 0 && p <= 100
      return nil if empty?

      sorted = to_a.sort
      return sorted.first.to_f if sorted.length == 1

      rank = (p / 100.0) * (sorted.length - 1)
      lower = rank.floor
      upper = rank.ceil
      return sorted[lower].to_f if lower == upper

      sorted[lower] + ((sorted[upper] - sorted[lower]) * (rank - lower))
    end

    # Return a random element or array of random elements
    #
    # @param n [Integer, nil] number of elements (nil for single element)
    # @return [Object, Array, nil]
    def sample(n = nil)
      arr = to_a
      return nil if arr.empty? && n.nil?
      return [] if arr.empty? && n

      n.nil? ? arr.sample : arr.sample(n)
    end

    # Sliding window averages over elements oldest to newest
    #
    # @param window [Integer] window size
    # @return [Array<Float>]
    def moving_average(window:)
      raise Error, 'buffer is empty' if empty?
      raise Error, 'window must be a positive integer' unless window.is_a?(Integer) && window.positive?
      raise Error, 'window exceeds buffer size' if window > @count

      arr = to_a
      arr.each { |v| raise Error, 'all elements must be numeric' unless v.is_a?(Numeric) }

      (0..(arr.length - window)).map do |i|
        arr[i, window].sum.to_f / window
      end
    end

    # Exponential moving average
    #
    # @param alpha [Float] smoothing factor (0 < alpha <= 1)
    # @return [Float]
    def ema(alpha:)
      raise Error, 'buffer is empty' if empty?
      raise Error, 'alpha must be between 0 (exclusive) and 1 (inclusive)' unless alpha.is_a?(Numeric) && alpha.positive? && alpha <= 1

      arr = to_a
      arr.each { |v| raise Error, 'all elements must be numeric' unless v.is_a?(Numeric) }

      result = arr.first.to_f
      arr.drop(1).each do |v|
        result = (alpha * v) + ((1 - alpha) * result)
      end
      result
    end

    # Human-readable string representation
    #
    # @return [String]
    def inspect
      "#<#{self.class} capacity=#{@capacity} size=#{@count} elements=#{to_a.inspect}>"
    end

    # Iterate over elements (oldest first)
    #
    # @yield [element]
    def each(&)
      to_a.each(&)
    end
  end
end
