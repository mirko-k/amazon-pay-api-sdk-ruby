require 'net/http'

module Constants
    SDK_TYPE = "amazon-pay-api-sdk-ruby".freeze
    SDK_VERSION = "2.0.0".freeze
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
    REPORTS = 'reports'.freeze
    REPORT_SCHEDULES = 'report-schedules'.freeze
    REPORT_DOCUMENTS = 'report-documents'.freeze
    DISBURSEMENTS = 'disbursements'.freeze
    DISPUTE_URLS = 'disputes'.freeze
    FILES_URLS = 'files'.freeze
    DISPUTE_FILING_REASON = {
      PRODUCT_NOT_RECEIVED: "ProductNotReceived",
      PRODUCT_UNACCEPTABLE: "ProductUnacceptable",
      PRODUCT_NO_LONGER_NEEDED: "ProductNoLongerNeeded",
      CREDIT_NOT_PROCESSED: "CreditNotProcessed",
      OVERCHARGED: "Overcharged",
      DUPLICATE_CHARGE: "DuplicateCharge",
      SUBSCRIPTION_CANCELLED: "SubscriptionCancelled",
      UNRECOGNIZED: "Unrecognized",
      FRAUDULENT: "Fraudulent",
      OTHER: "Other"
    }.freeze
    DISPUTE_REASON_CODE = {
      MERCHANT_RESPONSE_REQUIRED: "MerchantResponseRequired",
      MERCHANT_ADDITIONAL_EVIDENCES_REQUIRED: "MerchantAdditionalEvidencesRequired",
      BUYER_ADDITIONAL_EVIDENCES_REQUIRED: "BuyerAdditionalEvidencesRequired",
      MERCHANT_ACCEPTED_DISPUTE: "MerchantAcceptedDispute",
      MERCHANT_RESPONSE_DEADLINE_EXPIRED: "MerchantResponseDeadlineExpired",
      BUYER_CANCELLED: "BuyerCancelled",
      INVESTIGATOR_RESOLVED: "InvestigatorResolved",
      AUTO_RESOLVED: "AutoResolved",
      CHARGEBACK_FILED: "ChargebackFiled"
    }.freeze
    DISPUTE_RESOLUTION = {
      BUYER_WON: "BuyerWon",
      MERCHANT_WON: "MerchantWon",
      NO_FAULT: "NoFault"
    }.freeze
    DISPUTE_STATE = {
      UNDER_REVIEW: "UnderReview",
      ACTION_REQUIRED: "ActionRequired",
      RESOLVED: "Resolved",
      CLOSED: "Closed"
    }.freeze
    EVIDENCE_TYPE = {
      PRODUCT_DESCRIPTION: "ProductDescription",
      RECEIPT: "Receipt",
      CANCELLATION_POLICY: "CancellationPolicy",
      CUSTOMER_SIGNATURE: "CustomerSignature",
      TRACKING_NUMBER: "TrackingNumber",
      OTHER: "Other"
    }.freeze
end