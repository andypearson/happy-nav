require File.join(File.dirname(__FILE__), *%w[happy-nav navigation_presenter])
require File.join(File.dirname(__FILE__), *%w[happy-nav railtie]) if defined?(::Rails::Railtie)

module HappyNav
  
  def navigation(items = [], options = {})
    unless items.empty?
      @navigation_presenter = NavigationPresenter.new(items, options)
      if @current_pages
        @current_pages.each { |page| @navigation_presenter.current_item(page) }
      end
      @navigation = @navigation_presenter.to_html
    end
    @navigation ||= ''
  end
  
  def current_page(page = nil)
    @current_pages ||= []
    @current_pages << page if page
    @current_pages.first
  end
  
end