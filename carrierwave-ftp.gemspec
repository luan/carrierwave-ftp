
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'carrierwave/storage/ftp/version'

Gem::Specification.new do |s|
  s.name        = 'carrierwave-ftp'
  s.version     = Carrierwave::Storage::FTP::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Luan Santos']
  s.email       = ['luan@luansantos.com']
  s.homepage    = 'https://github.com/luan/carrierwave-ftp'
  s.summary     = 'FTP support for CarrierWave'
  s.description = 'Allows file upload using FTP for CarrierWave uploaders.'

  s.rubyforge_project = 'carrierwave-ftp'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map do |f|
    File.basename(f)
  end
  s.require_paths = ['lib']
  s.license = 'MIT'

  s.add_dependency 'carrierwave', ['>= 0.6.2']
  s.add_dependency 'double-bag-ftps', ['~> 0.1.4']
  s.add_dependency 'net-sftp', ['~> 4.0.0']
  s.add_development_dependency 'rake', ['~> 12.3']
  s.add_development_dependency 'rspec', ['~> 3.7']
  s.add_development_dependency 'rubocop', ['~> 0.52']
end
