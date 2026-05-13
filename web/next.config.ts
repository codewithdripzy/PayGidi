import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async redirects() {
    return [
      {
        source: '/appstore',
        destination: 'https://apps.apple.com/app/paygidi', // Replace with actual App Store URL
        permanent: false,
      },
      {
        source: '/playstore',
        destination: 'https://play.google.com/store/apps/details?id=com.paygidi.app', // Replace with actual Play Store URL
        permanent: false,
      },
    ]
  },
};

export default nextConfig;
