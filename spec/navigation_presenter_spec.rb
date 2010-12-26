require File.dirname(__FILE__) + '/spec_helper'

describe NavigationPresenter do
  
  include SpecHelperMethods
  
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
  
  describe '#to_html' do
    
    it 'should return an empty string with no items' do
      NavigationPresenter.new.to_html.should == ''
    end
    
    it 'should always return a string' do
      NavigationPresenter.new.to_html.should be_a(String)
      NavigationPresenter.new(@items).to_html.should be_a(String)
    end
    
    it 'should return a formatted navigation if there are items' do
      NavigationPresenter.new(@items).to_html.should == clean_string(@output)
    end
    
    it 'should correctly format a single item' do
      output = <<-eos
        <div class="nav">
          <ul>
            <li class="first last"><a href="/about" title="About">About</a></li>
          </ul>
        </div>
      eos
      
      NavigationPresenter.new(['About']).to_html.should == clean_string(output)
    end
    
    it 'should add an id to all links' do
      output = <<-eos
        <div class="nav">
          <ul>
            <li class="first"><a href="/" id="nav_home" title="Home">Home</a></li>
            <li class="last"><a href="/contact" id="nav_contact" title="Contact">Contact</a></li>
          </ul>
        </div>
      eos
      
      NavigationPresenter.new(['Home', 'Contact'], :id => true).to_html.should == clean_string(output)
    end
    
    it 'should add a class to the unordered list' do
      output = <<-eos
        <div class="nav">
          <ul class="ul-class">
            <li class="first last"><a href="/about" title="About">About</a></li>
          </ul>
        </div>
      eos
      
      NavigationPresenter.new(['About'], :class => 'ul-class').to_html.should == clean_string(output)
    end
    
    it 'should not wrap the unordered list in a div' do
      output = <<-eos
        <ul>
          <li class="first last"><a href="/about" title="About">About</a></li>
        </ul>
      eos
      
      NavigationPresenter.new(['About'], :wrap => false).to_html.should == clean_string(output)
    end
    
    describe 'with nested items' do
      
      before do
        @items = [
          'Home',
          {
            :text => 'About Us',
            :items => [
              {
                :text => 'Team',
                :items => [
                  'Guybrush Threepwood',
                  'Ghost Pirate LeChuck'
                ]
              }
            ]
          },
          {
            :text => 'Our Services',
            :items => ['Swash buckling']
          },
          'Contact'
        ]
      end
      
      it 'should render nested navigation links' do
        output = <<-eos
          <div class="nav">
            <ul>
              <li class="first"><a href="/" title="Home">Home</a></li>
              <li>
                <a href="/about-us" class="current" title="About Us">About Us</a>
                <ul class="nav-sub-1">
                  <li class="first last">
                    <a href="/about-us/team" class="current" title="Team">Team</a>
                    <ul class="nav-sub-2">
                      <li class="first"><a href="/about-us/team/guybrush-threepwood" class="current" title="Guybrush Threepwood">Guybrush Threepwood</a></li>
                      <li class="last"><a href="/about-us/team/ghost-pirate-lechuck" title="Ghost Pirate LeChuck">Ghost Pirate LeChuck</a></li>
                    </ul>
                  </li>
                </ul>
              </li>
              <li><a href="/our-services" title="Our Services">Our Services</a></li>
              <li class="last"><a href="/contact" title="Contact">Contact</a></li>
            </ul>
          </div>
        eos
        navigation_presenter = NavigationPresenter.new(@items)
        navigation_presenter.current_item('About Us')
        navigation_presenter.current_item('Team')
        navigation_presenter.current_item('Guybrush Threepwood')
        navigation_presenter.to_html.should == clean_string(output)
      end
      
      it 'should render a flat list if flat is passed as an option' do
        output = <<-eos
          <div class="nav">
            <ul>
              <li class="first"><a href="/" title="Home">Home</a></li>
              <li><a href="/about-us" class="current" title="About Us">About Us</a></li>
              <li><a href="/our-services" title="Our Services">Our Services</a></li>
              <li class="last"><a href="/contact" title="Contact">Contact</a></li>
            </ul>
          </div>
        eos
        navigation_presenter = NavigationPresenter.new(@items, :flat => true)
        navigation_presenter.current_item('About Us')
        navigation_presenter.current_item('Team')
        navigation_presenter.current_item('Guybrush Threepwood')
        navigation_presenter.to_html.should == clean_string(output)
      end
      
    end
    
  end
  
  describe '#item_link' do
    
    before do
      @navigation = NavigationPresenter.new
    end
    
    it 'should always return a string' do
      @navigation.item_link('Home').should be_a(String)
    end
    
    it 'should return a link with a title' do
      @navigation.item_link('About').should == '<a href="/about" title="About">About</a>'
    end
    
    it 'should return a link to root if the page is "Home"' do
      @navigation.item_link('Home').should == '<a href="/" title="Home">Home</a>'
    end
    
    it 'should allow customisation using a Hash' do
      @navigation.item_link({
        :text => 'Custom',
        :url => '/linky',
        :title => 'Custom Title'
      }).should == '<a href="/linky" title="Custom Title">Custom</a>'
    end
    
    it 'should allow for a summary' do
      @navigation.item_link({ :text => 'Summary', :summary => 'A quick summary...' }).should == '<a href="/summary" title="Summary: A quick summary..."><strong>Summary</strong> <em>A quick summary...</em></a>'
    end
    
    it 'should mark "About" as the current page' do
      @navigation.current_item('About')
      @navigation.item_link('About').should == '<a href="/about" class="current" title="About">About</a>'
    end
    
    it 'should allow for an id' do
      @navigation.item_link({ :text => 'Linky', :id => true }).should == '<a href="/linky" id="nav_linky" title="Linky">Linky</a>'
    end
    
    it 'should allow for a custom id' do
      @navigation.item_link({ :text => 'Linky', :id => 'custom' }).should == '<a href="/linky" id="nav_custom" title="Linky">Linky</a>'
    end
    
  end
  
  describe '#item_url' do
    
    before do
      @navigation = NavigationPresenter.new
    end
    
    it 'should always return a string' do
      @navigation.item_url('Home').should be_a(String)
    end
    
    it 'should return the path to root if the page is "Home"' do
      @navigation.item_url('Home').should == '/'
    end
    
    it 'should return a path' do
      @navigation.item_url('About').should == '/about'
    end
    
    it 'should path to the admin homepage' do
      @navigation.stub!(:admin?).and_return(true)
      @navigation.item_url('Home').should == '/admin'
    end
    
    it 'should path to the admin namespace' do
      @navigation.stub!(:admin?).and_return(true)
      @navigation.item_url('About').should == '/admin/about'
    end
    
    it 'should use the base_url option' do
      @navigation.stub!(:options).and_return({ :base_url => '/example/base' })
      @navigation.item_url('About').should == '/example/base/about'
    end
  
  end
  
  describe '#admin?' do
    
    before do
      @navigation = NavigationPresenter.new
    end
    
    it 'should return false if the admin option is not set' do
      @navigation.send(:admin?).should be_false
    end
    
    it 'should return false if the admin option is false' do
      @navigation.options[:admin] = false
      @navigation.send(:admin?).should be_false
    end
    
    it 'should return true if the admin option is true' do
      @navigation.options[:admin] = true
      @navigation.send(:admin?).should be_true
    end
    
  end
  
end