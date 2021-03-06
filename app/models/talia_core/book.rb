module TaliaCore


  # This refers to a book in a collection. Note that each book is
  # exactly in one Catalog/Macrocontribution (see ExpressionCard).
  class Book < ExpressionCard

    # return the string to be shown as book name
    def name
      self.dcns::title.empty? ? self.uri.local_name : self.dcns::title.first
    end

    # The pages of this book
    def pages
      Page.find(:all, :find_through => [N::DCT.isPartOf, self])
    end

    # The paragraphs of this book
    def paragraphs
      paragraphs_query.execute
    end

    # The chapters of this book, sorted by position
    def chapters
      qry = Query.new(TaliaCore::Chapter).select(:chapter).distinct
      qry.where(:chapter, N::HYPER.book, self)
      qry.where(:chapter, N::HYPER.first_page, :page)
      qry.where(:page, N::HYPER.position, :pos)
      qry.sort(:pos)
      qry.execute
    end

    # Creates an OrderedSource object for this` book containing all its pages,
    # ordered by their position
    def order_pages!
      ordered = ordered_pages
      ordered.delete_all unless ordered.first.nil?
      qry = Query.new(TaliaCore::Page).select(:p).distinct
      qry.where(:p, N::DCT.isPartOf, self)
      qry.where(:p, N::HYPER.position, :pos)
      qry.sort(:pos)
      pages = qry.execute
      pages.each do |page|
        ordered.add(page)
      end
        ordered.save!
      end

    # Returns an array containing all the pages in this book, ordered
    def ordered_pages
      uri = self.uri.to_s + '_ordered_pages'
      if OrderedSource.exists?(uri)
        OrderedSource.find(uri)
      else
        OrderedSource.new(uri)
      end
    end

    # return the position for search_key
    def position_for_search_key
      ("000000" + self.hyper.position[0].to_s)[-6..-1]
    end

    # returns the RDF.type of this book (e.g. Manuscript, Work, etc.)
    def material_type
      qry = Query.new(N::SourceClass).select(:type).distinct
      qry.where(self, N::RDF.type, :subtype)
      qry.where(:subtype, N::RDFS.subClassOf, :type)
      qry.where(:type, N::RDFS.subClassOf, N::HYPER.Material)
      qry.execute[0]
    end

    # returns the subClass of the RDF.type of this book (e.g. Copybook, Notebook, etc.)
    def material_subtype
      qry = Query.new(N::SourceClass).select(:subtype).distinct
      qry.where(self, N::RDF.type, :subtype)
      qry.where(:subtype, N::RDFS.subClassOf, :type)
      qry.where(:type, N::RDFS.subClassOf, N::HYPER.Material)
      qry.execute[0]
    end

    # returns all the subpart of this expression card
    def subparts
      pages = pages_query.execute
      paragraphs = paragraphs_query.execute
      subparts = pages + paragraphs
    end

    # returns all the subpart of this expression card that have some manifestations
    # of the given type related to them. Manifestation_type must be an URI
    def subparts_with_manifestations(manifestation_type, subpart_type = nil)
      assit_not_nil manifestation_type #TODO check that manifestation_type is an URI
      pages = []
      paragraphs = []

      if (subpart_type == nil || subpart_type == N::HYPER.Page)
        qry_pages = pages_query
        qry_pages.where(:m, N::HYPER.manifestation_of, :part)
        qry_pages.where(:m, N::RDF.type, manifestation_type)
        pages = qry_pages.execute
      end

      if (subpart_type == nil || subpart_type == N::HYPER.Paragraph)
        qry_para = paragraphs_query
        qry_para.where(:m, N::HYPER.manifestation_of, :part)
        qry_para.where(:m, N::RDF.type, manifestation_type)
        paragraphs = qry_para.execute
      end

      subparts = pages + paragraphs
    end

    # returns uri and title/siglum of all the subpart of this expression card that have some manifestations
    # of the given type related to them. Manifestation_type must be an URI
    # This is used in the advanced_search_widget to construct the drop-down menus.
    def subparts_uri_and_title_with_manifestations(manifestation_type)
      assit_not_nil manifestation_type #TODO check that manifestation_type is an URI

      # OK, the thing here is that we don't know if we have N::DCNS.title relation for
      # the subparts or not.
      # Since if we add a condition to the query to check if the DNCS.title is there
      # it will only return those entries _with_ the title, we need to retrieve them in
      # two rounds.
      # We first retrieve all of them (having :siglum instead of the title, that's what
      # we use if the title is missing) then we retrieve those with the titles.
      # Lastly we merge the results.
      # And this is done for both pages and paragraphs.

      qry = Query.new(N::URI).select(:part, :siglum).distinct
      qry.where(:part, N::DCT.isPartOf, self)
      qry.where(:part, N::HYPER.position, :pos)
      qry.where(:part, N::HYPER.siglum, :siglum)
      qry.sort(:pos)
      qry.where(:m, N::HYPER.manifestation_of, :part)
      qry.where(:m, N::RDF.type, manifestation_type)

      pages = qry.execute

      unless pages.empty?
        qry = Query.new(N::URI).select(:part, :title).distinct
        qry.where(:part, N::DCNS.title, :title)
        qry.where(:part, N::DCT.isPartOf, self)
        qry.where(:part, N::HYPER.position, :pos)
        qry.sort(:pos)
        qry.where(:m, N::HYPER.manifestation_of, :part)
        qry.where(:m, N::RDF.type, manifestation_type)

        pages_with_title = qry.execute

        # let's convert it to a hash, in this way it will be possible to do the next step
        # we also convert URIs to string here
        pages_hash = {}
        pages.each{|k, v| pages_hash[k.to_s] = v }

        # now we'll overwrite those entries that have a title
        pages_with_title.each{|k, v| pages_hash[k.to_s] = v } unless pages_with_title.empty?

        # let's convert it back to an array (that's what we'll use)
        pages = pages_hash.to_a

      end

      qry = Query.new(N::URI).select(:part, :siglum).distinct
      qry.where(:page, N::DCT.isPartOf, self)
      qry.where(:page, N::RDF.type, N::HYPER.Page)
      qry.where(:note, N::HYPER.page, :page)
      qry.where(:note, N::RDF.type, N::HYPER.Note)
      qry.where(:part, N::HYPER.note, :note)
      qry.where(:page, N::HYPER.position, :page_pos)
      qry.where(:note, N::HYPER.position, :note_pos)
      qry.where(:part, N::HYPER.siglum, :siglum)
      qry.sort(:page_pos)
      qry.sort(:note_pos)
      qry.where(:m, N::HYPER.manifestation_of, :part)
      qry.where(:m, N::RDF.type, manifestation_type)

      paragraphs = qry.execute

      unless paragraphs.empty?

        qry = Query.new(N::URI).select(:part, :title).distinct
        qry.where(:part, N::DCNS.title, :title)
        qry.where(:page, N::DCT.isPartOf, self)
        qry.where(:page, N::RDF.type, N::HYPER.Page)
        qry.where(:note, N::HYPER.page, :page)
        qry.where(:note, N::RDF.type, N::HYPER.Note)
        qry.where(:part, N::HYPER.note, :note)
        qry.where(:page, N::HYPER.position, :page_pos)
        qry.where(:note, N::HYPER.position, :note_pos)
        qry.sort(:page_pos)
        qry.sort(:note_pos)
        qry.where(:m, N::HYPER.manifestation_of, :part)
        qry.where(:m, N::RDF.type, manifestation_type)

        paragraphs_with_title = qry.execute

        # let's convert it to a hash, in this way it will be possible to do the next step
        # we also convert URIs to string here
        paragraphs_hash = {}
        paragraphs.each{|k, v| paragraphs_hash[k.to_s] = v }

        # now we'll overwrite those entries that have a title
        paragraphs_with_title.each{|k, v| paragraphs_hash[k.to_s] = v } unless paragraphs_with_title.empty?

        # let's convert it back to an array (that's what we'll use)
        paragraphs = paragraphs_hash.to_a

      end

      result = pages + paragraphs
    end



    def html_data=(html_data)
      self.add_manifestation(html_data)
    end

    def html_data
      html_data = TaliaCore::BookHtml.find(:all, :find_through => [N::HYPER.manifestation_of , self])
      html_data[0].html unless html_data.empty?
    end

    # creates or update, the HTML document containing the whole Book text, starting
    # from HyperEditions' XML text, converted into HTML.
    def create_html_data!(version=nil)
      html_data_uri = self.uri.to_s + "_html_data"
      html_data = TaliaCore::BookHtml.new(html_data_uri)
      html_data.create_html_version_of(self, version)
      self.html_data=html_data
    end

    def recreate_html_data!(version=nil)
      html_data_uri = self.uri.to_s + "_html_data"
      html_data = TaliaCore::BookHtml.find(html_data_uri)
      html_data.create_html_version_of(self, version)
      html_data.data_records[0].save!
    end

    # Returns the PDF representation of this book
    def pdf
      # TODO: Implementation
    end

    # Clones a book into the given catalog. This will clone all pages and also
    # create the page order on the fly. It is possible to pass a block
    # to this method, which will be run for each _page_ that is added
    # to the catalog (not for this element itself. The block will
    # receive the cloned page object.
    def clone_to(catalog)
      my_clone = catalog.add_from_concordant(self)
      pages = ordered_pages.ordered_objects
      cloned_order = my_clone.ordered_pages
      
      pages.each_index do |index|
        page = ordered_pages.at(index)
        next unless(page) # Skip empty elements
        page_clone = catalog.add_from_concordant(page)
        page_clone[N::DCT.isPartOf] << my_clone
        # We insert the page at the same index as the old page
        cloned_order.insert_at(index, page_clone)

        yield(page, page_clone) if(block_given?)

        page_clone.save!
      end

      cloned_order.save!
      my_clone.save!

      my_clone
    end

    private

    # default query for subparts
    def pages_query
      qry = Query.new(TaliaCore::Page).select(:part).distinct
      qry.where(:part, N::DCT.isPartOf, self)
      qry.where(:part, N::HYPER.position, :pos)
      qry.sort(:pos)
      qry
    end

    def paragraphs_query
      qry = Query.new(TaliaCore::Paragraph).select(:part).distinct
      qry.where(:page, N::DCT.isPartOf, self)
      qry.where(:page, N::RDF.type, N::HYPER.Page)
      qry.where(:note, N::HYPER.page, :page)
      qry.where(:note, N::RDF.type, N::HYPER.Note)
      qry.where(:part, N::HYPER.note, :note)
      qry.where(:page, N::HYPER.position, :page_pos)
      qry.where(:note, N::HYPER.position, :note_pos)
      qry.sort(:page_pos)
      qry.sort(:note_pos)
      qry
    end
  end
end
