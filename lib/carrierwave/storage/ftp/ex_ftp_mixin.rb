module ExFTPMixin
  def mkdir_p(dir)
    parts = dir.split('/')
    growing_path = resolve_root(parts)
    parts.each do |part|
      next if part == ''
      growing_path = growing_path == '' ? part : File.join(growing_path, part)
      mkdir_once(growing_path)
    end
  end

  def mkdir_once(dir)
    mkdir(dir)
    chdir(dir)
  rescue Net::FTPPermError, Net::FTPTempError
    nil
  end

  def resolve_root(path)
    path.first == '~' ? '' : '/'
  end
end
