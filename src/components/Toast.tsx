import { useEffect, useState } from "react";
import { CheckCircle2 } from "lucide-react";

interface ToastProps {
  message: string | null;
  onDone: () => void;
  duration?: number;
}

export default function Toast({ message, onDone, duration = 2500 }: ToastProps) {
  const [visible, setVisible] = useState(false);
  const [exiting, setExiting] = useState(false);

  useEffect(() => {
    if (!message) return;
    setVisible(true);
    setExiting(false);

    const exitTimer = setTimeout(() => setExiting(true), duration);
    const doneTimer = setTimeout(() => {
      setVisible(false);
      setExiting(false);
      onDone();
    }, duration + 300);

    return () => {
      clearTimeout(exitTimer);
      clearTimeout(doneTimer);
    };
  }, [message, duration, onDone]);

  if (!visible || !message) return null;

  return (
    <div className="fixed top-0 left-0 right-0 z-50 flex justify-center px-4 pt-3 pointer-events-none">
      <div
        className={`pointer-events-auto flex items-center gap-2.5 bg-emerald-500 dark:bg-emerald-600 text-white px-5 py-3 rounded-2xl shadow-lg shadow-emerald-500/20 text-sm font-semibold ${
          exiting ? "toast-exit" : "toast-enter"
        }`}
      >
        <CheckCircle2 size={18} strokeWidth={2.5} />
        {message}
      </div>
    </div>
  );
}
