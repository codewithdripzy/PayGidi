import { useState, useEffect } from "react";
import { Routes, Route, useParams } from "react-router-dom";
import { motion, AnimatePresence } from "framer-motion";
import axios from "axios";
import { HugeiconsIcon } from "@hugeicons/react";
import { 
  Building01Icon, 
  UserAccountIcon, 
  DocumentAttachmentIcon, 
  CheckmarkCircle01Icon,
  ArrowRight01Icon,
  ArrowLeft01Icon,
  Loading03Icon,
  AlertCircleIcon
} from "@hugeicons/core-free-icons";
import type { PaymentResponse, Payment, UserData } from "./types/payment";

// --- Components ---

const Loader = () => (
  <div className="fixed inset-0 flex flex-col items-center justify-center bg-background z-50">
    <div className="relative w-32 h-32 flex items-center justify-center">
      {/* Partial Gradient Arc Spinner */}
      <motion.div
        animate={{ rotate: 360 }}
        transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
        className="absolute inset-0 rounded-full p-[3px]"
        style={{
          background: "conic-gradient(from 0deg, transparent 25%, #FA4821 50%, #9E0261 100%)",
          WebkitMask: "linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0)",
          WebkitMaskComposite: "destination-out",
          maskComposite: "exclude",
        }}
      />
      
      {/* Glow effect */}
      <div className="absolute inset-0 rounded-full bg-primary/10 blur-2xl animate-pulse" />

      {/* Logo in the middle */}
      <motion.div
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ 
          duration: 0.5,
          repeat: Infinity,
          repeatType: "reverse"
        }}
        className="relative w-12 h-12 z-10"
      >
        <img 
          src="/icons/icon.svg" 
          alt="PayGidi Icon" 
          className="w-full h-full object-contain"
        />
      </motion.div>
    </div>
  </div>
);

const StatusMessage = ({ status, title: customTitle, message: customMessage }: { status: string, title?: string, message?: string }) => {
  const config: Record<string, { title: string, message: string, icon: any, color: string }> = {
    disbursed: {
      title: "Payment Received",
      message: "This payment has already been successfully processed.",
      icon: CheckmarkCircle01Icon,
      color: "text-green-500"
    },
    refunded: {
      title: "Payment Refunded",
      message: "This payment request was refunded by the merchant.",
      icon: AlertCircleIcon,
      color: "text-red-500"
    },
    expired: {
      title: "Payment Expired",
      message: "This payment request has expired. Please ask the customer to regenerate it.",
      icon: AlertCircleIcon,
      color: "text-orange-500"
    },
    rejected: {
      title: "Payment Rejected",
      message: "This payment request was rejected.",
      icon: AlertCircleIcon,
      color: "text-red-500"
    }
  };

  const current = config[status] || {
    title: customTitle || "Unknown Status",
    message: customMessage || "There is an issue with this payment request.",
    icon: AlertCircleIcon,
    color: "text-primary"
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-6 text-center bg-background relative overflow-hidden">
      {/* Ambient background blobs */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 rounded-full blur-[140px] opacity-20" style={{ background: 'radial-gradient(circle, #FA4821, transparent)' }} />

      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.5 }}
        className="relative z-10 flex flex-col items-center max-w-sm w-full"
      >
        {/* Logo */}
        <img
          src="/icons/logo/logo.svg"
          alt="PayGidi"
          className="h-8 mb-12 brightness-0 opacity-50"
        />

        {/* Icon */}
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ type: "spring", stiffness: 200, damping: 15, delay: 0.1 }}
          className={`w-20 h-20 rounded-full flex items-center justify-center mb-8 ${
            current.color === 'text-green-500' ? 'bg-green-500/10' :
            current.color === 'text-orange-500' ? 'bg-orange-500/10' : 'bg-red-500/10'
          }`}
        >
          <HugeiconsIcon icon={current.icon} className={`w-10 h-10 ${current.color}`} />
        </motion.div>

        <h1 className="text-3xl font-bold mb-2 tracking-tight">{current.title}</h1>
        <p className="text-foreground/50 text-base mb-10 leading-relaxed">{current.message}</p>

        <button
          onClick={() => window.location.href = "https://paygidi.site"}
          className="w-full py-4 bg-primary-gradient rounded-xl text-white hover:scale-[1.02] active:scale-95 transition-transform cursor-pointer text-sm tracking-wide"
        >
          Return to Home
        </button>
      </motion.div>
    </div>
  );
};

