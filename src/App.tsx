import React from 'react';
import { AppProviders } from './app/providers/AppProviders';
import { TierlistPage } from './presentation/pages/TierlistPage';

const App: React.FC = () => {
  return (
    <AppProviders>
      <TierlistPage />
    </AppProviders>
  );
};

export default App;