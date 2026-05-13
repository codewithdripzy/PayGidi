import Image from "next/image";
import Link from "next/link";

export default function Footer() {
  return (
    <footer className="bg-zinc-50 border-t border-zinc-200 pt-20 pb-10 z-10">
      <div className="max-w-6xl mx-auto px-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-12 mb-16">
          <div className="col-span-1 md:col-span-1">
            <Link href="/" className="inline-block mb-6">
              <Image
                src="/icons/logo/logo.svg"
                alt="PayGidi Logo"
                width={120}
                height={32}
                className="h-8 w-auto"
              />
            </Link>
            <p className="text-zinc-600 text-sm leading-relaxed max-w-xs">
              Secure, fast, and reliable digital payments for everyone. Join thousands of users who trust PayGidi for their daily transactions.
            </p>
          </div>
          
          <div>
            <h4 className="font-bold text-sm mb-6 text-black uppercase tracking-wider">Product</h4>
            <ul className="space-y-4">
                <li><Link href="#" className="text-zinc-800 hover:text-[#FA4821] text-sm transition-colors">Personal Account</Link></li>
                <li><Link href="#" className="text-zinc-800 hover:text-[#FA4821] text-sm transition-colors">Business Solutions</Link></li>
                <li><Link href="#" className="text-zinc-800 hover:text-[#FA4821] text-sm transition-colors">Payment Gateway</Link></li>
                <li><Link href="#" className="text-zinc-800 hover:text-[#FA4821] text-sm transition-colors">Security</Link></li>
              </ul>
            </div>
  
            <div>
              <h4 className="font-bold text-sm mb-6 text-black uppercase tracking-wider">Company</h4>
              <ul className="space-y-4">
                <li><Link href="#" className="text-zinc-800 hover:text-[#FA4821] text-sm transition-colors">About Us</Link></li>
                <li><Link href="#" className="text-zinc-800 hover:text-[#FA4821] text-sm transition-colors">Careers</Link></li>
                <li><Link href="#" className="text-zinc-800 hover:text-[#FA4821] text-sm transition-colors">Contact</Link></li>
                <li><Link href="#" className="text-zinc-800 hover:text-[#FA4821] text-sm transition-colors">Blog</Link></li>
              </ul>
            </div>
  
            <div>
              <h4 className="font-bold text-sm mb-6 text-black uppercase tracking-wider">Legal</h4>
              <ul className="space-y-4">
                <li><Link href="/privacy" className="text-zinc-800 hover:text-[#FA4821] text-sm transition-colors">Privacy Policy</Link></li>
                <li><Link href="/terms" className="text-zinc-800 hover:text-[#FA4821] text-sm transition-colors">Terms of Service</Link></li>
                <li><Link href="/cookies" className="text-zinc-800 hover:text-[#FA4821] text-sm transition-colors">Cookie Policy</Link></li>
            </ul>
          </div>
        </div>

        <div className="flex flex-col md:flex-row items-center justify-between pt-8 border-t border-zinc-200">
          <p className="text-zinc-400 text-xs mb-4 md:mb-0">
            © {new Date().getFullYear()} PayGidi. All rights reserved.
          </p>
          <div className="flex gap-6">
            <Link href="#" className="text-zinc-400 hover:text-black transition-colors">
              <span className="sr-only">Twitter</span>
              <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24"><path d="M24 4.557c-.883.392-1.832.656-2.828.775 1.017-.609 1.798-1.574 2.165-2.724-.951.564-2.005.974-3.127 1.195-.897-.957-2.178-1.555-3.594-1.555-3.179 0-5.515 2.966-4.797 6.045-4.091-.205-7.719-2.165-10.148-5.144-1.29 2.213-.669 5.108 1.523 6.574-.806-.026-1.566-.247-2.229-.616-.054 2.281 1.581 4.415 3.949 4.89-.693.188-1.452.232-2.224.084.626 1.956 2.444 3.379 4.6 3.419-2.07 1.623-4.678 2.348-7.29 2.04 2.179 1.397 4.768 2.212 7.548 2.212 9.142 0 14.307-7.721 13.995-14.646.962-.695 1.797-1.562 2.457-2.549z"/></svg>
            </Link>
            <Link href="#" className="text-zinc-400 hover:text-black transition-colors">
              <span className="sr-only">LinkedIn</span>
              <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24"><path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/></svg>
            </Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
