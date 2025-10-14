'use client';

import { useState, useEffect, useMemo } from 'react';

interface TimerProps {
  eventName: string;
  duration: number; // duration in seconds
  onStart: () => void;
  onComplete: () => void;
}

export default function Timer({ eventName, duration, onStart, onComplete }: TimerProps) {
  const [timeLeft, setTimeLeft] = useState(duration);
  const [isRunning, setIsRunning] = useState(false);
  const audio = useMemo(() => typeof Audio !== 'undefined' ? new Audio('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3') : undefined, []);

  useEffect(() => {
    setTimeLeft(duration);
    setIsRunning(true);
    onStart();
    // Reset timer if the event name or duration changes
  }, [eventName, duration, onStart]);

  useEffect(() => {
    if (!isRunning || timeLeft <= 0) {
      if (timeLeft <= 0 && isRunning) {
        // Timer finished
        audio?.play().catch(err => console.error('Audio play failed:', err));
        onComplete();
        setIsRunning(false);
      }
      return;
    }

    const interval = setInterval(() => {
      setTimeLeft((prev) => prev - 1);
    }, 1000);

    return () => clearInterval(interval);
  }, [isRunning, timeLeft, onComplete, audio]);

  const minutes = Math.floor(timeLeft / 60);
  const seconds = timeLeft % 60;
  const formattedTime = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;

  return (
    <div className="flex flex-col items-center justify-center p-4 bg-black/80 backdrop-blur-sm rounded-lg shadow-2xl max-w-xs mx-auto border border-gray-800">
      <h2 className="text-xs font-medium text-gray-500 mb-1.5">Current Task</h2>
      <p className="text-sm font-semibold text-white mb-4 text-center">{eventName}</p>

      <div className="text-5xl text-white mb-6 tracking-wider digital-font">
        {formattedTime}
      </div>
    </div>
  );
}
