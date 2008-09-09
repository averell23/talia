# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  
  def iip_flash_viewer(element, height = 400, width = 400)
    iip_data = get_iip_data_for(element)
    return "No iip data for #{element.uri}" unless(iip_data)
    
    render :partial => 'shared/iip_flash_viewer', :locals => {
      :image_path => iip_data.get_iip_root_file_path,
      :height => height.to_s,
      :width => width.to_s,
      :element_id => "iip_viewer_#{rand 10E16}" # Random name so that multiple instances can be used 
    }
  end
  
  def header
    render :partial => 'shared/main_header'
  end
  
  def footer
    render :partial => 'shared/main_footer'
  end
  
  def sidebar
    sidebar_title = nil
    sidebar_title = "#{@source.label} is" if(@source)
    widget(:sidebar,
      'active_tab' => 'context',
      'active_tab_options' => { :source => @source },
      'sidebar_title' => sidebar_title
    )
  end
  
  def talia_footer
    %( <div id="footer" class="open">
       <h1>Talia | Discovery</h1>
       <p>Let's discover things</p>
       </div> )
  end
  
  # Returns the title for the whole page. This returns the value
  # set in the controller, or a default value
  def page_title
    @page_title || TaliaCore::SITE_NAME
  end
  
  # Returns the subtitle for the page. See page_title
  def page_subtitle
    @page_subtitle ? @page_subtitle : "Let's discover what's out there"
  end
  
  # Creates a link to the given source
  def source_link(text, source)
    link_to(text, :controller => 'sources', :action => 'show', :id => source.uri.local_name)
  end
  
  def javascript(*file_names)
    file_names.each {|fn| content_for :javascript, javascript_include_tag(fn.to_s)}
    nil
  end
  
  def stylesheet(*file_names)
    file_names.each {|fn| content_for :stylesheet, stylesheet_link_tag(fn.to_s)}
    nil
  end
  
  # Helper to get the short name of a source
  def short_name(source) 
    assit_kind_of(TaliaCore::Source, source)
    shortname = source.talias::shortname
    if(shortname && shortname.size > 0)
      # get the first short name
      shortname = shortname[0]
    else
      shortname = source.uri.local_name
    end
    
    shortname
  end
  
  # Returns true if the given property has at least one value on the given
  # Source.
  def has_property?(property)
    property && property.size > 0
  end
  
  # Show each <tt>flash</tt> status (<tt>:notice</tt>, <tt>:error</tt>) only if it's present.
  def show_flash
    [:notice, :error].collect do |status|
      %(<div id="#{status}">#{flash[status]}</div>) unless flash[status].nil?
    end
  end
  
  # Show the logout box if the user is loggedin.
  # TODO: in future should handle even the login link.
  def login_box
    %(<div id="login_box">#{link_to("Logout", logout_path)}</div>) if logged_in?
  end
  
  def default_toolbar
    widget(:toolbar, :buttons => [ 
        ["Home", {:controller => 'sources', :action => 'show', :id => 'Lucca'}]
      ] )
  end
  
  # Get a link that contains the (thumbnail) image for the iip data record
  # of the first manifestation of the given expression card. The img_options
  # are added to the image tag.
  def thumb_link(element, img_options = {})
    url = element.uri.to_s
    title = element.uri.local_name
    
    # If this is a book we need to use the first page as a thumbnail
    data_element = if(element.is_a?(TaliaCore::Book))
      element.ordered_pages.first
    else
      element
    end
    
    # Try to get the iip data record for the manifestation of the element
    iip_data = get_iip_data_for(data_element)
    return titled_link(url, "missing image for #{title}", title) unless(iip_data)

    img_options = { :alt => title }.merge(img_options)
    img_tag = image_tag(url_for(:controller => 'source_data', :action => 'show', :id => iip_data.id), img_options)

    titled_link(url, img_tag, title)
  end
  
  def titled_link (url, text, title='')
    title ||= text
    text = text.t
    title = title.t
    "<a href='#{url}' title='#{title}'>#{text}</a>" 
  end
  
  def action_name
    controller.action_name
  end
  
  private
  
  def get_iip_data_for(expression_card)
    return nil unless(expression_card.manifestations.size > 0)
    iip_data = TaliaCore::DataTypes::IipData.find(:first, :conditions => { :source_id => expression_card.manifestations.first.id })
    iip_data
  end
  
end
