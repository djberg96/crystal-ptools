class File
  PTOOLS_VERSION = "0.1.0"
  IMAGE_EXT = %w[.bmp .gif .jpg .jpeg .png .ico .tiff]

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
  def self.bmp?(file : String|Path) : Bool
    str = File.readn(file, 6)
    size = IO::Memory.new(str[2,4], writeable: false).read_bytes(Int32)
    str[0,2].to_a == [66,77] && File.size(file) == size
  end

  # Is the file a gif?
  #
  def self.gif?(file : String|Path) : Bool
    %w[GIF89a GIF97a].includes?(String.new(File.readn(file, 6)))
  end

  # Is the file a jpeg file?
  #
  def self.jpg?(file : String|Path) : Bool
    File.readn(file, 10).hexstring == "ffd8ffe000104a464946"
  end

  # Is the file a png file?
  #
  def self.png?(file : String|Path) : Bool
    File.readn(file, 4).hexstring == "89504e47"
  end

  # Is the file a tiff?
  #
  def self.tiff?(file : String|Path) : Bool
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
  def self.ico?(file : String|Path) : Bool
    bytes = File.readn(file, 4)
    ["00000100", "00000200"].includes?(bytes[0,4].hexstring)
  end

  # Returns whether or not the file is an image. Only JPEG, PNG, BMP,
  # GIF, and ICO are checked against.
  #
  # This reads and checks the first few bytes of the file. For a version
  # that is more robust, but which depends on a 3rd party C library (and is
  # difficult to build on MS Windows), see the 'filemagic' library.
  #
  # By default the filename extension is also checked. You can disable this
  # by passing false as the second argument, in which case only the contents
  # are checked.
  #
  # Examples:
  #
  #    File.image?('somefile.jpg') # => true
  #    File.image?('somefile.txt') # => false
  #--
  # The approach I used here is based on information found at
  # http://en.wikipedia.org/wiki/Magic_number_(programming)
  #
  def self.image?(file : Path|String, check_file_extension : Bool = true) : Bool
    bool = bmp?(file) || jpg?(file) || png?(file) || gif?(file) || tiff?(file) || ico?(file)

    bool &&= IMAGE_EXT.includes?(File.extname(file).downcase) if check_file_extension

    bool
  end

  # Reads and returns an array of `num_lines` from `file`.
  #
  # Example:
  #
  #  File.head("somefile.txt")    # => ["This is line 1", "This is line 2", ...]
  #  File.head("somefile.txt", 3) # => ["This is line 1", "This is line 2", "This is line 3"]
  #
  def self.head(file : String|Path, num_lines : Int = 10)
    array = Array(String).new

    File.each_line(file) do |line|
      break if num_lines <= 0

      num_lines -= 1
      array << line
    end

    array
  end

  # Returns an array of each +program+ within +path+, or nil if it cannot be found.
  #
  # Examples:
  #
  #   File.whereis('ruby') # => ['/usr/bin/ruby', '/usr/local/bin/ruby']
  #   File.whereis('foo')  # => nil
  #
  def self.whereis(program : String|Path, path : String|Path = ENV["PATH"]) : Array(String)|Nil
    program = Path.new(program) unless program.is_a?(Path)
    path = String.new(path) if path.is_a?(Path)

    # Bail out early if an absolute path is provided.
    if program.absolute?
      found = Dir[program].first?

      if found && File.executable?(found) && !File.directory?(found)
        return [found]
      else
        return nil
      end
    end

    paths = Array(String).new

    # Iterate over each path glob the dir + program.
    path.split(Process::PATH_DELIMITER).each do |dir|
      next unless File.exists?(dir) # In case of bogus second argument

      file = File.join(dir, program)
      found = Dir[file].first?

      # Convert all forward slashes to backslashes if supported
      if found && File.executable?(found) && !File.directory?(found)
        paths << found
      end
    end

    paths.empty? ? nil : paths.uniq
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
  def self.which(program : String|Path, paths : String|Path = ENV["PATH"]) : String|Nil
    paths = String.new(paths) if paths.is_a?(Path)
    program = Path.new(program) if program.is_a?(String)

    if program.absolute?
      found = Dir[program].first?

      if found && File.executable?(found) && !File.directory?(found)
        return found
      else
        return nil
      end
    end

    paths.split(Process::PATH_DELIMITER).each do |dir|
      dir = File.expand_path(dir)

      next unless File.exists?(dir) # In case of bogus second argument

      file = File.join(dir, program)
      found = Dir[file].first?

      if found && File.executable?(found) && !File.directory?(found)
        return found
      end
    end

    nil
  end
end
