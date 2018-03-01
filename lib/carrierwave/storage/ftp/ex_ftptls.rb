require 'double_bag_ftps'

class ExFTPTLS < DoubleBagFTPS
  def mkdir_p(dir)
    parts = dir.split('/')
    growing_path = if parts.first == '~'
                     ''
                   else
                     '/'
                   end
    for part in parts
      next if part == ''
      growing_path = if growing_path == ''
                       part
                     else
                       File.join(growing_path, part)
                     end
      begin
        mkdir(growing_path)
        chdir(growing_path)
      rescue Net::FTPPermError, Net::FTPTempError => e
      end
    end
  end
end
