"use client";

import Image from "next/image";
import Link from "next/link";
import { useState, useEffect } from "react";

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <nav
      className={`fixed top-4 left-1/2 -translate-x-1/2 z-50 w-[95%] max-w-6xl transition-all duration-300 ${scrolled
        ? "bg-white/80 backdrop-blur-md border border-zinc-200 rounded-2xl py-3 px-6"
        : "bg-transparent py-5 px-6"
        }`}
    >
      <div className="flex items-center justify-between">
        <Link href="/" className="flex items-center gap-2">
          <Image
            src="/icons/logo/logo.svg"
            alt="PayGidi Logo"
            width={100}
            height={30}
            className="h-7 w-auto"
          />
        </Link>

        <div className="absolute left-1/2 -translate-x-1/2 hidden md:flex items-center gap-10">
          <Link href="#features" className="text-[15px] font-medium text-zinc-600 hover:text-black transition-colors">
            Features
          </Link>
          <Link href="#about" className="text-[15px] font-medium text-zinc-600 hover:text-black transition-colors">
            About
          </Link>
          <Link href="#faq" className="text-[14px] font-medium text-zinc-600 hover:text-black transition-colors">
            FAQ
          </Link>
        </div>

        <div className="flex items-center gap-4">
          {/* <Link
            href="/login"
            className="hidden sm:block text-sm font-medium text-zinc-600 hover:text-black transition-colors"
          >
            Login
          </Link> */}
          <Link
            href="/open-account"
            className="bg-gradient-to-r from-[#FA4821] to-[#9E0261] text-white px-5 py-2.5 rounded-full text-sm font-semibold hover:opacity-90 transition-all shadow-[0_10px_20px_rgba(250,72,33,0.15)]"
          >
            Open Account
          </Link>
        </div>
      </div>
    </nav>
  );
}
