class IndexController < ApplicationController
  before_filter :set_oauth, :only => [:auth, :list]
  
  def index
  end

  def auth
    @oauth.set_callback_url (url_for (:action => "list"))
    
    session['rtoken']  = @oauth.request_token.token
    session['rsecret'] = @oauth.request_token.secret
    
    redirect_to @oauth.request_token.authorize_url
  end

  def list
    begin
      @oauth.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])

      session['rtoken']  = nil
      session['rsecret'] = nil

      client = Twitter::Base.new(@oauth)
      profile = client.verify_credentials
    
      @screen_name = profile.screen_name
      @blocking = client.blocking
    rescue 
      redirect_to url_for :action => :auth
    end
  end

  private
    def set_oauth
      @oauth = Twitter::OAuth.new(App.oauth.token, App.oauth.secret)
    end
end