import { useState, useEffect, useRef } from "react";
import { Routes, Route, useParams } from "react-router-dom";
import { motion, AnimatePresence } from "framer-motion";
import axios from "axios";
import { HugeiconsIcon } from "@hugeicons/react";
import {
  // Building01Icon,
  UserAccountIcon,
  // DocumentAttachmentIcon,
  CheckmarkCircle01Icon,
  ArrowRight01Icon,
  ArrowLeft01Icon,
  AlertCircleIcon,
  Camera01Icon,
  InformationCircleIcon,
  InstagramIcon,
  // TiktokIcon,
  // LicenseIcon,
  Briefcase01Icon,
  // ContactIcon,
  Globe02Icon
} from "@hugeicons/core-free-icons";
import type { PaymentResponse, Payment, UserData } from "./types/payment";

// --- Types ---

type BusinessType = "registered" | "unregistered";

interface SocialProfile {
  platform: string;
  handle: string;
}

interface KYBFormData {
  businessName: string;
  description: string;
  businessType: BusinessType;
  nin: string;
  selfieImage: string;
  registration?: {
    cacNumber: string;
    companyName: string;
  };
  informalProfile?: {
    businessCategory: string;
    yearsActive: number;
    physicalAddress: string;
  };
  socialProfiles: SocialProfile[];
  contact: {
    email: string;
    phone: string;
  };
}

// --- Components ---

const Loader = () => (
  <div className="fixed inset-0 flex flex-col items-center justify-center bg-background z-50">
    <div className="relative w-32 h-32 flex items-center justify-center">
      <motion.div
        animate={{ rotate: 360 }}
        transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
        className="absolute inset-0 rounded-full p-[3px]"
        style={{
          background: "conic-gradient(from 0deg, transparent 25%, #FA4821 50%, #9E0261 100%)",
          WebkitMask: "linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0)",
          WebkitMaskComposite: "destination-out",
          maskComposite: "exclude",
          mask: "linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0)",
        }}
      />
      <div className="absolute inset-0 rounded-full bg-primary/10 blur-2xl animate-pulse" />
      <motion.div
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.5, repeat: Infinity, repeatType: "reverse" }}
        className="relative w-12 h-12 z-10"
      >
        <img src="/icons/icon.svg" alt="PayGidi Icon" className="w-full h-full object-contain" />
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
    },
    success: {
      title: "Submission Complete!",
      message: "Your verification is being processed. You will be notified once approved.",
      icon: CheckmarkCircle01Icon,
      color: "text-green-500"
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
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 rounded-full blur-[140px] opacity-20" style={{ background: 'radial-gradient(circle, #FA4821, transparent)' }} />
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.5 }}
        className="relative z-10 flex flex-col items-center max-w-sm w-full"
      >
        <img src="/icons/logo/logo.svg" alt="PayGidi" className="h-9 mb-12 -ml-5" />
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ type: "spring", stiffness: 200, damping: 15, delay: 0.1 }}
          className={`w-20 h-20 rounded-full flex items-center justify-center mb-8 ${current.color === 'text-green-500' ? 'bg-green-500/10' :
            current.color === 'text-orange-500' ? 'bg-orange-500/10' : 'bg-red-500/10'
            }`}
        >
          <HugeiconsIcon icon={current.icon} className={`w-10 h-10 ${current.color}`} />
        </motion.div>
        <h1 className="text-3xl font-bold mb-2 tracking-tight">{current.title}</h1>
        <div className="text-foreground/50 text-base mb-10 leading-relaxed max-w-lg">{current.message}</div>
        <button
          onClick={() => window.location.href = "https://paygidi.site"}
          className="w-full py-4 bg-primary-gradient rounded-xl text-white hover:scale-[1.02] active:scale-95 transition-transform cursor-pointer text-sm font-bold"
        >
          Return to Home
        </button>
      </motion.div>
    </div>
  );
};

