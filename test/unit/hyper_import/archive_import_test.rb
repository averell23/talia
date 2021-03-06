require 'test/unit'

# Load the helper class
require File.join(File.dirname(__FILE__), 'util_helper')

# require util stuff
require 'talia_util'

module TaliaUtil

  # Test te DataRecord storage class
  class ArchiveImportTest < Test::Unit::TestCase
  
    include UtilTestMethods
    
    suppress_fixtures
    
    # Flush RDF before each test
    def setup
      flush_once_for_import_test
      setup_once(:src) { hyper_import(load_doc('Goethe- und Schiller-Archiv')) }
    end

    # Test if the import succeeds
    def test_import
      assert_kind_of(TaliaCore::Archive, @src)
    end

    # Test source name
    def test_uri
      assert_equal(N::LOCAL + "Goethe-+und+Schiller-Archiv", @src.uri)
    end

    def test_siglum
      assert_property(@src.hyper::siglum, "Goethe- und Schiller-Archiv")
    end

    # Test if the types were imported correctly
    def test_types
      assert_types(@src, N::HYPER.Archive)
    end

    # Test the ordering
    def test_local_id
      assert_property(@src.hyper::local_id, "1")
    end

    def test_state
      assert_property(@src.hyper::country, "Germany")
    end

    def test_city
      assert_property(@src.hyper::city, "Weimar")
    end

    def test_street
      assert_property(@src.hyper::address, "Hans-Wahl-Straße n. 4 D-99423 Weimar")
    end

    def test_copyright
      assert_property(@src.dcns::rights, "© Stiftung Weimarer Klassik und Kunstsammlungen, Goethe- und Schiller-Archiv, Weimar 2003")
    end
    
  end
end