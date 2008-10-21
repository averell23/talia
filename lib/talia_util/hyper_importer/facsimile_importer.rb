module TaliaUtil
  
  module HyperImporter
    
    # Import class for paragraphs
    class FacsimileImporter < ContributionImporter
      
      source_type 'hyper:Facsimile'
      
      def import!
        contribution_import!
        import_dimensions!
      end
      
      # Import the dimensions
      def import_dimensions!
        if((width = @element_xml.elements['dimensionX'])&& (height = @element_xml.elements['dimensionY']))
          source.dct::extent << "#{width.text.strip}x#{height.text.strip} pixel"
        end
      end
      
    end
  end
end