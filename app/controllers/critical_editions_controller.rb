class CriticalEditionsController < SimpleEditionController
  set_edition_type :critical
  add_javascripts 'tooltip', 'wit-js'

  layout 'simple_edition', :except => [:advanced_search_popup, :auto_complete_for_words]
  caches_action :show, :dispatcher, :locale => :current_locale

  ADVANCED_SEARCH_RESULTS_PER_PAGE = 20

  def dispatcher
    @request_url = URI::decode(request.url)
    @source = TaliaCore::Source.find(@request_url)
    case @source
    when TaliaCore::Book
      prepare_for_book
    when TaliaCore::Chapter
      prepare_for_chapter
    else
      prepare_for_part
    end
    print_tool # Enable the print button
  end
 
  # GET /critical_editions/1
  def show
    set_custom_stylesheet ['tooltip']
    set_user_stylesheet ['tei_style', 'front_page']
    @path = [{:text => params[:id]}]
  end
  
  def print
    set_custom_stylesheet ['tooltip']
    set_user_stylesheet ['tei_style_print']
    source_uri = "#{N::LOCAL}#{edition_prefix}/#{params[:id]}/#{params[:part]}"    
    source = TaliaCore::Source.find(source_uri)
    if source.class == TaliaCore::Book
      @book = source 
    else
      @book = source.book
    end
    @header = :"talia.search.print.#{@edition.uri.local_name}.header"
    render :layout => 'critical_print'    
  end
  
  def advanced_search
    set_custom_stylesheet ['tooltip']
	  set_user_stylesheet ['tei_style']
    
    # set advanced search widget visible
    set_advanced_search_visible true

    # set default path
    @path = [{:text => params[:id], :link => @edition.uri.to_s}]    
    
    # if user has clicked on seach button, execute search method
    unless params[:advanced_search_submission].nil?
      # check if there are the params
      if (params[:words].nil? or params[:words].strip == "") && 
          (params[:mc].nil? or params[:mc].join.strip == "")
        redirect_to(:back) and return
      end

      # execute advanced search
      adv_src = AdvancedSearch.new
      page = params[:page] || '1'
      if page == 'all'
        page = '1'
        @limit = 0
      else
        @limit = ADVANCED_SEARCH_RESULTS_PER_PAGE
      end
      @result = adv_src.search(edition_prefix, @edition.uri.to_s, params[:id], params[:words], params[:operator], params[:mc], params[:mc_from], params[:mc_to], params[:mc_single], true, page, @limit)

      @result_count = adv_src.size
      @result_match_count = adv_src.match_count

      # the number of pages we have to display
      if @limit == 0
        @pages = 1
      else
        @pages = (@result_count.to_f / @limit).ceil
      end
      
      @searched_works = []
      # load information from advanced search widget rows
      unless params[:mc].nil?
        [params[:mc], params[:mc_from], params[:mc_to]].transpose.each do |work,from,to|
          work_item = TaliaCore::Source.find(work)
          from_item = TaliaCore::Source.find(from)
          to_item = TaliaCore::Source.find(to)
          @searched_works << {:work => work_item.title,
            :from => from_item.title || from_item.uri.local_name,
            :to   => to_item.title || to_item.uri.local_name
          }
        end
      end

      # load information from left side menu
      unless params[:mc_single].nil? || params[:mc_single] == ""
        @searched_works = []
        single_work = TaliaCore::Source.find(params[:mc_single])
        @searched_works << {:single_work => single_work.title,
          :type => single_work.type
        }
      end

      # get result for menu
      @exist_result = adv_src.menu_for_search(@edition.uri.to_s, params[:words], params[:operator], params[:mc], params[:mc_from], params[:mc_to])

      # search word
      @words = params[:words]
            
      # get chosen_book for menu
      if ((params[:mc_single]) && (params[:mc_single] != ''))
        @source = TaliaCore::Source.find(params[:mc_single])
        case @source
        when TaliaCore::Book
          @book = @source
        when TaliaCore::Chapter
          @chapter = @source
          @book = @chapter.book
        else
          @part = @source
          @book = @part.book
          @chapter = @part.chapter
        end
      end
    end
  end

  def advanced_search_popup
    @header = :"talia.search.print.#{@edition.uri.local_name}.advanced_search_header"
    set_custom_stylesheet [['editions/advanced_search_print_print', 'print']]
    set_user_stylesheet ['tei_style_print']
  end
  
  def advanced_search_print
    # set custom stylesheet for screen and print media
    set_custom_stylesheet ['tooltip']
    set_user_stylesheet ['tei_style_print']
    set_custom_edition_stylesheet ['critical_print']
    set_print_stylesheet ['critical_printreal']

    @path = []
    @header = :"talia.search.print.#{@edition.uri.local_name}.advanced_search_header"
    set_custom_stylesheet [['editions/advanced_search_print_video', 'screen'], ['editions/advanced_search_print_print', 'print']]
    render :layout => 'critical_print'
  end

  def auto_complete_for_words
    if (!params[:words].nil? && params[:words] != "")

      word = params[:words].split.last
      @result = Word.find(:all, {:conditions => "word LIKE '#{word}%'", :order => "counter DESC, word ASC", :limit => 10})
      
    else
      @result = []
    end
  end

  private
   
  # Activates the print button
  def print_tool
    @tools = [{:id =>'print', :text=> :'talia.global.print', :target => 'blank', :link => "#{@book.uri.to_s}/print"}]
  end
  
  def prepare_for_book
    @href_for_text = @request_url
    @book = @source
    @path = [
      {:text => params[:id], :link => @edition.uri.to_s}, 
      {:text => @book.dcns.title.first.to_s}        
    ]  
      set_custom_stylesheet ['tooltip']
      set_user_stylesheet ['tei_style']
  end
  
  def prepare_for_chapter
    @chapter = @source
    @href_for_text = @chapter.subparts_with_manifestations(N::HYPER.HyperEdition)[0] 
    @book = @chapter.book
    @path = [
      {:text => params[:id], :link => @edition.uri.to_s}, 
      {:text => @book.dcns.title.first.to_s, :link => @book.uri.to_s},
      {:text => @chapter.dcns.title.first.to_s}
    ]
    set_custom_stylesheet ['tooltip']
    set_user_stylesheet ['tei_style']
  end
  
  def prepare_for_part
    @part = @source
    @href_for_text = @request_url 
    @book = @part.book
    @chapter = @part.chapter
    @path = [
      {:text => params[:id], :link => @edition.uri.to_s}, 
      {:text => @book.dcns::title.first.to_s, :link => @book.uri.to_s}
    ]
    @path << {:text => @chapter.dcns::title.first.to_s, :link => @chapter.uri.to_s} unless @chapter.nil?
    @path << {:text => @part.dcns::title.empty? ? @part.uri.local_name.to_s : @part.dcns.title.first.to_s}
    set_custom_stylesheet ['tooltip']
    set_user_stylesheet ['tei_style']
  end

end
 
 



