# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "memorydb"
  gem.version       = '0.0.9'
  gem.authors       = ["Myles Megyesi"]
  gem.email         = ["myles.megyesi@gmail.com"]
  gem.description   = 'An in memory database'
  gem.summary       = 'An in memory database'

  gem.files         = Dir['lib/**/*.rb']
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake',   '~> 10.4.2'
  gem.add_development_dependency 'rspec',  '~> 2.14.1'
  gem.add_development_dependency 'virtus', '~> 1.0.0'
end
