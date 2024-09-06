## Amazon Pay Ruby SDK Usage

This guide provides step-by-step instructions on how to use the Amazon Pay Client for creating and updating merchant accounts, as well as claiming merchant accounts.


### Prerequisites

- Ruby installed on your system.
- `amazon-pay-api-sdk-ruby` gem installed or this source code has been imported in your project.
- Your `publicKeyId` & `privateKey.pem` file available.

### Install
```
gem install amazon-pay-api-sdk-ruby
```
or add the following in your Gemfile:

```ruby
gem 'amazon-pay-api-sdk-ruby'
```
```
bundle install
```

### Configuration

Create a configuration with your Amazon Pay credentials and region:

```ruby
config = {
  region: 'jp', # Supported Values: na, eu, jp
  public_key_id: 'PUBLIC_KEY_ID',
  private_key: File.read('privateKey.pem'),
  sandbox: true # Optional. Set this paramter true/false if your public_key_id does not have an environment prefix (does not begin with 'SANDBOX' or 'LIVE')
}
```

### Initialize the Amazon Pay Client:

```ruby
client = AmazonPayClient.new(config)
```


### Create Merchant Account

Define the payload and headers for the `create_merchant_account` API call:

```ruby
require './lib/amazon_pay'

client = AmazonPayClient.new(config)

createMerchantAccountPayload = {
    "uniqueReferenceId": "XXXXX",
    "ledgerCurrency": "JPY",
    "businessInfo": {
        "email": "abc@abc.com",
        "businessType": "CORPORATE",
        "businessLegalName": "Legal Name",
        "businessCategory": "Beauty",
        "businessAddress": {
            "addressLine1": "122, ABC XYZ",
            "addressLine2": "XYZ",
            "city": "XYZ",
            "stateOrRegion": "XYZ",
            "postalCode": "123456",
            "countryCode": "JP",
            "phoneNumber": {
                "countryCode": "123",
                "number": "1234567890"
            }
        },
        "businessDisplayName": "Business Name",
        "annualSalesVolume": {
            "amount": "100000",
            "currencyCode": "JPY"
        },
        "countryOfEstablishment": "JP",
        "customerSupportInformation": {
            "customerSupportEmail": "merchant@abc.com",
            "customerSupportPhoneNumber": {
                "countryCode": "1",
                "number": "1234567",
                "extension": "123"
            }
        }
    },
     "beneficiaryOwners": [{
            "personFullName": "Rufus Rufus",
            "residentialAddress": {
                "addressLine1": "4-7, Sunny Mansion 203",
                "addressLine2": "Boren Ave",
                "city": "Chiryushi",
                "stateOrRegion": "AICHI",
                "postalCode": "4720021",
                "countryCode": "JP",
                "phoneNumber": {
                    "countryCode": "81",
                    "number": "2062062061"
                }
            }
        }
    ],
    "primaryContactPerson": {
        "personFullName": "ABC ABC"
    },
    "integrationInfo": {
        "ipnEndpointUrls": [
            "https://website.com/ipnendpoint", "https://website.com/ipnendpoint"
        ]
    },
    "defaultStore": {
        "domainUrls": [
            "http://www.abc.com"
        ],
        "storeName": "ABC ABC",
        "privacyPolicyUrl": "http://www.abc.com/privacy",
        "storeStatus": {
            "state": "ACTIVE",
            "reasonCode": nil
        }
    },
    "merchantStatus": {
        "statusProvider": "ABC",
        "state": "ACTIVE",
        "reasonCode": nil
    }
}

response = client.create_merchant_account(createMerchantAccountPayload, headers: {})
if response.code.to_i == 201 || response.code.to_i == 200
    puts "Create Merchant Account API Response:"
    puts response.body
else
    puts "Error: Create Merchant Account API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Update Merchant Account

Define the payload and headers for the `update_merchant_account` API call:

```ruby
updateMerchantAccountPayload = {
    "businessInfo": {
      "businessAddress": {
        "addressLine1": "122, ABC XYZ",
        "addressLine2": "XYZ",
        "city": "XYZ",
        "stateOrRegion": "XYZ",
        "postalCode": "123456",
        "countryCode": "JP",
        "phoneNumber": {
            "countryCode": "123",
            "number": "2062062061"
        }
      }
    }
}

updateMerchantAccountHeader = {
    "x-amz-pay-authToken" : "AUTH_TOKEN"
}

