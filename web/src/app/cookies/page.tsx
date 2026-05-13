import LegalLayout from "@/components/LegalLayout";

export const metadata = {
  title: "Cookie Policy",
  description: "Learn how PayGidi uses cookies and similar technologies to improve your experience.",
};

export default function CookiePolicyPage() {
  return (
    <LegalLayout title="Cookie Policy" lastUpdated="May 13, 2026">
      <section>
        <h2 className="text-2xl font-bold text-black mb-4">1. What Are Cookies?</h2>
        <div className="text-zinc-600">
          Cookies are small text files that are placed on your computer or mobile device when you visit a website. 
          They are widely used to make websites work, or work more efficiently, as well as to provide reporting 
          information and assist with personalization.
        </div>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-black mb-4">2. Why We Use Cookies</h2>
        <div className="text-zinc-600">
          We use cookies for several reasons. Some cookies are required for technical reasons in order for our 
          website to operate. These are "essential" or "strictly necessary" cookies. Other cookies enable us 
          to track and target the interests of our users to enhance the experience on our online properties.
        </div>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-black mb-4">3. Types of Cookies We Use</h2>
        <ul className="list-disc pl-6 mt-4 space-y-4 text-zinc-600">
          <li>
            <strong>Essential Cookies:</strong> Necessary to provide you with services available through our website 
            and to use some of its features, such as access to secure areas.
          </li>
          <li>
            <strong>Performance and Functionality Cookies:</strong> Used to enhance the performance and functionality 
            of our website but are non-essential to their use.
          </li>
          <li>
            <strong>Analytics and Customization Cookies:</strong> Collect information that is used either in aggregate 
            form to help us understand how our website is being used or how effective our marketing campaigns are.
          </li>
        </ul>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-black mb-4">4. Managing Cookies</h2>
        <div className="text-zinc-600">
          You have the right to decide whether to accept or reject cookies. You can set or amend your web browser 
          controls to accept or refuse cookies. If you choose to reject cookies, you may still use our website 
          though your access to some functionality and areas of our website may be restricted.
        </div>
      </section>

      <section>
        <h2 className="text-2xl font-bold text-black mb-4">5. Updates to This Policy</h2>
        <div className="text-zinc-600">
          We may update this Cookie Policy from time to time in order to reflect, for example, changes to the 
          cookies we use or for other operational, legal or regulatory reasons. Please therefore re-visit this 
          Cookie Policy regularly to stay informed about our use of cookies and related technologies.
        </div>
      </section>
    </LegalLayout>
  );
}
