module Authentik
  class Actions::NewPrivateKey
    extend Extensions::Parameterizable

    with :public_key

    def call
      app = Models::App.find_by public_key: public_key

      Models::PrivateKey.create app: app
    end
  end

  class Actions::AuthenticateApp
    extend Extensions::Parameterizable

    with :query_string, :auth

    def call
      app = Models::App.find_by public_key: auth[:public_key]

      raise InvalidCredentials unless has_valid_hmac? app

      app
    rescue InvalidCredentials => e
      block_given? ? yield(e) : raise
    end

    InvalidCredentials = Class.new(StandardError)

    private

    def has_valid_hmac?(app)
      auth[:hmac] == calculate_hmac_for(app)
    end

    def calculate_hmac_for(app)
      OpenSSL::HMAC.digest \
        OpenSSL::Digest.new('sha1'),
        app.private_key.secret,
        query_string
    end
  end
end
