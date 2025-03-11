#### Version 2.0.0 - March 2025
- Introducing new v2 Dispute APIs for PSPs (Payment Service Provider). Buyers can create a dispute by filing an Amazon Pay A-to-z Guarantee claim or by filing a chargeback with their bank.
- The `createDispute` API is used to notify Amazon of a newly created chargeback dispute by a buyer on a transaction processed by the PSP (Payment Service Provider), ensuring the dispute is properly accounted for in the Amazon Pay systems.
- The `updateDispute` API is used to notify Amazon of the closure status of a chargeback dispute initiated by a buyer for orders processed by a partner PSP (Payment Service Provider), ensuring proper accounting within the Amazon systems.
- The `contestDispute` API is used by the partner, on behalf of the merchant, to formally contest a dispute managed by Amazon, requiring the submission of necessary evidence files within the specified Dispute Window (11 days for Chargeback, 7 days for A-Z Claims).
- The `uploadFile` API is utilised by PSPs (Payment Service Provider) to upload file-based evidence when a merchant contests a dispute, providing the necessary reference ID to the evidence file as part of the Update Dispute API process.
- Introducing the `updateCharge` API which enables you to update the charge status of any PSP (Payment Service Provider) processed payment method (PPM) transactions.
- Changing the directory name from `amazon_pay` to `amazon-pay-api-sdk-ruby` in order to make consistent with Gem name.
- Moved rspec to development dependency in gemspec
**Notice:** Those who may upgrade from 1.x.x to 2.0.0 or higher: You must change the require statement from: `require './lib/amazon_pay'` to `require './lib/amazon-pay-api-sdk-ruby'` or `require 'amazon_pay'` to `require 'amazon-pay-api-sdk-ruby'`

#### Version 1.2.0 - September 2024
- Added APIs for Reports.
- Included a README file with sample code for each API.

#### Version 1.1.0 - August 2024
- Added APIs for Buyer, CheckoutSession, ChargePermission, Charge, and Refund.
- Implemented a utility for generating button signatures.
- Included a README file with sample code for each API.

#### Version 1.0.0 - August 2024
Initial release with the following features:
- Amazon Pay Ruby SDK for accessing Amazon Pay APIs
- Required API headers for Amazon Pay integrations
- Added Account Management APIs for: Creating Merchant Account, Updating Merchant Account, Claiming Merchant Account
- Environment-specific public key handling logic
- API retry mechanism for status codes: 408, 429, 500, 502, 503, 504