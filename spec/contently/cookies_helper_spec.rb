RSpec.describe Contently::Jwt::CookiesHelper do
  it 'exists' do
    expect(Contently::Jwt::CookiesHelper).not_to be nil
  end

  it 'Gets the HTTP COOKIE' do
    env = {}
    env['HTTP_COOKIE'] = 'cookie=set'
    helper = Contently::Jwt::CookiesHelper.new(env)
    expect(helper.http_cookie).not_to be nil
  end

  it 'Gets the cookie value' do
    env = {}
    env['HTTP_COOKIE'] = 'cookie=value;cookie2=othervaluue'
    helper = Contently::Jwt::CookiesHelper.new(env)
    expect(helper.cookies['cookie']).to eq 'value'
    expect(helper.cookies['cookie2']).to eq 'othervaluue'
  end

  it 'Creates a cookie map' do
    env = {}
    env['HTTP_COOKIE'] = 'cookie=value;cookie2=othervaluue'
    helper = Contently::Jwt::CookiesHelper.new(env)
    expect(helper.make_cookie_header(helper.cookies)).to eq 'cookie=value; cookie2=othervaluue'
  end

  it 'returns a value by index' do
    env = {}
    env['HTTP_COOKIE'] = 'cookie=value;cookie2=othervaluue'
    helper = Contently::Jwt::CookiesHelper.new(env)
    expect(helper['cookie']).to eq 'value'
  end

  it 'sets a value by index' do
    env = {}
    env['HTTP_COOKIE'] = 'cookie=value;cookie2=othervaluue'
    helper = Contently::Jwt::CookiesHelper.new(env)
    helper['cookie'] = 'sample'
    expect(helper['cookie']).to eq 'sample'
  end
end
