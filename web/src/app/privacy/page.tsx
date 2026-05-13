import LegalLayout from "@/components/LegalLayout";

export const metadata = {
  title: "Privacy Policy",
  description: "Learn how PayGidi protects your personal information and privacy.",
};

export default function PrivacyPage() {
  return (
    <LegalLayout title="Privacy Policy" lastUpdated="May 13, 2026">
      <section>
        <h2 className="text-2xl font-bold text-black mb-4">1. Introduction</h2>
        <p>
          Welcome to PayGidi. We are committed to protecting your personal information and your right to privacy. 
          If you have any questions or concerns about our policy, or our practices with regards to your personal 
          information, please contact us at privacy@paygidi.com.
        </p>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-black mb-4">2. Information We Collect</h2>
        <p>
          We collect personal information that you provide to us such as name, address, contact information, 
          passwords and security data, and payment information.
        </p>
        <ul className="list-disc pl-6 mt-4 space-y-2 text-zinc-600">
          <li>Personal Identification Information (Name, email address, phone number, etc.)</li>
          <li>Financial Information (Bank account details, transaction history)</li>
          <li>Device and Usage Data (IP address, browser type, operating system)</li>
        </ul>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-black mb-4">3. How We Use Your Information</h2>
        <p>
          We use personal information collected via our Services for a variety of business purposes described below. 
          We process your personal information for these purposes in reliance on our legitimate business interests, 
          in order to enter into or perform a contract with you, with your consent, and/or for compliance with our 
          legal obligations.
        </p>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-black mb-4">4. Sharing Your Information</h2>
        <p>
          We only share information with your consent, to comply with laws, to provide you with services, 
          to protect your rights, or to fulfill business obligations.
        </p>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-black mb-4">5. Your Privacy Rights</h2>
        <p>
          In some regions, such as the European Economic Area (EEA) and United Kingdom (UK), you have rights 
          that allow you greater access to and control over your personal information. You may review, change, 
          or terminate your account at any time.
        </p>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-black mb-4">6. Contact Us</h2>
        <p>
          If you have questions or comments about this policy, you may email us at privacy@paygidi.com or by post to:
          PayGidi Technologies, Victoria Island, Lagos, Nigeria.
        </p>
      </section>
    </LegalLayout>
  );
}
