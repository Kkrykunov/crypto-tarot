import React, { useState } from 'react';

function ReadingForm({ onCreateReading }) {
  const [name, setName] = useState("");
  const [question, setQuestion] = useState("");
  const [readingType, setReadingType] = useState("single_card");

  const handleSubmit = (e) => {
    e.preventDefault();
    
    // Create reading type object for backend
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
    
    onCreateReading({
      name: name || "Безіменний розклад",
      question: question || "Без питання",
      readingType: readingTypeObj
    });
  };

  return (
    <div className="reading-form-container">
      <h2>Створити новий розклад</h2>
      
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="reading-name">Назва розкладу (необов'язково):</label>
          <input 
            type="text" 
            id="reading-name"
            value={name}
            onChange={(e) => setName(e.target.value)}
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
          />
        </div>
        
        <div className="form-group">
          <label>Виберіть тип розкладу:</label>
          <div className="radio-group">
            <label className="radio-label">
              <input 
                type="radio" 
                name="reading-type" 
                value="single_card" 
                checked={readingType === "single_card"}
                onChange={() => setReadingType("single_card")}
              />
              <span>Одна карта (швидка відповідь)</span>
            </label>
            
            <label className="radio-label">
              <input 
                type="radio" 
                name="reading-type" 
                value="three_card" 
                checked={readingType === "three_card"}
                onChange={() => setReadingType("three_card")}
              />
              <span>Три карти (минуле-теперішнє-майбутнє)</span>
            </label>
            
            <label className="radio-label">
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
        
        <button type="submit" className="btn btn-primary">Створити розклад</button>
      </form>
    </div>
  );
}

export default ReadingForm;