require 'net/http'
require_relative 'client_helper'
require_relative 'constants'

# AmazonPayClient class provides methods to interact with Amazon Pay API
class AmazonPayClient

  # Initialize the client with configuration settings
  def initialize(config)
    @helper = ClientHelper.new(config)
  end

  # Perform an API call to Amazon Pay
  # @param url_fragment [String] The URL fragment for the API endpoint
  # @param method [String] The HTTP method for the API call (e.g., 'POST', 'PATCH')
  # @param payload [Hash] The payload for the API call, default is an empty string
  # @param headers [Hash] Optional headers for the API call, default is an empty hash
  # @param query_params [Hash] Optional query parameters for the API call, default is an empty hash
  # @return [HTTPResponse] The response from the API call
  def api_call(url_fragment, method, payload: '', headers: {}, query_params: {})
    # Convert query parameters into a URL-encoded query string
    query = @helper.to_query(query_params)

    # Build the full URI by combining the URL fragment and query string
    uri = @helper.build_uri(url_fragment, query)

    # Initialize the retry counter
    retries = 0
  
    begin
      # Create a new HTTP request with the specified method, URI, and payload
      request = @helper.create_request(method, uri, payload)

      # Generate signed headers for the request
      signed_headers = @helper.signed_headers(method, uri, request.body, headers, query)

      # Set the signed headers on the request
      @helper.set_request_headers(request, signed_headers)

      # Send the HTTP request and get the response
      response = @helper.send_request(uri, request)
  
      # Check if the response code indicates a retryable error and if we haven't exceeded the maximum retries
      if Constants::RETRYABLE_ERROR_CODES.include?(response.code.to_i) && retries < Constants::MAX_RETRIES
        # Wait for a specified backoff period before retrying
        sleep Constants::BACKOFF_TIMES[retries]

        # Increment the retry counter
        retries += 1
        print "Retrying\n"
        # Raise an exception to force a retry
        raise "Transient error: #{response.code}" # Force retry
      end
  
      # Return the response if no retry is needed
      response 
  
      rescue => e
        # Catches any exceptions that occur during the request
        if retries < Constants::MAX_RETRIES

          # Increment the retry counter
          retries += 1

          # Wait for a specified backoff period before retrying
          sleep Constants::BACKOFF_TIMES[retries - 1] # Backoff before retry

          # Retry the request
          retry
        else
          # After maximum retries are exhausted, return the response from the last attempt
          response
        end
    end
  end 

  # Creates a merchant account
  # @param payload [Hash] The payload for the API call
  # @param headers [Hash] - Optional headers for the API call, default is an empty hash
  # @return [HTTPResponse] The response from the API call
  def create_merchant_account(payload, headers: {})
    api_call(Constants::MERCHANT_ACCOUNTS_BASE_URL, Constants::POST, payload: payload, headers: headers)
  end

  # Updates a merchant account
  # @param merchant_account_id [String] The ID of the merchant account to update
  # @param payload [Hash] The payload for the API call
  # @param headers [Hash] - Optional headers for the API call but requires x-amz-pay-authToken header for this API, default is an empty hash
  # @return [HTTPResponse] The response from the API call
  def update_merchant_account(merchant_account_id, payload, headers: {})
    api_call("#{Constants::MERCHANT_ACCOUNTS_BASE_URL}/#{merchant_account_id}", Constants::PATCH, payload: payload, headers: headers)
  end

  # Claims a merchant account
  # @param merchant_account_id [String] The ID of the merchant account to claim
  # @param payload [Hash] The payload for the API call
  # @param headers [Hash] Optional headers for the API call, default is an empty hash
  # @return [HTTPResponse] The response from the API call
  def merchant_account_claim(merchant_account_id, payload, headers: {})
    api_call("#{Constants::MERCHANT_ACCOUNTS_BASE_URL}/#{merchant_account_id}/claim", Constants::POST, payload: payload, headers: headers)
  end
end