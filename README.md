# crystal-ptools

This is a Crystal port of the "ptools" library originally written for Ruby.
It contains additional singleton methods for the File class.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     crystal-ptools:
       github: djberg96/crystal-ptools
   ```

2. Run `shards install`

## Usage

```crystal
require "crystal-ptools"

# Simulate the "which" command:
File.which("crystal") # => "/opt/homebrew/bin/crystal"
File.which("bogus")   # => nil

# Simulate the "whereis" command (minus the man pages):
File.whereis("crystal") # => ["/opt/homebrew/bin/crystal"]
File.whereis("bogus")   # => []

# Test to see if a file is an image:
File.image?("/path/to/some_image.bmp") # Is the file an image

# Or check for a specific type of image:
File.bmp?("/path/to/some_file.bmp")   # Is the file a bitmap file?
File.jpg?("/path/to/some_file.jpg")   # Is the file a JPEG file?
File.ico?("/path/to/some_file.ico")   # Is the file an ICO file?
File.png?("/path/to/some_file.png")   # Is the file a PNG file?
File.tiff?("/path/to/some_file.tiff") # Is the file a TIFF file?

# Test to see if a file is a binary file:
File.binary?("/bin/ls") # true
File.binary?("/path/to/some_file.jpg") # false

# Simulate the "wc" command:
File.wc("/path/to/some_file.txt", "words")
File.wc("/path/to/some_file.txt", "chars")
File.wc("/path/to/some_file.txt", "lines")
File.wc("/path/to/some_file.txt", "bytes")
```

## Development

To run the specs, simply clone the repo and run `crystal spec`.

## Contributing

1. Fork it (<https://github.com/djberg96/crystal-ptools/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Daniel Berger](https://github.com/djberg96) - creator and maintainer

## Copyright
(C) 2022, Daniel J. Berger
All Rights Reserved

## Author
Daniel J. Berger
