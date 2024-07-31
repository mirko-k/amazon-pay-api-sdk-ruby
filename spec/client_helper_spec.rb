require 'rspec'
require 'net/http'
require_relative '../lib/amazon_pay/client_helper'
require_relative 'shared_config'

RSpec.describe ClientHelper do
    include SharedConfig

    let(:config) { default_config('jp') }
    subject { ClientHelper.new(config) } # Initialize ClientHelper with the default config

    # Test for the fetch method
    describe '#fetch' do
        it 'fetches value from config hash using symbol key' do
            # Test fetching with symbol key
            expect(subject.fetch(:region, config)).to eq('jp')
        end

        it 'fetches value from config hash using string key' do
            # Test fetching with string key
            config_with_string_key = config.merge(SpecConstants::REGION => 'jp')
            expect(subject.fetch(SpecConstants::REGION, config_with_string_key)).to eq('jp')
        end

        it 'returns nil if key is not present in config' do
            # Test fetching a non-existent key
            expect(subject.fetch(:non_existent_key, config)).to be_nil
        end
    end

    # Test for the endpoint method
    describe '#endpoint' do
        context 'with a valid region' do
            it 'returns the correct endpoint URL' do
                # Test endpoint generation with a valid region
                valid_config = config.merge(region: 'jp')
                helper = ClientHelper.new(valid_config)
                expect(helper.endpoint).to eq(SpecConstants::JP_API_ENDPOINT)
            end
        end

        context 'with an unknown region' do
            it 'raises an error' do
                # Test endpoint generation with an invalid region
                invalid_config = config.merge(region: SpecConstants::UNKNOWN)
                expect { ClientHelper.new(invalid_config).endpoint }.to raise_error(ArgumentError, "Unknown region: '#{SpecConstants::UNKNOWN}'. Valid regions are: na, eu, jp.")
            end
        end
    end

     # Test for the http_method method
    describe '#http_method' do
        it 'returns the correct HTTP method object for a valid method' do
            # Test http_method with valid HTTP methods
            expect(subject.http_method(SpecConstants::GET)).to eq(Net::HTTP::Get)
            expect(subject.http_method(SpecConstants::POST)).to eq(Net::HTTP::Post)
            expect(subject.http_method(SpecConstants::PUT)).to eq(Net::HTTP::Put)
            expect(subject.http_method(SpecConstants::PATCH)).to eq(Net::HTTP::Patch)
            expect(subject.http_method(SpecConstants::DELETE)).to eq(Net::HTTP::Delete)
        end

        it 'raises an error for an unknown HTTP method' do
            # Test http_method with an invalid HTTP method
            expect { subject.http_method(SpecConstants::UNKNOWN) }.to raise_error(ArgumentError, "Unknown HTTP method: '#{SpecConstants::UNKNOWN}'. Valid methods are: GET, POST, PUT, PATCH, DELETE.")
        end
    end

    # Test for the signed_headers method
    describe '#signed_headers' do
        let(:method) { SpecConstants::POST }
        let(:uri) { URI(SpecConstants::URL) }
        let(:payload) { SpecConstants::PAYLOAD }
        let(:user_headers) { SpecConstants::CUSTOM_HEADERS_JSON }
        let(:query) { SpecConstants::QUERY }

        context 'when generating signed headers' do
            before do
                # Setup common mocks for testing
                setup_common_mocks(signing_success: true)
            end

            it 'generates signed headers correctly' do
                # Test generating signed headers with successful signing
                headers = subject.signed_headers(method, uri, payload, user_headers, query)
                expect_amazonpay_signed_headers(headers, true)
            end

            it 'does not include incorrect values in signed headers' do
                # Test generating signed headers with failed signing
                setup_common_mocks(signing_success: false)
                headers = subject.signed_headers(method, uri, payload, user_headers, query)
                expect_amazonpay_signed_headers(headers, false)
            end

            def setup_common_mocks(signing_success: true)
                # Setup mocks for various methods used in signed_headers
                allow(subject).to receive(:prepare_headers).and_return(SpecConstants::HEADERS)
                allow(subject).to receive(:canonicalize_headers).and_return(SpecConstants::CANONICAL_HEADERS)
                allow(subject).to receive(:build_canonical_request).and_return(SpecConstants::CANONICAL_REQUEST_STRING)
                if signing_success
                    allow(subject).to receive(:sign_headers).and_return(SpecConstants::SIGNED_HEADERS_STRING)
                    allow(subject).to receive(:authorization_header).and_return(SpecConstants::AUTHORIZATION_HEADER_STRING)
                else
                    allow(subject).to receive(:sign_headers).and_return(SpecConstants::INSSIGNED_HEADERS_STRING)
                    allow(subject).to receive(:authorization_header).and_return(SpecConstants::INAUTHORIZATION_HEADER_STRING)
                end
            end
        
            def expect_amazonpay_signed_headers(headers, signing_success)
                # Expectations for signed headers
                expect(headers).to include(SpecConstants::CONTENT_TYPE => Constants::APPLICATION_JSON)
                expect(headers).to include(SpecConstants::X_AMZ_PAY_REGION => 'jp')
                expect(headers).to include(SpecConstants::X_AMZ_PAY_DATE => SpecConstants::SAMPLE_FORMATTED_TIMESTAMP)
                if signing_success
                    expect(headers).to include(SpecConstants::AUTHORIZATION => SpecConstants::AUTHORIZATION_HEADER_STRING)
                else
                    expect(headers).not_to include(SpecConstants::AUTHORIZATION => SpecConstants::AUTHORIZATION_HEADER_STRING)
                end
            end
        end
    end

    # Test for the sign method
    describe '#sign' do
        let(:string_to_sign) { SpecConstants::STRING_TO_SIGN }
        let(:hashed_request) { "#{Constants::AMAZON_SIGNATURE_ALGORITHM}\n#{string_to_sign}" }
        let(:private_key) { OpenSSL::PKey::RSA.generate(2048).to_pem }
        let(:subject) { ClientHelper.new(config.merge(private_key: private_key)) }

        it 'signs the string using the private key' do
            # Test signing functionality with a valid private key
            allow_any_instance_of(OpenSSL::PKey::RSA).to receive(:sign_pss).and_return(SpecConstants::SIGNED_STRING)
            result = subject.sign(string_to_sign)
            expect(result).to eq(Base64.strict_encode64(SpecConstants::SIGNED_STRING))
        end

        it 'raises an error with an invalid private key' do
             # Test signing functionality with an invalid private key
            invalid_key = SpecConstants::UNKNOWN
            invalid_client = ClientHelper.new(config.merge(private_key: invalid_key))
            expect { invalid_client.sign(string_to_sign) }.to raise_error(OpenSSL::PKey::RSAError)
        end
    end

    # Test for the to_query method
    describe '#to_query' do
        let(:query_params) { SpecConstants::QUERY_PARAMS_JSON }

        it 'converts query parameters to URL query string' do
            # Test converting a hash to a query string
            result = subject.to_query(query_params)
            expect(result).to eq(SpecConstants::QUERY_PARAMS_URI)
        end

        it 'returns an empty string for empty query parameters' do
            # Test converting an empty hash to a query string
            result = subject.to_query({})
            expect(result).to eq('')
        end
    end

    # Test for the prepare_headers method
    describe '#prepare_headers' do
        let(:user_headers) { SpecConstants::CUSTOM_HEADERS_JSON }
        let(:uri) { URI(SpecConstants::URL) }
        let(:payload) { SpecConstants::PAYLOAD }

        before do
            allow(subject).to receive(:normalize_headers).and_return(user_headers)
            allow(subject).to receive(:formatted_timestamp).and_return(SpecConstants::SAMPLE_FORMATTED_TIMESTAMP)
        end

        it 'prepares headers correctly' do
            # Test preparing headers by ensuring correct headers are set
            headers = subject.prepare_headers(user_headers, uri, payload)
            expect(headers[Constants::CONTENT_TYPE]).to eq(Constants::APPLICATION_JSON)
            expect(headers[Constants::X_AMZ_PAY_REGION]).to eq(config[:region])
            expect(headers[Constants::X_AMZ_PAY_DATE]).to eq(SpecConstants::SAMPLE_FORMATTED_TIMESTAMP)
            expect(headers[Constants::X_AMZ_PAY_HOST]).to eq(uri.host)
            expect(headers[Constants::CONTENT_LENGTH]).to eq(payload.bytesize.to_s)
            expect(headers[Constants::X_AMZ_PAY_SDK_TYPE]).to eq(Constants::SDK_TYPE)
            expect(headers[Constants::X_AMZ_PAY_SDK_VERSION]).to eq(Constants::SDK_VERSION)
            expect(headers[SpecConstants::CUSTOM_HEADER]).to eq(SpecConstants::HEADER_VALUE)
        end
    end

    # Test for the normalize_headers method
    describe '#normalize_headers' do
        let(:headers) { SpecConstants::HEADERS }

        it 'normalizes headers by converting keys to strings and stripping values' do
            # Test normalization of headers
            normalized_headers = subject.normalize_headers(headers)
            expect(normalized_headers).to eq(SpecConstants::HEADERS)
        end

        it 'handles empty headers correctly' do
            # Test normalization with empty headers
            expect(subject.normalize_headers({})).to eq({})
        end
    end

    # Test for the canonicalize_headers method
    describe '#canonicalize_headers' do
        let(:headers) { SpecConstants::CANONICAL_HEADER_JSON }

        it 'canonicalizes headers by converting keys to lowercase and sorting them' do
            # Test conversion of headers to canonical form
            canonical_headers = subject.canonicalize_headers(headers)
            expect(canonical_headers).to eq(SpecConstants::EXPECTED_CANICAL_HEADER_JSON)
        end

        it 'handles empty headers correctly' do
            # Test conversion of empty headers to empty form
            expect(subject.canonicalize_headers({})).to eq({})
        end
    end

    # Test for the build_canonical_request method
    describe '#build_canonical_request' do
        let(:method) { SpecConstants::POST }
        let(:uri) { URI(SpecConstants::URL) }
        let(:query) { 'param1=value1&param2=value2' }
        let(:canonical_headers) do
        {
            SpecConstants::CONTENT_TYPE => SpecConstants::APPLICATION_JSON,
            camel_case_key(SpecConstants::ACCEPT) => SpecConstants::APPLICATION_JSON,
            camel_case_key(SpecConstants::X_AMZ_PAY_REGION) => SpecConstants::JP
        }
        end
        let(:payload) { SpecConstants::PAYLOAD }

        # Define expected request strings for various scenarios
        let(:expected_request_with_payload) do
            "POST\n/api\nparam1=value1&param2=value2\nContent-Type:application/json\nAccept:application/json\nX-Amz-Pay-Region:jp\n\nContent-Type;Accept;X-Amz-Pay-Region\nhashed_payload"
        end
        
        let(:expected_request_with_empty_payload) do
            "POST\n/api\nparam1=value1&param2=value2\nContent-Type:application/json\nAccept:application/json\nX-Amz-Pay-Region:jp\n\nContent-Type;Accept;X-Amz-Pay-Region\nhashed_payload"
        end
        
        let(:expected_request_with_empty_query) do
            "POST\n/api\n\nContent-Type:application/json\nAccept:application/json\nX-Amz-Pay-Region:jp\n\nContent-Type;Accept;X-Amz-Pay-Region\nhashed_payload"
        end
        
        let(:expected_request_with_empty_headers) do
            "POST\n/api\nparam1=value1&param2=value2\n\n\n\nhashed_payload"
        end

        # Converts specified keys from snake_case or lowercase to camelCase format.
        def camel_case_key(key)
            case key
                when 'accept'
                    'Accept'
                when 'x-amz-pay-region'
                    'X-Amz-Pay-Region'
                else
                    key
            end
        end

        # Test case for building the canonical request string with a non-empty payload.
        it 'builds the canonical request string correctly' do
            allow(subject).to receive(:hex_and_hash).with(payload).and_return(SpecConstants::HASH_PAYLOAD)
            canonical_request = subject.build_canonical_request(method, uri, query, canonical_headers, payload)
            expect(canonical_request).to eq(expected_request_with_payload)
        end

         # Test case for handling an empty payload.
        it 'handles empty payload correctly' do
            allow(subject).to receive(:hex_and_hash).with('').and_return(SpecConstants::HASH_PAYLOAD)
            canonical_request = subject.build_canonical_request(method, uri, query, canonical_headers, '')
            expect(canonical_request).to eq(expected_request_with_empty_payload)
        end

        # Test case for handling an empty query string.
        it 'handles empty query string correctly' do
            allow(subject).to receive(:hex_and_hash).with(payload).and_return(SpecConstants::HASH_PAYLOAD)
            canonical_request = subject.build_canonical_request(method, uri, '', canonical_headers, payload)
            expect(canonical_request).to eq(expected_request_with_empty_query)
        end

         # Test case for handling empty headers.
        it 'handles empty headers correctly' do
            allow(subject).to receive(:hex_and_hash).with(payload).and_return(SpecConstants::HASH_PAYLOAD)
            canonical_request = subject.build_canonical_request(method, uri, query, {}, payload)
            expect(canonical_request).to eq(expected_request_with_empty_headers)
        end
    end

    # Test for the authorization_header method
    describe '#authorization_header' do
        let(:signed_headers) { '' }
        let(:public_key_id) { SpecConstants::DUMMY_PUBLIC_KEY }

        before do
            subject.instance_variable_set(:@amazon_signature_algorithm, Constants::AMAZON_SIGNATURE_ALGORITHM)
            subject.instance_variable_set(:@public_key_id, public_key_id)
        end

        it 'builds the correct authorization header' do
            # Test generation of authorization header
            expected_header = "#{Constants::AMAZON_SIGNATURE_ALGORITHM} PublicKeyId=#{public_key_id}, #{signed_headers}"
            expect(subject.authorization_header(signed_headers)).to eq(expected_header)
        end
    end

     # Test for the hex_and_hash method
    describe '#hex_and_hash' do
        let(:data) { SpecConstants::UNKNOWN }
        let(:hashed_data) { Digest::SHA256.hexdigest(data) }

        it 'returns the correct SHA256 hash in hexadecimal format' do
            # Test SHA256 hashing of data
            expect(subject.hex_and_hash(data)).to eq(hashed_data)
        end
    end

     # Test for the formatted_timestamp method
    describe '#formatted_timestamp' do
        it 'returns the current UTC time in the correct format' do
            # Mocking the current time
            mock_time = Time.utc(2024, 7, 19, 10, 21, 04)
            allow(Time).to receive(:now).and_return(mock_time)
            
            # Format the mocked time
            expected_time = mock_time.iso8601.delete(':-')
            
            # Check the output of formatted_timestamp
            expect(subject.formatted_timestamp).to eq(expected_time)
        end
    end

    # Test for the url_encode method
    describe '#url_encode' do
        let(:value) { 'value with spaces ~' }
        let(:encoded_value) { URI.encode_www_form_component(value).gsub('%7E', '~') }

        it 'returns the URL encoded value' do
            # Test URL encoding of a value
            expect(subject.url_encode(value)).to eq(encoded_value)
        end
    end

    # Test for the create_request method
    describe '#create_request' do
        let(:method) { SpecConstants::POST }
        let(:uri) { URI(SpecConstants::URL) }
        let(:payload) { SpecConstants::PAYLOAD }

        it 'creates a new HTTP request with the given method, URI, and payload' do
            # Test creation of an HTTP request with method, URI, and payload
            request = subject.create_request(method, uri, payload)
            expect(request).to be_an_instance_of(Net::HTTP::Post)
            expect(request.body).to eq(payload)
            expect(request.path).to eq(SpecConstants::API)
        end
    end

    # Test for the set_request_headers method
    describe '#set_request_headers' do
        let(:request) { Net::HTTP::Post.new(SpecConstants::API) }
        let(:headers) { { SpecConstants::CONTENT_TYPE => SpecConstants::APPLICATION_JSON, SpecConstants::ACCEPT => SpecConstants::APPLICATION_JSON } }

        it 'sets the headers for the request' do
             # Test setting headers for an HTTP request
            subject.set_request_headers(request, headers)
            expect(request[SpecConstants::CONTENT_TYPE]).to eq(SpecConstants::APPLICATION_JSON)
            expect(request[SpecConstants::ACCEPT]).to eq(SpecConstants::APPLICATION_JSON)
        end
    end

    # Test for the send_request method
    describe '#send_request' do
        let(:uri) { URI(SpecConstants::URL) }
        let(:request) { Net::HTTP::Post.new(uri) }
        let(:response) { instance_double(Net::HTTPResponse, code: Constants::HTTP_OK, body: 'OK') }

        before do
            # Mock Net::HTTP start and request methods
            allow(Net::HTTP).to receive(:start).and_yield(double('HTTP', request: response))
        end

        it 'sends the request and returns the response' do
            # Test sending an HTTP request and receiving a response
            result = subject.send_request(uri, request)
            expect(result).to eq(response)
        end
    end

    # Test for the build_uri method
    describe '#build_uri' do
        let(:base_url) { SpecConstants::URL }
        let(:url_fragment) { '' }
        let(:query) { SpecConstants::QUERY_PARAMS_URI }
        let(:full_uri) { URI("#{base_url}#{url_fragment}?#{query}") }

        before do
            # Set base URL in the subject
            subject.instance_variable_set(:@base_url, base_url)
        end

        it 'builds the correct full URI' do
            # Test building a full URI with base URL, fragment, and query
            expect(subject.build_uri(url_fragment, query)).to eq(full_uri)
        end

        it 'handles empty query correctly' do
            # Test building a URI without query parameters
            full_uri_without_query = URI("#{base_url}#{url_fragment}")
            expect(subject.build_uri(url_fragment, '')).to eq(full_uri_without_query)
        end
    end

    # Test for the validate_config method
    describe '#validate_config' do
        context 'with some required keys missing' do
            let(:incomplete_config) do
                {
                region: 'jp',
                public_key_id: nil,
                private_key: SpecConstants::DUMMY_PRIVATE_KEY,
                sandbox: true
                }
            end

            it 'raises an error with missing keys listed' do
                # Test validation of config with some missing required keys
                expect {
                    subject.validate_config(incomplete_config)
                }.to raise_error(StandardError, /Missing required config keys: public_key_id/)
            end
        end

        context 'with multiple required keys missing' do
            let(:incomplete_config) do
                {
                    region: nil,
                    public_key_id: nil,
                    private_key: SpecConstants::DUMMY_PRIVATE_KEY,
                    sandbox: true
                }
            end

            it 'raises an error with all missing keys listed' do
                # Test validation of config with multiple missing required keys
                expect {
                    subject.validate_config(incomplete_config)
                }.to raise_error(StandardError, /Missing required config keys: region, public_key_id/)
            end
        end
    end

    # Test for the determine_environment method
    describe '#determine_environment' do
        before do
            # Set instance variable for testing
            subject.instance_variable_set(:@public_key_id, public_key_id)
        end

        context 'when @public_key_id starts with LIVE' do
            let(:public_key_id) { "LIVE-1234" }

            it 'returns :live' do
                expect(subject.determine_environment(config)).to eq(:live)
            end
        end

        context 'when @public_key_id starts with SANDBOX' do
            let(:public_key_id) { "SANDBOX-1234" }

            it 'returns :sandbox' do
                expect(subject.determine_environment(config)).to eq(:sandbox)
            end
        end

        context 'when @public_key_id does not start with LIVE or SANDBOX' do
            let(:public_key_id) { 'OTHER-KEY' }

            it 'returns :sandbox when fetch(:sandbox, config) is true' do
                allow(subject).to receive(:fetch).with(:sandbox, config).and_return(true)
                expect(subject.determine_environment(config)).to eq(:sandbox)
            end

            it 'returns :live when fetch(:sandbox, config) is false' do
                allow(subject).to receive(:fetch).with(:sandbox, config).and_return(false)
                expect(subject.determine_environment(config)).to eq(:live)
            end
        end
    end
end