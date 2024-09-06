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

  # Generates a signature for the given payload
  # This method is used to generate a signature for an Amazon Pay button payload.
  # The payload can be provided as either a String or a Hash. If a Hash is provided, it is converted to a JSON string before signing.
  # @param {Object|String} payload - The payload to be signed, which can be a JSON string or a Hash.
  # @return {String} The signature for the provided payload.
  def generate_button_signature(payload)
    @helper.sign(payload.is_a?(String) ? payload : JSON.generate(payload))
  end

  # API to retrieve Buyer information
  # Fetches details of a Buyer using the buyer token provided.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/buyer.html#get-buyer
  # @param {String} buyer_token - The unique token associated with the Buyer.
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @return [HTTPResponse] The response from the API call, which includes the details of the Buyer, such as name, email, and address.
  def get_buyer(buyer_token, headers: {})
    api_call("#{Constants::BUYERS_URL}/#{buyer_token}", Constants::GET, headers: headers)
  end

  # API to create a CheckoutSession object
  # Creates a new CheckoutSession object.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/checkout-session.html#create-checkout-session
  # @param {Object} payload - The payload for the request. This should include all the required fields such as chargeAmount, currencyCode, etc.
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @return [HTTPResponse] The response from the API call, which includes the details of the newly created CheckoutSession.
  def create_checkout_session(payload, headers: {})
    api_call(Constants::CHECKOUT_SESSION_URL, Constants::POST, payload: payload, headers: headers)
  end

  # API to get a CheckoutSession object
  # Retrieves details of a previously created CheckoutSession object.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/checkout-session.html#get-checkout-session
  # @param {String} checkout_session_id - The unique identifier for the CheckoutSession.
  # @param {Object} headers - Optional headers for the request.
  # @return [HTTPResponse] The response from the API call, which includes the details of the CheckoutSession object.{Object} [headers=null] - The headers for the request
  def get_checkout_session(checkout_session_id, headers: {})
    api_call("#{Constants::CHECKOUT_SESSION_URL}/#{checkout_session_id}", Constants::GET, headers: headers)
  end

  # API to update a CheckoutSession object
  # Updates a previously created CheckoutSession object with new information.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/checkout-session.html#update-checkout-session
  # @param {String} checkout_session_id - The unique identifier for the CheckoutSession.
  # @param {Object} payload - The payload for the request. This should include the fields that need to be updated.
  # @param {Object} headers - Optional headers for the request.
  # @return [HTTPResponse] The response from the API call, which includes the updated details of the CheckoutSession.
  def update_checkout_session(checkout_session_id, payload, headers: {})
    api_call("#{Constants::CHECKOUT_SESSION_URL}/#{checkout_session_id}", Constants::PATCH, payload: payload, headers: headers)
  end

  # API to complete a Checkout Session
  # Confirms the completion of buyer checkout.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/checkout-session.html#complete-checkout-session
  # @param {String} checkout_session_id - The unique identifier for the CheckoutSession.
  # @param {Object} payload - The payload for the request, typically including fields like chargeAmount, currencyCode, etc.
  # @param {Object} headers - Optional headers for the request.
  # @return [HTTPResponse] The response from the API call, which confirms the completion of the checkout process.
  def complete_checkout_session(checkout_session_id, payload, headers: {})
    api_call("#{Constants::CHECKOUT_SESSION_URL}/#{checkout_session_id}/complete", Constants::POST, payload: payload, headers: headers)
  end

  # API to finalize a Checkout Session
  # Finalizes the checkout process by confirming the payment and completing the session.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/checkout-session.html#finalize-checkout-session
  # @param {String} checkout_session_id - The unique ID of the checkout session that needs to be finalized.
  # @param {Object} payload - The payload for the request, typically including payment confirmation details.
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @return [HTTPResponse] The response from the API call, indicating the success or failure of the checkout finalization.
  def finalize_checkout_session(checkout_session_id, payload, headers: {})
    api_call("#{Constants::CHECKOUT_SESSION_URL}/#{checkout_session_id}/finalize", Constants::POST, payload: payload, headers: headers)
  end

  # API to retrieve a Charge Permission object
  # Fetches details of a Charge Permission, which is associated with a Checkout Session.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/charge-permission.html#get-charge-permission
  # @param {String} charge_permission_id - The unique identifier for the Charge Permission.
  # @param {Object} headers - Optional headers for the request.
  # @return [HTTPResponse] The response from the API call, including the details of the Charge Permission.
  def get_charge_permission(charge_permission_id, headers: {})
    api_call("#{Constants::CHARGE_PERMISSIONS_URL}/#{charge_permission_id}", Constants::GET, headers: headers)
  end

  # API to update a Charge Permission object
  # Updates a previously created Charge Permission with new information.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/charge-permission.html#update-charge-permission
  # @param {String} charge_permission_id - The unique identifier for the Charge Permission.
  # @param {Object} payload - The payload for the request. This should include the fields that need to be updated.
  # @param {Object} headers - Optional headers for the request.
  # @return [HTTPResponse] The response from the API call, including the updated details of the Charge Permission.
  def update_charge_permission(charge_permission_id, payload, headers: {})
    api_call("#{Constants::CHARGE_PERMISSIONS_URL}/#{charge_permission_id}", Constants::PATCH, payload: payload, headers: headers)
  end

  # API to close a Charge Permission object
  # Closes a Charge Permission, preventing further charges.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/charge-permission.html#close-charge-permission
  # @param {String} charge_permission_id - The unique identifier for the Charge Permission.
  # @param {Object} payload - The payload for the request, typically including a reason for closure.
  # @param {Object} headers - Optional headers for the request.
  # @return [HTTPResponse] The response from the API call, confirming the closure of the Charge Permission.
  def close_charge_permission(charge_permission_id, payload, headers: {})
    api_call("#{Constants::CHARGE_PERMISSIONS_URL}/#{charge_permission_id}/close", Constants::DELETE, payload: payload, headers: headers)
  end

  # API to create a new charge
  # Initiates a new charge with the provided payment details.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/charge.html#create-charge
  # @param {Object} payload - The payload containing payment details, such as the amount and currency.
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @return [HTTPResponse] The response from the API call, which includes details of the created charge.
  def create_charge(payload, headers: {})
    api_call(Constants::CHARGES_URL, Constants::POST, payload: payload, headers: headers)
  end

  # API to retrieve charge details
  # Retrieves details of an existing charge using its unique charge ID.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/charge.html#get-charge
  # @param {String} charge_id - The unique ID of the charge to retrieve.
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @return [HTTPResponse] The response from the API call, which includes details of the requested charge.
  def get_charge(charge_id, headers: {})
    api_call("#{Constants::CHARGES_URL}/#{charge_id}", Constants::GET, headers: headers)
  end

  # API to capture a charge
  # Captures an authorized charge to collect the funds.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/charge.html#capture-charge
  # @param {String} charge_id - The unique ID of the charge to capture.
  # @param {Object} payload - The payload containing capture details, such as the amount to capture.
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @return [HTTPResponse] The response from the API call, which includes details of the captured charge.
  def capture_charge(charge_id, payload, headers: {})
    api_call("#{Constants::CHARGES_URL}/#{charge_id}/capture", Constants::POST, payload: payload, headers: headers)
  end

  # API to cancel a charge
  # Cancels an existing charge, preventing it from being captured.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/charge.html#cancel-charge
  # @param {String} charge_id - The unique ID of the charge to cancel.
  # @param {Object} payload - The payload containing cancellation details.
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @return [HTTPResponse] The response from the API call, which confirms the cancellation of the charge.
  def cancel_charge(charge_id, payload, headers: {})
    api_call("#{Constants::CHARGES_URL}/#{charge_id}/cancel", Constants::DELETE, payload: payload, headers: headers)
  end

  # API to create a refund
  # Initiates a new refund for a previously captured charge.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/refund.html#create-refund
  # @param {Object} payload - The payload containing refund details, such as the amount and currency.
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @return [HTTPResponse] The response from the API call, which includes details of the created refund.
  def create_refund(payload, headers: {})
    api_call(Constants::REFUNDS_URL, Constants::POST, payload: payload, headers: headers)
  end

  # API to retrieve refund details
  # Retrieves details of an existing refund using its unique refund ID.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/refund.html#get-refund
  # @param {String} refund_id - The unique ID of the refund to retrieve.
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @return [HTTPResponse] The response from the API call, which includes details of the requested refund.
  def get_refund(refund_id, headers: {})
    api_call("#{Constants::REFUNDS_URL}/#{refund_id}", Constants::GET, headers: headers)
  end

  # API to retrieve a list of reports
  # Retrieves a list of reports based on the provided query parameters.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/reports.html#get-reports
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @param {Object} query_params - Query parameters to filter the reports, such as report type or processing status.
  # @return [HTTPResponse] The response from the API call, which includes a list of reports matching the criteria.
  def get_reports(headers: {}, query_params: {})
    api_call(Constants::REPORTS, Constants::GET, headers: headers, query_params: query_params)
  end

  # API to retrieve a specific report by ID
  # Retrieves details of a specific report using its unique report ID.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/reports.html#get-report-by-id
  # @param {String} report_id - The unique ID of the report to retrieve.
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @return [HTTPResponse] The response from the API call, which includes details of the requested report.
  def get_report_by_id(report_id, headers: {})
    api_call("#{Constants::REPORTS}/#{report_id}", Constants::GET, headers: headers)
  end

  # API to create a new report
  # Creates a new report based on the provided payload.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/reports.html#create-report
  # @param {Object} payload - The payload containing data required to generate the report.
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @return [HTTPResponse] The response from the API call, which includes confirmation and details of the created report.
  def create_report(payload, headers: {})
    api_call(Constants::REPORTS, Constants::POST, payload: payload, headers: headers)
  end

  # API to retrieve a specific report document by ID
  # Retrieves the content of a specific report document using its unique report document ID.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/reports.html#get-report-document
  # @param {String} report_document_id - The unique ID of the report document to retrieve.
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @return [HTTPResponse] The response from the API call, which includes the content of the requested report document.
  def get_report_document(report_document_id, headers: {})
    api_call("#{Constants::REPORT_DOCUMENTS}/#{report_document_id}", Constants::GET, headers: headers)
  end

  # API to retrieve a list of report schedules
  # Retrieves a list of report schedules based on the provided query parameters.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/reports.html#get-report-schedules
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @param {Object} query_params - Query parameters to filter the report schedules, such as schedule type or status.
  # @return [HTTPResponse] The response from the API call, which includes a list of report schedules matching the criteria.
  def get_report_schedules(headers: {}, query_params: {})
    api_call(Constants::REPORT_SCHEDULES, Constants::GET, headers: headers, query_params: query_params)
  end

  # API to retrieve a specific report schedule by ID
  # Retrieves details of a specific report schedule using its unique report schedule ID.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/reports.html#get-report-schedule-by-id
  # @param {String} report_schedule_id - The unique ID of the report schedule to retrieve.
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @return [HTTPResponse] The response from the API call, which includes details of the requested report schedule.
  def get_report_schedule_by_id(report_schedule_id, headers: {})
    api_call("#{Constants::REPORT_SCHEDULES}/#{report_schedule_id}", Constants::GET, headers: headers)
  end

  # API to create a new report schedule
  # Creates a new report schedule based on the provided payload.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/reports.html#create-report-schedule
  # @param {Object} payload - The payload containing data required to set up the report schedule.
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @return [HTTPResponse] The response from the API call, which includes confirmation and details of the created report schedule.
  def create_report_schedule(payload, headers: {}, query_params: {})
    api_call(Constants::REPORT_SCHEDULES, Constants::POST, payload: payload, headers: headers, query_params: query_params)
  end

  # API to cancel an existing report schedule by ID
  # Cancels a specific report schedule using its unique report schedule ID.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/reports.html#cancel-report-schedule
  # @param {String} report_schedule_id - The unique ID of the report schedule to cancel.
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @return [HTTPResponse] The response from the API call, which includes confirmation of the cancellation.
  def cancel_report_schedule(report_schedule_id, headers: {})
    api_call("#{Constants::REPORT_SCHEDULES}/#{report_schedule_id}", Constants::DELETE, headers: headers)
  end

  # API to retrieve a list of disbursements
  # Retrieves a list of disbursements based on the provided query parameters.
  # @see https://developer.amazon.com/docs/amazon-pay-api-v2/reports.html#get-disbursements
  # @param {Object} headers - Optional headers for the request, such as authorization tokens or custom headers.
  # @param {Object} query_params - Query parameters to filter the disbursements, such as date range or status.
  # @return [HTTPResponse] The response from the API call, which includes a list of disbursements matching the criteria.
  def get_disbursements(headers: {}, query_params: {})
    api_call(Constants::DISBURSEMENTS, Constants::GET, headers: headers, query_params: query_params)
  end
end