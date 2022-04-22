module Trestle
  module Omniauth
    module ControllerMethods
      extend ActiveSupport::Concern

      included do
        helper_method :current_user, :logged_in?

        before_action :require_authenticated_user
      end

      protected

      def current_user
        @current_user ||= session[:trestle_user]
      end

      def login!(auth_hash)
        trimmed_auth = auth_hash.slice(*%w[provider uid info extra])

        # Remove this complex type from omniauth-saml to prevent an infinite
        # loop when we call as_json before storing it in the session cookie.
        trimmed_auth['extra'].delete('response_object')

        session[:trestle_user] = trimmed_auth.to_h.as_json
        @current_user = auth_hash
      end

      def logout!
        session.delete(:trestle_user)
        @current_user = nil
      end

      def logged_in?
        !!current_user
      end

      def store_location
        session[:trestle_return_to] = request.fullpath
      end

      def previous_location
        session.delete(:trestle_return_to)
      end

      def require_authenticated_user
        logged_in? || login_required!
      end

      def login_required!
        store_location
        redirect_to trestle.login_url
        false
      end
    end
  end
end
