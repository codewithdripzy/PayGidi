"use client";

import { useState } from "react";
import { motion, Variants } from "framer-motion";

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1
    }
  }
};

const itemVariants: Variants = {
  hidden: { opacity: 0, y: 20 },
  visible: { 
    opacity: 1, 
    y: 0,
    transition: {
      duration: 0.5,
      ease: "easeOut"
    }
  }
};

const faqs = [
  {
    question: "How do I open a PayGidi account?",
    answer: "Opening an account is easy and takes less than 3 minutes. Just download the app or click 'Get Started', fill in your details, and verify your identity with your BVN or NIN."
  },
  {
    question: "Is PayGidi secure?",
    answer: "Yes, PayGidi is powered by Squad (a GTCO company) and uses bank-grade encryption to ensure your money is always safe. We are fully licensed and regulated."
  },
  {
    question: "How do Virtual Dollar Cards work?",
    answer: "Our virtual cards allow you to pay for global services like Netflix, Apple Music, and Amazon. You can create a card instantly and fund it from your Naira wallet at competitive rates."
  },
  {
    question: "What are the transaction fees?",
    answer: "We believe in transparency. Basic transfers are incredibly cheap, and there are zero maintenance fees on your wallet. You'll always see the exact fee before you confirm any transaction."
  },
  {
    question: "How do I contact support?",
    answer: "Our support team is available 24/7. You can reach us via the in-app chat, email at hello@paygidi.com, or call us directly for urgent matters."
  }
];

export default function FAQ() {
  const [openIndex, setOpenIndex] = useState<number | null>(null);

  return (
    <section id="faq" className="py-24 bg-white">
      <div className="max-w-3xl mx-auto px-6">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-bold text-black mb-4">Questions? We've got Answers</h2>
          <p className="text-zinc-500">Everything you need to know about PayGidi.</p>
        </div>

        <motion.div 
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
          className="space-y-4"
        >
          {faqs.map((faq, index) => (
            <motion.div 
              key={index} 
              variants={itemVariants}
              className="border border-zinc-100 rounded-2xl overflow-hidden transition-all duration-200"
            >
              <button
                onClick={() => setOpenIndex(openIndex === index ? null : index)}
                className="w-full flex items-center justify-between p-6 text-left hover:bg-zinc-50 transition-colors"
              >
                <span className="font-semibold text-black">{faq.question}</span>
                <span className={`transform transition-transform duration-200 ${openIndex === index ? "rotate-180" : ""}`}>
                  <svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M5 7.5L10 12.5L15 7.5" stroke="#454545" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                  </svg>
                </span>
              </button>
              <div 
                className={`overflow-hidden transition-all duration-300 ease-in-out ${
                  openIndex === index ? "max-h-96 opacity-100" : "max-h-0 opacity-0"
                }`}
              >
                <div className="p-6 pt-4 text-zinc-600 leading-relaxed text-[15px]">
                  {faq.answer}
                </div>
              </div>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}
