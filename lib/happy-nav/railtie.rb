require 'happy-nav'
require 'rails'

module HappyNav
  class Railtie < Rails::Railtie
    initializer 'happy-nav.initialize', :after => :after_initialize do
      ActionView::Base.send :include, HappyNav
    end
  end
end