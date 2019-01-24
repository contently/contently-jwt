lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'contently/jwt/version'

Gem::Specification.new do |spec|
  spec.name          = 'contently-jwt'
  spec.version       = Contently::Jwt::VERSION
  spec.authors       = ['Seth Webster']
  spec.email         = ['sethwebster@gmail.com']

  spec.summary       = 'Provides JWT Service, Middleware'
  spec.description   = 'Provides JWT Service, Middleware'
  spec.homepage      = 'https://github.com/contently/contently-jwt'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/contently/contently-jwt'
    spec.metadata['changelog_uri'] = 'https://github.com/contently/contently-jwt'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'guard', '~> 2.15'
  spec.add_development_dependency 'guard-rspec', '~> 4.7.3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'devise'
  spec.add_dependency 'devise-jwt'
  spec.add_dependency 'jwt'
  spec.add_dependency 'openssl'
  spec.add_dependency 'warden'
end
