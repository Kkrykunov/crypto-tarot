import React, { useState, useEffect } from 'react';
import './index.scss';
import { AuthClient } from "@dfinity/auth-client";
import { crypto_tarot_backend } from "../../declarations/crypto_tarot_backend";

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [authClient, setAuthClient] = useState(null);
  const [principal, setPrincipal] = useState(null);
  const [reading, setReading] = useState(null);
  const [loading, setLoading] = useState(false);
  const [question, setQuestion] = useState("");
  const [readingName, setReadingName] = useState("");
  const [readingType, setReadingType] = useState("single_card");
  const [showHistory, setShowHistory] = useState(false);
  const [readingHistory, setReadingHistory] = useState([]);

  useEffect(() => {
    // Initialize auth client
    const initAuth = async () => {
      const client = await AuthClient.create();
      setAuthClient(client);
      
      if (await client.isAuthenticated()) {
        handleAuthenticated(client);
      }
    };
    
    initAuth();
  }, []);

  async function handleAuthenticated(client) {
    const userIdentity = client.getIdentity();
    setIsAuthenticated(true);
    setPrincipal(userIdentity.getPrincipal().toString());
    
    // Завантажити історію розкладів після автентифікації
    loadReadingHistory();
  }

  async function loadReadingHistory() {
    try {
      setLoading(true);
      const history = await crypto_tarot_backend.getUserReadings();
      setReadingHistory(history);
      setLoading(false);
    } catch (error) {
      console.error("Помилка завантаження історії:", error);
      setLoading(false);
    }
  }

  async function login() {
    if (authClient) {
      authClient.login({
        identityProvider: process.env.II_URL,
        onSuccess: () => {
          handleAuthenticated(authClient);
        },
      });
    }
  }

  async function logout() {
    if (authClient) {
      await authClient.logout();
      setIsAuthenticated(false);
      setPrincipal(null);
      setReading(null);
      setReadingHistory([]);
      setShowHistory(false);
    }
  }

  async function createReading() {
    try {
      setLoading(true);
      
      // Prepare reading type object
      let readingTypeObj;
      switch (readingType) {
        case 'single_card':
          readingTypeObj = { single_card: null };
          break;
        case 'three_card':
          readingTypeObj = { three_card: null };
          break;
        case 'celtic_cross':
          readingTypeObj = { celtic_cross: null };
          break;
        default:
          readingTypeObj = { single_card: null };
      }
      
      const result = await crypto_tarot_backend.createReading(
        readingName || "Безіменний розклад",
        question || "Без питання",
        readingTypeObj
      );
      
      setReading(result);
      setLoading(false);
      
      // Оновити історію після створення нового розкладу
      loadReadingHistory();
    } catch (error) {
      console.error("Error creating reading:", error);
      setLoading(false);
      alert("Помилка при створенні розкладу: " + error.message);
    }
  }

  // Функція для перевірки Plug Wallet
  async function checkPlugWallet() {
    // Перевіряємо, чи Plug доступний
    if (window.ic?.plug) {
      return true;
    } else {
      alert("Для донатів потрібно встановити Plug Wallet. Відвідайте https://plugwallet.ooo");
      window.open("https://plugwallet.ooo", "_blank");
      return false;
    }
  }

  // Функція для донатів через Plug Wallet
  async function donateWithPlug(amount) {
    if (!await checkPlugWallet()) return;
    
    try {
      // Запитуємо доступ до Plug
      const connected = await window.ic.plug.requestConnect();
      if (!connected) {
        alert("Будь ласка, підключіться до Plug Wallet");
        return;
      }

      // Здійснюємо транзакцію
      const result = await window.ic.plug.requestTransfer({
        to: "xtluj-cz345-i6wcz-vmzxq-nmvt2-3d24w-uu2vt-5cbmy-4guib-iifts-2qe",
        amount: Number(amount),
      });

      if (result) {
        alert("Дякуємо за вашу підтримку!");
      }
    } catch (error) {
      console.error("Помилка при донаті через Plug:", error);
      alert("Сталася помилка при здійсненні донату. Спробуйте пізніше.");
    }
  }

  function formatDate(timestamp) {
    const date = new Date(Number(timestamp) / 1000000);
    return date.toLocaleString('uk-UA');
  }
  
  function getReadingTypeName(readingType) {
    if ('single_card' in readingType) return 'Одна карта';
    if ('three_card' in readingType) return 'Три карти';
    if ('celtic_cross' in readingType) return 'Кельтський хрест';
    return 'Невідомий розклад';
  }

  return (
    <div className="app">
      <header className="header">
        <h1>Таро Мудрість Блокчейну</h1>
        <p>Розкладник Таро на блокчейні Internet Computer</p>
        
        <div className="auth-section">
          {isAuthenticated ? (
            <div className="user-info">
              <span>ID: {principal && `${principal.substring(0, 5)}...${principal.substring(principal.length - 5)}`}</span>
              <button onClick={logout}>Вийти</button>
            </div>
          ) : (
            <button onClick={login}>Увійти через Internet Identity</button>
          )}
        </div>
      </header>
      
      <main className="container">
        {loading && (
          <div className="loading-overlay">
            <div className="spinner"></div>
            <p>Тасуємо карти...</p>
          </div>
        )}
        
        {isAuthenticated && (
          <div className="nav-buttons">
            <button 
              onClick={() => {
                setShowHistory(false);
                setReading(null);
              }} 
              className={!showHistory && !reading ? "active" : ""}
            >
              Новий розклад
            </button>
            <button 
              onClick={() => {
                setShowHistory(true);
                setReading(null);
              }} 
              className={showHistory ? "active" : ""}
            >
              Історія розкладів
            </button>
          </div>
        )}
        
        {isAuthenticated ? (
          showHistory ? (
            <div className="reading-history">
              <h2>Історія ваших розкладів</h2>
              
              {readingHistory.length === 0 ? (
                <p className="no-readings">У вас ще немає збережених розкладів</p>
              ) : (
                <div className="readings-list">
                  {readingHistory.map((item, index) => (
                    <div 
                      key={index} 
                      className="reading-item" 
                      onClick={() => {
                        setReading(item);
                        setShowHistory(false);
                      }}
                    >
                      <h3>{item.name}</h3>
                      <p className="reading-date">{formatDate(item.timestamp)}</p>
                      <p className="reading-type">{getReadingTypeName(item.readingType)}</p>
                      <p className="reading-question">{item.question.substring(0, 50)}{item.question.length > 50 ? '...' : ''}</p>
                    </div>
                  ))}
                </div>
              )}
            </div>
          ) : reading ? (
            <div className="reading-result">
              <h2>{reading.name}</h2>
              <p>Створено: {formatDate(reading.timestamp)}</p>
              <p>Тип розкладу: {getReadingTypeName(reading.readingType)}</p>
              
              {reading.question && (
                <div className="question-box">
                  <h3>Ваше питання:</h3>
                  <p>{reading.question}</p>
                </div>
              )}
              
              <div className="cards-container">
                {reading.cards.map((card, index) => (
                  <div key={index} className={`card ${card.isReversed ? 'reversed' : ''}`}>
                    <h3>{card.name}</h3>
                    <p>{card.description}</p>
                    <p><strong>{card.isReversed ? 'Перевернуте значення:' : 'Пряме значення:'}</strong> {card.isReversed ? card.reversed_meaning : card.upright_meaning}</p>
                  </div>
                ))}
              </div>
              
              <div className="feedback-donation-section">
                <div className="feedback-section">
                  <h3>Ваші враження від розкладу:</h3>
                  <div className="feedback-buttons">
                    <button className="feedback-btn positive" onClick={() => alert("Дякуємо за позитивний відгук! Ми раді, що розклад був корисним.")}>
                      У мене гарний прогноз
                    </button>
                    <button className="feedback-btn negative" onClick={() => alert("Дякуємо за відгук. Карти показують лише можливості, майбутнє у ваших руках!")}>
                      У мене поганий прогноз
                    </button>
                  </div>
                </div>
                
                <div className="donation-section">
                  <h3>Підтримати проект:</h3>
                  <p>Всі донати йдуть на розвиток проекту і покращення розкладника</p>
                  
                  <div className="donation-options">
                    <button className="donation-btn" onClick={() => donateWithPlug(100000000)}>Донат 1 ICP через Plug</button>
                    <button className="donation-btn" onClick={() => donateWithPlug(500000000)}>Донат 5 ICP через Plug</button>
                    <button className="donation-btn" onClick={() => donateWithPlug(1000000000)}>Донат 10 ICP через Plug</button>
                  </div>
                  
                  <div className="wallet-addresses">
                    <h4>Або надішліть донат напряму на гаманці:</h4>
                    <div className="wallet-item">
                      <span className="wallet-type">ICP (Internet Computer):</span>
                      <code>xtluj-cz345-i6wcz-vmzxq-nmvt2-3d24w-uu2vt-5cbmy-4guib-iifts-2qe</code>
                      <button className="copy-btn" onClick={() => {
                        navigator.clipboard.writeText("xtluj-cz345-i6wcz-vmzxq-nmvt2-3d24w-uu2vt-5cbmy-4guib-iifts-2qe");
                        alert("Адресу ICP гаманця скопійовано!");
                      }}>
                        Копіювати
                      </button>
                    </div>
                    
                    <div className="wallet-item">
                      <span className="wallet-type">ETH (Ethereum):</span>
                      <code>0xeb348022421bc3b7957a4174F13bD326E4644745</code>
                      <button className="copy-btn" onClick={() => {
                        navigator.clipboard.writeText("0xeb348022421bc3b7957a4174F13bD326E4644745");
                        alert("Адресу ETH гаманця скопійовано!");
                      }}>
                        Копіювати
                      </button>
                    </div>
                    
                    <div className="wallet-item">
                      <span className="wallet-type">BTC (Bitcoin):</span>
                      <code>bc1pyqv54u5l59xjw99cwjaw7m9c86qy2ylz23wlyh0wdmuwme9zk7xska2ax3</code>
                      <button className="copy-btn" onClick={() => {
                        navigator.clipboard.writeText("bc1pyqv54u5l59xjw99cwjaw7m9c86qy2ylz23wlyh0wdmuwme9zk7xska2ax3");
                        alert("Адресу BTC гаманця скопійовано!");
                      }}>
                        Копіювати
                      </button>
                    </div>
                    
                    <div className="wallet-item">
                      <span className="wallet-type">SOL (Solana):</span>
                      <code>DBt5u7sVUJM7k6QiDZVLkRdkVrDu1k6X9GLhtWWr2evs</code>
                      <button className="copy-btn" onClick={() => {
                        navigator.clipboard.writeText("DBt5u7sVUJM7k6QiDZVLkRdkVrDu1k6X9GLhtWWr2evs");
                        alert("Адресу SOL гаманця скопійовано!");
                      }}>
                        Копіювати
                      </button>
                    </div>
                  </div>
                </div>
              </div>
              
              <button onClick={() => setReading(null)}>Новий розклад</button>
            </div>
          ) : (
            <div className="reading-form">
              <h2>Створити новий розклад</h2>
              
              <div className="form-group">
                <label htmlFor="reading-name">Назва розкладу (необов'язково):</label>
                <input 
                  type="text" 
                  id="reading-name"
                  value={readingName}
                  onChange={(e) => setReadingName(e.target.value)}
                  placeholder="Наприклад: Мій шлях на цей місяць"
                />
              </div>
              
              <div className="form-group">
                <label htmlFor="question">Ваше питання:</label>
                <textarea 
                  id="question"
                  value={question}
                  onChange={(e) => setQuestion(e.target.value)}
                  placeholder="Зосередьтесь на питанні, на яке хочете отримати відповідь..."
                ></textarea>
              </div>
              
              <div className="form-group">
                <label>Виберіть тип розкладу:</label>
                <div className="radio-group">
                  <label>
                    <input 
                      type="radio" 
                      name="reading-type" 
                      value="single_card" 
                      checked={readingType === "single_card"}
                      onChange={() => setReadingType("single_card")}
                    />
                    <span>Одна карта (швидка відповідь)</span>
                  </label>
                  
                  <label>
                    <input 
                      type="radio" 
                      name="reading-type" 
                      value="three_card" 
                      checked={readingType === "three_card"}
                      onChange={() => setReadingType("three_card")}
                    />
                    <span>Три карти (минуле-теперішнє-майбутнє)</span>
                  </label>
                  
                  <label>
                    <input 
                      type="radio" 
                      name="reading-type" 
                      value="celtic_cross" 
                      checked={readingType === "celtic_cross"}
                      onChange={() => setReadingType("celtic_cross")}
                    />
                    <span>Кельтський хрест (детальний розклад)</span>
                  </label>
                </div>
              </div>
              
              <button onClick={createReading}>Створити розклад</button>
            </div>
          )
        ) : (
          <div className="welcome-message">
            <h2>Ласкаво просимо до Таро Мудрості Блокчейну</h2>
            <p>Увійдіть через Internet Identity, щоб почати роботу з розкладником Таро на блокчейні.</p>
            <button onClick={login}>Увійти</button>
          </div>
        )}
      </main>
      
      <footer>
        <p>Працює на блокчейні Internet Computer</p>
        <p>Created for DoraHacks - Let's Try ICP NaUKMA ICP Hackathon</p>
      </footer>
    </div>
  );
}

export default App;