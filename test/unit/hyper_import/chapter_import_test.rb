require 'test/unit'

# Load the helper class
require File.join(File.dirname(__FILE__), 'util_helper')

# require util stuff
require 'talia_util'

module TaliaUtil

  # Test te DataRecord storage class
  class ChapterImportTest < Test::Unit::TestCase
  
    include UtilTestMethods
    
    suppress_fixtures
    
    # Flush RDF before each test
    def setup
      setup_once(:flush) do
        clean_data_files
        Util.flush_rdf
        Util.flush_db
        true
      end
      setup_once(:src) do
        hyper_import(load_doc('AC-[Text]'))
      end
    end
    
    # Test if the import succeeds
    def test_import
      assert_kind_of(TaliaCore::Chapter, @src)
    end
    
    # Test if the types were imported correctly
    def test_types
      assert_types(@src, N::HYPER + "Chapter", N::HYPER + "Work")
    end
    
    # Test the title property
    def test_title
      assert_property(@src.dcns::title, "[Text]")
    end
    
    # Test the ordering
    def test_ordering
      assert_property(@src.hyper::position, "2")
    end
    
    # Test the first page
    def test_first_page
      assert_property(@src.hyper::first_page, N::LOCAL + "AC,[Text]")
    end
    
    # Test source name
    def test_uri
      assert_equal(N::LOCAL + "AC-[Text]", @src.uri)
    end
    
    def test_siglum
      assert_equal('AC-[Text]', @src.siglum)
    end
    
    # Test the name
    def test_name
      assert_property(@src.hyper::name, "[Text]")
    end
    
  end
end
