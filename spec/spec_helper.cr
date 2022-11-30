require "spec"
require "../src/crystal-ptools"

def with_file(file, size = 25)
  begin
    File.open(file, "w") do |fh|
      size.times do |n|
        fh.puts("This is line #{n+1}")
      end
    end
    yield file
  ensure
    File.delete(file) if File.exists?(file)
  end
end
