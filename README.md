[![Main workflow: unit tests](https://github.com/s2k/ini_file/actions/workflows/ruby.yml/badge.svg)](https://github.com/s2k/ini_file/actions) <sup style="font-size:125%;">᛫</sup> [![CodeQL for 'ini_file'](https://github.com/s2k/ini_file/actions/workflows/codeql.yml/badge.svg)](https://github.com/s2k/fd/actions/workflows/codeql-analysis.yml) <sup style="font-size:125%;">᛫</sup> [![Maintainability](https://api.codeclimate.com/v1/badges/a85527d101c9ed8f581b/maintainability)](https://codeclimate.com/github/s2k/fd/maintainability)

# A Ruby gem to parse INI files

A while ago (notice the date & tool of the first commit) I needed a way to parse INI files in a Ruby tool.

The library was supposed to read & and write INI files. In particular I wanted the tool to _keep_ any comments in a _read_ INI file in place with the following setting.

Therefore: `ini_file.rb`

It' not (yet?) a Ruby gem, but may still be useful for folks.


