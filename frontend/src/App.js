import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Dashboard from './pages/Dashboard';
import Login from './pages/Login';
import Menus from './pages/Menus';
import Recipes from './pages/Recipes';
import Inventory from './pages/Inventory';
import Reports from './pages/Reports';
import Settings from './pages/Settings';

function App() {
  const token = localStorage.getItem('token');

  return (
    <Router>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="/dashboard" element={token ? <Dashboard /> : <Navigate to="/login" />} />
        <Route path="/menus" element={token ? <Menus /> : <Navigate to="/login" />} />
        <Route path="/recipes" element={token ? <Recipes /> : <Navigate to="/login" />} />
        <Route path="/inventory" element={token ? <Inventory /> : <Navigate to="/login" />} />
        <Route path="/reports" element={token ? <Reports /> : <Navigate to="/login" />} />
        <Route path="/settings" element={token ? <Settings /> : <Navigate to="/login" />} />
        <Route path="/" element={token ? <Navigate to="/dashboard" /> : <Navigate to="/login" />} />
      </Routes>
    </Router>
  );
}

export default App;
