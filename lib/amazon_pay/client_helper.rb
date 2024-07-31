require 'openssl'
require 'time'
require 'json'
require 'base64'
require_relative 'constants'
require 'uri'

# ClientHelper class provides utility functions for API interactions
class ClientHelper
  attr_reader :base_url

  # Initialize with configuration settings
  def initialize(config)
    validate_config(config)
    @region = fetch(:region, config)
    @public_key_id = fetch(:public_key_id, config) 
    @private_key = fetch(:private_key, config)
    @amazon_signature_algorithm = Constants::AMAZON_SIGNATURE_ALGORITHM 
    @salt_length = 32 
    environment = determine_environment(config)
    @base_url = "https://#{endpoint}/#{environment}/#{Constants::API_VERSION}/"
  end

  # Determine the environment based on the public key or the config setting
  def determine_environment(config)
    @live = Constants::LIVE[0...-1].downcase
    @sandbox = Constants::SANDBOX[0...-1].downcase
    if @public_key_id.start_with?(Constants::LIVE)
      :live
    elsif @public_key_id.start_with?(Constants::SANDBOX)
      :sandbox
    else
      fetch(:sandbox, config) ? :sandbox : :live
    end
  end

  # Fetch value from config hash
  def fetch(key, config)
    config[key] || config[key.to_s]
  end

  # Get endpoint URL based on region
  def endpoint
    Constants::API_ENDPOINTS[@region] || raise(ArgumentError, "Unknown region: '#{@region}'. Valid regions are: #{Constants::API_ENDPOINTS.keys.join(', ')}.")
  end

  # Get HTTP method object based on method string
  def http_method(method)
    Constants::METHOD_TYPES[method] || raise(ArgumentError, "Unknown HTTP method: '#{method}'. Valid methods are: #{Constants::METHOD_TYPES.keys.join(', ')}.")
  end

  # Generate signed headers for the API request
  def signed_headers(method, uri, payload, user_headers, query)
    headers = prepare_headers(user_headers, uri, payload) 
    canonical_headers = canonicalize_headers(headers) 
    canonical_request = build_canonical_request(method, uri, query, canonical_headers, payload) 
    signed_headers = sign_headers(canonical_request, canonical_headers)
    
    # Add authorization header
    headers[Constants::AUTHORIZATION] = authorization_header(signed_headers) 
    headers
  end

  # Sign the given string using the private key
  def sign(string_to_sign)
    hashed_request = "#{@amazon_signature_algorithm}\n#{hex_and_hash(string_to_sign)}"
    rsa = OpenSSL::PKey::RSA.new(@private_key)
    Base64.strict_encode64(rsa.sign_pss(Constants::HASH_ALGORITHM, hashed_request, salt_length: @salt_length, mgf1_hash: Constants::HASH_ALGORITHM))
  end

  # Convert query parameters to URL query string
  def to_query(query_params)
    URI.encode_www_form(query_params.sort.to_h)
  end

  # Prepare headers for the API request
  def prepare_headers(user_headers, uri, payload)
    headers = normalize_headers(user_headers)
    headers[Constants::ACCEPT] = headers[Constants::CONTENT_TYPE] = Constants::APPLICATION_JSON
    headers[Constants::X_AMZ_PAY_REGION] = @region
    headers[Constants::X_AMZ_PAY_DATE] = formatted_timestamp
    headers[Constants::X_AMZ_PAY_HOST] = uri.host
    headers[Constants::CONTENT_LENGTH] = payload.bytesize.to_s unless payload.empty?
    headers[Constants::X_AMZ_PAY_SDK_TYPE] = Constants::SDK_TYPE
    headers[Constants::X_AMZ_PAY_SDK_VERSION] = Constants::SDK_VERSION
    headers
  end

  # Normalize headers by converting keys to strings and stripping values
  def normalize_headers(headers)
    headers.transform_keys(&:to_s).transform_values(&:strip)
  end

  # Canonicalize headers by converting keys to lowercase and sorting them
  def canonicalize_headers(headers)
    headers.transform_keys(&:downcase).sort.to_h
  end

  # Build the canonical request string
  def build_canonical_request(method, uri, query, canonical_headers, payload)
    headers_string = canonical_headers.map { |k, v| "#{k}:#{v}" }.join("\n")
    signed_headers = canonical_headers.keys.join(';')
    hashed_payload = hex_and_hash(payload)

    "#{method}\n#{uri.path}\n#{query}\n#{headers_string}\n\n#{signed_headers}\n#{hashed_payload}"
  end

  # Sign the canonical request headers
  def sign_headers(canonical_request, canonical_headers)
    hashed_request = "#{@amazon_signature_algorithm}\n#{hex_and_hash(canonical_request)}"
    rsa = OpenSSL::PKey::RSA.new(@private_key)
    signature = Base64.strict_encode64(rsa.sign_pss(Constants::HASH_ALGORITHM, hashed_request, salt_length: @salt_length, mgf1_hash: Constants::HASH_ALGORITHM))
    "SignedHeaders=#{canonical_headers.keys.join(';')}, Signature=#{signature}"
  end

  # Build authorization header from signed headers
  def authorization_header(signed_headers)
    "#{@amazon_signature_algorithm} PublicKeyId=#{@public_key_id}, #{signed_headers}"
  end

  # Compute SHA256 hash of the given data
  def hex_and_hash(data)
    Digest::SHA256.hexdigest(data)
  end

  # Format the current timestamp
  def formatted_timestamp
    Time.now.utc.iso8601.delete(':-')
  end

  # URL encode the given value
  def url_encode(value)
    URI.encode_www_form_component(value).gsub('%7E', '~')
  end

  # AmazonPayClient dependency methods
  # Create a new HTTP request
  def create_request(method, uri, payload)
    request = http_method(method).new(uri)
    request.body = payload.is_a?(String) ? payload : JSON.generate(payload)
    request
  end

  # Set headers for the HTTP request
  def set_request_headers(request, signed_headers)
    signed_headers.each { |k, v| request[k] = v }
  end

  # Send the HTTP request
  def send_request(uri, request)
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == Constants::HTTPS) do |http|
      http.request(request)
    end
  end

  # Build the full URI for the API request
  def build_uri(url_fragment, query)
    URI.parse("#{@base_url}#{url_fragment}#{query.empty? ? '' : "?#{query}"}")
  end

  # This method checks if all required configuration keys are present in the given config. 
  # If any required key is missing, it raises a StandardError with a message listing the missing keys.
  def validate_config(config)
    # Define the list of required keys.
    required_keys = %i[region public_key_id private_key]

    # Identify which required keys are missing from the config hash.
    missing_keys = required_keys.select { |key| config[key].nil? }

    # If there are missing keys, raise an error with a descriptive message.
    unless missing_keys.empty?
      raise StandardError, "Missing required config keys: #{missing_keys.join(', ')}"
    end
  end

end