module Ini_File
	require "English"

	class Invalid_IniFile < RuntimeError
	end

	class Pair
		attr_reader( :key, :value, :comment )
		def initialize( key = nil , val = nil, comment = "" )
			@key, @value, @comment = key, val, comment
		end

		def to_s
			res = ""
			res += "\n#@comment\n" if @comment != ""
			res += "#@key = #@value\n"
			return res
		end
	end

	class Section
		attr_reader :sect_name, :entries, :comment_

		def initialize( sct_name = nil, comment = "" )
			@sect_name, @comment_ = sct_name, comment

			# Key names are mapped to the whole Pair object
			@entries = Hash.new
		end

		def comment( commentee = nil )
			if commentee != nil
				return @entries.entry( commentee )
			else
				return @comment_
			end
		end

		def comment= ( comment )
			@comment_ = comment
		end

		def add_pair( key, val, comment = "" )
			@entries[ key ] = Pair.new( key, val, comment )
		end

		def empty?
			@entries.empty?
		end

		def get_value( key )
			@entries[key].value
		end
		alias [] get_value

		def inspect
			"< " + self.class.to_s + " - Name: #@sect_name / Comment: #@comment_ - #{@entries.inspect} >"
		end

		def get_pair( pair_name )
			return @entries[ pair_name ]
		end

		def to_s
			res = "\n"
			res += "#@comment_\n" if @comment_ != ""
			res += "[#@sect_name]\n" if @sect_name
			@entries.each{ | k, v |
				res += v.to_s
			}
			return res
		end

	end

	class Sections
		attr_reader :sections

		def initialize
			# Maps Section_names to Section_Objects
			@sections = Hash.new
			@sections[ "" ] = Section.new
		end

		def <<( sect_name )
			@sections[ sect_name ] = Section.new( sect_name )
		end

		def sort
			return @sections.keys.sort
		end

		def size
			return sections.size
		end

		def each
			@sections.keys.sort.each{ | k |
				yield k
			}
		end

		def section( sect_name )
			return @sections[ sect_name ]
		end

		def to_s
			res = ""
			each{ | sect |
				res += section( sect ).to_s
			}
			return res
		end
	end


	class IniFile

		attr_reader :file
		attr_reader :sections

		def initialize( filename )
			@file = filename
			@sections = Sections.new
			last_section = ""
			comment = ""
			 File.foreach( @file ){ | line |
				case line
					when /^\s*$/
					# Start a new section
					when /^\s*\[\s*([^\]]*)\s*\]/
						@sections << $1
						last_section = $1
						@sections.section( $1 ).comment = comment
						comment = ""
					when /^\s*(.*?)\s*=\s*(.*?)\s*$/
						@sections.section( last_section ).add_pair( $1 , $2, comment )
						comment = ""
					when /^\s*(?=[;\#])(.*?)\s*$/
						comment += ( ( comment.size == 0 ) ? "" : "\n" ) + $1
					else
						raise Invalid_IniFile, "Can't parse file '#@file' at line #{$INPUT_LINE_NUMBER}" , caller
				end
			}
		end

		def each_section( &b )
			@sections.each { | s |
			yield s
			}
		end

		def section( sect_name )
			return @sections.section( sect_name )
		end

		def to_s
			return @sections.to_s
		end

		def ==( other )
			to_s == other.to_s
		end

		def save( file_name )
			File.open( file_name, "w" ) { | file |
				file.puts to_s
			}
		end
	end
end