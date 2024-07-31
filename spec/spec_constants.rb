module SpecConstants
    DUMMY_PUBLIC_KEY = 'dummy_public_key'.freeze
    DUMMY_PRIVATE_KEY = 'dummy_private_key'.freeze
    JP_API_ENDPOINT = 'pay-api.amazon.jp'.freeze
    X_AMZ_PAY_REGION = 'x-amz-pay-region'.freeze
    X_AMZ_PAY_DATE = 'x-amz-pay-date'.freeze   
    ACCEPT = 'accept'.freeze
    REGION = 'region'.freeze
    JP = 'jp'.freeze
    CONTENT_TYPE = 'Content-Type'.freeze
    STRING_TO_SIGN = 'string_to_sign'.freeze
    APPLICATION_JSON = 'application/json'.freeze
    SAMPLE_FORMATTED_TIMESTAMP = '20240719T123456Z'.freeze
    HEADERS = {
        CONTENT_TYPE => APPLICATION_JSON,
        X_AMZ_PAY_REGION => JP,
        X_AMZ_PAY_DATE => SAMPLE_FORMATTED_TIMESTAMP
    }
    QUERY = 'param=value'.freeze
    QUERY_PARAMS_JSON = { b: 'value_b', a: 'value_a' }.freeze
    QUERY_PARAMS_URI = 'a=value_a&b=value_b'.freeze
    CANONICAL_HEADERS = HEADERS
    CANONICAL_REQUEST_STRING = 'your_canonical_request_string_here'.freeze
    SIGNED_HEADERS_STRING = 'your_signed_headers_string_here'.freeze
    INSSIGNED_HEADERS_STRING = 'incorrect_signed_headers_string'.freeze
    AUTHORIZATION_HEADER_STRING = 'your_authorization_header_string_here'.freeze
    INAUTHORIZATION_HEADER_STRING = 'incorrect_authorization_header_string'.freeze
    SIGNED_STRING= 'signed_string'.freeze
    INVALID_CONFIG_ERROR_MESSAGE = 'Missing required config keys: public_key_id, private_key, sandbox'.freeze
    URL = 'https://example.com/api'.freeze
    API = '/api'.freeze
    PAYLOAD = '{"key":"value"}'.freeze
    CUSTOM_HEADER = 'Custom-Header'.freeze
    HEADER_VALUE = 'HeaderValue'.freeze
    CUSTOM_HEADERS_JSON = { CUSTOM_HEADER => HEADER_VALUE }
    GET = 'GET'.freeze
    POST = 'POST'.freeze
    PUT = 'PUT'.freeze
    PATCH = 'PATCH'.freeze
    DELETE = 'DELETE'.freeze
    UNKNOWN = 'unknown'.freeze
    AUTHORIZATION = 'authorization'.freeze
    CANONICAL_HEADER_JSON = {
        CONTENT_TYPE => APPLICATION_JSON,
        ACCEPT => APPLICATION_JSON,
        X_AMZ_PAY_REGION => REGION
    }.freeze
    EXPECTED_CANICAL_HEADER_JSON = {
        ACCEPT => APPLICATION_JSON,
        CONTENT_TYPE.downcase => APPLICATION_JSON,
        X_AMZ_PAY_REGION => REGION
    }.freeze
    HASH_PAYLOAD = 'hashed_payload'.freeze
    SAMPLE_MERCHANT_ACCOUNT_ID = '12345'
end