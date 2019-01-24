RSpec.describe Contently::Jwt::TokenHelper do
  before(:each) do
    key = OpenSSL::PKey::RSA.new 512
    @service = Contently::Jwt::Service.new(key)
    token = @service.encode(payload: {
                              username: 'someguy@somedomain.com',
                              exp: (Time.now.utc + 10).to_i
                            })

    @expired_token = @service.encode(payload: {
      username: 'some-other-guy@somedomain.com',
      exp: 0
    })

    @env = {}
    @env['HTTP_COOKIE'] = "token=#{token}"
    @cookies_helper = Contently::Jwt::CookiesHelper.new(@env)
    @headers_helper = Contently::Jwt::HeadersHelper.new(@env)
    @token_helper = Contently::Jwt::TokenHelper.new(@cookies_helper, @headers_helper, key)
  end

  it 'exists' do
    expect(Contently::Jwt::TokenHelper).not_to be nil
  end

  it 'Finds the token' do
    expect(@token_helper.token).not_to be nil
  end

  it 'Returns nil for a missing token' do
    @env['HTTP_COOKIE'] = ''
    expect(@token_helper.token).to be nil
  end

  it 'decodes a token' do
    expect(@token_helper.token).not_to be nil
    decoded = @token_helper.decode_token

    expect(decoded).not_to be nil
    expect(decoded['username']).to eq 'someguy@somedomain.com'
    expect(@token_helper.expired?).to eq false
  end

  it 'fails to decode when token expired' do
    @env['HTTP_COOKIE'] = "token=#{@expired_token}"
    expect(@token_helper.token).not_to be nil
    decoded = @token_helper.decode_token

    expect(decoded).to be nil
    expect(@token_helper.expired?).to eq true
  end

  it 'decodes an auth token' do
  end
end