const Camera = ({ onCapture }: { onCapture: (base64: string) => void }) => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [stream, setStream] = useState<MediaStream | null>(null);
  const [captured, setCaptured] = useState<string | null>(null);

  const startCamera = async () => {
    try {
      const s = await navigator.mediaDevices.getUserMedia({ video: { facingMode: "user" } });
      setStream(s);
      if (videoRef.current) videoRef.current.srcObject = s;
    } catch (err) {
      console.error("Camera access denied", err);
    }
  };

  const capture = () => {
    if (videoRef.current && canvasRef.current) {
      const video = videoRef.current;
      const canvas = canvasRef.current;
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
      const ctx = canvas.getContext("2d");
      ctx?.drawImage(video, 0, 0);
      const base64 = canvas.toDataURL("image/jpeg");
      setCaptured(base64);
      onCapture(base64);
      stopCamera();
    }
  };

  const stopCamera = () => {
    stream?.getTracks().forEach(track => track.stop());
    setStream(null);
  };

  useEffect(() => {
    return () => stopCamera();
  }, [stream]);

  if (captured) {
    return (
      <div className="space-y-4">
        <div className="relative aspect-square rounded-3xl overflow-hidden border-4 border-primary/20 shadow-2xl">
          <img src={captured} className="w-full h-full object-cover" alt="Captured" />
          <div className="absolute inset-0 bg-primary/5 pointer-events-none" />
        </div>
        <button
          onClick={() => { setCaptured(null); startCamera(); }}
          className="w-full py-4 bg-white/5 border border-white/10 rounded-2xl font-bold flex items-center justify-center gap-2 hover:bg-white/10 transition-all"
        >
          <HugeiconsIcon icon={Camera01Icon} className="w-5 h-5" /> Retake Photo
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {!stream ? (
        <div
          onClick={startCamera}
          className="aspect-square rounded-3xl bg-white/5 border-2 border-dashed border-white/10 flex flex-col items-center justify-center gap-4 cursor-pointer hover:border-primary/50 transition-all group"
        >
          <div className="w-20 h-20 rounded-full bg-primary/10 flex items-center justify-center group-hover:scale-110 transition-transform">
            <HugeiconsIcon icon={Camera01Icon} className="w-10 h-10 text-primary" />
          </div>
          <div className="text-center">
            <p className="font-bold text-lg">Grant Camera Access</p>
            <p className="text-sm text-foreground/50">Required for liveness verification</p>
          </div>
        </div>
      ) : (
        <div className="relative aspect-square rounded-3xl overflow-hidden border-4 border-primary/20 bg-black">
          <video ref={videoRef} autoPlay playsInline className="w-full h-full object-cover scale-x-[-1]" />
          <div className="absolute inset-0 border-[30px] border-black/40 rounded-3xl pointer-events-none flex items-center justify-center">
            <div className="w-full h-full border-2 border-primary/40 rounded-[20%] opacity-50 border-dashed" />
          </div>
          <button
            onClick={capture}
            className="absolute bottom-6 left-1/2 -translate-x-1/2 w-16 h-16 rounded-full bg-white border-4 border-primary flex items-center justify-center shadow-2xl active:scale-90 transition-transform"
          >
            <div className="w-12 h-12 rounded-full border-2 border-black/10" />
          </button>
        </div>
      )}
      <canvas ref={canvasRef} className="hidden" />
    </div>
  );
};

