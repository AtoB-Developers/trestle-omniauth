class Trestle::Omniauth::SessionsController < Trestle::ApplicationController
  layout 'trestle/omniauth'

  skip_before_action :require_authenticated_user

  # Disable CSRF the session creation endpoint to support SAML.
  #
  # The SAML IdP (e.g. Okta) performs a POST back to this endpoint to create
  # the session. This request obvious does not originate from our web frontend;
  # it's more like an API request where CSRF does not make sense.
  # This is a widely documented issue with SAML and omniauth, and this is the
  # recommended mitigation.
  skip_before_action :verify_authenticity_token, only: :create

  def new
    @providers = Trestle.config.omniauth.providers.keys
  end

  def create
    login!(request.env['omniauth.auth'])
    redirect_to previous_location || instance_exec(&Trestle.config.omniauth.redirect_on_login)
  end

  def destroy
    logout!
    redirect_to instance_exec(&Trestle.config.omniauth.redirect_on_logout)
  end
end
