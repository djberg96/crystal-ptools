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
end
