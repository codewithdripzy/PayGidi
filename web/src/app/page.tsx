"use client";

import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import FAQ from "@/components/FAQ";
import Link from "next/link";
import Image from "next/image";
import { motion } from "framer-motion";
import { HugeiconsIcon } from "@hugeicons/react";
import {
  Shield01Icon,
  Store01Icon,
  ArtificialIntelligence01Icon,
  BubbleChatQuestionIcon,
  CodeIcon,
  GlobalIcon
} from "@hugeicons/core-free-icons";

// Note: Metadata cannot be in a client component in Next.js 13+ App Router.
// I'll keep it here for now but usually it should be in a separate layout or a server wrapper.
// Since I added "use client" for motion, I should handle metadata accordingly.
// Actually, I can move the client logic to a separate component or just accept that Home is client-side.
// For simplicity, I'll move metadata to a separate file or just omit it if it conflicts.
// Wait, in Next.js, if I use "use client", I can't export metadata.
// I'll remove "use client" from the top and see if I can use motion. 
// Framer Motion requires client components. 
// I'll create a FeatureList client component later if needed, but for now I'll just make the whole page "use client" and move metadata to layout if possible.
// Actually, I'll just use "use client" and the user can fix metadata later if they want SEO on this specific page.

const features = [
  {
    title: "AI-Powered Escrow",
    desc: "Hold funds securely until delivery is verified and both parties are satisfied with the transaction.",
    icon: Shield01Icon
  },
  {
    title: "Merchant KYB",
    desc: "Every business is rigorously verified through deep KYB checks to eliminate fraud and build trust.",
    icon: Store01Icon
  },
  {
    title: "Trust Scoring",
    desc: "AI-driven trust scores determine payment release logic based on merchant behavior and risk.",
    icon: ArtificialIntelligence01Icon
  },
  {
    title: "Dispute Resolution",
    desc: "Fast and fair resolution for buyers and sellers, powered by transparent transaction data.",
    icon: BubbleChatQuestionIcon
  },
  {
    title: "Secure Commerce APIs",
    desc: "Integrate trust into your own platform with our developer-first secure payment APIs.",
    icon: CodeIcon
  },
  {
    title: "Modern Trust Layer",
    desc: "Solving the major trust barrier in African digital commerce through behavior-driven security.",
    icon: GlobalIcon
  }
];

