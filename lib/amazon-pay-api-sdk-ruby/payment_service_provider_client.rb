module PaymentServiceProviderClient
    # API to create dispute. 
    # The createDispute operation is used to notify Amazon of a newly created chargeback dispute by a buyer on a
    # transaction processed by the PSP (Payment Service Provider), ensuring the dispute is properly accounted for in the Amazon Pay systems.
    # @see https://developer.amazon.com/docs/amazon-pay-apis/dispute.html/#create-dispute
    # @param {Object} payload - The payload containing statusDetails.
    # @param {Object} headers - Requires : x-amz-pay-idempotency-key, Optional headers for the request, such as authorization tokens or custom headers.
    # @return [HTTPResponse] The response from the API call, which includes details of the dispute.
    def create_dispute(payload, headers: {});    
        api_call(Constants::DISPUTE_URLS, Constants::POST, payload: payload, headers: headers)
    end

    # API to update dispute. 
    # The updateDispute operation is used to notify Amazon of the closure status of a chargeback dispute initiated by a
    # buyer for orders processed by a partner PSP (Payment Service Provider), ensuring proper accounting within the Amazon systems.
    # @see https://developer.amazon.com/docs/amazon-pay-apis/dispute.html/#update-dispute
    # @param {String} dispute_id - The unique ID of the dispute to retrieve.
    # @param {Object} payload - The payload containing statusDetails.
    # @param {Object} headers - Optional headers for the request, such as x-amz-pay-idempotency-key, authorization tokens or custom headers.
    # @return [HTTPResponse] The response from the API call, which includes details of the dispute.
    def update_dispute(dispute_id, payload, headers: {});    
        api_call("#{Constants::DISPUTE_URLS}/#{dispute_id}", Constants::PATCH, payload: payload, headers: headers)
    end

    # API to contest dispute.
    # The contestDispute operation is used by the partner, on behalf of the merchant, to formally contest a dispute
    # managed by Amazon, requiring the submission of necessary evidence files within the specified
    # Dispute Window (11 days for Chargeback, 7 days for A-Z Claims).
    # @see https://developer.amazon.com/docs/amazon-pay-apis/dispute.html/#contest-dispute
    # @param {String} dispute_id - The unique ID of the dispute to retrieve.
    # @param {Object} payload - The payload containing statusDetails.
    # @param {Object} headers - Optional headers for the request, such as x-amz-pay-idempotency-key, authorization tokens or custom headers.
    # @return [HTTPResponse] The response from the API call, which includes details of the dispute.
    def contest_dispute(dispute_id, payload, headers: {});    
        api_call("#{Constants::DISPUTE_URLS}/#{dispute_id}/contest", Constants::POST, payload: payload, headers: headers)
    end

    # API to upload file.
    # The uploadFile operation is utilised by PSPs (Payment Service Provider) to upload file-based evidence when a
    # merchant contests a dispute, providing the necessary reference ID to the evidence file as part of
    # the Update Dispute API process.
    # @see https://developer.amazon.com/docs/amazon-pay-apis/file.html#upload-a-file
    # @param {Object} headers - Requires : x-amz-pay-idempotency-key, Optional headers for the request, such as authorization tokens or custom headers.
    # @return [HTTPResponse] The response from the API call, which includes details of the file.
    def upload_file(payload, headers: {});    
        api_call(Constants::FILES_URLS, Constants::POST, payload: payload, headers: headers)
    end
end  