import React, { useState, useEffect } from 'react';
import TarotCard from './TarotCard';

function ReadingResult({ reading, onNewReading }) {
  const [interpretation, setInterpretation] = useState('');
  
  useEffect(() => {
    if (reading) {
      generateInterpretation();
    }
  }, [reading]);
  
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
  
  function generateInterpretation() {
    if (!reading) return '';
    
    let text = '';
    
    if ('single_card' in reading.readingType) {
      // Single card interpretation
      const card = reading.cards[0];
      text = `<h3>Інтерпретація розкладу</h3>
              <p>Карта ${card.name} ${card.isReversed ? '(у перевернутому положенні)' : ''} вказує на:</p>
              <p>${card.description}</p>
              <p>${card.isReversed ? card.reversed_meaning : card.upright_meaning}</p>`;
    } 
    else if ('three_card' in reading.readingType) {
      // Three card interpretation
      text = `<h3>Інтерпретація розкладу на три карти</h3>
              <div class="position-interpretation">
                <h4>Минуле: ${reading.cards[0].name}</h4>
                <p>${reading.cards[0].description}</p>
                <p>${reading.cards[0].isReversed ? reading.cards[0].reversed_meaning : reading.cards[0].upright_meaning}</p>
              </div>
              <div class="position-interpretation">
                <h4>Теперішнє: ${reading.cards[1].name}</h4>
                <p>${reading.cards[1].description}</p>
                <p>${reading.cards[1].isReversed ? reading.cards[1].reversed_meaning : reading.cards[1].upright_meaning}</p>
              </div>
              <div class="position-interpretation">
                <h4>Майбутнє: ${reading.cards[2].name}</h4>
                <p>${reading.cards[2].description}</p>
                <p>${reading.cards[2].isReversed ? reading.cards[2].reversed_meaning : reading.cards[2].upright_meaning}</p>
              </div>`;
    }
    else if ('celtic_cross' in reading.readingType) {
      // Celtic Cross interpretation
      const positions = [
        "Теперішнє - Що впливає на вас зараз",
        "Виклик - З якою перешкодою ви стикаєтесь",
        "Минуле - Недавні події, що впливають на ситуацію",
        "Майбутнє - Куди рухається ситуація",
        "Зверху - Ваша мета або найкращий результат",
        "Знизу - Приховані почуття або мотиви",
        "Порада - Як слід підходити до ситуації",
        "Зовнішні впливи - Як інші бачать вас",
        "Надії/Страхи - На що ви сподіваєтесь чи чого боїтесь",
        "Результат - Ймовірний підсумок"
      ];
      
      text = `<h3>Інтерпретація Кельтського хреста</h3>`;
      
      for (let i = 0; i < Math.min(positions.length, reading.cards.length); i++) {
        const card = reading.cards[i];
        text += `<div class="position-interpretation">
                  <h4>${positions[i]}: ${card.name}</h4>
                  <p>${card.description}</p>
                  <p>${card.isReversed ? card.reversed_meaning : card.upright_meaning}</p>
                </div>`;
      }
    }
    
    setInterpretation(text);
  }
  
  if (!reading) return null;
  
  return (
    <div className="reading-result">
      <h2>{reading.name}</h2>
      <p className="reading-date">Виконано: {formatDate(reading.timestamp)}</p>
      <p className="reading-type">{getReadingTypeName(reading.readingType)}</p>
      
      {reading.question && (
        <div className="question-box">
          <h3>Ваше питання:</h3>
          <p>{reading.question}</p>
        </div>
      )}
      
      <div className="cards-container">
        {reading.cards.map((card, index) => (
          <TarotCard 
            key={index} 
            card={card} 
            position={index}
            readingType={reading.readingType}
          />
        ))}
      </div>
      
      <div 
        className="reading-interpretation"
        dangerouslySetInnerHTML={{ __html: interpretation }}
      />
      
      <div className="reading-actions">
        <button onClick={onNewReading} className="btn btn-primary">
          Новий розклад
        </button>
      </div>
    </div>
  );
}

export default ReadingResult;