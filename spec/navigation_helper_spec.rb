require File.dirname(__FILE__) + '/spec_helper'

describe 'Happy Nav!' do
  
  include SpecHelperMethods
  
  before do
    @view = ActionView::Base.new
  end
  
  describe 'after loading the plugin' do
    
    it "should be mixed into ActionView::Base" do
      ActionView::Base.included_modules.include?(HappyNav).should be_true
    end
    
    it 'should respond to happy_title helper' do
      @view.should respond_to(:navigation)
    end
    
    it 'should respond to title helper' do
      @view.should respond_to(:current_page)
    end
    
  end
  
  describe '#navigation' do
    
    before do
      @items = ['Home', 'About', 'Our Services', 'Contact']
      @output = <<-eos
        <div class="nav">
          <ul>
            <li class="first"><a href="/" title="Home">Home</a></li>
            <li><a href="/about" title="About">About</a></li>
            <li><a href="/our-services" title="Our Services">Our Services</a></li>
            <li class="last"><a href="/contact" title="Contact">Contact</a></li>
          </ul>
        </div>
      eos
    end
    
    it 'should always return a string' do
      @view.navigation.should be_a(String)
    end
    
    it 'should return blank if there are no items' do
      @view.navigation.should == ''
    end
    
    it 'should return the formatted navigation if there are items' do
      @view.navigation(@items).should == clean_string(@output)
    end
    
    it 'should return the generated navigation multiple times' do
      output = ''
      output += @view.navigation(@items)
      output += @view.navigation
      output += @view.navigation
      
      output.should == clean_string(@output+@output+@output)
    end
    
    it 'should regenerate the navigation if new items are passed' do
      output = <<-eos
        <div class="nav">
          <ul>
            <li class="first last"><a href="/about" title="About">About</a></li>
          </ul>
        </div>
      eos
      @view.navigation(@items).should == clean_string(@output)
      @view.navigation(['About']).should == clean_string(output)
    end
    
  end
  
  describe '#current_page' do
    
    it 'should be nil by default' do
      @view.current_page.should == nil
    end
    
    it 'should mark the current page' do
      @view.current_page('Home')
      @view.current_page.should == 'Home'
    end
    
    it 'should render a navigation with the current page' do
      output = <<-eos
        <div class="nav">
          <ul>
            <li class="first last"><a href="/about" class="current" title="About">About</a></li>
          </ul>
        </div>
      eos
      @view.current_page('About')
      @view.navigation(['About']).should == clean_string(output)
    end
    
  end
  
end