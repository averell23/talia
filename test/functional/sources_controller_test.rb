require File.dirname(__FILE__) + '/../test_helper'
require 'sources_controller'

# Re-raise errors caught by the controller.
class SourcesController; def rescue_action(e) raise e end; end

class SourcesControllerTest < Test::Unit::TestCase
  def setup
    @controller = SourcesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @source_name      = 'something'
    @unexistent_name  = 'somewhat'
  end

  def test_index
    # FAILURE: TaliaCore::Source.find(:all) needed.
    get :index, {}
    assert_response :success
  end
  
  # SHOW
  def test_show_without_the_source_name
    # This will raise an exception, cause the route called is:
    #   sources/show
    # It tries to find a source with the name 'show'
    # This behavior it's ok, cause we cannot never request this route.
    assert_raise(ActiveRecord::RecordNotFound) { get :show, {} }
  end
  
  def test_show_with_unexistent_source_name
    assert_raise(ActiveRecord::RecordNotFound) { get :show, {:id => @unexistent_name} }
  end
  
  def test_show_with_wrong_http_verbs
    post    :show, {:id => @source_name}
    assert_response :success
    put     :show, {:id => @source_name}
    assert_response :success
    delete  :show, {:id => @source_name}
    assert_response :success
  end
  
  def test_show
    get :show, {:id => @source_name}
    assert_response :success
    
    assert_select 'h1', 'Show source'
    assert_select 'table' do
      assert_select 'tr', :count => 4
      assert_select 'tr' do
        assert_select 'th', :count => 4
        assert_select 'td', :count => 4
      end
    end
    
    assert_select "a[href=/sources]"
    # FAILURE: support for edit_source_path(@source) needed.
    assert_select "a[href=/sources/#{@source_name}/edit]"
  end
  
  # SHOW_ATTRIBUTE
  def test_show_attribute_without_thw_source_name
    assert_raise(ActiveRecord::RecordNotFound) { get :show_attribute, {} }
  end
  
  def test_show_attribute_with_unexistent_source_name
    assert_raise(ActiveRecord::RecordNotFound) { get :show_attribute, {:id => @unexistent_name} }
  end
  
  def test_show_attribute_with_wrong_http_verbs
    post   :show_attribute, {:id => @source_name, :attribute => 'name'}
    # FAILURE: support for @source.read_attribute needed.
    assert_response :success
    put    :show_attribute, {:id => @source_name, :attribute => 'name'}
    assert_response :success
    delete :show_attribute, {:id => @source_name, :attribute => 'name'}
    assert_response :success
  end
  
  def test_show_attribute
    assert_routing("sources/#{@source_name}/name",
                  {:controller => 'sources', :action => 'show_attribute', 
                    :id => 'something', :attribute => 'name'})
    get :show_attribute, {:id => @source_name, :attribute => 'name'}
    # FAILURE: support for @source.read_attribute needed.
    assert_response :success
  end
  
  # NEW
  def test_new
    get :new, {}
    
    assert_select 'h1', 'New source'
    assert_select "form[method=?]", "post"
    assert_select "form[action=?]", "/sources"
    assert_select 'form' do
      assert_select "p",                    :count => 4
      assert_select "label",                :count => 4
      assert_select "select",               :count => 1
      assert_select "input[type=text]",     :count => 3
      assert_select "input[type=submit]",   :count => 1
      assert_select "select[id=source_primary_source]" do
        assert_select "option", :count => 2
      end
    end
    assert_select "a[href=/sources]"
  end
  
  # EDIT
  def test_edit_without_the_source_name
    assert_raise(ActiveRecord::RecordNotFound) { get :edit, {} }
  end
  
  def test_edit_with_wrong_source_name
    assert_raise(ActiveRecord::RecordNotFound) { get :edit, {:id => @unexistent_name} }
  end
  
  def test_edit
    get :edit, {:id => @source_name}
    
    assert_select 'h1', 'Edit source'
    assert_select "form[method=?]", "post"
    assert_select "form[action=?]", "/sources/something?html%5Bmethod%5D=put"
    assert_select 'form' do
      assert_select "p",                    :count => 4
      assert_select "label",                :count => 4
      assert_select "select",               :count => 1
      assert_select "input[type=text]",     :count => 3
      assert_select "input[type=submit]",   :count => 1
      assert_select "select[id=source_primary_source]" do
        assert_select "option", :count => 2
      end
    end
    assert_select "a[href=/sources]"
    # FAILURE: support for source_path(@source) needed.
    assert_select "a[href=/sources/#{@source_name}]"
  end
  
  # UPDATE
  def test_update_without_the_source_name
    assert_raise(ActiveRecord::RecordNotFound) { put :update, {} }
  end
  
  def test_update_with_wrong_source_name
    assert_raise(ActiveRecord::RecordNotFound) { put :update, {:id => @unexistent_name} }
  end
  
  def test_update_wrong_http_verbs
    get     :update, {:id => @source_name}
    assert_response :success
    post    :update, {:id => @source_name}
    assert_response :success
    delete  :update, {:id => @source_name}
    assert_response :success
  end
  
  def test_update
    source = TaliaCore::Source.find(@source_name)
    source.name = 'updated name'
    params = {:id => @source_name, :source => source}
    put :update, params
    assert_response :success
    # TODO implent tests for redirect to the index action
  end
  
  # DESTROY
  def test_destroy_without_the_source_name
    assert_raise(ActiveRecord::RecordNotFound) { delete :destroy, {} }
  end
  
  def test_destroy_with_wrong_source_name
    assert_raise(ActiveRecord::RecordNotFound) { delete :destroy, {:id => @unexistent_name} }
  end
  
  def test_destroy_with_wrong_http_verbs
    get     :destroy, {:id => @source_name}
    assert_response 302
    post    :destroy, {:id => @source_name}
    assert_response 302
    put     :destroy, {:id => @source_name}
    assert_response 302
  end
  
  def test_destroy
    delete :destroy, {:id => @source_name}
    assert_response 302
    # TODO implent tests for redirect to the index action
  end
end