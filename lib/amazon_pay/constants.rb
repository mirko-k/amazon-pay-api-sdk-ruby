require 'net/http'

module Constants
    SDK_TYPE = "amazon-pay-api-sdk-ruby".freeze
    SDK_VERSION = "1.1.0".freeze
    API_VERSION = "v2".freeze
    API_ENDPOINTS = {
      'na' => 'pay-api.amazon.com',
      'eu' => 'pay-api.amazon.eu',
      'jp' => 'pay-api.amazon.jp'
    }.freeze
    METHOD_TYPES = {
      'GET' => Net::HTTP::Get,
      'POST' => Net::HTTP::Post,
      'PUT' => Net::HTTP::Put,
      'PATCH' => Net::HTTP::Patch,
      'DELETE' => Net::HTTP::Delete
    }.freeze
    HASH_ALGORITHM = "SHA256".freeze
    HTTPS = 'https'.freeze
    AMAZON_SIGNATURE_ALGORITHM = "AMZN-PAY-RSASSA-PSS-V2".freeze
    AUTHORIZATION = 'authorization'.freeze
    ACCEPT = 'accept'.freeze
    CONTENT_TYPE = 'content-type'.freeze
    APPLICATION_JSON = 'application/json'.freeze
    X_AMZ_PAY_REGION = 'x-amz-pay-region'.freeze
    X_AMZ_PAY_DATE = 'x-amz-pay-date'.freeze
    X_AMZ_PAY_HOST = 'x-amz-pay-host'.freeze
    CONTENT_LENGTH = 'content-length'.freeze
    X_AMZ_PAY_SDK_TYPE = 'x-amz-pay-sdk-type'.freeze
    X_AMZ_PAY_SDK_VERSION = 'x-amz-pay-sdk-version'.freeze
    LIVE = 'LIVE-'
    SANDBOX = 'SANDBOX-'
    MERCHANT_ACCOUNTS_BASE_URL = 'merchantAccounts'.freeze
    GET = 'GET'.freeze
    POST = 'POST'.freeze
    PATCH = 'PATCH'.freeze
    DELETE = 'DELETE'.freeze
    MAX_RETRIES = 3.freeze
    BACKOFF_TIMES = [1, 2, 4].freeze # Define backoff times for retries
    RETRYABLE_ERROR_CODES = [408, 429, 500, 502, 503, 504].freeze
    HTTP_OK = '200'
    HTTP_SERVER_ERROR = '500'
    BUYERS_URL = 'buyers'.freeze
    CHECKOUT_SESSION_URL = 'checkoutSessions'.freeze
    CHARGE_PERMISSIONS_URL = 'chargePermissions'.freeze
    CHARGES_URL = 'charges'.freeze
    REFUNDS_URL = 'refunds'.freeze
end