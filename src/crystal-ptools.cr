class File
  PTOOLS_VERSION = "0.1.0"

  # Read N bytes from path or filename. Returns a Bytes object.
  #
  def self.readn(filename : Path|String, nbytes : Int, encoding = nil, invalid = nil) : Bytes
    return Bytes.empty unless nbytes > 0
    open(filename, "r") do |file|
      file.set_encoding(encoding, invalid: invalid) if encoding
      bytes = Bytes.new(nbytes)
      file.read(bytes)
      bytes
    end
  end

  # Is the file a bitmap file?
  #
  def self.bmp?(file : String) : Bool
    str = File.readn(file, 6)
    size = IO::Memory.new(str[2,4], writeable: false).read_bytes(Int32)
    str[0,2].to_a == [66,77] && File.size(file) == size
  end

  # Is the file a gif?
  #
  def self.gif?(file)
    %w[GIF89a GIF97a].includes?(String.new(File.readn(file, 6)))
  end

  # Is the file a jpeg file?
  #
  def self.jpg?(file : String | Path) : Bool
    File.readn(file, 10).hexstring == "ffd8ffe000104a464946"
  end

  # Is the file a png file?
  #
  def self.png?(file : String | Path) : Bool
    File.readn(file, 4).hexstring == "89504e47"
  end

  # Is the file a tiff?
  #
  def self.tiff?(file : String | Path) : Bool
    return false if File.size(file) < 12

    bytes = File.readn(file, 4)
    first_two_chars = String.new(bytes[0,2])

    # II is Intel, MM is Motorola
    return false if first_two_chars != "II" && first_two_chars != "MM"
    return false if bytes.last != 42

    true
  end

  # Is the file an ico file?
  #
  def self.ico?(file : String | Path) : Bool
    bytes = File.readn(file, 4)
    ["00000100", "00000200"].includes?(bytes[0,4].hexstring)
  end

  # Looks for the first occurrence of +program+ within +path+.
  #
  # On Windows, it looks for executables ending with the suffixes defined
  # in your PATHEXT environment variable, or '.exe', '.bat' and '.com' if
  # that isn't defined, which you may optionally include in +program+.
  #
  # Returns nil if not found.
  #
  # Examples:
  #
  #   File.which('ruby') # => '/usr/local/bin/ruby'
  #   File.which('foo')  # => nil
  #
  def self.which(program : String, paths : String|Path = ENV["PATH"])
    paths = String.new(paths) if paths.is_a?(Path)
    program = Path.new(program) if program.is_a?(String)

    if program.absolute?
      found = Dir[program].first

      if found && File.executable?(found) && !File.directory?(found)
        return found.to_s
      else
        return nil
      end
    end

    paths.split(Process::PATH_DELIMITER).each do |dir|
      dir = File.expand_path(dir)

      next unless File.exists?(dir) # In case of bogus second argument

      file = File.join(dir, program)
      found = Dir[file]
      next if found.empty?
      found = found.first

      if File.executable?(found) && !File.directory?(found)
        return found
      end
    end

    nil
  end
end
