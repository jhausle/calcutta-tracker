import { Routes, Route, Navigate } from 'react-router-dom';
import Games from './pages/Games';
import Results from './pages/Results';
import Owners from './pages/Owners';
import TournamentManagement from './pages/TournamentManagement';
import Bracket from './pages/Bracket';

function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<Navigate to="/games" replace />} />
      <Route path="/games" element={<Games />} />
      <Route path="/bracket" element={<Bracket />} />
      <Route path="/results" element={<Results />} />
      <Route path="/owners" element={<Owners />} />
      <Route path="/manage" element={<TournamentManagement />} />
    </Routes>
  );
}

export default AppRoutes; 