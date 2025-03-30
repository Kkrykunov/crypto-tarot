import React from 'react';

function Header({ isAuthenticated, principal, login, logout, showHistory, showHome }) {
  return (
    <header className="app-header">
      <div className="logo" onClick={showHome}>
        <h1>🔮 Crypto Tarot</h1>
        <p>Розклад Таро на блокчейні</p>
      </div>
      
      <div className="header-actions">
        {isAuthenticated ? (
          <>
            <div className="user-info">
              <span className="principal-id" title={principal}>
                {principal ? principal.substring(0, 5) + '...' + principal.substring(principal.length - 5) : ''}
              </span>
            </div>
            <button className="btn btn-secondary" onClick={showHistory}>Історія</button>
            <button className="btn btn-outline" onClick={logout}>Вийти</button>
          </>
        ) : (
          <button className="btn btn-primary" onClick={login}>Увійти</button>
        )}
      </div>
    </header>
  );
}

export default Header;