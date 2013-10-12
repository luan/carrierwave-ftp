# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "carrierwave/storage/ftp/version"

Gem::Specification.new do |s|
  s.name        = "carrierwave-ftp"
  s.version     = Carrierwave::Storage::FTP::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Luan Santos"]
  s.email       = ["luan@luansantos.com"]
  s.homepage    = "https://github.com/luan/carrierwave-ftp"
  s.summary     = %q{FTP support for CarrierWave}
  s.description = %q{Allows file upload using FTP for CarrierWave uploaders.}

  s.rubyforge_project = "carrierwave-ftp"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.license = 'MIT'

  s.add_dependency "carrierwave", [">= 0.6.2"]
  s.add_dependency "net-sftp", ["~> 2.0.5"]
  s.add_development_dependency "rspec", ["~> 2.6"]
  s.add_development_dependency "rake", ["~> 0.9"]
end
