  module TaliaCore
  
  
  # This refers to a book in a collection. Note that each book is 
  # exactly in one Catalog/Macrocontribution (see AbstractWorkCard).
  class Book < ExpressionCard
    
    # The pages of this book
    def pages
      Page.find(:all, :find_through => [N::HYPER.is_part_of, self])
    end
    
    # A descriptive text about this book
    def material_description
      description = inverse[N::HYPER.description_of]
      assit(description.size <= 1, "There shouldn't be multiple descriptions")
      (description.size > 0) ? description[0] : ''
    end
    
    # Returns the PDF representation of this book
    def pdf
      # TODO: Implementation
    end
    
  end
end
