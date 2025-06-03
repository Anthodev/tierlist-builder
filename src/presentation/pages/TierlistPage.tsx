import React from 'react';

export const TierlistPage: React.FC = () => {
  return (
    <div className="min-h-screen bg-background">
      <header className="border-b">
        <div className="container mx-auto px-4 py-4">
          <h1 className="text-2xl font-bold">Tierlist Builder</h1>
        </div>
      </header>
      <main className="container mx-auto px-4 py-8">
        <p className="text-muted-foreground">Welcome to the Tierlist Builder!</p>
      </main>
    </div>
  );
};