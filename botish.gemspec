# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'botish'
  spec.version       = File.open('VERSION').read
  spec.authors       = ['Adrien Waksberg']
  spec.email         = ['botish@yae.im']
  spec.summary       = 'Botish is an IRC bot'
  spec.description   = 'Botish is an IRC modular bot, you can add your own plugins'
  spec.homepage      = 'https://github.com/nishiki/botish'
  spec.license       = 'GPL-2.0'

  spec.files         = %x(git ls-files -z).split("\x0")
  spec.executables   = ['botish']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
end
