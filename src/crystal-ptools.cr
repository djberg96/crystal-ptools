class File
  PTOOLS_VERSION = "0.1.0"
  IMAGE_EXT = %w[.bmp .gif .jpg .jpeg .png .ico .tiff]

  # File::Info tweaks required for now while core devs debate compatability.

  struct File::Info
    def blksize
      @stat.st_blksize
    end

    def blocks
      @stat.st_blocks
    end
  end

  # Returns whether or not +file+ is a binary non-image file, i.e. executable,
  # shared object, etc.
  #
  # It performs a best guess based on a simple test of the first `blksize`
  # characters, or 4096, whichever is smaller. If it finds two consecutive zero
  # characters, it is considered binary.
  #
  # Example:
  #
  #   ```crystal
  #   File.binary?('somefile.exe') # => true
  #   File.binary?('somefile.txt') # => false
  #   ```
  #
  def self.binary?(file : String|Path) : Bool
    bool = false
    size = File.size(file)

    return bool if size == 0
    return bool if image?(file)
    return bool if check_bom?(file)

    num_bytes = File.info(file).blksize
    num_bytes = 4096 if num_bytes > 4096
    num_bytes = size if size < num_bytes

    File.open(file) do |fh|
      bytes = fh.read_string(num_bytes).bytes
      bytes.each_with_index do |b, n|
        if b == 0 && bytes[n+1] == 0
          bool = true
          break
        end
      end
    end

    bool
  end

  # Returns whether or not the given +text+ contains a BOM marker.
  # If present, we can generally assume it's a text file.
  #
  def self.check_bom?(file)
    bytes = File.readn(file, 4)

    bool = false
    bool = true if bytes == Bytes[239, 187, 191]
    bool = true if bytes.in?(Bytes[0, 0, 254, 255], Bytes[0, 0, 254, 255])
    bool = true if bytes.in?(Bytes[254, 255], Bytes[255, 254])

    bool
  end

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

  # Returns a count for the given `filename`. By default it returns the word
  # count, but you may also specify "chars", "bytes" or "lines" as an option.
  #
  def self.wc(filename : Path|String, option : String = "words") : Int
    count = 0

    File.each_line(filename, chomp: false) do |line|
      case option
      when "words"
        count += line.split.size
      when "lines"
        count += 1
      when "bytes"
        count += line.bytes.size
      when "chars"
        count += line.chars.size
      end
    end

    count
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

  # Reads and returns an array of the first `num_lines` from `file`.
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

  # Reads and returns an array of the last `num_lines` from `file`. Note that
  # this does not implement `tail -f` behavior.
  #
  # Example:
  #
  #  File.tail("somefile.txt")    # => ["This is line 10", "This is line 9", ...]
  #  File.tail("somefile.txt", 3) # => ["This is line 10", "This is line 9", "This is line 8"]
  #
  def self.tail(file : String|Path, num_lines : Int = 10, line_size : Int = 1024)
    array = Array(String).new
    return array if num_lines < 1

    File.open(file) do |fh|
      offset = num_lines * line_size
      fh.seek(0 &- (fh.size < offset ? fh.size : offset), IO::Seek::End)
      array = fh.gets_to_end.lines

      if array.size > num_lines
        array = array[array.size - num_lines..-1]
      end
    end

    array
  end

  # Returns an array of each `program` within `path`, or nil if it cannot be found.
  # If a `path` is provided, it should be a string delimited by `Process::PATH_DELIMITER`.
  # By default your `ENV["PATH"]` is searched.
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
