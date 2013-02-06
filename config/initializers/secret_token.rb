# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

# Run `rake secret > secret_token` from RAILS_ROOT before you start the app

begin
    token_file = Rails.root.to_s + "/secret_token"
    secret_token = open(token_file).read
    VisualCloud::Application.configure do
        config.secret_token = secret_token
    end
rescue LoadError, Errno::ENOENT => e
    error = "\nSecret Token couldn't be loaded : #{e}\nGenerate secret_token by running `rake secret > secret_token`\n".red
    raise error
end
