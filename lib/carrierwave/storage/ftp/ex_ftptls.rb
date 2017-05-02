require 'double_bag_ftps'

class ExFTPTLS < DoubleBagFTPS
  def mkdir_p(dir)
    parts = dir.split("/")
    if parts.first == "~"
      growing_path = ""
    else
      growing_path = "/"
    end
    for part in parts
      next if part == ""
      if growing_path == ""
        growing_path = part
      else
        growing_path = File.join(growing_path, part)
      end
      begin
        mkdir(growing_path)
        chdir(growing_path)
      rescue Net::FTPPermError, Net::FTPTempError => e
      end
    end
  end
end
