require 'talia_util/hyper_xml_import'

class ImportController < ApplicationController
  def create
    respond_to do |format|
      format.xml do
        begin
          # TODO should we move the xml doc creation in #import?
          @document = TaliaUtil::HyperImporter::Importer.import(REXML::Document.new(params[:document]))
          render :inline => 'The source has been created.', :status => :created
        rescue
          render :inline => 'Error', :status => 400
        end
      end
    end
  end
end