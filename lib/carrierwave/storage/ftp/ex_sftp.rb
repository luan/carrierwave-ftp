require 'net/sftp'

class Net::SFTP::Session
  def mkdir_p!(dir)
    parts = dir.split("/")
    growing_path = ""
    for part in parts
      next if part == ""
      if growing_path == ""
        growing_path = part
      else
        growing_path = File.join(growing_path, part)
      end
      begin
        mkdir!(growing_path)
      rescue
      end
    end
  end
end
