class PagesController < ApplicationController
  def home
    @products = Product.active.crinkles
  end

  def about
  end

  def contact
  end
  
  def legal_page
    @legal_page = ContentBlock.current_legal_page(params[:key])
    
    unless @legal_page
      redirect_to root_path, alert: "Legal page not found."
      return
    end
    
    # Set page title for SEO
    @page_title = @legal_page.title
  end
end
