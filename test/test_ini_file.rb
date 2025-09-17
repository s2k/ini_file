# frozen_string_literal: true

require 'English'
require 'minitest/autorun'
require 'tempfile'
require_relative '../lib/ini_file'

class IniFileTest < Minitest::Test
  include IniFileGem
end

class TestIni < IniFileTest
  def setup
    @ini = IniFile.new('test_1.ini')
    @sections = ['', 'TheFirstSection', 'Another Section', 'AndThe 3rd', 'Has2CommentLines'].sort
    @allkeys = %w[before_any_section_or_comment 1stKey s1k1 s1k2].sort
  end

  def test_get_filename
    assert_equal('test_1.ini', @ini.file)
  end

  def test_retrieve_sections
    assert_equal(@sections, @ini.sections.sort)
  end

  def test_each_section
    assert_equal(@sections.size, @ini.sections.size)
    i = 0
    @ini.each_section do |s|
      assert_equal(@sections[i], s)
      i += 1
    end
  end

  def test_section
    sct1 = @ini.section('TheFirstSection')

    assert_equal('aValue', sct1.get_value('s1k1'))
    assert_equal('anotherValue', sct1['s1k2'])
    assert_equal('1234', @ini.section('')['before_any_section_or_comment'])
    assert_equal('aValue', @ini.section('TheFirstSection')['s1k1'])
  end

  def test_section_empty
    assert_empty(@ini.section('Another Section'))
    assert_empty(@ini.section('AndThe 3rd'))
    refute_empty(@ini.section('TheFirstSection'))
  end

  def test_get_sectioncomment
    assert_equal(';This is yet another comment', @ini.section('TheFirstSection').comment)
    cmt = "; Two comment lines\n# that both belong to section [Has2CommentLines]"

    assert_equal(cmt, @ini.section('Has2CommentLines').comment)
  end

  def test_get_paircomment
    assert_equal('', @ini.section('').get_pair('before_any_section_or_comment').comment)
    assert_equal('# a comment concerning Has2CommentLines/key2',
                 @ini.section('Has2CommentLines').get_pair('key2').comment)
    assert_equal('# Note that this is a comment', @ini.section('').get_pair('1stKey').comment)
  end

  def test_ini_to_string
    ini_to_s = @ini.to_s
    fn = Tempfile.new('initemp')
    fn.puts ini_to_s
    fn.close
    @ini2 = IniFile.new(fn.path)

    assert_equal(@ini, @ini2)
  end

  def test_save_ini_file
    expect = <<~ENDOFFILE

      before_any_section_or_comment = 1234

      # Note that this is a comment
      1stKey = 1stValue

      [AndThe 3rd]

      [Another Section]

      ; Two comment lines
      # that both belong to section [Has2CommentLines]
      [Has2CommentLines]
      key1 = Value_1

      # a comment concerning Has2CommentLines/key2
      key2 = Value_2

      ;This is yet another comment
      [TheFirstSection]
      s1k1 = aValue
      s1k2 = anotherValue
    ENDOFFILE
    tmp_name = './ini-tmp.ini'
    @ini.save(tmp_name)
    f = File.readlines(tmp_name).join

    assert_equal(expect, f)
  end
end

class TestIniFileValidation < IniFileTest
  def setup
    @sections = ['', 'TheFirstSection', 'Another Section', 'AndThe 3rd', 'Has2CommentLines'].sort
    @allkeys = %w[before_any_section_or_comment 1stKey s1k1 s1k2].sort
  end

  def test_invalid_ini_file
    assert_raises(InvalidIniFile, "Should have risen InvalidIniFile, but didn't") do
      @ini = IniFile.new('test_2.ini')
    end
  end
end
