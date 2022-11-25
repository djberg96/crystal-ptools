require "./spec_helper"

describe File do
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