response = client.update_merchant_account('XXXXXXXXX', updateMerchantAccountPayload, headers: updateMerchantAccountHeader)
if response.code.to_i == 200
    puts "Update Merchant Account API Response:"
    puts response.body
else
    puts "Error: Update Merchant Account API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Merchant Account Claim

Define the payload and headers for the `merchant_account_claim` API call:

```ruby

merchantAccountClaimPayload = {
    "uniqueReferenceId": "XXXXXX"
}

response = client.merchant_account_claim('XXXXXXXXX', merchantAccountClaimPayload, headers: {})
if response.code.to_i == 303 || response.code.to_i == 200
    puts "Merchant Account Claim API Response:"
    puts response.body
    puts "Headers:"
    puts response.to_hash.to_json
else
    puts "Error: Merchant Account Claim API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Generate Button Signature

```ruby
def button_payload = {
    "webCheckoutDetails": {
        "checkoutReviewReturnUrl": "https://a.com/merchant-review-page"
    },
    "storeId": "amzn1.application-oa2-client.xxxxxxxxxxxx",
    "scopes": ["name", "email", "phoneNumber", "billingAddress"],
    "deliverySpecifications": {
        "specialRestrictions": ["RestrictPOBoxes"],
        "addressRestrictions": {
            "type": "Allowed",
            "restrictions": {
                "US": {
                    "statesOrRegions": ["WA"],
                    "zipCodes": ["95050", "93405"]
                },
                "GB": {
                    "zipCodes": ["72046", "72047"]
                },
                "IN": {
                    "statesOrRegions": ["AP"]
                },
                "JP": {}
            }
        }
    }
}  

response = client.generate_button_signature(button_payload)
puts "Button Signature:"
puts response
```

### Get Buyer

```ruby
response = client.get_buyer('BUYER_TOKEN', headers: {})
if response.code.to_i == 200
    puts "Get Buyer API Response:"
    puts response.body
else
    puts "Error: Get Buyer API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Create Checkout Session

```ruby
require 'securerandom'

def createCheckoutSessionPayload = {
    "webCheckoutDetails": {
        "checkoutReviewReturnUrl": "https://a.com/merchant-review-page"
    },
    "storeId": "amzn1.application-oa2-client.xxxxxxxxxxxxx",
    "scopes": ["name", "email", "phoneNumber", "billingAddress"],
    "deliverySpecifications": {
        "specialRestrictions": ["RestrictPOBoxes"],
        "addressRestrictions": {
            "type": "Allowed",
            "restrictions": {
                "US": {
                    "statesOrRegions": ["WA"],
                    "zipCodes": ["95050", "93405"]
                },
                "GB": {
                    "zipCodes": ["72046", "72047"]
                },
                "IN": {
                    "statesOrRegions": ["AP"]
                },
                "JP": {}
            }
        }
    }
}

def create_checkout_session_header = {
    "x-amz-pay-Idempotency-Key": SecureRandom.uuid
}

response = client.create_checkout_session(createCheckoutSessionPayload, headers: create_checkout_session_header)
if response.code.to_i == 201 || response.code.to_i == 200
    puts "Create Checkout Session API Response:"
    puts response.body
else
    puts "Error: Create Checkout Session API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Get Checkout Session

```ruby
response = client.get_checkout_session("checkout_session_id", headers: {})
if response.code.to_i == 200
    puts "Get Checkout Session API Response:"
    puts response.body
else
    puts "Error: Get Checkout Session API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Update Checkout Session

```ruby
def update_checkout_session_payload = {
    "paymentDetails": {
        "paymentIntent": "AuthorizeWithCapture",
        "canHandlePendingAuthorization":false,
        "softDescriptor": "Descriptor",
        "chargeAmount": {
            "amount": "1",
            "currencyCode": "USD"
        }
     },
    "merchantMetadata": {
        "merchantReferenceId": "Merchant reference ID",
        "merchantStoreName": "Merchant store name",
        "noteToBuyer": "Note to buyer",
        "customInformation": "Custom information"
    }
}

response = client.update_checkout_session("checkout_session_id", update_checkout_session_payload, headers: {})
if response.code.to_i == 200
    puts "Update Checkout Session API Response:"
    puts response.body
else
    puts "Error: Update Checkout Session API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Complete Checkout Session

```ruby
def complete_checkout_session_payload = {
    "chargeAmount": {
        "amount": "10.00",
        "currencyCode": "USD"
    }
}

