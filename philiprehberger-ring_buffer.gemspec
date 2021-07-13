# frozen_string_literal: true

require_relative 'lib/philiprehberger/ring_buffer/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-ring_buffer'
  spec.version = Philiprehberger::RingBuffer::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']

  spec.summary = 'Fixed-size circular buffer with overflow, statistics, and enumeration'
  spec.description = 'Fixed-capacity ring buffer that overwrites oldest entries on overflow, ' \
                       'with built-in statistics (average, sum, min, max), last-n retrieval, and Enumerable support.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-ring_buffer'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-ring-buffer'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-ring-buffer/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-ring-buffer/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
