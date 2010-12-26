require 'active_support'
require 'action_pack'
require 'action_view'
require 'action_controller'

require File.join(File.dirname(__FILE__), "../lib/happy-nav")

ActionView::Base.class_eval do
  include HappyNav
end

module SpecHelperMethods
  def clean_string(s)
    s.gsub(/^\s+/, "").gsub(/\n/, "")
  end
end