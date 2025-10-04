'use client';

import { useState, useEffect } from 'react';

interface TimerProps {
  eventName: string;
  duration: number; // duration in seconds
  onStart: () => void;
  onComplete: () => void;
}

export default function Timer({ eventName, duration, onStart, onComplete }: TimerProps) {
  const [timeLeft, setTimeLeft] = useState(duration);
  const [isRunning, setIsRunning] = useState(false);
  const [hasStarted, setHasStarted] = useState(false);

  useEffect(() => {
    setTimeLeft(duration);
    setIsRunning(false);
    setHasStarted(false);
  }, [duration]);

  useEffect(() => {
    if (!isRunning) return;

    const interval = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev <= 1) {
          clearInterval(interval);
          setIsRunning(false);
          // Play sound when timer ends
          const audio = new Audio('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3');
          audio.play().catch(err => console.log('Audio play failed:', err));
          onComplete();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(interval);
  }, [isRunning, onComplete]);

  const handleStart = () => {
    if (!hasStarted) {
      onStart();
      setHasStarted(true);
    }
    setIsRunning(true);
  };

  const handlePause = () => {
    setIsRunning(false);
  };

  const handleSkip = () => {
    setIsRunning(false);
    onComplete();
  };

  const minutes = Math.floor(timeLeft / 60);
  const seconds = timeLeft % 60;
  const formattedTime = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;

  return (
    <div className="flex flex-col items-center justify-center p-6 bg-black/80 backdrop-blur-sm rounded-lg shadow-2xl max-w-sm mx-auto border border-gray-800">
      <h2 className="text-sm font-medium text-gray-500 mb-2">Current Task</h2>
      <p className="text-lg font-semibold text-white mb-6 text-center">{eventName}</p>

      <div className="text-7xl text-white mb-8 tracking-wider digital-font">
        {formattedTime}
      </div>

      <div className="flex gap-3 w-full">
        {!isRunning ? (
          <button
            onClick={handleStart}
            className="flex-1 px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-medium rounded-md transition-colors"
          >
            {hasStarted ? 'Resume' : 'Start'}
          </button>
        ) : (
          <button
            onClick={handlePause}
            className="flex-1 px-4 py-2.5 bg-yellow-600 hover:bg-yellow-700 text-white font-medium rounded-md transition-colors"
          >
            Pause
          </button>
        )}

        <button
          onClick={handleSkip}
          className="px-4 py-2.5 bg-gray-700 hover:bg-gray-600 text-white font-medium rounded-md transition-colors"
        >
          Skip
        </button>
      </div>
    </div>
  );
}
