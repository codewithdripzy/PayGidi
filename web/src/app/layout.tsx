import type { Metadata } from "next";
import { Google_Sans_Flex, Stack_Sans_Notch } from "next/font/google";
import "./globals.css";

const stackSansNotch = Stack_Sans_Notch({
  variable: "--font-stack-sans-notch",
});

const googleSansFlex = Google_Sans_Flex({
  variable: "--font-google-sans-flex",

});

export const metadata: Metadata = {
  title: {
    default: "PayGidi | Fast & Secure Digital Payments",
    template: "%s | PayGidi"
  },
  description: "The simplest way to send, receive and manage your money in Nigeria.",
  keywords: ["payments", "fintech", "nigeria", "digital wallet", "money transfer"],
  authors: [{ name: "PayGidi" }],
  creator: "PayGidi",
  publisher: "PayGidi",
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  icons: {
    icon: "/icons/icon.png",
  },
};

import GDPRBanner from "@/components/GDPRBanner";
import { Analytics } from "@vercel/analytics/react";
import { SpeedInsights } from "@vercel/speed-insights/next";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${stackSansNotch.variable} ${googleSansFlex.variable} h-full antialiased`}>
      <body className="min-h-full flex flex-col font-sans">
        {children}
        <GDPRBanner />
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}

