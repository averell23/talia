class Admin::TranslationsController < ApplicationController
  require_role 'admin'
  PER_PAGE = 30

  # GET /admin/translations
  def index
    redirect_to :action => 'edit', :id => Locale.active.code
  end

  # GET /admin/translations/edit/en-US
  def edit
    @translations = ViewTranslation.find_by_locale(params[:id], params[:page], PER_PAGE)
    @locale_code = params[:id]
  end

  # PUT /admin/translations/update/en-US
  def update
    if ViewTranslation.update(params[:translations].keys, params[:translations].values)
      flash[:notice] = 'Your translations has been saved'
    else
      flash[:error]  = 'There was some problems'
    end

    redirect_to :action => 'edit', :id => params[:id], :page => params[:page]
  end
end
