# crystal-ptools

This is a Crystal port of the "ptools" library originally written for Ruby.
It contains additional singleton methods for the File class.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     crystal-ptools:
       github: your-github-user/crystal-ptools
   ```

2. Run `shards install`

## Usage

```crystal
require "crystal-ptools"

File.bmp?("/path/to/some_file.bmp") # Is the file a bitmap file?
File.jpg?("/path/to/some_file.bmp") # Is the file a JPEG file?
File.ico?("/path/to/some_file.bmp") # Is the file an ICO file?
File.png?("/path/to/some_file.bmp") # Is the file a PNG file?
File.tiff?("/path/to/some_file.bmp") # Is the file a TIFF file?
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/your-github-user/crystal-ptools/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Daniel Berger](https://github.com/djberg96) - creator and maintainer
