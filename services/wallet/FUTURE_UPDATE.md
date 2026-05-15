# Future Updates: PayGidi V2 Payment Endpoint

## V2 Automated Outreach Integration

In a future `v2` update, the payment processing system will integrate an automated intelligent agent layer for advanced KYB (Know Your Business) verification and onboarding.

### Current Flow (V1)
Currently, when a payment is created via `POST /wallet/payments/new`, the funds are locked and a notification email is sent to the merchant's provided email address. This email contains a static frontend link (`https://kyb.paygidi.com/...`) which takes the merchant to a standard web form to complete their KYB before the AI service kicks in to verify them.

### Planned Flow (V2)
In the upcoming `/v2/wallet/payments/new` endpoint, we will shift to a frictionless, conversational KYB approach:

1. **Omnichannel Messaging Agent:**
   Instead of just dispatching a generic email, the PayGidi system will employ an automated AI agent to immediately contact the business via their active social channels or messaging apps (e.g., **WhatsApp**, **Instagram DM**, or **X (Twitter)**).
   
2. **Conversational KYB:**
   The AI agent will proactively message the vendor stating: 
   *"Hello [Merchant Name], you have a pending locked payment of [Amount] on PayGidi. Please provide your business documents to release the funds."*
   The merchant can then upload documents or provide details directly within WhatsApp, Instagram, or X. 

3. **Seamless Verification Pipeline:**
   The AI agent streams the received documents and responses directly to our internal AI analysis pipeline. Once the trust score reaches an acceptable threshold, the funds are automatically disbursed or sent to the user for final approval.

This dramatically lowers the friction of onboarding, captures vendors exactly where they are already conducting business, and leverages our AI trust layer dynamically.
