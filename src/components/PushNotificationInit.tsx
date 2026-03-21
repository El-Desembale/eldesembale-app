'use client';

import { useEffect } from 'react';
import { getToken } from 'firebase/messaging';
import { getMessagingInstance } from '@/lib/firebase';
import { saveFcmToken } from '@/lib/firestore';
import { User } from 'firebase/auth';

interface Props {
  user: User;
}

export function PushNotificationInit({ user }: Props) {
  useEffect(() => {
    const init = async () => {
      try {
        const messaging = await getMessagingInstance();
        if (!messaging) return;

        const permission = await Notification.requestPermission();
        if (permission !== 'granted') return;

        const vapidKey = process.env.NEXT_PUBLIC_FIREBASE_VAPID_KEY;
        const token = await getToken(messaging, { vapidKey });
        if (token) {
          await saveFcmToken(user.uid, token);
        }
      } catch (e) {
        console.error('Error initializing push notifications:', e);
      }
    };

    init();
  }, [user]);

  return null;
}