const KYBForm = () => {
  const { paymentId } = useParams();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [paymentData, setPaymentData] = useState<{ payment: Payment; customer: UserData } | null>(null);
  const [accepted, setAccepted] = useState(false);
  const [currentStep, setCurrentStep] = useState(1);

  useEffect(() => {
    const fetchPayment = async () => {
      try {
        const response = await axios.get<PaymentResponse>(`https://api.paygidi.com/wallet/payments/${paymentId}`);
        if (response.data.success) {
          setPaymentData(response.data.data);
        } else {
          setError(response.data.message);
        }
      } catch (err) {
        setError("Failed to retrieve payment information. Please try again.");
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    if (paymentId) fetchPayment();
  }, [paymentId]);

  if (loading) return <Loader />;

  if (error || !paymentData) {
    return <StatusMessage status="error" title="Error" message={error || "Something went wrong"} />;
  }

  const { payment, customer } = paymentData;
  const customerName = `${customer.personData.firstName} ${customer.personData.lastName}`;
  const amountFormatted = new Intl.NumberFormat('en-NG', { style: 'currency', currency: 'NGN' }).format(payment.amount);

  if (payment.status !== "pending" && payment.status !== "action_required" && payment.status !== "in_progress") {
    return <StatusMessage status={payment.status} />;
  }

  if (!accepted) {
    return (
      <div className="min-h-screen flex items-center justify-center p-6 bg-background relative overflow-hidden">
        {/* Background decorative elements */}
        <div className="absolute top-0 left-0 w-32 h-32 bg-primary/20 blur-[80px] -translate-x-1/2 -translate-y-1/2 rounded-full" />
        <div className="absolute bottom-0 right-0 w-48 h-48 bg-accent/20 blur-[100px] translate-x-1/3 translate-y-1/3 rounded-full" />

        <motion.div 
          initial={{ scale: 0.95, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          className="max-w-xl w-full bg-white/5 border border-white/10 backdrop-blur-2xl rounded-[2.5rem] p-10 text-center shadow-2xl relative z-10"
        >
          <div className="flex justify-center mb-10">
            <img 
              src="/icons/logo/logo.svg" 
              alt="PayGidi" 
              className="h-12"
            />
          </div>
          
          <h2 className="text-2xl md:text-3xl font-bold mb-6 leading-tight">
            <span className="text-primary">{customerName}</span> would like to pay you <span className="text-primary">{amountFormatted}</span> for your service.
          </h2>
          
          <p className="text-foreground/60 text-lg mb-12 font-medium">
            Would you like to continue to receive this payment?
          </p>

          <div className="grid grid-cols-2 gap-4">
            <button 
              onClick={() => setAccepted(true)}
              className="py-4 bg-primary-gradient rounded-2xl font-bold text-white hover:scale-[1.03] active:scale-95 transition-all flex items-center justify-center gap-2 group cursor-pointer"
            >
              Accept <HugeiconsIcon icon={ArrowRight01Icon} className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
            </button>
            <button 
              onClick={() => window.history.back()}
              className="py-4 bg-white/5 border border-white/10 rounded-2xl font-bold text-foreground/80 hover:bg-white/10 transition-all active:scale-95 cursor-pointer"
            >
              Reject
            </button>
          </div>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen py-12 px-6 bg-background">
      <div className="max-w-2xl mx-auto">
        <motion.div 
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          className="mb-10 text-center"
        >
          <div className="flex justify-center mb-6">
             <img 
                src="/icons/logo/logo.svg" 
                alt="PayGidi" 
                className="h-10"
              />
          </div>
          <h1 className="text-3xl font-bold mb-2">Business Verification</h1>
          <p className="text-foreground/60 font-medium">Complete your KYB to receive payment from {customerName}</p>
        </motion.div>

        {/* Continue with PayGidi Button */}
        <motion.button
          initial={{ y: 10, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.2 }}
          whileHover={{ scale: 1.01 }}
          whileTap={{ scale: 0.99 }}
          className="w-full mb-10 p-6 rounded-3xl bg-white/5 border border-white/10 flex items-center justify-between group hover:bg-white/10 transition-colors cursor-pointer"
        >
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-2xl bg-primary-gradient flex items-center justify-center shadow-lg shadow-primary/20">
              <img src="/icons/icon.svg" alt="" className="w-6 h-6" />
            </div>
            <div className="text-left">
              <p className="text-sm text-foreground/50 font-semibold uppercase tracking-wider">Have a PayGidi business account?</p>
              <p className="text-lg font-bold text-white">Continue with PayGidi</p>
            </div>
          </div>
          <HugeiconsIcon icon={ArrowRight01Icon} className="w-6 h-6 text-primary group-hover:translate-x-2 transition-transform" />
        </motion.button>

        {/* Stepper Form */}
        <div className="bg-white/5 border border-white/10 rounded-[2rem] p-8 backdrop-blur-xl shadow-2xl relative overflow-hidden">
          {/* Progress Bar */}
          <div className="flex items-center justify-between mb-12 relative px-4">
            <div className="absolute top-1/2 left-0 w-full h-[2px] bg-white/10 -translate-y-1/2 z-0" />
            <motion.div 
              className="absolute top-1/2 left-0 h-[2px] bg-primary-gradient -translate-y-1/2 z-0"
              animate={{ width: `${(currentStep - 1) * 50}%` }}
              transition={{ duration: 0.5 }}
            />
            
            {[1, 2, 3].map((step) => (
              <div key={step} className="relative z-10 flex flex-col items-center">
                <motion.div 
                  className={`w-12 h-12 rounded-full flex items-center justify-center font-bold text-sm transition-colors duration-300 ${
                    currentStep >= step ? 'bg-primary text-white' : 'bg-white/10 text-foreground/40'
                  }`}
                  animate={currentStep === step ? { scale: 1.1 } : { scale: 1 }}
                >
                  {currentStep > step ? <HugeiconsIcon icon={CheckmarkCircle01Icon} className="w-6 h-6" /> : step}
                </motion.div>
                <span className={`text-[10px] mt-2 font-bold uppercase tracking-widest ${
                  currentStep >= step ? 'text-primary' : 'text-foreground/40'
                }`}>
                  {step === 1 ? 'Business' : step === 2 ? 'Owner' : 'Documents'}
                </span>
              </div>
            ))}
          </div>

          {/* Form Steps */}
          <AnimatePresence mode="wait">
            {currentStep === 1 && (
              <motion.div
                key="step1"
                initial={{ x: 20, opacity: 0 }}
                animate={{ x: 0, opacity: 1 }}
                exit={{ x: -20, opacity: 0 }}
                className="space-y-6"
              >
                <div className="flex items-center gap-3 mb-6">
                  <div className="p-2 bg-primary/10 rounded-lg">
                    <HugeiconsIcon icon={Building01Icon} className="w-6 h-6 text-primary" />
                  </div>
                  <h3 className="text-xl font-bold">Business Information</h3>
                </div>
                
                <div className="space-y-5">
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-foreground/70 ml-1 uppercase tracking-tight">Legal Business Name</label>
                    <input type="text" placeholder="Enter business name" className="w-full bg-white/5 border border-white/10 rounded-2xl p-5 focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all font-medium" />
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <label className="text-sm font-bold text-foreground/70 ml-1 uppercase tracking-tight">Registration Type</label>
                      <select className="w-full bg-white/5 border border-white/10 rounded-2xl p-5 focus:outline-none focus:border-primary/50 transition-all appearance-none font-medium">
                        <option>RC Number</option>
                        <option>BN Number</option>
                      </select>
                    </div>
                    <div className="space-y-2">
                      <label className="text-sm font-bold text-foreground/70 ml-1 uppercase tracking-tight">Number</label>
                      <input type="text" placeholder="1234567" className="w-full bg-white/5 border border-white/10 rounded-2xl p-5 focus:outline-none focus:border-primary/50 transition-all font-medium" />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-foreground/70 ml-1 uppercase tracking-tight">Business Address</label>
                    <textarea placeholder="Full physical address" rows={3} className="w-full bg-white/5 border border-white/10 rounded-2xl p-5 focus:outline-none focus:border-primary/50 transition-all font-medium resize-none" />
                  </div>
                </div>
              </motion.div>
            )}

            {currentStep === 2 && (
              <motion.div
                key="step2"
                initial={{ x: 20, opacity: 0 }}
                animate={{ x: 0, opacity: 1 }}
                exit={{ x: -20, opacity: 0 }}
                className="space-y-6"
              >
                <div className="flex items-center gap-3 mb-6">
                   <div className="p-2 bg-primary/10 rounded-lg">
                    <HugeiconsIcon icon={UserAccountIcon} className="w-6 h-6 text-primary" />
                  </div>
                  <h3 className="text-xl font-bold">Owner Details</h3>
                </div>
                
                <div className="space-y-5">
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <label className="text-sm font-bold text-foreground/70 ml-1 uppercase tracking-tight">First Name</label>
                      <input type="text" placeholder="John" className="w-full bg-white/5 border border-white/10 rounded-2xl p-5 focus:outline-none focus:border-primary/50 transition-all font-medium" />
                    </div>
                    <div className="space-y-2">
                      <label className="text-sm font-bold text-foreground/70 ml-1 uppercase tracking-tight">Last Name</label>
                      <input type="text" placeholder="Doe" className="w-full bg-white/5 border border-white/10 rounded-2xl p-5 focus:outline-none focus:border-primary/50 transition-all font-medium" />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-foreground/70 ml-1 uppercase tracking-tight">Personal Email</label>
                    <input type="email" placeholder="john@example.com" className="w-full bg-white/5 border border-white/10 rounded-2xl p-5 focus:outline-none focus:border-primary/50 transition-all font-medium" />
                  </div>
                  <div className="space-y-2">
                    <label className="text-sm font-bold text-foreground/70 ml-1 uppercase tracking-tight">BVN (Bank Verification Number)</label>
                    <input type="password" placeholder="22********9" className="w-full bg-white/5 border border-white/10 rounded-2xl p-5 focus:outline-none focus:border-primary/50 transition-all font-medium" />
                  </div>
                </div>
              </motion.div>
            )}

            {currentStep === 3 && (
              <motion.div
                key="step3"
                initial={{ x: 20, opacity: 0 }}
                animate={{ x: 0, opacity: 1 }}
                exit={{ x: -20, opacity: 0 }}
                className="space-y-6"
              >
                <div className="flex items-center gap-3 mb-6">
                   <div className="p-2 bg-primary/10 rounded-lg">
                    <HugeiconsIcon icon={DocumentAttachmentIcon} className="w-6 h-6 text-primary" />
                  </div>
                  <h3 className="text-xl font-bold">Document Upload</h3>
                </div>
                
                <div className="space-y-5">
                  {[
                    { label: "CAC Certificate", desc: "Upload PDF or Image of your CAC document" },
                    { label: "Proof of Address", desc: "Utility bill or Bank statement (last 3 months)" },
                    { label: "Valid ID", desc: "NIN, Voter's Card, or International Passport" }
                  ].map((doc, i) => (
                    <div key={i} className="group cursor-pointer">
                      <label className="text-sm font-bold text-foreground/70 ml-1 block mb-2 uppercase tracking-tight">{doc.label}</label>
                      <div className="w-full border-2 border-dashed border-white/10 rounded-2xl p-8 text-center group-hover:border-primary/50 transition-all bg-white/[0.02]">
                        <HugeiconsIcon icon={DocumentAttachmentIcon} className="w-10 h-10 text-foreground/20 mx-auto mb-3 group-hover:text-primary transition-colors" />
                        <p className="text-sm text-foreground/50 font-medium">{doc.desc}</p>
                        <p className="text-xs text-primary font-bold mt-3 uppercase tracking-widest">Click to browse files</p>
                      </div>
                    </div>
                  ))}
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Navigation Buttons */}
          <div className="flex items-center gap-4 mt-12">
            {currentStep > 1 && (
              <button 
                onClick={() => setCurrentStep(prev => prev - 1)}
                className="flex-[1] py-5 bg-white/5 border border-white/10 rounded-2xl font-bold flex items-center justify-center gap-2 hover:bg-white/10 transition-all active:scale-95 cursor-pointer"
              >
                <HugeiconsIcon icon={ArrowLeft01Icon} className="w-5 h-5" /> Back
              </button>
            )}
            <button 
              onClick={() => {
                if (currentStep < 3) setCurrentStep(prev => prev + 1);
                else alert("KYB Submitted successfully! We will verify your details shortly.");
              }}
              className="flex-[2] py-5 bg-primary-gradient rounded-2xl font-bold text-white hover:scale-[1.02] active:scale-95 transition-all flex items-center justify-center gap-2 group cursor-pointer"
            >
              {currentStep === 3 ? 'Submit Verification' : 'Next Step'} 
              {currentStep < 3 && <HugeiconsIcon icon={ArrowRight01Icon} className="w-5 h-5 group-hover:translate-x-1 transition-transform" />}
            </button>
          </div>
        </div>

        <p className="text-center mt-10 text-sm text-foreground/40 font-medium">
          Your data is encrypted and processed securely according to our privacy policy.
        </p>
      </div>
    </div>
  );
};

export default function App() {
  return (
    <Routes>
      <Route path="/:paymentId" element={<KYBForm />} />
      <Route path="*" element={<StatusMessage status="error" title="404" message="Page not found" />} />
    </Routes>
  );
}
