import React from 'react';
import { NavLink } from 'react-router-dom';

const Navigation = () => {
  const linkClasses = "px-4 py-2 text-white hover:bg-blue-700 rounded transition-colors";
  const activeLinkClasses = "bg-blue-700";

  return (
    <nav className="mt-4 flex justify-center space-x-4">
      <NavLink 
        to="/games" 
        className={({ isActive }) => `${linkClasses} ${isActive ? activeLinkClasses : ''}`}
      >
        Games
      </NavLink>
      <NavLink 
        to="/bracket" 
        className={({ isActive }) => `${linkClasses} ${isActive ? activeLinkClasses : ''}`}
      >
        Tournament Bracket
      </NavLink>
      <NavLink 
        to="/results" 
        className={({ isActive }) => `${linkClasses} ${isActive ? activeLinkClasses : ''}`}
      >
        Tournament Results
      </NavLink>
      <NavLink 
        to="/owners" 
        className={({ isActive }) => `${linkClasses} ${isActive ? activeLinkClasses : ''}`}
      >
        Owners
      </NavLink>
      <NavLink 
        to="/manage" 
        className={({ isActive }) => `${linkClasses} ${isActive ? activeLinkClasses : ''}`}
      >
        Manage Tournament
      </NavLink>
    </nav>
  );
}

export default Navigation;