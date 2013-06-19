# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "memorydb"
  gem.version       = '0.0.1'
  gem.authors       = ["Myles Megyesi"]
  gem.email         = ["myles.megyesi@gmail.com"]
  gem.description   = 'An in memory database'
  gem.summary       = 'An in memory database'

  gem.files         = Dir['lib/**/*.rb']
  gem.require_paths = ['lib']

  gem.add_dependency             'multi_json',       '~> 1.7.6'

  gem.add_development_dependency 'multi_json',       '~> 1.5.0'
  gem.add_development_dependency 'rake',             '~> 10.0.3'
  gem.add_development_dependency 'rspec',            '~> 2.12.0'
  gem.add_development_dependency 'virtus',           '~> 0.5.3'
end
