class PagesController < ApplicationController
  def home
    @products = Product.active
  end

  def about
  end

  def contact
  end
end