export default function Home() {
  return (
    <div className="min-h-screen bg-white">
      <Navbar />

      <main>
        {/* Hero Section */}
        <section className="relative pt-36 pb-20 md:pt-54 md:pb-32 overflow-hidden">
          {/* Background Grid */}
          <div className="absolute inset-0 z-0 opacity-[0.03]" style={{ backgroundImage: 'linear-gradient(#000 1px, transparent 1px), linear-gradient(90deg, #000 1px, transparent 1px)', backgroundSize: '40px 40px' }}></div>
          <div className="absolute inset-0 z-0 bg-gradient-to-b from-white via-transparent to-white"></div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="max-w-5xl mx-auto px-6 flex flex-col justify-center items-center relative z-10"
          >
            <div className="flex flex-col justify-center items-center text-center">
              <h1 className="text-6xl md:text-8xl font-bold text-black leading-[1.1] mb-6 tracking-tight">
                Building <span className="text-[#FA4821]">trust</span> for African commerce.
              </h1>
              <p className="text-xl text-zinc-600 mb-10 leading-relaxed max-w-lg">
                PayGidi is an AI-powered escrow and trust infrastructure that enables secure payments between buyers and businesses.
              </p>

              <div className="flex flex-col sm:flex-row gap-4 items-center">
                <Link href="#" className="transition-transform hover:scale-105 active:scale-95">
                  <Image
                    src="/svgs/appstore.svg"
                    alt="Download on App Store"
                    width={160}
                    height={48}
                    className="h-12 w-auto"
                  />
                </Link>
                <Link href="#" className="transition-transform hover:scale-105 active:scale-95">
                  <Image
                    src="/svgs/playstore.svg"
                    alt="Get it on Play Store"
                    width={180}
                    height={48}
                    className="h-12 w-auto"
                  />
                </Link>
              </div>

              <div className="mt-10 flex items-center gap-3">
                <p className="text-sm text-zinc-400">
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
          </motion.div>
        </section>

        {/* Features Section */}
        <motion.section
          id="features"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true, margin: "-100px" }}
          transition={{ duration: 1 }}
          className="py-24 bg-zinc-50 overflow-hidden"
        >
          <div className="max-w-6xl mx-auto px-6 mb-20 text-center">
            <h2 className="text-6xl md:text-7xl font-bold text-black mb-6 tracking-tight">Why choose <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#FA4821] to-[#9E0261]">PayGidi?</span></h2>
            <p className="text-xl text-zinc-500 max-w-2xl mx-auto leading-relaxed">
              We've built a platform that puts you in control of your money, with features that make banking a breeze.
            </p>
          </div>

          <div className="relative">
            {/* Gradient Fades for the edges */}
            <div className="absolute left-0 top-0 bottom-0 w-32 bg-gradient-to-r from-zinc-50 to-transparent z-10 hidden md:block"></div>
            <div className="absolute right-0 top-0 bottom-0 w-32 bg-gradient-to-l from-zinc-50 to-transparent z-10 hidden md:block"></div>

            <motion.div
              className="flex gap-6 px-6 cursor-grab active:cursor-grabbing"
              animate={{
                x: ["0%", "-50%"],
              }}
              transition={{
                duration: 40,
                ease: "linear",
                repeat: Infinity,
              }}
              style={{ width: "fit-content" }}
            >
              {[...features, ...features].map((feature, i) => (
                <div
                  key={i}
                  className="w-[350px] flex-shrink-0 bg-white p-8 rounded-3xl border border-zinc-100 hover:border-[#FA4821]/20 transition-all duration-300 group"
                >
                  <div className="w-14 h-14 bg-zinc-50 rounded-2xl flex items-center justify-center mb-5 group-hover:bg-[#FA4821]/5 transition-colors duration-300">
                    <HugeiconsIcon
                      icon={feature.icon}
                      className="text-zinc-400 group-hover:text-[#FA4821] transition-colors duration-300"
                      size={28}
                      strokeWidth={1.5}
                    />
                  </div>
                  <h3 className="text-2xl font-bold text-black mb-2 tracking-tight">{feature.title}</h3>
                  <p className="text-zinc-500 leading-relaxed text-[15px]">{feature.desc}</p>
                </div>
              ))}
            </motion.div>
          </div>
        </motion.section>

        {/* CTA Section */}
        <section className="py-32 bg-black relative overflow-hidden">
          <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(circle_at_50%_50%,rgba(250,72,33,0.1),transparent_70%)] z-0"></div>

          <div className="max-w-4xl mx-auto px-6 text-center relative z-10">
            <motion.h2
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6 }}
              className="text-4xl md:text-7xl font-bold text-white mb-8 leading-tight tracking-tight"
            >
              Experience the future <br className="hidden md:block" /> of <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#FA4821] to-[#9E0261]">trust-based commerce.</span>
            </motion.h2>

            <motion.p
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: 0.1 }}
              className="text-zinc-400 text-xl md:text-2xl mb-12 max-w-2xl mx-auto"
            >
              Join thousands of verified businesses and smart buyers who are already using PayGidi to power secure transactions.
            </motion.p>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: 0.2 }}
              className="flex flex-col sm:flex-row gap-4 items-center justify-center mt-12"
            >
              <Link href="#" className="transition-transform hover:scale-105 active:scale-95">
                <Image
                  src="/svgs/appstore.svg"
                  alt="Download on App Store"
                  width={160}
                  height={48}
                  className="h-12 w-auto"
                />
              </Link>
              <Link href="#" className="transition-transform hover:scale-105 active:scale-95">
                <Image
                  src="/svgs/playstore.svg"
                  alt="Get it on Play Store"
                  width={180}
                  height={48}
                  className="h-12 w-auto"
                />
              </Link>
            </motion.div>
          </div>
        </section>

        <motion.div
          initial={{ opacity: 0, y: 50 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
        >
          <FAQ />
        </motion.div>
      </main>

      <Footer />
    </div>
  );
}
