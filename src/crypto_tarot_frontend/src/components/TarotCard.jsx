import React, { useState, useEffect } from 'react';

function TarotCard({ card, position, readingType }) {
  const [flipped, setFlipped] = useState(false);
  const [positionName, setPositionName] = useState('');
  
  useEffect(() => {
    // Flip card after a delay
    const timer = setTimeout(() => {
      setFlipped(true);
    }, 500 + position * 300);
    
    // Set position name based on reading type
    setPositionNameByType();
    
    return () => clearTimeout(timer);
  }, []);
  
  function setPositionNameByType() {
    if ('single_card' in readingType) {
      setPositionName('Відповідь');
    } 
    else if ('three_card' in readingType) {
      const positions = ['Минуле', 'Теперішнє', 'Майбутнє'];
      setPositionName(positions[position] || `Позиція ${position + 1}`);
    }
    else if ('celtic_cross' in readingType) {
      const positions = [
        "Теперішнє", "Виклик", "Минуле", "Майбутнє", 
        "Ціль", "Підсвідоме", "Порада", "Зовнішнє", 
        "Надії/Страхи", "Результат"
      ];
      setPositionName(positions[position] || `Позиція ${position + 1}`);
    }
  }
  
  return (
    <div className={`tarot-card ${flipped ? 'flipped' : ''}`}>
      <div className="card-inner">
        <div className="card-front">
          <span>?</span>
        </div>
        <div className={`card-back ${card.isReversed ? 'reversed' : ''}`}>
          {card.isReversed && <div className="reversed-indicator">Перевернута</div>}
          <div className="card-name">{card.name}</div>
          <div className="card-description">{card.description}</div>
          <div className="card-meaning">
            {card.isReversed ? card.reversed_meaning : card.upright_meaning}
          </div>
          <div className="card-position">{positionName}</div>
        </div>
      </div>
    </div>
  );
}

export default TarotCard;