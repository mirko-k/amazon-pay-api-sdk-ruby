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
    "beneficiaryOwners": [
        {
            "personId": "BO1",
            "personFullName": "ABC ABC",
            "residentialAddress": {
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
        },
        {
            "personId": "BO2",
            "personFullName": "ABC ABC",
            "residentialAddress": {
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
            "state": "Active",
            "reasonCode": nil
        }
    },
    "merchantStatus": {
        "statusProvider": "ABC",
        "state": "ACTIVE",
        "reasonCode": nil
    }
}

createMerchantAccountHeader = {
    "x-amz-pay-Idempotency-Key": "idempotency-key"
}

response = client.create_merchant_account(createMerchantAccountPayload, headers: createMerchantAccountHeader)
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

updateMerchantAccountHeader = {}

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
if response.code.to_i == 303
    puts "Merchant Account Claim API Response:"
    puts response.body
else
    puts "Error: Merchant Account Claim API"
    puts "Status: #{response.code}"
    puts response.body
end
```