module TaliaCore

  # Refers to a transcription of a Manuscript subpart
  class Transcription < HyperEdition
    def available_versions
      # this is needed because previews must provide the format, while in normal
      # operations the format is retrieved from the source (which doesn't exist
      # in the preview case)
      @format = self.dcns::format.first if @format.nil?
      case @format
      when 'application/xml+hnml'
        ['linear', 'diplomatic']
      when 'application/xml+tei', 'application/xml+tei-p4', 'application/xml+tei-p5'
        ['standard']
      when 'application/xml+wittei'
        ['dipl', 'norm', 'study']
      when 'text/html'
        ['standard']
      else
        #FIXME: add a better thing for this after the review        raise(ArgumentError, "Unknown content type for #{self.uri}: #{self.dcns::format.first}")
        ['standard']
      end
    end


    def to_html(version=nil, layer=nil, xml=nil, format=nil, preview=false)
      self.class.benchmark("\033[36m\033[1m\033[Transcription\033[0m Creating XML for #{self.id}") do
      @format = format unless format.nil?
      #fills the @in_xml and the @format vars
      prepare_transformation(xml, format)
      # if no version is specified, it takes the first available
      return '' if available_versions.nil? and version.nil?
      version = available_versions[0] if version.nil?
      output = ''
      unless @in_xml.nil?
        begin
          case @format
          when 'application/xml+hnml'
            max_layer = hnml_max_layer
            middle_output = ''
            if max_layer != ''
              shown_layer = layer.nil? ? max_layer : layer
              transformer_parameters = {'layer' => shown_layer}
            end
            mid_xml = perform_transformation("transcription_#{version}", @in_xml, transformer_parameters)
            output = perform_transformation("transcription_#{version}_2", mid_xml, transformer_parameters)
          when 'application/xml+tei', 'application/xml+tei-p4', 'application/xml+tei-p5'
            output = perform_transformation('tei', @in_xml)
          when 'application/xml+wittei'
            # visning is the parameter for the version in the wab-transform.xsl file
            transformer_parameters = {'visning' => version, 'prosjekt' => (preview ? 'discovery-preview' : 'discovery')}
            output =  perform_transformation('wab-transform', @in_xml, transformer_parameters)
          when 'text/html'
            output = @in_xml
          end
        rescue Exception => e
          # #TODO: handle these specific (java) exception:
          #   net.sf.saxon.trans.XPathException
          #    org.xml.sax.SAXParseException
            logger.warn("\033[1m\033[4m\033[31mTranscription\033[0m Xml transformation of #{self.uri} failed with message: " + e.message)
          output = "XML is Broken!"
        end
      else
        puts "Warning file was missing: #{infile} calculation will continue"
      end
      output
    end
  end
end
end
