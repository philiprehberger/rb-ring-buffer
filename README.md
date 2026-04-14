# philiprehberger-ring_buffer

[![Tests](https://github.com/philiprehberger/rb-ring-buffer/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-ring-buffer/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-ring_buffer.svg)](https://rubygems.org/gems/philiprehberger-ring_buffer)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-ring-buffer)](https://github.com/philiprehberger/rb-ring-buffer/commits/main)

Fixed-size circular buffer with overflow, statistics, and enumeration

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-ring_buffer"
```

Or install directly:

```bash
gem install philiprehberger-ring_buffer
```

## Usage

```ruby
require "philiprehberger/ring_buffer"

buf = Philiprehberger::RingBuffer.new(3)
buf.push(1)
buf.push(2)
buf.push(3)
buf.push(4)      # overwrites 1
buf.to_a          # => [2, 3, 4]
buf.full?         # => true
```

### Index Access

```ruby
buf = Philiprehberger::RingBuffer.new(5)
[10, 20, 30].each { |v| buf.push(v) }

buf[0]   # => 10 (oldest)
buf[-1]  # => 30 (newest)
buf[99]  # => nil (out of bounds)
```

### First / Last Elements

```ruby
buf = Philiprehberger::RingBuffer.new(10)
(1..10).each { |v| buf.push(v) }

buf.first      # => 1
buf.first(3)   # => [1, 2, 3]
buf.last(3)    # => [8, 9, 10]
```

### Clear

```ruby
buf = Philiprehberger::RingBuffer.new(5)
[1, 2, 3].each { |v| buf.push(v) }
buf.clear
buf.size   # => 0
buf.empty? # => true
```

### Consuming Elements

```ruby
buf = Philiprehberger::RingBuffer.new(3)
[1, 2, 3].each { |v| buf.push(v) }

buf.shift    # => 1   (removes oldest)
buf.pop      # => 3   (removes newest)
buf.to_a     # => [2]

buf.push(4)
buf.push(5)
buf.oldest   # => 2   (peek, no mutation)
buf.newest   # => 5
```

`shift`, `pop`, `oldest`, and `newest` all return `nil` when the buffer is empty.

### Statistics

```ruby
buf = Philiprehberger::RingBuffer.new(100)
[10, 20, 30].each { |v| buf.push(v) }

buf.average   # => 20.0
buf.sum       # => 60
buf.min       # => 10
buf.max       # => 30
buf.variance  # => 66.66666666666667
buf.stddev    # => 8.16496580927726
buf.median    # => 20.0
```

### Resize

```ruby
buf = Philiprehberger::RingBuffer.new(3)
[1, 2, 3].each { |v| buf.push(v) }

buf.resize(5)
buf.capacity     # => 5
buf.to_a         # => [1, 2, 3]

buf.resize(2)
buf.to_a         # => [2, 3] (keeps most recent)
```

### Batch Push

```ruby
buf = Philiprehberger::RingBuffer.new(5)
buf.concat(1, 2, 3, 4, 5)
buf.to_a  # => [1, 2, 3, 4, 5]
```

### Percentile

```ruby
buf = Philiprehberger::RingBuffer.new(100)
(1..100).each { |v| buf.push(v) }

buf.percentile(25)   # => 25.75
buf.percentile(50)   # => 50.5
buf.percentile(75)   # => 75.25
buf.percentile(90)   # => 90.1
```

### Moving Averages

```ruby
buf = Philiprehberger::RingBuffer.new(5)
[1, 2, 3, 4, 5].each { |v| buf.push(v) }

buf.moving_average(window: 3)  # => [2.0, 3.0, 4.0]
buf.ema(alpha: 0.5)            # => 4.0625
```

### Descriptive Helpers

```ruby
buf = Philiprehberger::RingBuffer.new(10)
[1, 2, 3, 4, 5, 6].each { |v| buf.push(v) }

buf.range                  # => 5 (max - min)
buf.count_by(&:even?)      # => { false => 3, true => 3 }
```

### Random Sampling

```ruby
buf = Philiprehberger::RingBuffer.new(5)
[10, 20, 30, 40, 50].each { |v| buf.push(v) }

buf.sample       # => random element
buf.sample(2)    # => [random, random]
```

### Enumerable

```ruby
buf = Philiprehberger::RingBuffer.new(5)
[1, 2, 3].each { |v| buf.push(v) }
buf.map { |v| v * 2 }     # => [2, 4, 6]
buf.select(&:odd?)        # => [1, 3]
```

## API

| Method | Description |
|--------|-------------|
| `RingBuffer.new(capacity)` | Create a buffer with fixed capacity |
| `#push(value)` | Add a value, overwriting oldest if full |
| `#shift` | Remove and return the oldest element (or `nil`) |
| `#pop` | Remove and return the newest element (or `nil`) |
| `#oldest` | Peek the oldest element without removing (or `nil`) |
| `#newest` | Peek the newest element without removing (or `nil`) |
| `#[](index)` | Access by index (0 = oldest, -1 = newest) |
| `#to_a` | Convert to array (oldest first) |
| `#size` | Number of elements in the buffer |
| `#full?` | Whether the buffer is at capacity |
| `#empty?` | Whether the buffer has no elements |
| `#first(n)` | First n elements (oldest) |
| `#last(n)` | Last n elements (most recent) |
| `#clear` | Remove all elements, reset state |
| `#concat(*values)` | Push multiple values at once |
| `#resize(new_capacity)` | Change buffer capacity, keeping most recent elements |
| `#percentile(p)` | Calculate the p-th percentile (0-100) with interpolation |
| `#sample(n)` | Random element (or array of n random elements) |
| `#inspect` | Human-readable string representation |
| `#average` | Average of numeric elements |
| `#sum` | Sum of numeric elements |
| `#min` | Minimum element |
| `#max` | Maximum element |
| `#variance` | Population variance |
| `#stddev` | Population standard deviation |
| `#median` | Median value |
| `#moving_average(window:)` | Sliding window averages (oldest to newest) |
| `#ema(alpha:)` | Exponential moving average (single float) |
| `#range` | Spread between min and max numeric elements |
| `#count_by(&block)` | Bucketed counts by block return value |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-ring-buffer)

🐛 [Report issues](https://github.com/philiprehberger/rb-ring-buffer/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-ring-buffer/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
