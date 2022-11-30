require "./spec_helper"

describe File do
  describe ".bmp?" do
    it "returns the expected value for a bitmap image file" do
      File.bmp?("spec/img/test.bmp").should be_true
    end

    it "returns the expected value for a non-bitmap image file" do
      File.bmp?("spec/img/test.gif").should be_false
    end

    it "returns the expected value for a non-image file" do
      File.bmp?("spec/txt/empty.txt").should be_false
    end
  end

  describe ".gif?" do
    it "returns the expected value for a gif image file" do
      File.gif?("spec/img/test.gif").should be_true
    end

    it "returns the expected value for a non-bitmap image file" do
      File.gif?("spec/img/test.jpg").should be_false
    end

    it "returns the expected value for a non-image file" do
      File.gif?("spec/txt/empty.txt").should be_false
    end
  end

  describe ".ico?" do
    it "returns the expected value for a ico file" do
      File.ico?("spec/img/test.ico").should be_true
    end

    it "returns the expected value for a non-ico image file" do
      File.ico?("spec/img/test.bmp").should be_false
      File.ico?("spec/img/test.png").should be_false
    end

    it "returns the expected value for a non-image file" do
      File.ico?("spec/txt/empty.txt").should be_false
    end
  end

  describe ".jpg?" do
    it "returns the expected value for a jpeg file" do
      File.jpg?("spec/img/test.jpg").should be_true
    end

    it "returns the expected value for a jpeg file with no extension" do
      File.jpg?("spec/img/jpg_no_ext").should be_true
    end

    it "returns the expected value for a non-jpeg image file" do
      File.jpg?("spec/img/test.gif").should be_false
    end

    it "returns the expected value for a non-image file" do
      File.jpg?("spec/txt/empty.txt").should be_false
    end
  end

  describe ".png?" do
    it "returns the expected value for a png file" do
      File.png?("spec/img/test.png").should be_true
    end

    it "returns the expected value for a non-png image file" do
      File.png?("spec/img/test.gif").should be_false
    end

    it "returns the expected value for a non-image file" do
      File.png?("spec/txt/empty.txt").should be_false
    end
  end

  describe ".tiff?" do
    it "returns the expected value for a tiff file" do
      File.tiff?("spec/img/test.tiff").should be_true
    end

    it "returns the expected value for a non-tiff image file" do
      File.tiff?("spec/img/test.gif").should be_false
      File.tiff?("spec/img/test.png").should be_false
    end

    it "returns the expected value for a non-image file" do
      File.tiff?("spec/txt/empty.txt").should be_false
    end
  end

  describe ".image?" do
    it "returns the expected value for an image file" do
      File.image?("spec/img/test.tiff").should be_true
      File.image?("spec/img/test.bmp").should be_true
      File.image?("spec/img/test.gif").should be_true
      File.image?("spec/img/test.png").should be_true
      File.image?("spec/img/test.ico").should be_true
    end

    it "returns the expected value for a non-image file" do
      File.image?("spec/txt/empty.txt").should be_false
    end
  end

  describe ".head" do
    array = Array(String).new
    25.times{ |n| array << "This is line #{n+1}" }

    it "returns the expected result with a default size" do
      with_file("basic_head_file.txt") do |file|
        File.head(file).should eq(array[0..9])
      end
    end

    it "returns the expected result with a specified size" do
      with_file("basic_head_file.txt") do |file|
        File.head(file, 5).should eq(array[0..4])
      end
    end

    it "returns the expected result with a negative size" do
      with_file("basic_head_file.txt") do |file|
        File.head(file, -5).should eq(Array(String).new)
      end
    end

    it "returns the expected result with a size larger than file" do
      with_file("basic_head_file.txt") do |file|
        File.head(file, 30).should eq(array)
      end
    end
  end

  describe ".tail" do
    array = Array(String).new
    25.times{ |n| array << "This is line #{n+1}" }

    it "returns the expected result with a default size" do
      with_file("basic_tail_file.txt") do |file|
        File.tail(file).should eq(array[15..24])
      end
    end

    it "returns the expected result with a specified size" do
      with_file("basic_tail_file.txt") do |file|
        File.tail(file, 5).should eq(array[20..24])
      end
    end

    it "returns the expected result with a negative size" do
      with_file("basic_tail_file.txt") do |file|
        File.tail(file, -5).should eq(Array(String).new)
      end
    end

    it "returns the expected result with a size larger than file" do
      with_file("basic_tail_file.txt") do |file|
        File.tail(file, 30).should eq(array)
      end
    end
  end

  describe ".whereis" do
    it "returns the expected result if a binary is found" do
      expected = IO::Memory.new
      Process.run(command: "which", args: ["crystal"], output: expected, error: expected)
      File.whereis("crystal").should eq([expected.to_s.chomp])
    end

    it "returns the expected result if an absolute path is used" do
      expected = IO::Memory.new
      Process.run(command: "which", args: ["crystal"], output: expected, error: expected)
      program = expected.to_s.chomp
      File.whereis(program).should eq([program])
    end

    it "returns nil if the binary isn't found" do
      File.whereis("bogus").should be_nil
    end

    it "returns nil if the binary isn't found on the specified path" do
      File.whereis("crystal", "/usr/local/bogus").should be_nil
    end
  end

  describe ".which" do
    it "returns the expected result if the binary is found" do
      expected = IO::Memory.new
      Process.run(command: "which", args: ["crystal"], output: expected, error: expected)
      File.which("crystal").should eq(expected.to_s.chomp)
    end

    it "returns the expected result if an absolute path to binary is used and found" do
      expected = IO::Memory.new
      Process.run(command: "which", args: ["crystal"], output: expected, error: expected)
      program = expected.to_s.chomp
      File.which(program).should eq(program)
    end

    it "returns nil if the binary isn't found" do
      File.which("bogus").should be_nil
    end

    it "returns nil if the binary isn't found on the specified path" do
      File.which("crystal", "/usr/local/bogus").should be_nil
    end
  end
end
