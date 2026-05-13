import LegalLayout from "@/components/LegalLayout";

export const metadata = {
  title: "Terms of Service",
  description: "Read the terms and conditions for using the PayGidi platform.",
};

export default function TermsPage() {
  return (
    <LegalLayout title="Terms of Service" lastUpdated="May 13, 2026">
      <section>
        <h2 className="text-2xl font-bold text-black mb-4">1. Agreement to Terms</h2>
        <p>
          By accessing or using PayGidi, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, 
          then you may not access the service.
        </p>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-black mb-4">2. Account Registration</h2>
        <p>
          To use certain features of the Service, you must register for an account. You must provide accurate and 
          complete information and keep your account information updated. You are responsible for maintaining 
          the confidentiality of your account and password.
        </p>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-black mb-4">3. Use of the Service</h2>
        <p>
          You may use the Service only for lawful purposes and in accordance with these Terms. You agree not to:
        </p>
        <ul className="list-disc pl-6 mt-4 space-y-2 text-zinc-600">
          <li>Use the Service in any way that violates any applicable local or international law.</li>
          <li>Engage in any conduct that restricts or inhibits anyone's use or enjoyment of the Service.</li>
          <li>Attempt to gain unauthorized access to any part of the Service or its related systems.</li>
        </ul>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-black mb-4">4. Payment Processing</h2>
        <p>
          PayGidi facilitates payments between users. We are not a bank and do not hold deposits. All financial 
          transactions are processed through our partner financial institutions and payment gateways.
        </p>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-black mb-4">5. Termination</h2>
        <p>
          We may terminate or suspend your account and bar access to the Service immediately, without prior notice 
          or liability, under our sole discretion, for any reason whatsoever and without limitation, including 
          but not limited to a breach of the Terms.
        </p>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-black mb-4">6. Limitation of Liability</h2>
        <p>
          In no event shall PayGidi, nor its directors, employees, partners, agents, suppliers, or affiliates, 
          be liable for any indirect, incidental, special, consequential or punitive damages, including without 
          limitation, loss of profits, data, use, goodwill, or other intangible losses.
        </p>
      </section>
    </LegalLayout>
  );
}
