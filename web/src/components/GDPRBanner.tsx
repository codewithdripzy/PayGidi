"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import Link from "next/link";

export default function GDPRBanner() {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const consent = localStorage.getItem("paygidi-cookie-consent");
    if (!consent) {
      const timer = setTimeout(() => setIsVisible(true), 2000);
      return () => clearTimeout(timer);
    }
  }, []);

  const acceptCookies = () => {
    localStorage.setItem("paygidi-cookie-consent", "true");
    setIsVisible(false);
  };

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          initial={{ y: 100, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          exit={{ y: 100, opacity: 0 }}
          className="fixed bottom-0 left-0 right-0 z-50 p-4 md:p-6"
        >
          <div className="max-w-7xl mx-auto">
            <div className="bg-black text-white border border-white/10 shadow-[0_-20px_50px_rgba(0,0,0,0.2)] rounded-[2rem] p-6 md:p-8 backdrop-blur-xl bg-black/90">
              <div className="flex flex-col md:flex-row items-center justify-between gap-6">
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-2xl bg-[#FA4821]/20 flex items-center justify-center flex-shrink-0">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M12 22C17.5228 22 22 17.5228 22 12C22 6.47715 17.5228 2 12 2C6.47715 2 2 6.47715 2 12C2 17.5228 6.47715 22 12 22Z" stroke="#FA4821" strokeWidth="1.5"/>
                      <circle cx="12" cy="12" r="3" fill="#FA4821"/>
                    </svg>
                  </div>
                  <div>
                    <p className="font-bold text-lg tracking-tight mb-1">We value your privacy</p>
                    <p className="text-sm text-zinc-400 leading-relaxed max-w-2xl">
                      We use cookies to improve your experience, analyze our traffic, and show you personalized content. 
                      By continuing to visit this site you agree to our 
                      <Link href="/cookies" className="text-[#FA4821] hover:underline ml-1">Cookie Policy</Link>.
                    </p>
                  </div>
                </div>

                <div className="flex gap-3 w-full md:w-auto">
                  <button
                    onClick={acceptCookies}
                    className="flex-1 md:flex-none px-10 bg-white text-black text-sm font-bold py-4 rounded-full hover:bg-zinc-200 transition-all"
                  >
                    Accept All
                  </button>
                  <button
                    onClick={() => setIsVisible(false)}
                    className="flex-1 md:flex-none px-10 bg-white/10 text-white text-sm font-bold py-4 rounded-full hover:bg-white/20 transition-all border border-white/10"
                  >
                    Decline
                  </button>
                </div>
              </div>
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
