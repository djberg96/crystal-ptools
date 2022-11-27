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
end
