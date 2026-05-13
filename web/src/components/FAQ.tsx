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
    question: "How does the AI-powered escrow work?",
    answer: "PayGidi holds your funds in a secure escrow account when you initiate a purchase. The money is only released to the merchant once you confirm receipt of the goods or services, or when our AI trust engine verifies a successful delivery."
  },
  {
    question: "What is the PayGidi Trust Score?",
    answer: "The Trust Score is a dynamic rating assigned to every merchant based on their transaction history, delivery speed, dispute rates, and KYB verification status. High-scoring merchants benefit from faster payouts."
  },
  {
    question: "How do you verify merchants?",
    answer: "We perform rigorous Know Your Business (KYB) checks, including legal registration verification, physical address confirmation, and historical performance analysis to ensure you only deal with legitimate businesses."
  },
  {
    question: "What happens if there's a dispute?",
    answer: "Our automated dispute resolution system analyzes delivery evidence and transaction data to reach a fair conclusion quickly. Both buyers and sellers are protected by our transparent escrow rules."
  },
  {
    question: "Can I integrate PayGidi into my own store?",
    answer: "Yes! We provide robust, developer-friendly APIs that allow you to add an escrow trust layer to your custom e-commerce platform or mobile app with just a few lines of code."
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
