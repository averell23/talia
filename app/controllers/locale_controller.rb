class LocaleController < ApplicationController
  before_filter :check_globalize
  before_filter :normalize_key, :only => [ :translate, :translate_unformatted ]
  
  def set
    Locale.set(params[:id]) if params[:id]
    flush_locale
    session[:locale] = Locale.active
    session[:__globalize_translations] = nil
    logger.debug("[#{Time.now.to_s(:db)}] - Set current Locale on #{Locale.language}")
    redirect_to request.env['HTTP_REFERER'] if request.env['HTTP_REFERER']
  end
  
  def translate
    if request.xhr?
      Locale.set_pluralized_translation(params[:key], 1, params[:value])
      @formatted_value = params[:value]
      render :layout => false, :inline => "<%= #{inline} %>"
    end
  end
  
  def translate_unformatted
    if request.xhr?
      @unformatted_value = Locale.translate(params[:key])
      render :layout => false, :inline => "<%= @unformatted_value %>"
    end
  end
  
  def translations
    if request.xhr?
      logger.debug("Translations got from the server: #{session[:__globalize_translations].inspect}")
      render :json => session[:__globalize_translations].to_json, :status => 200
    end
  end
  
  private
  def check_globalize
    # Note: self.class.globalize? is deprecated.
    globalize? && self.class.globalize?
  end
  
  def inline
    case Locale.formatting
      when :textile   then 'textilize_without_paragraph( @formatted_value )'
      when :markdown  then 'markdown( @formatted_value )'
      else                 '@formatted_value'
    end
  end
  
  # Normalize the translation key, according to Globalize keys handling.
  def normalize_key
    params[:key] = params[:key].gsub('_', ' ') unless params[:key].blank?
  end
end
