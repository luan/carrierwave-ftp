require 'double_bag_ftps'
require 'carrierwave/storage/ftp/ex_ftp_mixin'

class ExFTPTLS < DoubleBagFTPS
  include ExFTPMixin
end
