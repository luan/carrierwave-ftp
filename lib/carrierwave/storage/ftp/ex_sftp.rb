require 'net/sftp'

class Net::SFTP::Session
  def mkdir_p!(dir)
    parts = dir.split(File::SEPARATOR)
    growing_parts = []
    for part in parts
      growing_parts.push(part)
      begin
        mkdir!(File.join(growing_parts))
      rescue StandardError
      end
    end
  end
end
