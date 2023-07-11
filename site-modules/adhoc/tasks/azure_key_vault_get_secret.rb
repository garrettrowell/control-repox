#!/opt/puppetlabs/puppet/bin/ruby

require 'uri'
require 'net/https'
require 'json'

require_relative "../../ruby_task_helper/files/task_helper.rb"

class Azure_key_vault_get_secret < TaskHelper
  def task(client_id: nil, client_secret: nil, tenant_id: nil, vault_api_version: nil, secret_version: nil, vault_name: nil, secret_name: nil, **kwargs)
    # Get Bearer Token
    token_uri = URI("https://login.microsoftonline.com/#{tenant_id}/oauth2/v2.0/token")
    token_header = { 'Content-Type' => 'application/x-www-form-urlencoded' }

    token_data = {
      'grant_type'    => 'client_credentials',
      'client_id'     => client_id,
      'client_secret' => client_secret,
      'scope'         => 'https://vault.azure.net/.default'
    }

    token_https = Net::HTTP.new(token_uri.host, token_uri.port)
    token_https.use_ssl = true
    token_request = Net::HTTP::Post.new(token_uri.request_uri, token_header)
    token_request.body = URI.encode_www_form(token_data)

    token_response = token_https.request(token_request)
    token_response_body = JSON.parse(token_response.body)
    access_token = token_response_body['access_token']
#    puts JSON.pretty_generate(token_response_body)

    # Get Secret
    version_parameter = secret_version.empty? ? secret_version : "/#{secret_version}"
    secret_uri = URI("https://#{vault_name}.vault.azure.net/secrets/#{secret_name}#{version_parameter}?api-version=#{vault_api_version}")
    secret_header = {
      'Content-Type'  => 'application/x-www-form-urlencoded',
      'Authorization' => "Bearer #{access_token}"
    }
    secret_https = Net::HTTP.new(secret_uri.host, secret_uri.port)
    secret_https.use_ssl = true
    secret_request = Net::HTTP::Get.new(secret_uri.request_uri, secret_header)
    secret_response = secret_https.request(secret_request)
    secret_response_body = JSON.parse(secret_response.body)
#    puts JSON.pretty_generate(secret_response_body)

    { _result: secret_response_body['value'] }
  end
end

if __FILE__ == $0
  Azure_key_vault_get_secret.run
end
