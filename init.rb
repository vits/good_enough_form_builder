require 'good_enough_form_builder'
require 'good_enough_form_helpers'

ActionView::Base.send :include, GoodEnoughFormBuilder::Helpers
