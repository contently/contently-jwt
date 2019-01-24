RSpec.describe Contently::Jwt::TokenHelper do
  before(:each) do
    token = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InNldGh3ZWJzdGVyQGdtYWlsLmNvbSIsInN1YiI6InNldGh3ZWJzdGVyQGdtYWlsLmNvbSIsInJlZnJlc2hUb2tlbiI6IlBMTTRaaWZnUlpkZjNmcW9NV1YxMlpHcVpjdVlVbXgyVG9ob295MG5iajlIODJpdmE5L0hEWEtDQ2VOVzl0eXFpOWJka0dRSjQ1TFUzQitRYk11Z3pnZ2hDeXBISVp2TUtUalcraE5rWWhNa3ErRTBHL0ZzcC9BWlB0WGNSaU4wYTZzdVVldWo2TWpicktjV2JpQ2lXelBHbGREZWs5Q1RQTUdUQlg2dmVXZ1VnV0FHUGFCb21DR3dPeVFSbTNDaTRRQUhCZTNDN0haV1NZK1g0dFdlZUtrZ0RoTlQ3VUxaYjYramIxR25zSFQwTEc4WTBZQUZ3Ti9zTXViZmM2ZlZ2U2pSQnlnelVrV1A0WXVQN0pkcjFDMW11VjA2a1gxS1d6SlJYNEpSRGRnRm53cS9BbXhGSUs5R2ZxOStXaE9ib2RoNlV6UjNMSnNYcEpMYStQUk0rSnR4T2M0di9QZnk0UnZESE16TU43WWYwaEpPSklhcmo2SHpyWXJnQ1FpTEZIWk4yanRvNDljNFl0czZWUCtVUnVMNERaNjJZLzBNQWp0a2ZrMFd2a2pZL09Xa2ZKaXR5ajdPU0JSdjhEVnRLRFF4dXMvcEplMElIU0NMWW9qaExhVlhSY20wR1FtVjNqYmxOZXlsRmtQRU5CVUsrWWo0end3Wk55cUtGV0VPUHhIcEZlUmZWZ2dUbndSbUVDaGpZMXFUQ1lvMWtHdU9hY05qbG9sRVkra3NxY2xGd3VwbmdaVDNKeEtYMFhwdkNKV1FleWdka3doYk44Nm1ZbTZQbjRNQ2pEbndZS2lHL3lUK2pDZFRvQU5rQVhlbDhyeThRY0pFMldRQ0NzbkhFSGVjczFuRkRtT1RYMGtpeUw3cjViZlZUSVJrVHZORCtHZVdLRW1sMlhvWXJwUjlIT01XZXVoUE1FT1Q1R2lnMWZZQ3U1VjZ1NmRmRk8yUjh4amk4U0pQd3diSjdwS0kwS1luakd6S2srKzVoTXBhTnpUN2NiOHAzY2tzTmczcFV3VzhET01IamQvT3UzbFJyYzF1SkhUZXI2Z2NDT2RoNnRvNG1lWlBZbDlNNGp3ejJmektVTWpCWUZicjI2RWd6V0N6WE9NUFpPbHNaRXVNa2lXME1BPT0iLCJyZWZyZXNoVXJsIjoiaHR0cDovL2RvY2tlci5mb3IubWFjLmxvY2FsaG9zdDo4MDAwL3JlZnJlc2giLCJpYXQiOjE1NDczMDE1MjIsImV4cCI6MTU0NzMwMTU4Mn0.u56kYf1Y8rzIxMzVdIwc1-RsmHSVkTKh2XAblrBrUXbuADYU5gyp5qmMdRHT8xNyJdm12N24lzFI2WN73XNKyc3PZA4piKYNJyKtuEsGgHFzB6BLvy24kIUm_kZkj8QctMQkQnyU2S67OJJwuySWiFwPP0M_c63p4yji4G2AFlk'
    key = OpenSSL::PKey::RSA.new 512
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
    decoded = @token_helper.decode_token
    expect(@token_helper.token).not_to be nil
    expect(decoded).not_to be nil
    expect(decoded['username']).to eq 'sethwebster@gmail.com'
    expect(@token_helper.expired?).to eq true
  end
end
