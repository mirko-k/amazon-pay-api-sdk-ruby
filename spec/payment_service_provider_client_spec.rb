require 'rspec'
require_relative '../lib/amazon_pay/payment_service_provider_client'
require_relative 'shared_config'

RSpec.describe PaymentServiceProviderClient do
    include SharedConfig

    let(:config) { default_config(SpecConstants::JP) }  
    let(:client) { AmazonPayClient.new(config) }
    let(:payload) { SpecConstants::PAYLOAD }
    let(:headers) { SpecConstants::CUSTOM_HEADERS_JSON }
    let(:dispute_id) { 'dispute_id' }
    let(:response) { instance_double(Net::HTTPResponse) }

    describe '#create_dispute' do
        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                Constants::DISPUTE_URLS,
                Constants::POST,
                payload: payload,
                headers: headers
            ).and_return(response)

            result = client.create_dispute(payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#update_dispute' do

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::DISPUTE_URLS}/#{dispute_id}",
                Constants::PATCH,
                payload: payload,
                headers: headers
            ).and_return(response)

            result = client.update_dispute(dispute_id, payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#contest_dispute' do

        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                "#{Constants::DISPUTE_URLS}/#{dispute_id}/contest",
                Constants::POST,
                payload: payload,
                headers: headers
            ).and_return(response)

            result = client.contest_dispute(dispute_id, payload, headers: headers)
            expect(result).to eq(response)
        end
    end

    describe '#upload_file' do
        it 'calls api_call with the correct parameters' do
            expect(client).to receive(:api_call).with(
                Constants::FILES_URLS,
                Constants::POST,
                payload: payload,
                headers: headers
            ).and_return(response)

            result = client.upload_file(payload, headers: headers)
            expect(result).to eq(response)
        end
    end
end
