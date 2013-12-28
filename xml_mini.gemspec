require 'pathname'
lib_path = Pathname.new(__FILE__).join('../lib').expand_path.to_s
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include? lib_path

require 'xml_mini/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'xml_mini'
  s.version     = XmlMini::VERSION
  s.summary     = 'XML support extracted from the Rails framework'
  s.description = 'XML support extracted from the Rails framework'

  s.required_ruby_version = '>= 1.9.3'

  s.license = 'MIT'

  s.author   = 'Joseph Anthony Pasquale Holsten'
  s.email    = 'joseph@josephholsten.com'
  s.homepage = 'http://www.rubyonrails.org'

  s.files        = Dir['CHANGELOG.md', 'MIT-LICENSE', 'README.rdoc', 'lib/**/*']
  s.require_path = 'lib'

  s.rdoc_options.concat ['--encoding',  'UTF-8']

  s.add_runtime_dependency 'builder'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'libxml-ruby'
  s.add_development_dependency 'nokogiri'
end

