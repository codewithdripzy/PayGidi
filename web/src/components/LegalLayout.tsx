"use client";

import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import Link from "next/link";
import { motion } from "framer-motion";

interface LegalLayoutProps {
  title: string;
  lastUpdated: string;
  children: React.ReactNode;
}

export default function LegalLayout({ title, lastUpdated, children }: LegalLayoutProps) {
  return (
    <div className="min-h-screen bg-white relative overflow-hidden">
      
      <Navbar />

      <main className="relative z-10 pt-40 pb-24">
        <div className="max-w-4xl mx-auto px-6">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
          >
            <Link
              href="/"
              className="inline-flex items-center gap-2 text-zinc-400 hover:text-[#FA4821] mb-8 transition-colors text-sm font-medium"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M15 18L9 12L15 6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
              Back to Home
            </Link>

            <h1 className="text-5xl md:text-7xl font-bold text-black mb-4 tracking-tight">
              {title.split(" ").map((word, i) => (
                <span key={i} className={i === title.split(" ").length - 1 ? "text-transparent bg-clip-text bg-gradient-to-r from-[#FA4821] to-[#9E0261]" : ""}>
                  {word}{" "}
                </span>
              ))}
            </h1>
            <p className="text-zinc-500 mb-16 font-medium tracking-wide uppercase text-xs">Last updated: {lastUpdated}</p>

            <div className="prose prose-zinc max-w-none prose-h2:text-2xl prose-h2:font-bold prose-h2:mt-12 prose-h2:mb-6 prose-p:text-zinc-800 prose-p:leading-relaxed prose-li:text-zinc-800 prose-strong:text-blac flex flex-col gap-10">
              {children}
            </div>
          </motion.div>
        </div>
      </main>

      <Footer />
    </div>
  );
}
