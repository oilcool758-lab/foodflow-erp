import React from 'react';
import Navigation from '../components/Navigation';

function Settings() {
  return (
    <div className="flex h-screen bg-gray-100">
      <Navigation />
      <div className="flex-1 overflow-auto p-8">
        <h1 className="text-3xl font-bold mb-8 text-gray-800">Settings</h1>
        <p className="text-gray-600">Settings Coming Soon...</p>
      </div>
    </div>
  );
}

export default Settings;
