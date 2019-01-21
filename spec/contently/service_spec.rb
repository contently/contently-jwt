RSpec.describe Contently::Jwt::Service do
  it "has a version number" do
    expect(Contently::Jwt::VERSION).not_to be nil
  end

  it "encodes/decodes correctly" do
    service = Contently::Jwt::Service.new('../../certs/private.key')
    payload = {
      username: 'someone@somewhere.com',
      user_id: 12
    }

    encoded = service.encode(payload: payload)
    decoded = service.decode(encoded)
    expect(decoded[:username]).to be payload['username']
    expect(decoded[:user_Id]).to be payload['user_id']
    expect(service).not_to be nil
  end
end
