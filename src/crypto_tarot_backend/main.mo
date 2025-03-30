import Array "mo:base/Array";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Random "mo:base/Random";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";

actor CryptoTarot {
    // Типи для нашого додатку
    public type CardId = Nat;
    public type CardName = Text;

    // Тип карти Таро
    public type TarotCard = {
        id: CardId;
        name: CardName;
        description: Text;
        upright_meaning: Text;
        reversed_meaning: Text;
        isReversed: Bool;
    };
    
    // Тип для розкладу
    public type ReadingType = {
        #single_card;
        #three_card;
        #celtic_cross;
    };
    
    // Тип для збереженого розкладу
    public type SavedReading = {
        id: Text;
        user: Principal;
        name: Text;
        question: Text;
        readingType: ReadingType;
        cards: [TarotCard];
        timestamp: Int;
    };

    // Стабільне сховище для розкладів (зберігається між оновленнями кодової бази)
    private stable var readingsEntries : [(Text, SavedReading)] = [];
    private var readings = HashMap.HashMap<Text, SavedReading>(
        0, Text.equal, Text.hash
    );
    
    private stable var nextReadingId : Nat = 0;

    // Визначення всіх карт Таро (буде створено при ініціалізації)
    private var tarotDeck : [TarotCard] = [];
    
    // Ініціалізація колоди Таро
    private func initializeTarotDeck() {
        let buffer = Buffer.Buffer<TarotCard>(78); // Створюємо буфер для 78 карт
        
        // Додаємо Старші аркани (0-21)
        buffer.add({ 
            id = 0; 
            name = "0 - The Fool"; 
            description = "Початок, спонтанність, безтурботність, ризик, потенціал";
            upright_meaning = "Пригода, нові можливості, потенціал, удача новачка";
            reversed_meaning = "Безрозсудність, ризикована поведінка, погане судження, апатія";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 1; 
            name = "I - The Magician"; 
            description = "Маніфестація, винахідливість, сила";
            upright_meaning = "Творчість, сила волі, намір, рішучість";
            reversed_meaning = "Маніпуляція, погане планування, невикористані таланти";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 2; 
            name = "II - The High Priestess"; 
            description = "Інтуїція, священне знання, божественна жіночність";
            upright_meaning = "Внутрішній голос, підсвідомість, глибоке знання";
            reversed_meaning = "Секрети, відключення від інтуїції, приховування інформації";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 3; 
            name = "III - The Empress"; 
            description = "Жіночність, краса, природа";
            upright_meaning = "Турбота, достаток, родючість, материнська опіка";
            reversed_meaning = "Залежність, придушення, пустота, руйнування";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 4; 
            name = "IV - The Emperor"; 
            description = "Авторитет, структура, контроль, захист";
            upright_meaning = "Стабільність, лідерство, впевненість, сила волі";
            reversed_meaning = "Домінування, надмірний контроль, непохитність, негнучкість";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 5; 
            name = "V - The Hierophant"; 
            description = "Традиція, духовність, освіта, інституції";
            upright_meaning = "Мудрість, дотримання правил, духовний пошук, навчання";
            reversed_meaning = "Догматизм, обмеження, надмірна залежність від традицій";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 6; 
            name = "VI - The Lovers"; 
            description = "Любов, гармонія, вибір, спілкування";
            upright_meaning = "Справжня любов, партнерство, гармонійний союз, важливий вибір";
            reversed_meaning = "Дисбаланс, розлучення, поганий вибір, неузгодженість цінностей";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 7; 
            name = "VII - The Chariot"; 
            description = "Перемога, подорож, впевненість, рішучість";
            upright_meaning = "Досягнення, контроль, подолання перешкод, цілеспрямованість";
            reversed_meaning = "Втрата контролю, відсутність напрямку, агресія, поразка";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 8; 
            name = "VIII - Strength"; 
            description = "Сила, мужність, переконання, вплив";
            upright_meaning = "Внутрішня сила, сміливість, терпіння, самоконтроль";
            reversed_meaning = "Слабкість, невпевненість, відсутність самоконтролю, сумніви";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 9; 
            name = "IX - The Hermit"; 
            description = "Роздуми, самотність, внутрішній пошук";
            upright_meaning = "Мудрість, самоаналіз, духовний пошук, споглядання";
            reversed_meaning = "Ізоляція, самота, ігнорування життєвих уроків, відчуження";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 10; 
            name = "X - Wheel of Fortune"; 
            description = "Доля, удача, зміни, цикли";
            upright_meaning = "Хороша удача, доля, карма, життєві цикли, поворотні моменти";
            reversed_meaning = "Невдача, негативні зміни, відсутність контролю, зовнішні сили";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 11; 
            name = "XI - Justice"; 
            description = "Справедливість, чесність, закон, правда";
            upright_meaning = "Рівновага, чесність, ясність, причина і наслідок";
            reversed_meaning = "Несправедливість, нечесність, відсутність відповідальності";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 12; 
            name = "XII - The Hanged Man"; 
            description = "Жертва, перспектива, очікування, відпускання";
            upright_meaning = "Новий погляд, розширення свідомості, здатність відпускати";
            reversed_meaning = "Егоїзм, стагнація, опір, непотрібні жертви";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 13; 
            name = "XIII - Death"; 
            description = "Кінець, перехід, трансформація, оновлення";
            upright_meaning = "Трансформація, прийняття змін, завершення циклу";
            reversed_meaning = "Опір змінам, страх, невдача трансформації, стагнація";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 14; 
            name = "XIV - Temperance"; 
            description = "Баланс, помірність, терпіння, інтеграція";
            upright_meaning = "Гармонія, рівновага, поміркованість, поєднання";
            reversed_meaning = "Дисбаланс, надмірність, недостатня інтеграція, конфлікт";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 15; 
            name = "XV - The Devil"; 
            description = "Залежність, матеріалізм, темна сторона, спокуса";
            upright_meaning = "Залежність, негативні шаблони, матеріалізм, тіньова сторона";
            reversed_meaning = "Звільнення, подолання залежностей, відокремлення";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 16; 
            name = "XVI - The Tower"; 
            description = "Раптові зміни, хаос, руйнування, одкровення";
            upright_meaning = "Різкі зміни, прорив, криза, одкровення, пробудження";
            reversed_meaning = "Уникнення катастрофи, страх змін, продовження кризи";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 17; 
            name = "XVII - The Star"; 
            description = "Надія, натхнення, оновлення, духовність";
            upright_meaning = "Надія, віра, зцілення, відновлення, духовне осяяння";
            reversed_meaning = "Безнадійність, розчарування, відсутність віри в себе";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 18; 
            name = "XVIII - The Moon"; 
            description = "Ілюзії, несвідоме, страхи, підсвідомість";
            upright_meaning = "Інтуїція, сни, підсвідомі сили, невизначеність";
            reversed_meaning = "Страх, обман, заплутаність, неправильне розуміння";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 19; 
            name = "XIX - The Sun"; 
            description = "Радість, успіх, оптимізм, енергія";
            upright_meaning = "Щастя, успіх, позитивність, життєва сила, оптимізм";
            reversed_meaning = "Тимчасові труднощі, відсутність ясності, надмірний оптимізм";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 20; 
            name = "XX - Judgement"; 
            description = "Відродження, пробудження, відновлення, вирішення";
            upright_meaning = "Пробудження, оновлення, духовне осяяння, рішення";
            reversed_meaning = "Страх змін, опір трансформації, самокритика";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 21; 
            name = "XXI - The World"; 
            description = "Завершення, досягнення, інтеграція, подорож";
            upright_meaning = "Завершеність, цілісність, успіх, досягнення, гармонія";
            reversed_meaning = "Відсутність завершеності, затримки, розчарування";
            isReversed = false;
        });
        
        // Додаємо Молодші аркани - Жезли
        buffer.add({ 
            id = 22; 
            name = "Ace of Wands"; 
            description = "Нові можливості, натхнення, творчий потенціал";
            upright_meaning = "Творчий початок, ентузіазм, новий проект або ідея";
            reversed_meaning = "Затримка, блок творчості, відсутність напрямку";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 23; 
            name = "Two of Wands"; 
            description = "Планування, вибір шляху, початок реалізації";
            upright_meaning = "Планування майбутнього, прийняття рішень, підготовка";
            reversed_meaning = "Страх вибору, нерішучість, затримка в планах";
            isReversed = false;
        });

        buffer.add({ 
            id = 24; 
            name = "Three of Wands"; 
            description = "Розширення, дальновидність, підприємництво";
            upright_meaning = "Прогрес, дальновидність, передбачення, розширення проектів";
            reversed_meaning = "Затримки, розчарування, перешкоди в бізнесі";
            isReversed = false;
        });

        buffer.add({ 
            id = 25; 
            name = "Four of Wands"; 
            description = "Святкування, гармонія, досягнення, спільнота";
            upright_meaning = "Стабільність, святкування, досягнення, домашнє щастя";
            reversed_meaning = "Незавершеність, неузгодженість, відсутність підтримки";
            isReversed = false;
        });

        buffer.add({ 
            id = 26; 
            name = "Five of Wands"; 
            description = "Конфлікт, конкуренція, боротьба";
            upright_meaning = "Конфлікти, конкуренція, протиріччя, дискусії";
            reversed_meaning = "Вирішення конфліктів, співпраця, уникнення конфронтації";
            isReversed = false;
        });

        buffer.add({ 
            id = 27; 
            name = "Six of Wands"; 
            description = "Перемога, успіх, визнання";
            upright_meaning = "Перемога, досягнення, публічне визнання, гордість";
            reversed_meaning = "Падіння, сумніви у власному успіху, марнославство";
            isReversed = false;
        });

        buffer.add({ 
            id = 28; 
            name = "Seven of Wands"; 
            description = "Захист, стійкість, виклик";
            upright_meaning = "Відстоювання позиції, конкуренція, захист переконань";
            reversed_meaning = "Капітуляція, перевищення повноважень, відчуття поразки";
            isReversed = false;
        });

        buffer.add({ 
            id = 29; 
            name = "Eight of Wands"; 
            description = "Швидкість, рух, прогрес";
            upright_meaning = "Швидкі дії, рух, комунікація, подорожі";
            reversed_meaning = "Затримки, розчарування, внутрішній опір, сварки";
            isReversed = false;
        });

        buffer.add({ 
            id = 30; 
            name = "Nine of Wands"; 
            description = "Впевненість, стійкість, рішучість";
            upright_meaning = "Стійкість, сила, підготовка до останньої битви";
            reversed_meaning = "Впертість, параноя, виснаження, здача позицій";
            isReversed = false;
        });

        buffer.add({ 
            id = 31; 
            name = "Ten of Wands"; 
            description = "Тягар, відповідальність, важка праця";
            upright_meaning = "Перевантаження, тягар, наполегливість, відданість";
            reversed_meaning = "Вигорання, відмова від відповідальності, делегування";
            isReversed = false;
        });

        buffer.add({ 
            id = 32; 
            name = "Page of Wands"; 
            description = "Ентузіазм, дослідження, творчий потенціал";
            upright_meaning = "Дослідження, ентузіазм, свобода, пригоди";
            reversed_meaning = "Нестабільність, затримки, погані новини, поверховість";
            isReversed = false;
        });

        buffer.add({ 
            id = 33; 
            name = "Knight of Wands"; 
            description = "Енергія, пристрасть, дія, пригоди";
            upright_meaning = "Енергійність, впевненість, імпульсивність, пригоди";
            reversed_meaning = "Гнів, імпульсивність, необдумані дії, затримки";
            isReversed = false;
        });

        buffer.add({ 
            id = 34; 
            name = "Queen of Wands"; 
            description = "Впевненість, оптимізм, незалежність";
            upright_meaning = "Впевненість, визначеність, лідерство, привабливість";
            reversed_meaning = "Ревнощі, залежність, поганий темперамент, невпевненість";
            isReversed = false;
        });

        buffer.add({ 
            id = 35; 
            name = "King of Wands"; 
            description = "Лідерство, бачення, відвага, харизма";
            upright_meaning = "Лідерство, підприємництво, відвага, стратегія";
            reversed_meaning = "Жорстокість, необдуманість, невміння делегувати, імпульсивність";
            isReversed = false;
        });

        // Додаємо Молодші аркани - Чаші
        buffer.add({ 
            id = 36; 
            name = "Ace of Cups"; 
            description = "Нові почуття, духовність, інтуїція";
            upright_meaning = "Нові стосунки, співчуття, творчість";
            reversed_meaning = "Емоційна втрата, заблокована творчість, пустота";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 37; 
            name = "Two of Cups"; 
            description = "Партнерство, взаємність, спорідненість";
            upright_meaning = "Союз, любов, дружба, партнерство, взаємна привабливість";
            reversed_meaning = "Дисбаланс, конфлікти, непорозуміння в стосунках";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 38; 
            name = "Three of Cups"; 
            description = "Святкування, дружба, творчість";
            upright_meaning = "Дружба, святкування, співпраця, радість, спільнота";
            reversed_meaning = "Перебільшення, тріський у стосунках, самотність";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 39; 
            name = "Four of Cups"; 
            description = "Апатія, споглядання, переоцінка";
            upright_meaning = "Апатія, споглядання, нереалізовані можливості";
            reversed_meaning = "Нові цілі, рух вперед, прийняття нового";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 40; 
            name = "Five of Cups"; 
            description = "Втрата, жаль, розчарування";
            upright_meaning = "Розчарування, смуток за минулим, зосередження на негативі";
            reversed_meaning = "Прийняття втрати, рух вперед, знаходження утіхи";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 41; 
            name = "Six of Cups"; 
            description = "Ностальгія, спогади, невинність";
            upright_meaning = "Ностальгія, дитячі спогади, невинність, радість";
            reversed_meaning = "Зациклення на минулому, нереалістичні спогади";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 42; 
            name = "Seven of Cups"; 
            description = "Можливості, вибір, мрії";
            upright_meaning = "Видіння, можливості, вибір, фантазії, мрії";
            reversed_meaning = "Розчарування, ілюзії, неясність щодо майбутнього";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 43; 
            name = "Eight of Cups"; 
            description = "Відхід, розчарування, духовний пошук";
            upright_meaning = "Відхід, залишення позаду, рух далі, шукання дечого глибшого";
            reversed_meaning = "Страх змін, застійність, страх невідомого";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 44; 
            name = "Nine of Cups"; 
            description = "Задоволення, радість, емоційне виконання";
            upright_meaning = "Задоволення бажань, емоційне здійснення, щастя";
            reversed_meaning = "Матеріалізм, пусте задоволення, завищені очікування";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 45; 
            name = "Ten of Cups"; 
            description = "Божественна любов, щасливі стосунки, гармонія";
            upright_meaning = "Гармонія, шлюб, родинне щастя";
            reversed_meaning = "Розбита сім'я, домашній конфлікт, нещастя";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 46; 
            name = "Page of Cups"; 
            description = "Інтуїція, можливості, емоційні пропозиції";
            upright_meaning = "Творчі можливості, інтуїція, чутливість, добрі новини";
            reversed_meaning = "Емоційна незрілість, блокування інтуїції, розчарування";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 47; 
            name = "Knight of Cups"; 
            description = "Романтика, ідеалізм, чарівність";
            upright_meaning = "Романтичні пропозиції, ідеалізм, харизма, артистичність";
            reversed_meaning = "Емоційна нестабільність, обман, маніпуляції";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 48; 
            name = "Queen of Cups"; 
            description = "Емоційна безпека, інтуїція, співчуття";
            upright_meaning = "Інтуїція, емпатія, емоційна стабільність, турбота";
            reversed_meaning = "Емоційна драма, маніпуляції, емоційна нестабільність";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 49; 
            name = "King of Cups"; 
            description = "Емоційний контроль, збалансованість, дипломатія";
            upright_meaning = "Дипломатія, емоційний контроль, мудрість, зрілість";
            reversed_meaning = "Емоційна маніпуляція, відсутність співчуття, холодність";
            isReversed = false;
        });
        
        // Додаємо Молодші аркани - Мечі
        buffer.add({ 
            id = 50; 
            name = "Ace of Swords"; 
            description = "Ясність, істина, нові ідеї";
            upright_meaning = "Ясність, інтелект, нова перспектива, прорив";
            reversed_meaning = "Заплутаність, хаос, жорстокість, відсутність ясності";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 51; 
            name = "Two of Swords"; 
            description = "Рішення, баланс, застій";
            upright_meaning = "Рівновага, дилема, вибір, блокування емоцій";
            reversed_meaning = "Заплутаність, уникнення, напруга, дезінформація";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 52; 
            name = "Three of Swords"; 
            description = "Серцевий біль, розрив, горе";
            upright_meaning = "Серцевий біль, скорбота, емоційний біль, розчарування";
            reversed_meaning = "Прощення, відновлення, звільнення, відпускання";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 53; 
            name = "Four of Swords"; 
            description = "Відпочинок, відновлення, споглядання";
            upright_meaning = "Спокій, відновлення, медитація, відступ";
            reversed_meaning = "Хвилювання, вигорання, виснаження, стрес";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 54; 
            name = "Five of Swords"; 
            description = "Конфлікт, поразка, конкуренція";
            upright_meaning = "Розбрат, агресія, конфлікт, інтриги";
            reversed_meaning = "Каяття, примирення, вирішення конфлікту";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 55; 
            name = "Six of Swords"; 
            description = "Перехід, дистанція, зцілення";
            upright_meaning = "Перехід, відхід, подорож, залишення позаду";
            reversed_meaning = "Перешкоди, затримки, тривога, нерозв'язані питання";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 56; 
            name = "Seven of Swords"; 
            description = "Обман, стратегія, таємничість";
            upright_meaning = "Обман, шахрайство, стратегія, хитрість";
            reversed_meaning = "Зізнання, викриття, залишення хитрощів";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 57; 
            name = "Eight of Swords"; 
            description = "Пастка, заточення, самообмеження";
            upright_meaning = "Обмеження, заточення, ментальне блокування";
            reversed_meaning = "Звільнення, новий погляд, подолання обмежень";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 58; 
            name = "Nine of Swords"; 
            description = "Тривога, кошмари, провина";
            upright_meaning = "Тривога, страх, нічні кошмари, неспокій";
            reversed_meaning = "Надія, подолання страхів, просвітлення";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 59; 
            name = "Ten of Swords"; 
            description = "Кінець, поразка, жертва";
            upright_meaning = "Поразка, крах, зрада, болісний кінець";
            reversed_meaning = "Відновлення, відродження, опір, виживання";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 60; 
            name = "Page of Swords"; 
            description = "Цікавість, проникливість, концентрація";
            upright_meaning = "Допитливість, спостережливість, уважність, новини";
            reversed_meaning = "Поспішні рішення, неправдива інформація, імпульсивність";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 61; 
            name = "Knight of Swords"; 
            description = "Амбіції, дія, імпульсивність";
            upright_meaning = "Амбіційність, рішучість, інтелектуальна боротьба";
            reversed_meaning = "Безрозсудність, імпульсивність, агресивність";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 62; 
            name = "Queen of Swords"; 
            description = "Незалежність, чесність, інтелект";
            upright_meaning = "Інтелект, незалежність, ясність, правда";
            reversed_meaning = "Холодність, жорстокість, гіркота, відсутність емпатії";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 63; 
            name = "King of Swords"; 
            description = "Авторитет, правда, ясність";
            upright_meaning = "Інтелектуальна сила, авторитет, правда, етика";
            reversed_meaning = "Зловживання владою, маніпуляції, жорстокість";
            isReversed = false;
        });
        
        // Додаємо Молодші аркани - Пентаклі
        buffer.add({ 
            id = 64; 
            name = "Ace of Pentacles"; 
            description = "Процвітання, нові ресурси, достаток";
            upright_meaning = "Нові фінансові можливості, процвітання, щедрість";
            reversed_meaning = "Упущені можливості, матеріальні проблеми, жадібність";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 65; 
            name = "Two of Pentacles"; 
            description = "Баланс, адаптація, пріоритети";
            upright_meaning = "Фінансовий баланс, адаптивність, гнучкість";
            reversed_meaning = "Дисбаланс, перевантаження, неорганізованість";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 66; 
            name = "Three of Pentacles"; 
            description = "Майстерність, співпраця, командна робота";
            upright_meaning = "Майстерність, якість, співпраця, взаємна підтримка";
            reversed_meaning = "Посередність, конфлікт в команді, некомпетентність";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 67; 
            name = "Four of Pentacles"; 
            description = "Безпека, заощадження, володіння";
            upright_meaning = "Економія, безпека, консерватизм, захист ресурсів";
            reversed_meaning = "Жадібність, матеріалізм, надмірний контроль";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 68; 
            name = "Five of Pentacles"; 
            description = "Нестаток, ізоляція, бідність";
            upright_meaning = "Фінансові труднощі, бідність, ізоляція, хвороба";
            reversed_meaning = "Відновлення, духовне пробудження, подолання труднощів";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 69; 
            name = "Six of Pentacles"; 
            description = "Щедрість, благодійність, обмін";
            upright_meaning = "Щедрість, благодійність, отримання допомоги";
            reversed_meaning = "Егоїзм, борги, нерівність, зловживання щедрістю";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 70; 
            name = "Seven of Pentacles"; 
            description = "Оцінка, терпіння, розвиток";
            upright_meaning = "Терпіння, важка праця, оцінка прогресу, інвестиції";
            reversed_meaning = "Нетерпіння, низька якість, погані інвестиції";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 71; 
            name = "Eight of Pentacles"; 
            description = "Навчання, перфекціонізм, майстерність";
            upright_meaning = "Навчання, старанність, розвиток навичок, увага до деталей";
            reversed_meaning = "Лінощі, перфекціонізм, недостатній розвиток навичок";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 72; 
            name = "Nine of Pentacles"; 
            description = "Достаток, розкіш, самодостатність";
            upright_meaning = "Фінансова незалежність, особистий успіх, розкіш";
            reversed_meaning = "Показна розкіш, матеріалізм, фінансова залежність";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 73; 
            name = "Ten of Pentacles"; 
            description = "Багатство, спадщина, стабільність";
            upright_meaning = "Сімейне багатство, спадщина, фінансова стабільність";
            reversed_meaning = "Сімейні конфлікти, фінансові проблеми, втрата спадщини";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 74; 
            name = "Page of Pentacles"; 
            description = "Амбіції, навчання, прагнення";
            upright_meaning = "Навчання, старанність, надійність, хороші новини";
            reversed_meaning = "Відсутність фокусу, незрілість, фінансові проблеми";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 75; 
            name = "Knight of Pentacles"; 
            description = "Відповідальність, працьовитість, надійність";
            upright_meaning = "Надійність, відповідальність, методичність";
            reversed_meaning = "Лінощі, застій, нудьга, надмірний перфекціонізм";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 76; 
            name = "Queen of Pentacles"; 
            description = "Достаток, щедрість, домашній затишок";
            upright_meaning = "Практичність, щедрість, плодючість, домашній комфорт";
            reversed_meaning = "Невпевненість, залежність, матеріалізм, ревнощі";
            isReversed = false;
        });
        
        buffer.add({ 
            id = 77; 
            name = "King of Pentacles"; 
            description = "Багатство, бізнес, лідерство";
            upright_meaning = "Добробут, безпека, контроль, лідерство в бізнесі";
            reversed_meaning = "Жадібність, корупція, зловживання владою";
            isReversed = false;
        });
        
        // Встановлюємо колоду
        tarotDeck := Buffer.toArray(buffer);
    };

   // Ініціалізуємо колоду при створенні актора
   do {
        // Створення базової колоди Таро
        initializeTarotDeck();
    };

    // Збереження стану перед оновленням
    system func preupgrade() {
        readingsEntries := Iter.toArray(readings.entries());
    };

    // Відновлення стану після оновлення
    system func postupgrade() {
        readings := HashMap.fromIter<Text, SavedReading>(
            readingsEntries.vals(),
            10,
            Text.equal,
            Text.hash
        );
        readingsEntries := [];
        
        // Переініціалізація колоди, якщо потрібно
        if (tarotDeck.size() == 0) {
            initializeTarotDeck();
        };
    };

    // Отримати всі карти Таро
    public query func getAllCards() : async [TarotCard] {
        return tarotDeck;
    };

    // Отримати одну карту за id
    public query func getCard(id: CardId) : async ?TarotCard {
        for (card in tarotDeck.vals()) {
            if (card.id == id) {
                return ?card;
            };
        };
        return null;
    };

    // Створити розклад: це головна функція, аналог perform_reading() в Python
    public shared(msg) func createReading(
        name: Text,
        question: Text,
        readingType: ReadingType
    ) : async SavedReading {
        let readingId = Nat.toText(nextReadingId);
        nextReadingId += 1;
        
        // Отримати випадковий seed для тасування
        let seed = await Random.blob();
        
        // Визначити кількість карт залежно від типу розкладу
        let cardCount = switch (readingType) {
            case (#single_card) { 1 };
            case (#three_card) { 3 };
            case (#celtic_cross) { 10 };
        };
        
        // Перетасувати колоду і витягнути потрібну кількість карт
        let drawnCards = drawRandomCards(seed, cardCount);
        
        // Створити запис розкладу
        let reading : SavedReading = {
            id = readingId;
            user = msg.caller;
            name = name;
            question = question;
            readingType = readingType;
            cards = drawnCards;
            timestamp = Time.now();
        };
        
        // Зберегти розклад
        readings.put(readingId, reading);
        
        return reading;
    };

    // Функція для перетасування колоди та вибору карт
    private func drawRandomCards(seed: Blob, count: Nat) : [TarotCard] {
        let buffer = Buffer.Buffer<TarotCard>(count);
        
        // Використовуємо seed для генерації випадкових чисел
        let rand = Random.Finite(seed);
        
        // Тимчасово копіюємо колоду
        let tempDeck = Array.thaw<TarotCard>(tarotDeck);
        
        var cardsDrawn = 0;
        var remainingCards = tempDeck.size();
        
        while (cardsDrawn < count and remainingCards > 0) {
            // Випадково вибираємо карту з тих, що залишились
            let randomIndexOpt = rand.range(32); // Використовуємо 32 біти для випадкового числа
            let randomIndex = switch (randomIndexOpt) {
                case (null) { 0 };
                case (?index) { index % remainingCards };
            };
            
            // Отримуємо карту і визначаємо, чи вона перевернута
            var card = tempDeck[randomIndex];
            
            // Випадково визначаємо, чи карта перевернута
            let isReversedOpt = rand.coin();
            let isReversed = switch (isReversedOpt) {
                case (null) { false };
                case (?reversed) { reversed };
            };
            
            // Клонуємо карту з оновленням стану перевертання
            let drawnCard : TarotCard = {
                id = card.id;
                name = card.name;
                description = card.description;
                upright_meaning = card.upright_meaning;
                reversed_meaning = card.reversed_meaning;
                isReversed = isReversed;
            };
            
            // Додаємо карту до результату
            buffer.add(drawnCard);
            
            // Прибираємо карту з тимчасової колоди, замінюючи її останньою картою
            if (randomIndex < remainingCards - 1) {
                tempDeck[randomIndex] := tempDeck[remainingCards - 1];
            };
            
            // Безпечне зменшення лічильника
            remainingCards := remainingCards - 1;
            cardsDrawn += 1;
        };
        
        return Buffer.toArray(buffer);
    };

    // Отримати розклад за ID
    public query func getReading(readingId: Text) : async ?SavedReading {
        return readings.get(readingId);
    };

    // Отримати всі розклади для поточного користувача
    public shared query(msg) func getUserReadings() : async [SavedReading] {
        let buffer = Buffer.Buffer<SavedReading>(0);
        
        for ((_, reading) in readings.entries()) {
            if (reading.user == msg.caller) {
                buffer.add(reading);
            };
        };
        
        return Buffer.toArray(buffer);
    };

    // Отримати інформацію про доступні типи розкладів
    public query func getReadingTypes() : async [(Text, Text)] {
        return [
            ("single_card", "Одна карта: швидка відповідь на конкретне питання"),
            ("three_card", "Три карти: минуле, теперішнє, майбутнє"),
            ("celtic_cross", "Кельтський хрест: повний розклад з 10 карт")
        ];
    };
}