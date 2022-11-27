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
  def self.jpg?(file : String) : Bool
    File.readn(file, 10).hexstring == "ffd8ffe000104a464946"
  end
end