response = client.complete_checkout_session("checkout_session_id", complete_checkout_session_payload, headers: {})
if response.code.to_i == 200
    puts "Complete Checkout Session API Response:"
    puts response.body
else
    puts "Error: Complete Checkout Session API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Finalize Checkout Session

```ruby
def finalize_checkout_session_payload = {
    "shippingAddress": {
        "name": "Susy S",
        "addressLine1": "11 Ditka Ave",
        "addressLine2": "Suite 2500",
        "city": "Chicago",
        "county": nil,
        "district": nil,
        "stateOrRegion": "IL",
        "postalCode": "60602",
        "countryCode": "US",
        "phoneNumber": "800-000-0000"
    },
    "billingAddress": {
        "name": "Susy S",
        "addressLine1": "11 Ditka Ave",
        "addressLine2": "Suite 2500",
        "city": "Chicago",
        "county": null,
        "district": null,
        "stateOrRegion": "IL",
        "postalCode": "60602",
        "countryCode": "US",
        "phoneNumber": "800-000-0000"
    },
    "chargeAmount": {
        "amount": "10",
        "currencyCode": "USD"
    },
    "paymentIntent": "Confirm"
}

response = client.finalize_checkout_session("checkout_session_id", finalize_checkout_session_payload, headers: {})
if response.code.to_i == 200 || response.code.to_i == 202
    puts "Finalize Checkout Session API Response:"
    puts response.body
else
    puts "Error: Finalize Checkout Session API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Get Charge Permission

```ruby
response = client.get_charge_permission("charge_permission_id", headers: {})
if response.code.to_i == 200
    puts "Get Charge Permission API Response:"
    puts response.body
else
    puts "Error: Get Charge Permission API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Update Charge Permission

```ruby
def update_charge_permission_payload = {
    "merchantMetadata": {
        "merchantReferenceId": "32-41-323141-32",
        "merchantStoreName": "ShangameshestStoreFront",
        "noteToBuyer": "Some Note to buyer",
        "customInformation": ""    
     }  
}

response = client.update_charge_permission("charge_permission_id", update_charge_permission_payload, headers: {})
if response.code.to_i == 200
    puts "Update Charge Permission API Response:"
    puts response.body
else
    puts "Error: Update Charge Permission API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Close Charge Permission

```ruby
def close_charge_permission = {
    "closureReason": "No more charges required for Store",
    "cancelPendingCharges": false
}

response = client.close_charge_permission("charge_permission_id", close_charge_permission, headers: {})
if response.code.to_i == 200
    puts "Close Charge Permission API Response:"
    puts response.body
else
    puts "Error: Close Charge Permission API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Create Charge

```ruby
require 'securerandom'

def create_charge_payload = {
    "chargePermissionId": "S01-XXXXXX-XXXXXX",
    "chargeAmount": {
        "amount": "10.00",
        "currencyCode": "USD"
    },
    "captureNow": true, 
    "softDescriptor": "Descriptor",
    "canHandlePendingAuthorization": false 
}

def create_charge_header = {
    "x-amz-pay-Idempotency-Key": SecureRandom.uuid
}

response = client.create_charge(create_charge_payload, headers: create_charge_header)
if response.code.to_i == 201 || response.code.to_i == 200
    puts "Create Charge Response:"
    puts response.body
else
    puts "Error: Create Charge API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Get Charge

```ruby
response = client.get_charge('S01-XXXXXX-XXXXXX-XXXXXX', headers: {})
if response.code.to_i == 200
    puts "Get Charge Response:"
    puts response.body
else
    puts "Error: Get Charge API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Capture Charge

```ruby
require 'securerandom'

def capture_charge_payload = {
    "captureAmount": {
        "amount": "1.00",
        "currencyCode": "USD"
    },
    "softDescriptor": "Descriptor"
}

def capture_charge_header = {
    "x-amz-pay-Idempotency-Key": SecureRandom.uuid
}

response = client.capture_charge('S01-XXXXXX-XXXXXX-XXXXXX', capture_charge_payload, headers: capture_charge_header)
if response.code.to_i == 200
    puts "Capture Charge Response:"
    puts response.body
else
    puts "Error: Capture Charge API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Cancel Charge

```ruby
def cancel_charge_payload = {
    "cancellationReason": "Charge Cancellation Reason"
}

response = client.cancel_charge('S01-XXXXXX-XXXXXX-XXXXXX', cancel_charge_payload, headers: {})
if response.code.to_i == 200
    puts "Cancel Charge Response:"
    puts response.body
