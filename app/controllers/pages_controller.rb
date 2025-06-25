class PagesController < ApplicationController
  def home
    @products = Product.active.crinkles
  end

  def about
  end

  def contact
  end
end