const KYBForm = () => {
  const { paymentId } = useParams();
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);
  const [paymentData, setPaymentData] = useState<{ payment: Payment; customer: UserData } | null>(null);
  const [accepted, setAccepted] = useState(false);
  const [currentStep, setCurrentStep] = useState(1);
  const [formData, setFormData] = useState<KYBFormData>({
    businessName: "",
    description: "",
    businessType: "unregistered",
    nin: "",
    selfieImage: "",
    socialProfiles: [{ platform: "instagram", handle: "" }],
    contact: { email: "", phone: "" },
    informalProfile: { businessCategory: "", yearsActive: 1, physicalAddress: "" },
    registration: { cacNumber: "", companyName: "" }
  });

  useEffect(() => {
    const fetchPayment = async () => {
      try {
        const response = await axios.get<PaymentResponse>(`${import.meta.env.VITE_API_BASE_URL}/api/v1/wallet/payment/${paymentId}`);
        if (response.data.success) {
          setPaymentData(response.data.data);
          setFormData(prev => ({
            ...prev,
            businessName: response.data.data.payment.businessName || "",
            contact: {
              email: response.data.data.payment.merchantEmail || "",
              phone: response.data.data.payment.merchantPhoneNumber || ""
            }
          }));
        } else {
          setError(response.data.message);
        }
      } catch (err) {
        setError("Failed to retrieve payment information. Please check your connection.");
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    if (paymentId) fetchPayment();
  }, [paymentId]);

  const handleSubmit = async () => {
    setSubmitting(true);
    try {
      const payload = {
        paymentId: Number(paymentId),
        businessName: formData.businessName,
        description: formData.description,
        businessType: formData.businessType,
        nin: formData.nin,
        selfieImage: formData.selfieImage,
        contact: formData.contact,
        socialProfiles: formData.socialProfiles,
        ...(formData.businessType === "registered" ? { registration: formData.registration } : { informalProfile: formData.informalProfile }),
        metadata: {
          submittedAt: new Date().toISOString(),
          ipAddress: "client-side-ip"
        }
      };

      const res = await axios.post(`${import.meta.env.VITE_API_BASE_URL}/api/v1/kyb/payment/submit`, payload);
      if (res.data.success) {
        setSuccess(true);
      } else {
        alert(res.data.message);
      }
    } catch (err: any) {
      alert(err.response?.data?.message || "Submission failed. Please try again.");
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) return <Loader />;
  if (success) return <StatusMessage status="success" />;
  if (error || !paymentData) return <StatusMessage status="error" title="Oops!" message={error || "Could not load details"} />;

  const { payment, customer } = paymentData;
  const customerName = `${customer.personData?.firstName} ${customer.personData?.lastName}`;
  const amountFormatted = new Intl.NumberFormat('en-NG', { style: 'currency', currency: 'NGN' }).format(payment.amount);

  if (payment.status !== "pending" && payment.status !== "action_required" && payment.status !== "in_progress") {
    return <StatusMessage status={payment.status} />;
  }

  if (!accepted) {
    return (
      <div className="min-h-screen flex items-center justify-center p-6 bg-background relative overflow-hidden">
        <div className="absolute top-0 left-0 w-32 h-32 bg-primary/20 blur-[80px] -translate-x-1/2 -translate-y-1/2 rounded-full" />
        <motion.div
          initial={{ scale: 0.95, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          className="max-w-xl w-full bg-white/5 border border-white/10 backdrop-blur-2xl rounded-[2.5rem] p-10 text-center shadow-2xl relative z-10"
        >
          <div className="flex justify-center mb-10">
            <img src="/icons/logo/logo.svg" alt="PayGidi" className="h-13 -ml-5" />
          </div>
          <h2 className="text-2xl md:text-3xl font-bold mb-6 leading-tight">
            <span className="text-primary">{customerName}</span> would like to pay you <span className="text-primary">{amountFormatted}</span> for your service.
          </h2>
          <p className="text-foreground/60 text-lg mb-12 font-medium">Accept this payment and verify your business details to continue.</p>
          <div className="grid grid-cols-2 gap-4">
            <button onClick={() => setAccepted(true)} className="py-4 bg-primary-gradient rounded-2xl font-bold text-white hover:scale-[1.03] transition-all flex items-center justify-center gap-2 group">
              Accept <HugeiconsIcon icon={ArrowRight01Icon} className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
            </button>
            <button onClick={() => window.history.back()} className="py-4 bg-white/5 border border-white/10 rounded-2xl font-bold text-foreground/80 hover:bg-white/10 transition-all">Reject</button>
          </div>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen py-12 px-6 bg-background">
      <div className="max-w-2xl mx-auto">
        <motion.div initial={{ y: 20, opacity: 0 }} animate={{ y: 0, opacity: 1 }} className="mb-10 text-center">
          <div className="flex justify-center mb-6">
            <img src="/icons/logo/logo.svg" alt="PayGidi" className="h-10 -ml-5" />
          </div>
          <h1 className="text-3xl font-bold mb-2">Business Verification</h1>
          <p className="text-foreground/60 font-medium tracking-tight">Complete your KYB to receive {amountFormatted} from {customerName}</p>
        </motion.div>

        <div className="bg-white/5 border border-white/10 rounded-[2.5rem] p-8 md:p-10 backdrop-blur-xl shadow-2xl relative overflow-hidden">
          {/* Progress Bar */}
          <div className="flex items-center justify-between mb-12 relative px-4">
            <div className="absolute top-1/2 left-0 w-full h-[2px] bg-white/10 -translate-y-1/2 z-0" />
            <motion.div
              className="absolute top-1/2 left-0 h-[2px] bg-primary-gradient -translate-y-1/2 z-0"
              animate={{ width: `${((currentStep - 1) / 4) * 100}%` }}
              transition={{ duration: 0.5 }}
            />

            {[1, 2, 3, 4, 5].map((step) => (
              <div key={step} className="relative z-10 flex flex-col items-center">
                <motion.div
                  className={`w-10 h-10 rounded-full flex items-center justify-center font-bold text-xs transition-colors duration-300 ${currentStep >= step ? 'bg-primary text-white shadow-lg shadow-primary/30' : 'bg-white/10 text-foreground/40'}`}
                  animate={currentStep === step ? { scale: 1.2 } : { scale: 1 }}
                >
                  {currentStep > step ? <HugeiconsIcon icon={CheckmarkCircle01Icon} className="w-5 h-5" /> : step}
                </motion.div>
                <span className={`text-[9px] mt-2 font-bold uppercase tracking-widest hidden sm:block ${currentStep >= step ? 'text-primary' : 'text-foreground/40'}`}>
                  {["Intent", "ID", "Signals", "Live", "Final"][step - 1]}
                </span>
              </div>
            ))}
          </div>

          <AnimatePresence mode="wait">
            {/* Step 1: Business Intent */}
            {currentStep === 1 && (
              <motion.div key="step1" initial={{ x: 20, opacity: 0 }} animate={{ x: 0, opacity: 1 }} exit={{ x: -20, opacity: 0 }} className="space-y-6">
                <div className="flex items-center gap-3 mb-8">
                  <div className="p-3 bg-primary/10 rounded-2xl"><HugeiconsIcon icon={Briefcase01Icon} className="w-6 h-6 text-primary" /></div>
                  <div>
                    <h3 className="text-xl font-bold">Business Intent</h3>
                    <p className="text-sm text-foreground/50 font-medium">Tell us about your trade</p>
                  </div>
                </div>

                <div className="space-y-5">
                  <div className="grid grid-cols-2 gap-3 p-1 bg-white/5 rounded-2xl border border-white/10">
                    <button
                      onClick={() => setFormData({ ...formData, businessType: "unregistered" })}
                      className={`py-3 rounded-xl font-bold text-sm transition-all ${formData.businessType === "unregistered" ? 'bg-primary text-white shadow-lg' : 'text-foreground/60 hover:text-white'}`}
                    >
                      Informal Vendor
                    </button>
                    <button
                      onClick={() => setFormData({ ...formData, businessType: "registered" })}
                      className={`py-3 rounded-xl font-bold text-sm transition-all ${formData.businessType === "registered" ? 'bg-primary text-white shadow-lg' : 'text-foreground/60 hover:text-white'}`}
                    >
                      Registered Business
                    </button>
                  </div>

                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-foreground/50 ml-1 uppercase tracking-widest">Trading Name</label>
                    <input
                      value={formData.businessName}
                      onChange={(e) => setFormData({ ...formData, businessName: e.target.value })}
                      type="text" placeholder="e.g. Trendy Wears Lagos" className="w-full bg-white/5 border border-white/10 rounded-2xl p-5 focus:outline-none focus:border-primary/50 transition-all font-medium"
                    />
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-foreground/50 ml-1 uppercase tracking-widest">Service Description</label>
                    <textarea
                      value={formData.description}
                      onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                      placeholder="What exactly are you providing for this payment?" rows={3} className="w-full bg-white/5 border border-white/10 rounded-2xl p-5 focus:outline-none focus:border-primary/50 transition-all font-medium resize-none"
                    />
                  </div>
                </div>
              </motion.div>
            )}

            {/* Step 2: Identity */}
            {currentStep === 2 && (
              <motion.div key="step2" initial={{ x: 20, opacity: 0 }} animate={{ x: 0, opacity: 1 }} exit={{ x: -20, opacity: 0 }} className="space-y-6">
                <div className="flex items-center gap-3 mb-8">
                  <div className="p-3 bg-primary/10 rounded-2xl"><HugeiconsIcon icon={UserAccountIcon} className="w-6 h-6 text-primary" /></div>
                  <div>
                    <h3 className="text-xl font-bold">Identity Layer</h3>
                    <p className="text-sm text-foreground/50 font-medium">Verify your legal identity</p>
                  </div>
                </div>

                <div className="space-y-6">
                  <div className="p-5 bg-orange-500/10 border border-orange-500/20 rounded-2xl flex gap-4">
                    <HugeiconsIcon icon={InformationCircleIcon} className="w-6 h-6 text-orange-500 shrink-0" />
                    <p className="text-xs text-orange-200/80 font-medium leading-relaxed">
                      We require your National Identity Number (NIN) to ensure all transactions are accountable. Your data is encrypted.
                    </p>
                  </div>
                  <div className="space-y-2">
                    <label className="text-[10px] font-black text-foreground/50 ml-1 uppercase tracking-widest">NIN (11 Digits)</label>
                    <input
                      value={formData.nin}
                      onChange={(e) => setFormData({ ...formData, nin: e.target.value })}
                      type="text" maxLength={11} placeholder="00000000000" className="w-full bg-white/5 border border-white/10 rounded-2xl p-5 text-center text-2xl tracking-[0.5em] focus:outline-none focus:border-primary/50 transition-all font-bold"
                    />
                  </div>
                </div>
              </motion.div>
            )}

            {/* Step 3: Signals */}
            {currentStep === 3 && (
              <motion.div key="step3" initial={{ x: 20, opacity: 0 }} animate={{ x: 0, opacity: 1 }} exit={{ x: -20, opacity: 0 }} className="space-y-6">
                <div className="flex items-center gap-3 mb-8">
                  <div className="p-3 bg-primary/10 rounded-2xl"><HugeiconsIcon icon={Globe02Icon} className="w-6 h-6 text-primary" /></div>
                  <div>
                    <h3 className="text-xl font-bold">Trust Signals</h3>
                    <p className="text-sm text-foreground/50 font-medium">Prove your business activity</p>
                  </div>
                </div>

                {formData.businessType === "registered" ? (
                  <div className="space-y-5">
                    <div className="space-y-2">
                      <label className="text-[10px] font-black text-foreground/50 ml-1 uppercase tracking-widest">CAC Number (RC/BN)</label>
                      <input
                        value={formData.registration?.cacNumber}
                        onChange={(e) => setFormData({ ...formData, registration: { ...formData.registration!, cacNumber: e.target.value, companyName: formData.businessName } })}
                        type="text" placeholder="RC-1234567" className="w-full bg-white/5 border border-white/10 rounded-2xl p-5 focus:outline-none focus:border-primary/50 transition-all font-bold"
                      />
                    </div>
                  </div>
                ) : (
                  <div className="space-y-6">
                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <label className="text-[10px] font-black text-foreground/50 ml-1 uppercase tracking-widest">Business Category</label>
                        <select
                          value={formData.informalProfile?.businessCategory}
                          onChange={(e) => setFormData({ ...formData, informalProfile: { ...formData.informalProfile!, businessCategory: e.target.value } })}
                          className="w-full bg-white/5 border border-white/10 rounded-2xl p-5 focus:outline-none appearance-none font-bold"
                        >
                          <option value="">Select...</option>
                          <option value="fashion">Fashion</option>
                          <option value="food">Food & Drinks</option>
                          <option value="tech">Tech Services</option>
                          <option value="other">Other</option>
                        </select>
                      </div>
                      <div className="space-y-2">
                        <label className="text-[10px] font-black text-foreground/50 ml-1 uppercase tracking-widest">Years Active</label>
                        <input
                          value={formData.informalProfile?.yearsActive}
                          onChange={(e) => setFormData({ ...formData, informalProfile: { ...formData.informalProfile!, yearsActive: parseInt(e.target.value) || 0 } })}
                          type="number" className="w-full bg-white/5 border border-white/10 rounded-2xl p-5 focus:outline-none font-bold"
                        />
                      </div>
                    </div>
                    <div className="space-y-2">
                      <label className="text-[10px] font-black text-foreground/50 ml-1 uppercase tracking-widest">Primary Social Handle (Instagram)</label>
                      <div className="relative">
                        <HugeiconsIcon icon={InstagramIcon} className="absolute left-5 top-1/2 -translate-y-1/2 w-5 h-5 text-primary" />
                        <input
                          value={formData.socialProfiles[0].handle}
                          onChange={(e) => setFormData({ ...formData, socialProfiles: [{ platform: "instagram", handle: e.target.value }] })}
                          type="text" placeholder="@yourhandle" className="w-full bg-white/5 border border-white/10 rounded-2xl p-5 pl-12 focus:outline-none focus:border-primary/50 transition-all font-bold"
                        />
                      </div>
                    </div>
                  </div>
                )}
              </motion.div>
            )}

            {/* Step 4: Liveness */}
            {currentStep === 4 && (
              <motion.div key="step4" initial={{ x: 20, opacity: 0 }} animate={{ x: 0, opacity: 1 }} exit={{ x: -20, opacity: 0 }} className="space-y-6">
                <div className="flex items-center gap-3 mb-8">
                  <div className="p-3 bg-primary/10 rounded-2xl"><HugeiconsIcon icon={Camera01Icon} className="w-6 h-6 text-primary" /></div>
                  <div>
                    <h3 className="text-xl font-bold">Liveness Check</h3>
                    <p className="text-sm text-foreground/50 font-medium">Capture a selfie to verify it's you</p>
                  </div>
                </div>

                <Camera onCapture={(img) => setFormData({ ...formData, selfieImage: img })} />
              </motion.div>
            )}

            {/* Step 5: Review */}
            {currentStep === 5 && (
              <motion.div key="step5" initial={{ scale: 0.95, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} className="space-y-6">
                <div className="flex flex-col items-center text-center py-6">
                  <div className="w-20 h-20 rounded-full bg-green-500/10 flex items-center justify-center mb-4">
                    <HugeiconsIcon icon={CheckmarkCircle01Icon} className="w-10 h-10 text-green-500" />
                  </div>
                  <h3 className="text-2xl font-bold">Ready to Submit</h3>
                  <p className="text-sm text-foreground/50 mt-1">Review your details before final verification</p>
                </div>

                <div className="bg-white/5 border border-white/10 rounded-3xl p-6 space-y-4">
                  <div className="flex justify-between border-b border-white/5 pb-3">
                    <span className="text-xs font-bold text-foreground/40 uppercase">Business</span>
                    <span className="text-sm font-bold">{formData.businessName}</span>
                  </div>
                  <div className="flex justify-between border-b border-white/5 pb-3">
                    <span className="text-xs font-bold text-foreground/40 uppercase">Type</span>
                    <span className="text-sm font-bold capitalize">{formData.businessType}</span>
                  </div>
                  <div className="flex justify-between border-b border-white/5 pb-3">
                    <span className="text-xs font-bold text-foreground/40 uppercase">NIN Status</span>
                    <span className="text-sm font-bold text-primary">Provided</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-xs font-bold text-foreground/40 uppercase">Selfie</span>
                    <span className="text-sm font-bold text-green-500">Captured</span>
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Navigation */}
          <div className="flex items-center gap-4 mt-12">
            {currentStep > 1 && (
              <button onClick={() => setCurrentStep(prev => prev - 1)} className="flex-1 py-5 bg-white/5 border border-white/10 rounded-2xl font-bold flex items-center justify-center gap-2 hover:bg-white/10 transition-all active:scale-95">
                <HugeiconsIcon icon={ArrowLeft01Icon} className="w-5 h-5" /> Back
              </button>
            )}
            <button
              disabled={submitting || (currentStep === 4 && !formData.selfieImage) || (currentStep === 2 && formData.nin.length < 11)}
              onClick={() => {
                if (currentStep < 5) setCurrentStep(prev => prev + 1);
                else handleSubmit();
              }}
              className={`flex-[2] py-5 bg-primary-gradient rounded-2xl font-bold text-white hover:scale-[1.02] active:scale-95 transition-all flex items-center justify-center gap-2 group disabled:opacity-50 disabled:hover:scale-100 ${submitting ? 'animate-pulse' : ''}`}
            >
              {submitting ? 'Processing...' : currentStep === 5 ? 'Confirm & Submit' : 'Next Step'}
              {currentStep < 5 && !submitting && <HugeiconsIcon icon={ArrowRight01Icon} className="w-5 h-5 group-hover:translate-x-1 transition-transform" />}
            </button>
          </div>
        </div>
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