else
    puts "Error: Cancel Charge API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Create Refund

```ruby
def create_refund_payload = {
    "chargeId": "S01-XXXXXX-XXXXXX-XXXXXX",
    "refundAmount": {
        "amount": "1.00",
        "currencyCode": "USD"
    },
    "softDescriptor": "Descriptor"
}

def create_refund_header = {
    "x-amz-pay-Idempotency-Key": SecureRandom.uuid
}

response = client.create_refund(create_refund_payload, headers: create_refund_header)
if response.code.to_i == 201 || response.code.to_i == 200
    puts "Create Refund Response:"
    puts response.body
else
    puts "Error: Create Refund API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Get Refund

```ruby
response = client.get_refund('S01-XXXXXX-XXXXXX-XXXXXX', headers: {})
if response.code.to_i == 200
    puts "Get Refund Response:"
    puts response.body
else
    puts "Error: Get Refund API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Get Reports

```ruby
response = client.get_reports(query_params: {})
if response.code.to_i == 200
    puts "Get Reports Response:"
    puts response.body
else
    puts "Error: Get Reports API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Get Report By Id

```ruby
def report_id = "123456789"
response = client.get_report_by_id(report_id, headers: {})
if response.code.to_i == 200
    puts "Get Report By Id Response:"
    puts response.body
else
    puts "Error: Get Report By Id API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Create Report

```ruby
def create_report_payload = {
    "reportType": "_GET_FLAT_FILE_OFFAMAZONPAYMENTS_SANDBOX_SETTLEMENT_DATA_",
    "startTime": "20240810T000000Z",
    "endTime": "20240815T000000Z"
}
response = client.create_report(create_report_payload, headers: {"x-amz-pay-Idempotency-Key": SecureRandom.uuid})
if response.code.to_i == 201
    puts "Create Report Response:"
    puts response.body
else
    puts "Error: Create Report API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Get Report Document


```ruby
def report_document_id = "123456789"
response = client.get_report_document(report_document_id, headers: {})
if response.code.to_i == 200
    puts "Get Report Document Response:"
    puts response.body
else
    puts "Error: Get Report Document API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Get Report Schedules

```ruby
def query_params = {
    "reportType": "_GET_FLAT_FILE_OFFAMAZONPAYMENTS_SANDBOX_SETTLEMENT_DATA_",
}
response = client.get_report_schedules(query_params: query_params, headers: {})
if response.code.to_i == 200
    puts "Get Report Schedules Response:"
    puts response.body
else
    puts "Error: Get Report Schedules API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Get Report Schedule By ID

```ruby
def report_schedule_id = "123456789"
response = client.get_report_schedule_by_id(report_schedule_id, headers: {})
if response.code.to_i == 200
    puts "Get Report Schedule By ID Response:"
    puts response.body
else
    puts "Error: Get Report Schedule By ID API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Create Report Schedule

```ruby
def create_report_schdule_payload = {
    "reportType": "_GET_FLAT_FILE_OFFAMAZONPAYMENTS_SANDBOX_SETTLEMENT_DATA_",
    "scheduleFrequency": "P1D",
    "nextReportCreationTime": "20241001T000000Z"
}
response = client.create_report_schedule(create_report_schdule_payload, headers: {"x-amz-pay-Idempotency-Key": SecureRandom.uuid}, query_params: {})
if response.code.to_i == 201
    puts "Create Report Schedule Response:"
    puts response.body
else
    puts "Error: Create Report Schedule API"
    puts "Status: #{response.code}"
    puts response.body
end
```

#### Cancel Report Schedule

```ruby
def report_schedule_id = "123456789"
response = client.cancel_report_schedule(report_schedule_id, headers: {})
if response.code.to_i == 200
    puts "Cancel Report Schedule Schedule Response:"
    puts response.body
else
    puts "Error: Cancel Report Schedule Schedule API"
    puts "Status: #{response.code}"
    puts response.body
end
```

### Get Disbursements

```ruby
def query_params = {
    "startTime": '20240810T000000Z',
    "endTime": '20240815T000000Z'
    "pageSize": "30",
    "nextToken": ""
}
response = client.get_disbursements(query_params: {}, headers: {})
if response.code.to_i == 200
    puts "Get Disbursements Response:"
    puts response.body
else
    puts "Error: Get Disbursements API"
    puts "Status: #{response.code}"
    puts response.body
end
```