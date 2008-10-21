  
require 'rexml/document'
require 'talia_core/data_types/file_store'

module TaliaCore

  # Refers to a transcription of a Work subpart
  class TextReconstruction < HyperEdition
    def available_versions
      case self.dcns::format.first
      when 'application/xml+hnml', 'application/xml+gml'
        ['diplomatic']
      when 'application/xml+tei'
        ['standard']
      when 'application/xml+wit_tei'
        ['norm', 'dipl', 'study']
      else
        raise(ArgumentError, "Unknown content type #{self.dcns::format.first}")
      end
    end
    
    def to_html(version=nil, layer=nil)
      # if no version is specified, it takes the first available
      version = available_versions[0] if version.nil?
      require 'JXslt/jxslt'
      saxon = JXslt::Saxon.new
      infile = self.data[0].file_path
      output = ''
      case self.dcns::format.first
      when 'application/xml+hnml'
        max_layer = hnml_max_layer
        middle_output = ''     
        if max_layer != '' 
          shown_layer = layer.nil? ? max_layer : layer
          transformer_parameters = {'layer' => shown_layer}
        end
        xsl = 'public/xsl/hnml/edition_linear.xsl'
        middle_output = saxon.transform(xsl, infile, nil, options = {:in => "stream", :out => "string", :transformer_parameters => transformer_parameters})
        xsl = 'public/xsl/hnml/edition_linear_2.xsl'
        output = saxon.transform(xsl, middle_output, nil, options = {:in => "string", :out => "string", :transformer_parameters => transformer_parameters})
      when 'application/xml+tei'
        xsl = 'public/xsl/TEI/p4/html/tei.xsl'
        output = saxon.transform(xsl, infile, nil, options = {:in => "stream", :out => "string"})
      when 'application/xml+wit_tei'
        xsl = 'public/xsl/WitTEI/wab-transform.xsl'    
        # visning is the parameter for the version in the wab-transform.xsl file        
        transformer_parameters = {'visning' => version}
        output = saxon.transform(xsl, infile, nil, options = {:in => "stream", :out => "string", :transformer_parameters => transformer_parameters})          
      end
      output
    end
   
  end
end