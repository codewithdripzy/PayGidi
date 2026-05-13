"use client";

import Image from "next/image";
import Link from "next/link";
import { useState } from "react";

export default function OpenAccount() {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
    password: "",
  });

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const nextStep = (e: React.FormEvent) => {
    e.preventDefault();
    setStep(step + 1);
  };

  return (
    <div className="min-h-screen bg-zinc-50 flex flex-col md:flex-row">
      {/* Left Side - Info */}
      <div className="hidden md:flex w-1/2 bg-black p-20 flex-col justify-between relative overflow-hidden">
        <div className="absolute top-0 right-0 w-[800px] h-[800px] bg-[#FA4821]/5 rounded-full blur-[120px] -translate-y-1/2 translate-x-1/3"></div>

        <Link href="/">
          <Image
            src="/icons/logo/logo_w.svg"
            alt="PayGidi Logo"
            width={140}
            height={40}
            className="relative z-10"
          />
        </Link>

        <div className="relative z-10">
          <h1 className="text-5xl lg:text-6xl font-bold text-white mb-8 leading-tight tracking-tight">
            Start your journey <br /> with <span className="text-[#FA4821]">PayGidi.</span>
          </h1>
          <ul className="space-y-6">
            {[
              "Join 10,000+ active users",
              "Get your virtual card instantly",
              "Zero fees on your first 10 transfers",
              "Bank-grade security features"
            ].map((item, i) => (
              <li key={i} className="flex items-center gap-4 text-zinc-400 text-lg">
                <div className="w-6 h-6 rounded-full bg-[#FA4821]/20 flex items-center justify-center text-[#FA4821]">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                </div>
                {item}
              </li>
            ))}
          </ul>
        </div>

        <p className="text-zinc-500 text-sm relative z-10">
          © {new Date().getFullYear()} PayGidi. All rights reserved. Parntered with Squad

          {/* Licensed by CBN. */}
        </p>
      </div>

      {/* Right Side - App Download */}
      <div className="w-full md:w-1/2 bg-white flex flex-col items-center justify-center p-6 md:py-20 md:px-10 relative overflow-hidden">
        {/* Background Accent */}
        <div className="absolute bottom-0 right-0 w-64 h-64 bg-[#FA4821]/5 rounded-full blur-3xl translate-x-1/2 translate-y-1/2"></div>

        <div className="w-full max-w-xl relative z-10 text-center">
          <div className="md:hidden mb-12 flex justify-center">
            <Link href="/">
              <Image
                src="/icons/logo/logo.svg"
                alt="PayGidi Logo"
                width={120}
                height={32}
              />
            </Link>
          </div>

          <div className="mb-12">
            <h2 className="text-5xl font-bold text-black mb-3 tracking-tight">Open a <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#FA4821] to-[#9E0261]">PayGidi</span> Account</h2>
            <p className="text-zinc-500 text-md leading-relaxed">Scan the QR code below with your phone camera to get the app</p>
          </div>

          {/* QR Code Section */}
          <div className="mb-12 flex justify-center">
            <div className="p-2 bg-white border-2 border-zinc-100 rounded-[2.5rem] shadow-[0_20px_50px_rgba(0,0,0,0.05)] relative group transition-all duration-300 hover:scale-105">
              <div className="w-48 h-48 bg-zinc-50 rounded-2xl flex items-center justify-center relative overflow-hidden">
                <Image
                  src="/svgs/qr.svg"
                  alt="QR Code"
                  width={140}
                  height={140}
                  className="w-full h-auto"
                />
                {/* Brand Overlay */}
                {/* <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                  <div className="w-10 h-10 bg-white rounded-xl shadow-lg flex items-center justify-center p-1.5">
                    <Image
                      src="/icons/logo/logo.svg"
                      alt="Logo"
                      width={40}
                      height={40}
                      className="w-full h-auto"
                    />
                  </div>
                </div> */}
              </div>
            </div>
          </div>

          <div className="mb-12">
            <p className="text-zinc-400 font-medium mb-6 text-sm">Or Download on</p>
            <div className="flex flex-col sm:flex-row gap-4 items-center justify-center">
              <Link href="#" className="transition-transform hover:scale-105 active:scale-95">
                <Image
                  src="/svgs/appstore.svg"
                  alt="Download on App Store"
                  width={140}
                  height={42}
                  className="h-11 w-auto"
                />
              </Link>
              <Link href="#" className="transition-transform hover:scale-105 active:scale-95">
                <Image
                  src="/svgs/playstore.svg"
                  alt="Get it on Play Store"
                  width={155}
                  height={42}
                  className="h-11 w-auto"
                />
              </Link>
            </div>
          </div>

          <div className="flex justify-center items-center gap-2">
            <p className="text-sm text-zinc-400 font-medium">
              In partnership with
            </p>
            <div className="flex items-center gap-2">
              <Image
                src="/icons/logo/squad.svg"
                alt="Squad Logo"
                width={100}
                height={30}
                className="h-6 w-auto opacity-80"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
