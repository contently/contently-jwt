RSpec.describe Contently::Jwt do
  it "has a version number" do
    expect(Contently::Jwt::VERSION).not_to be nil
  end

  it "does something useful" do
    @app = {}
    middleware = Contently::Jwt::Middleware.new(@app)
    expect(middleware).not_to be nil
  end
end
