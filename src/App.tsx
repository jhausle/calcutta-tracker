import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ShoppingBasket as Basketball } from 'lucide-react';
import Navigation from './components/Navigation';
import Games from './pages/Games';
import Results from './pages/Results';
import Owners from './pages/Owners';
import TournamentManagement from './pages/TournamentManagement';
import Bracket from './pages/Bracket';

function App() {
  return (
    <BrowserRouter>
      <div className="min-h-screen bg-gray-50">
        <header className="bg-blue-600 text-white py-6 shadow-lg">
          <div className="container mx-auto px-4">
            <div className="flex items-center justify-center space-x-3">
              <Basketball size={32} />
              <h1 className="text-3xl font-bold">Bozo Boys Calcutta Tracker</h1>
            </div>
            <Navigation />
          </div>
        </header>

        <main className="container mx-auto px-4 py-8">
          <Routes>
            <Route path="/" element={<Navigate to="/games" replace />} />
            <Route path="/games" element={<Games />} />
            <Route path="/bracket" element={<Bracket />} />
            <Route path="/results" element={<Results />} />
            <Route path="/owners" element={<Owners />} />
            <Route path="/manage" element={<TournamentManagement />} />
          </Routes>
        </main>

        <footer className="bg-gray-100 py-4 mt-8">
          <div className="container mx-auto px-4 text-center text-gray-600">
            <p>Data provided by ESPN</p>
          </div>
        </footer>
      </div>
    </BrowserRouter>
  );
}

export default App