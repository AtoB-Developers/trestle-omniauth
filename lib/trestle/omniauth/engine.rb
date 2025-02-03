require 'omniauth'

module Trestle
  module Omniauth
    class Engine < ::Rails::Engine
      isolate_namespace Trestle::Omniauth

      initializer "trestle.sprockets" do |app|
        # Sprockets manifest
        config.assets.precompile << "trestle/omniauth/manifest.js"
      end if defined?(Sprockets)

      initializer "trestle.propshaft" do |app|
        app.config.assets.excluded_paths << root.join("app/assets/sprockets")
      end if defined?(Propshaft)

      config.before_initialize do
        Trestle::Engine.paths['app/helpers'].concat(paths['app/helpers'].existent)
      end

      config.to_prepare do
        Trestle::ApplicationController.include Trestle::Omniauth::ControllerMethods
      end

      initializer 'trestle.omniauth.configure' do
        Trestle::Engine.middleware.use ::OmniAuth::Builder do
          Trestle.config.omniauth.providers.each do |name, args|
            provider name, *args
          end
        end
      end
    end
  end
end
