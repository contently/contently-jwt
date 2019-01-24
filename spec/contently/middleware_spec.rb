RSpec.describe Contently::Jwt::Middleware do
  it 'has a version number' do
    expect(Contently::Jwt::VERSION).not_to be nil
  end

  it 'does something useful' do
    @app = {}
    puts Dir.pwd
    middleware = Contently::Jwt::Middleware.new(@app, private_key_path: './certs/private.key')
    expect(middleware).not_to be nil
  end
end
