'use client';

import useSWR from 'swr';
import Timer from '@/components/Timer';

const fetcher = (url: string) => fetch(url).then((res) => res.json());

export default function Home() {
  const { data, error, isLoading, mutate } = useSWR('/api/event', fetcher, {
    refreshInterval: 60000, // Poll every minute
  });

  console.log('SWR Data:', data);
  console.log('SWR Error:', error);
  console.log('SWR Loading:', isLoading);

  const handleStart = async () => {
    if (!data?.id) return;

    try {
      await fetch('/api/event', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          pageId: data.id,
          newStatus: 'In Progress',
        }),
      });
    } catch (error) {
      console.error('Failed to update status to In Progress:', error);
    }
  };

  const handleComplete = async () => {
    if (!data?.id) return;

    try {
      await fetch('/api/event', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          pageId: data.id,
          newStatus: 'Completed',
        }),
      });

      // Immediately refresh to check for next task
      mutate();
    } catch (error) {
      console.error('Failed to update status to Completed:', error);
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-950">
        <p className="text-gray-400 text-sm">Syncing...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-950">
        <p className="text-red-400 text-sm">Error loading events</p>
      </div>
    );
  }

  if (!data?.id) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-950">
        <p className="text-gray-400 text-sm">No active events scheduled.</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-950">
      <Timer
        eventName={data.title}
        duration={data.duration}
        onStart={handleStart}
        onComplete={handleComplete}
      />
    </div>
  );
}
