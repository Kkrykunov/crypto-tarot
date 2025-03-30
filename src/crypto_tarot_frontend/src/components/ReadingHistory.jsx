import React, { useState, useEffect } from 'react';
import { crypto_tarot_backend } from "../../../declarations/crypto_tarot_backend";

function ReadingHistory({ setCurrentReading, setShowHistory }) {
  const [readings, setReadings] = useState([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    loadReadings();
  }, []);
  
  async function loadReadings() {
    try {
      setLoading(true);
      const userReadings = await crypto_tarot_backend.getUserReadings();
      setReadings(userReadings);
      setLoading(false);
    } catch (error) {
      console.error("Error loading reading history:", error);
      setLoading(false);
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
  
  function viewReading(reading) {
    setCurrentReading(reading);
    setShowHistory(false);
  }
  
  return (
    <div className="reading-history">
      <h2>Історія розкладів</h2>
      
      {loading ? (
        <div className="loading-message">Завантаження історії...</div>
      ) : readings.length === 0 ? (
        <div className="no-readings">
          <p>У вас ще немає збережених розкладів.</p>
          <button 
            className="btn primary" 
            onClick={() => setShowHistory(false)}
          >
            Створити перший розклад
          </button>
        </div>
      ) : (
        <>
          <div className="readings-list">
            {readings.map((reading, index) => (
              <div 
                key={index} 
                className="reading-item" 
                onClick={() => viewReading(reading)}
              >
                <h3>{reading.name}</h3>
                <p className="reading-date">{formatDate(reading.timestamp)}</p>
                <p className="reading-type">{getReadingTypeName(reading.readingType)}</p>
                <p className="reading-question">
                  {reading.question.substring(0, 50)}
                  {reading.question.length > 50 ? '...' : ''}
                </p>
              </div>
            ))}
          </div>
          
          <button 
            className="btn primary" 
            onClick={() => setShowHistory(false)}
          >
            Створити новий розклад
          </button>
        </>
      )}
    </div>
  );
}

export default ReadingHistory;