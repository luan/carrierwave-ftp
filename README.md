# CarrierWave FTP storage

This gem adds support for FTP upload to [CarrierWave](https://github.com/jnicklas/carrierwave/)

## Installation

Install the latest release:

    gem install carrierwave-ftp

Require it in your code:

    require 'carrierwave/storage/ftp'

Or, in Rails you can add it to your Gemfile:

    gem 'carrierwave-ftp', :require => 'carrierwave/storage/ftp'

## Getting Started

First configure CarrierWave with your FTP credentials:

```ruby
CarrierWave.configure do |config|
  config.ftp_host = "ftp.example.com"
  config.ftp_port = 21
  config.ftp_user = "example"
  config.ftp_passwd = "secret"
  config.ftp_folder = "/public_html/uploads"
  config.ftp_url = "http://example.com/uploads"
end
```

And then in your uploader, set the storage to `:ftp`:

```ruby
class AvatarUploader < CarrierWave::Uploader::Base
  storage :ftp
end
```
