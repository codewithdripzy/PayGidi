// components/OrelloVoice.tsx
'use client';

import { OrelloAgent } from '@orello/next';

export default function OrelloVoice() {
  return <OrelloAgent agent={process.env.NEXT_PUBLIC_ORELLO_ASSISTANT_KEY} apiKey={process.env.NEXT_PUBLIC_ORELLO_API_KEY} />;
}