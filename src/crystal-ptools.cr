class File
  PTOOLS_VERSION = "0.1.0"

  def self.jpg?(file : String) : Bool
    bool = false

    begin
      bytes = Bytes.new(10)
      fh = File.open(file)
      fh.read(bytes)
      bool = bytes.to_a == [255, 216, 255, 224, 0, 16, 74, 70, 73, 70]
    ensure
      fh.close if fh
    end

    bool
  end
end
