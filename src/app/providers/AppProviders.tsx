import React from 'react';

interface AppProvidersProps {
  children: React.ReactNode;
}

export const AppProviders: React.FC<AppProvidersProps> = ({ children }) => {
  return (
    <>
      {/* Future providers will be added here:
          - Theme Provider
          - Tierlist Provider (global state)
          - Toast/Notification Provider
      */}
      {children}
    </>
  );
};