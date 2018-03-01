require 'net/sftp'

module Net
  module SFTP
    class Session
      def mkdir_p!(dir)
        parts = dir.split(File::SEPARATOR)
        growing_parts = []
        parts.each do |part|
          growing_parts.push(part)
          mkdir_once(File.join(growing_parts))
        end
      end

      def mkdir_once(dir)
        mkdir!(dir)
      rescue StandardError
        nil
      end
    end
  end
end
