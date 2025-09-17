# frozen_string_literal: true

# Wraps gem content in a matching namespace
#
module IniFileGem
  require 'English'

  class InvalidIniFile < RuntimeError
  end

  # Pair represents a single key values pair in an INI file.
  #
  class Pair
    attr_reader :key, :value, :comment

    def initialize(key = nil, val = nil, comment = '')
      @key = key
      @value = val
      @comment = comment
    end

    def to_s
      res = ''
      res += "\n#{@comment}\n" if @comment != ''
      res += "#{@key} = #{@value}\n"
      res
    end
  end

  # INI files can be structured by using sections (parts that are marked with `[section_title]`)
  # This class represents the sections (if any) in an INI file,
  # including it's comments & key/value pairs
  class Section
    attr_reader :sect_name, :entries, :comment_

    def initialize(sct_name = nil, comment = '')
      @sect_name = sct_name
      @comment_ = comment

      # Key names are mapped to the whole Pair object
      @entries = {}
    end

    def comment(commentee = nil)
      if commentee.nil?
        @comment_
      else
        @entries.entry(commentee)
      end
    end

    def comment=(comment)
      @comment_ = comment
    end

    def add_pair(key, val, comment = '')
      @entries[key] = Pair.new(key, val, comment)
    end

    def empty?
      @entries.empty?
    end

    def get_value(key)
      @entries[key].value
    end
    alias [] get_value

    def inspect
      "< #{self.class} - Name: #{@sect_name} / Comment: #{@comment_} - #{@entries.inspect} >"
    end

    def get_pair(pair_name)
      @entries[pair_name]
    end

    def to_s
      res = "\n"
      res += "#{@comment_}\n" if @comment_ != ''
      res += "[#{@sect_name}]\n" if @sect_name
      @entries.each_value { |v| res += v.to_s }

      res
    end
  end

  # Sections are collections of, sections
  #
  class Sections
    attr_reader :sections

    def initialize
      # Maps Section_names to Section_Objects
      @sections = {}
      @sections[''] = Section.new
    end

    def <<(sect_name)
      @sections[sect_name] = Section.new(sect_name)
    end

    def sort
      @sections.keys.sort
    end

    def size
      sections.size
    end

    def each(&)
      @sections.keys.sort.each(&)
    end

    def section(sect_name)
      @sections[sect_name]
    end

    def to_s
      res = ''
      each do |sect|
        res += section(sect).to_s
      end
      res
    end
  end

  # This is the main class.
  # It's initialises by passing a filename to `init`.
  #
  class IniFile
    attr_reader :file, :sections

    def initialize(filename)
      @file = filename
      @sections = Sections.new
      last_section = ''
      comment = ''
      File.foreach(@file) do |line|
        case line
        when /^\s*$/
        # Start a new section
        when /^\s*\[\s*([^\]]*)\s*\]/
          @sections << Regexp.last_match(1)
          last_section = Regexp.last_match(1)
          @sections.section(Regexp.last_match(1)).comment = comment
          comment = ''
        when /^\s*(.*?)\s*=\s*(.*?)\s*$/
          @sections.section(last_section).add_pair(Regexp.last_match(1), Regexp.last_match(2), comment)
          comment = ''
        when /^\s*(?=[;\#])(.*?)\s*$/
          comment += (comment.size.zero? ? '' : "\n") + Regexp.last_match(1)
        else
          raise InvalidIniFile, "Can't parse file '#{@file}' at line #{$INPUT_LINE_NUMBER}", caller
        end
      end
    end

    def each_section(&block)
      @sections.each(&block)
    end

    def section(sect_name)
      @sections.section(sect_name)
    end

    def to_s
      @sections.to_s
    end

    def ==(other)
      to_s == other.to_s
    end

    def save(file_name)
      File.open(file_name, 'w') do |file|
        file.puts to_s
      end
    end
  end
end
