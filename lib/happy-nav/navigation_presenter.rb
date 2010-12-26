class NavigationPresenter
  
  include ActionView::Helpers::TagHelper
  
  attr_accessor :items, :options
  
  def initialize(items = [], options = {}, current_items = [])
    @items = items
    @options = options
    @current_items = current_items
  end
  
  def to_html
    unless @items.empty?
      wrap do
        h.content_tag :ul, :class => @options[:class] do i=0
          content = ''
          @items.each do |item| i=i+1
            content += h.content_tag :li, :class => classes(i) do 
              item_link(item) + nested_navigation(item).to_s
            end
          end
          content.html_safe
        end
      end
    else
      ''
    end
  end
  
  def nested_navigation(item)
    unless @options[:flat]
      item = format_item(item)
      if item[:items] && current_item?(item[:permalink])
        options = {
          :level => next_level,
          :class => 'nav-sub-' + next_level.to_s,
          :base_url => item[:url],
          :wrap => false
        }
        NavigationPresenter.new(item[:items], options, @current_items[1..-1]).to_html
      end
    end
  end
  
  def item_link(item, options = {})

    item = format_item(item, options)
    content = item[:text]
    
    if item[:summary]
      item[:title] += ': '+item[:summary]
      content = h.content_tag(:strong, content) + ' ' + content_tag(:em, item[:summary])
    end
    
    if item[:id] || @options[:id]
      item[:id] = item[:permalink] if @options[:id] === true || item[:id] === true
      item[:id] = "nav_#{item[:id]}"
    end
    
    h.link_to content, item[:url], {
      :id => item[:id],
      :class => (current_item?(item[:permalink]) ? 'current' : nil),
      :title => item[:title],
    }
  end
  
  def item_url(text)
    if (text == 'Home')
      admin? ? '/admin' : '/'
    else
      base_url + '/' + text.parameterize('-')
    end
  end
  
  def base_url
    if options[:base_url]
      options[:base_url]
    else
      admin? ? '/admin' : ''
    end
  end
  
  def current_item(current_item)
    @current_items << current_item
  end
  
  private
    
    def h
      ActionController::Base.helpers
    end
    
    def classes(i)
      classes = []
      classes << 'first' if i==1
      classes << 'last' if i==@items.length
      !classes.empty? ? classes.join(' ') : nil
    end
    
    def current_item?(permalink)
      !@current_items.empty? && permalink == @current_items.first.parameterize('-')
    end
    
    def admin?
      @options[:admin]
    end
    
    def format_item(item, options = {})
      item = { :text => item } if item.kind_of? String
      item = item.merge(options)
      item[:id] = nil if !item[:id]
      item[:url] = item_url(item[:text]) if !item[:url]
      item[:title] = item[:text] if !item[:title]
      item[:permalink] = item[:text].parameterize('-') if !item[:permalink]
      item
    end
    
    def current_level
      @options[:level] ||= 0
    end
    
    def next_level
      current_level + 1
    end
    
    def wrap(&block)
      if @options[:wrap] === false
        yield
      else
        h.content_tag :div, { :class => 'nav' } do
          yield
        end
      end
    end
    
end