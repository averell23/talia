module LayoutHelper
  def title(page_title)
    @content_for_title = if page_title.to_s
      page_title.to_s
    elsif @source
      short_name(@source)
    end
  end

  def subtitle
    @subtitle || "Let's discover what's out there"
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
  
  # Show flash messages.
  def show_flash
    return if flash.empty?

    flash.map do |status, message|
      content_tag(:div, h(message), :id => "flash_#{status}")
    end
  end
  
  # Show the logout box if the user is loggedin.
  # TODO: in future should handle even the login link.
  def login_box
    %(<div id="login_box">#{languages_box} | #{link_to("Logout", logout_path)}</div>) if logged_in?
  end
  
  def languages_box
    select_tag("languages", languages_box_options_tags, :onchange => change_language_function)
  end
  
  def languages_box_options_tags
    languages.map do |language, locale|
      language = language.to_s.titleize
      selected = locale == Locale.active.code
      value = change_language_path(locale)
      content_tag(:option, language, :value => value, :selected => selected)
    end
  end
  
  def change_language_function
    "javascript:window.location.href = this.options[this.selectedIndex].value;"
  end
  
  def stylesheet(*file_names)
    @content_for_stylesheet ||= ""
    @content_for_stylesheet << file_names.map { |fn| stylesheet_link_tag(fn.to_s) }.join("\n")
  end
  
  # URL-encode a string
  def escape(string)
    UriEncoder.escape string
  end
  
  # URL-decode a string
  def unescape(string)
    UriEncoder.unescape string
  end
  
  def unescape_link(link)
    UriEncoder.unescape_link(link)
  end
end