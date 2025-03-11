require 'rspec'
require_relative '../lib/amazon_pay/client'
require_relative '../lib/amazon_pay/client_helper'
require_relative 'shared_config'

RSpec.describe AmazonPayClient do
    include SharedConfig

    # Define the configuration and mock ClientHelper
    let(:config) { default_config(SpecConstants::REGION) }
    let(:client_helper) { instance_double(ClientHelper) }
    let(:client) { AmazonPayClient.new(config) }
    
    # Define constants for API endpoint and headers
    let(:url_fragment) { SpecConstants::URL }
    let(:method) { SpecConstants::POST }
    let(:payload) { SpecConstants::PAYLOAD }
    let(:headers) { SpecConstants::CUSTOM_HEADERS_JSON }
    let(:query_params) { SpecConstants::QUERY_PARAMS_JSON }
    
    # Construct the URI for the API request
    let(:uri) { URI.parse("#{SpecConstants::URL}#{SpecConstants::API}/v2/#{url_fragment}?#{SpecConstants::QUERY}") }
    
    # Create a mock request object
    let(:request) { Net::HTTP::Post.new(uri) }
    
    # Define a mock response object
    let(:response) { instance_double(Net::HTTPResponse) }
    
    # Define the expected signed headers for the request
    let(:signed_headers) { { SpecConstants::AUTHORIZATION => SpecConstants::CUSTOM_HEADER } }
    let(:merchant_account_id) { SpecConstants::SAMPLE_MERCHANT_ACCOUNT_ID }

    # Before each test, set up the behavior of ClientHelper methods
    before do
        allow(ClientHelper).to receive(:new).with(config).and_return(client_helper)
        allow(client_helper).to receive(:to_query).with(query_params).and_return(SpecConstants::QUERY)
        allow(client_helper).to receive(:build_uri).with(url_fragment, SpecConstants::QUERY).and_return(uri)
        allow(client_helper).to receive(:create_request).with(method, uri, payload).and_return(request)
        allow(client_helper).to receive(:signed_headers).with(method, uri, payload, headers, SpecConstants::QUERY).and_return(signed_headers)
        allow(client_helper).to receive(:set_request_headers).with(request, signed_headers)
        allow(client_helper).to receive(:send_request).with(uri, request).and_return(response)
    end

    describe '#initialize' do
        context 'with valid configuration' do
            it 'initializes ClientHelper with the given configuration' do
                # Verify that ClientHelper was initialized with the correct config
                expect(client.instance_variable_get(:@helper)).to eq(client_helper)
            end
        end

        context 'with invalid configuration' do
            it 'raises an error when ClientHelper fails validation' do
                invalid_config = { region: SpecConstants::JP } # Invalid configuration

                # Simulate an error when creating ClientHelper with invalid config
                allow(ClientHelper).to receive(:new).with(invalid_config).and_raise(StandardError, SpecConstants::INVALID_CONFIG_ERROR_MESSAGE)

                # Expect an error to be raised when initializing AmazonPayClient with invalid config
                expect {AmazonPayClient.new(invalid_config)}.to raise_error(StandardError, SpecConstants::INVALID_CONFIG_ERROR_MESSAGE)
            end
        end
    end

    describe '#api_call' do
        # Define doubles for HTTP request and response objects
        let(:request) { instance_double(Net::HTTP::Post, body: payload) }
        let(:transient_error_response) { instance_double(Net::HTTPResponse, code: Constants::HTTP_SERVER_ERROR) }
        let(:success_response) { instance_double(Net::HTTPResponse, code: Constants::HTTP_OK) }
    
        # Set up the test environment
        before do
            # Configure the client_helper to return a transient error response first and then a success response
            allow(client_helper).to receive(:send_request).and_return(transient_error_response, success_response )
        end
    
        it 'converts query parameters, builds URI, creates and sends the request' do
            # Call the api_call method and get the result
            result = client.api_call(url_fragment, method, payload: payload, headers: headers, query_params: query_params)

            # Verify interactions and results using the helper method
            verify_api_call_interactions(result)
        end

        # Helper method to verify interactions and result
        def verify_api_call_interactions(result)
            # Verify that ClientHelper methods are called with the expected arguments
            expect(client_helper).to have_received(:to_query).with(query_params)
            expect(client_helper).to have_received(:build_uri).with(url_fragment, SpecConstants::QUERY)
            expect(client_helper).to have_received(:create_request).with(method, uri, payload).at_least(:once)
            expect(client_helper).to have_received(:signed_headers).with(method, uri, payload, headers, SpecConstants::QUERY).at_least(:once)
            expect(client_helper).to have_received(:send_request).exactly(2).times.with(uri, request)
            
            # Verify that the result's code is 200
            expect(result.code).to eq(Constants::HTTP_OK)
        end
    end

    describe '#create_merchant_account' do
        it 'calls create_merchant_account api with the correct parameters' do
            expect(client).to receive(:api_call).with(
                Constants::MERCHANT_ACCOUNTS_BASE_URL,
                Constants::POST,
                payload: payload,
                headers: headers
            ).and_return(response)
            
            result = client.create_merchant_account(payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#update_merchant_account' do
        it 'calls update_merchant_account with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::MERCHANT_ACCOUNTS_BASE_URL}/#{merchant_account_id}",
                Constants::PATCH,
                payload: payload,
                headers: headers,
            ).and_return(response)
            
            result = client.update_merchant_account(merchant_account_id, payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#merchant_account_claim' do
        it 'calls merchant_account_claim with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::MERCHANT_ACCOUNTS_BASE_URL}/#{merchant_account_id}/claim",
                Constants::POST,
                payload: payload,
                headers: headers,
            ).and_return(response)
            
            result = client.merchant_account_claim(merchant_account_id, payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#generate_button_signature' do
        let(:payload_hash) { { key: 'value' } }
        let(:payload_string) { JSON.generate(payload_hash) }
        let(:signature) { 'signed_payload' }

        before do
            allow(client_helper).to receive(:sign).with(payload_string).and_return(signature)
        end

        it 'signs the payload if it is a Hash' do
            expect(client.generate_button_signature(payload_hash)).to eq(signature)
        end

        it 'signs the payload if it is a String' do
            expect(client.generate_button_signature(payload_string)).to eq(signature)
        end
    end

    describe '#get_buyer' do
        let(:buyer_token) { 'buyerToken' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::BUYERS_URL}/#{buyer_token}",
                Constants::GET,
                headers: headers
            ).and_return(response)

            result = client.get_buyer(buyer_token, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#create_checkout_session' do
        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                Constants::CHECKOUT_SESSION_URL,
                Constants::POST,
                payload: payload,
                headers: headers
            ).and_return(response)

            result = client.create_checkout_session(payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#get_checkout_session' do
        let(:checkout_session_id) { 'checkoutSessionId' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::CHECKOUT_SESSION_URL}/#{checkout_session_id}",
                Constants::GET,
                headers: headers
            ).and_return(response)

            result = client.get_checkout_session(checkout_session_id, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#update_checkout_session' do
        let(:checkout_session_id) { 'checkoutSessionId' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::CHECKOUT_SESSION_URL}/#{checkout_session_id}",
                Constants::PATCH,
                payload: payload,
                headers: headers
            ).and_return(response)

            result = client.update_checkout_session(checkout_session_id, payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#complete_checkout_session' do
        let(:checkout_session_id) { 'checkoutSessionId' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::CHECKOUT_SESSION_URL}/#{checkout_session_id}/complete",
                Constants::POST,
                payload: payload,
                headers: headers
            ).and_return(response)

            result = client.complete_checkout_session(checkout_session_id, payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#finalize_checkout_session' do
        let(:checkout_session_id) { 'checkoutSessionId' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::CHECKOUT_SESSION_URL}/#{checkout_session_id}/finalize",
                Constants::POST,
                payload: payload,
                headers: headers
            ).and_return(response)

            result = client.finalize_checkout_session(checkout_session_id, payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#get_charge_permission' do
        let(:charge_permission_id) { 'chargePermissionId' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::CHARGE_PERMISSIONS_URL}/#{charge_permission_id}",
                Constants::GET,
                headers: headers
            ).and_return(response)

            result = client.get_charge_permission(charge_permission_id, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#update_charge_permission' do
        let(:charge_permission_id) { 'chargePermissionId' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::CHARGE_PERMISSIONS_URL}/#{charge_permission_id}",
                Constants::PATCH,
                payload: payload,
                headers: headers
            ).and_return(response)

            result = client.update_charge_permission(charge_permission_id, payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#close_charge_permission' do
        let(:charge_permission_id) { 'chargePermissionId' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::CHARGE_PERMISSIONS_URL}/#{charge_permission_id}/close",
                Constants::DELETE,
                payload: payload,
                headers: headers
            ).and_return(response)

            result = client.close_charge_permission(charge_permission_id, payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#create_charge' do
        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                Constants::CHARGES_URL,
                Constants::POST,
                payload: payload,
                headers: headers
            ).and_return(response)

            result = client.create_charge(payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#get_charge' do
        let(:charge_id) { 'chargeId' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::CHARGES_URL}/#{charge_id}",
                Constants::GET,
                headers: headers
            ).and_return(response)

            result = client.get_charge(charge_id, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#update_charge' do
        let(:charge_id) { 'chargeId' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::CHARGES_URL}/#{charge_id}",
                Constants::PATCH,
                payload: payload,
                headers: headers
                ).and_return(response)

            result = client.update_charge(charge_id, payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#capture_charge' do
        let(:charge_id) { 'chargeId' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::CHARGES_URL}/#{charge_id}/capture",
                Constants::POST,
                payload: payload,
                headers: headers
            ).and_return(response)

            result = client.capture_charge(charge_id, payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#cancel_charge' do
        let(:charge_id) { 'chargeId' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::CHARGES_URL}/#{charge_id}/cancel",
                Constants::DELETE,
                payload: payload,
                headers: headers
            ).and_return(response)

            result = client.cancel_charge(charge_id, payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#create_refund' do
        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                Constants::REFUNDS_URL,
                Constants::POST,
                payload: payload,
                headers: headers
            ).and_return(response)

            result = client.create_refund(payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#get_refund' do
        let(:refund_id) { 'refundId' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::REFUNDS_URL}/#{refund_id}",
                Constants::GET,
                headers: headers
            ).and_return(response)

            result = client.get_refund(refund_id, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#get_reports' do
        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                Constants::REPORTS,
                Constants::GET,
                headers: headers,
                query_params: query_params
            ).and_return(response)

            result = client.get_reports(headers: headers, query_params: query_params)
            expect(result).to eq(response)
        end
    end

    describe '#get_report_by_id' do
        let(:report_id) { 'reportId' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::REPORTS}/#{report_id}",
                Constants::GET,
                headers: headers
            ).and_return(response)

            result = client.get_report_by_id(report_id, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#create_report' do
        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                Constants::REPORTS,
                Constants::POST,
                payload: payload,
                headers: headers
            ).and_return(response)

            result = client.create_report(payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#get_report_document' do
        let(:report_document_id) { 'reportDocumentId' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::REPORT_DOCUMENTS}/#{report_document_id}",
                Constants::GET,
                headers: headers
            ).and_return(response)

            result = client.get_report_document(report_document_id, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#get_report_schedules' do
        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                Constants::REPORT_SCHEDULES,
                Constants::GET,
                headers: headers,
                query_params: query_params
            ).and_return(response)

            result = client.get_report_schedules(headers: headers, query_params: query_params)
            expect(result).to eq(response)
        end
    end

    describe '#get_report_schedule_by_id' do
        let(:report_schedule_id) { 'reportScheduleId' }

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::REPORT_SCHEDULES}/#{report_schedule_id}",
                Constants::GET,
                headers: headers
            ).and_return(response)

            result = client.get_report_schedule_by_id(report_schedule_id, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#create_report_schedule' do
        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
            Constants::REPORT_SCHEDULES,
            Constants::POST,
            payload: payload,
            headers: headers,
            query_params: query_params
            ).and_return(response)

            result = client.create_report_schedule(payload, headers: headers, query_params: query_params)
            expect(result).to eq(response)
        end
    end

    describe '#cancel_report_schedule' do
        let(:report_schedule_id) { 'reportScheduleId' }
        let(:response) { '200' }

        before do
            allow(client).to receive(:api_call).and_return(response)
        end

        it 'calls api_call with the correct parameters' do
            result = client.cancel_report_schedule(report_schedule_id, headers: headers)
            
            expect(client).to have_received(:api_call).with(
            "report-schedules/#{report_schedule_id}",
            "DELETE",
            headers: headers
            )
            
            expect(result).to eq(response)
        end
    end

end