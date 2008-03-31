class AdminController < ApplicationController
  require_role 'admin'

  def index
    @links = %w(users sources)
  end
end
