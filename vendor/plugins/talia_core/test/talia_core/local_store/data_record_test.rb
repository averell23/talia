# Load the helper class
require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')

class UploadedFile < File
  include ActionController::UploadedFile
  attr_accessor_with_default(:content_type) { 'text/plain' }
  alias_method :original_path, :path
  
  def size
    self.class.size(original_path)
  end
end

module TaliaCore
  # Test te DataRecord storage class
  class DataRecordTest < Test::Unit::TestCase
    
    fixtures :source_records, :data_records

    def setup
      @test_records = DataRecord.find_data_records(1)
      
      setup_once(:image_mime_types) do
        Mime::Type.register "image/gif", :gif, [], %w( gif )
        Mime::Type.register "image/jpeg", :jpeg, [], %w( jpeg jpg jpe jfif pjpeg pjp )
        Mime::Type.register "image/png", :png, [], %w( png )
        Mime::Type.register "image/tiff", :tiff, [], %w( tiff tif )
        Mime::Type.register "image/bmp", :bmp, [], %w( bmp )
        image_mime_types = ['image/gif', 'image/jpeg', 'image/png', 'image/tiff', 'image/bmp']
        image_mime_types
      end
    end
    
    def test_paths
      tempfile_path = File.join(TALIA_ROOT, 'tmp', 'data_records')
      data_path     = File.join(TALIA_ROOT, 'data')
      assert_equal(tempfile_path, DataRecord.tempfile_path)
      assert_equal(tempfile_path, DataRecord.new.send(:tempfile_path))
      assert_equal(data_path, DataRecord.data_path)
      assert_equal(data_path, DataRecord.new.send(:data_path))
    end
    
    # test not nil and records numbers
    def test_records_numbers
      assert_not_equal [], @test_records
      assert_equal 13, @test_records.size
    end
  
    # test class type and mime_type
    def test_mime_types
      assert_kind_of(SimpleText, @test_records[0])
      assert_kind_of(SimpleText, @test_records[1])
      assert_equal("text/plain", @test_records[0].mime_type)
      assert_equal("text/plain", @test_records[1].mime_type)
    end
    
    # test data directory
    def test_data_directory
      dir_for_test = File.expand_path(@test_records[0].data_directory)
      assert_equal(data_path_test(@test_records[0].id), dir_for_test)
      assert( File.exists?(dir_for_test) )
      assert_equal(File.join(data_path_test, 'temp1.txt'), File.join(dir_for_test, @test_records[0].location))
      assert( File.exists?(File.join(dir_for_test, @test_records[0].location)), "#{File.join(dir_for_test, @test_records[0].location)} does not exist" )
    end

    def test_should_find_or_create_and_assign_file
      # FIXME: I use #file and #source_record_id instead of fixtures,
      # due to unpredictable ids assignment.
      # Because test process doesn't drop tables, but just empty and re-fill them.
      params = {:file => file, :source_record_id => source_record_id}
      assert(DataRecord.find_or_create_and_assign_file(params))
    end

    # test file size
    def test_file_size
      assert_equal(180, @test_records[0].size)
    end
    
    # test binary access
    def test_binary_access
      # Check initial position
      assert_equal(0, @test_records[0].position)
      
      # Try to read all bytes
      bytes = @test_records[0].all_bytes
      assert_equal(180, bytes.size)
      assert_equal(false, @test_records[0].is_file_open?)

      # Re-check position (it should be 0)
      assert_equal(0, @test_records[0].position)
      
      # Read only one bytes and check position
      byte = @test_records[0].get_byte
      # check byte by code (76 == 'L')
      assert_equal(76, byte)
      # Re-check position (it should be 1)
      assert_equal(1, @test_records[0].position)
    end
    
    # test for specific classes methods
    def test_specific_classes_methods
      # Get a line
      line = "LINE1: This is a simple text to check the DataRecords class\n"
      assert_equal(line, @test_records[0].get_line)
    end
    
    def test_mime_type
      ['text/plain'].each do |mime|
        assert_equal('SimpleText', DataRecord.mime_type(mime))
      end

      @image_mime_types.each { |mime| assert_equal('ImageData', DataRecord.mime_type(mime)) }
      
      ['text/xml', 'application/xml'].each do |mime|
        assert_equal('XmlData', DataRecord.mime_type(mime))
      end
      
      assert_equal('DataRecord', DataRecord.mime_type('application/rtf'))
    end
    
    def test_file_should_always_return_nil
      assert_nil(DataRecord.new.file)
    end
    
    def test_should_save_attachment
      assert(!DataRecord.new.send(:save_attachment?))
      data_record = DataRecord.new do |dr|
        dr.file = file
      end
      assert(data_record.send(:save_attachment?))
    end
        
    def test_full_filename
      data_record = DataRecord.new do |dr|
        dr.location  = 'image.jpg'
        dr.assign_type 'image/jpeg'
      end
      expected = File.join(DataRecord.data_path, data_record.type, data_record.location)
      assert_equal(expected, data_record.send(:full_filename))
    end

    def test_extract_filename
      assert_equal('temp1.txt', DataRecord.extract_filename(file))
    end

    private
    def data_path_test(id=nil)
      @data_path_test ||= File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'data_for_test', 'SimpleText', ("00" + id.to_s)[-3..-1], id.to_s))
    end

    def file
      UploadedFile.new(File.join(data_path_test(DataRecord.find(:first).id), DataRecord.find(:first).location))
    end

    def source_record_id
      SourceRecord.find(:first).id
    end
  end  
end
