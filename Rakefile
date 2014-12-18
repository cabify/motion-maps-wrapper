# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require './lib/motion-maps-wrapper'

begin
  require 'bundler'
  require 'motion/project/template/gem/gem_tasks'
  Bundler.require(:default, :development)
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'motion-maps-wrapper'
  app.info_plist['google_maps_api_key'] = ENV['GOOGLE_MAPS_API_KEY']
end
