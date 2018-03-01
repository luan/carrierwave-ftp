require 'net/ftp'
require 'carrierwave/storage/ftp/ex_ftp_mixin'

class ExFTP < Net::FTP
  include ExFTPMixin
end
