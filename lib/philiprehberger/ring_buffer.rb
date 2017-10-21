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

      if @count < @capacity
        @buffer[0...@count]
      else
        start = @head
        Array.new(@capacity) { |i| @buffer[(start + i) % @capacity] }
      end
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

    # Iterate over elements (oldest first)
    #
    # @yield [element]
    def each(&)
      to_a.each(&)
    end
  end
end
