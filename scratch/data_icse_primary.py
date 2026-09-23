# ICSE Primary Curriculum (Class 1 to Class 5)
# Aligned with CISCE Mathematics Curriculum Guidelines

icse_primary_chapters = [
    # ==================== Class 1 (ICSE) ====================
    {
        "board": "icse", "grade": "Class 1", "chapterNumber": 1,
        "title": "Pre-Number Concepts & Spatial Sense", "icon": "📍",
        "description": "Spatial vocabulary: top, bottom, on, under, inside, outside, above, below, near, far, and sorting.",
        "keyConcepts": ["Spatial Relationships", "Inside & Outside", "Top, Middle & Bottom", "Sorting by Attributes"],
        "rules": [
            "Top is highest up; bottom is lowest down.",
            "Inside means enclosed within a container; outside is beyond the container boundary.",
            "Near means closer distance; far means greater distance."
        ],
        "exampleQuestion": "A red apple is sitting on top of a wooden table. Is the apple ON or UNDER the table?",
        "exampleExplanation": "The apple rests on the upper flat surface of the table: it is ON the table.",
        "exampleAnswer": "ON the table",
        "funFact": "Spatial awareness helps astronauts navigate in zero gravity inside the International Space Station!",
        "mascotAdvice": "Look at the object in relation to its surroundings: check if it is above, below, inside, or outside!"
    },
    {
        "board": "icse", "grade": "Class 1", "chapterNumber": 2,
        "title": "Numbers 1 to 20 & Zero", "icon": "🔢",
        "description": "Number names, counting objects, before/after/between, and the mathematical concept of zero.",
        "keyConcepts": ["Counting 1 to 20", "Number Names", "Concept of Zero (Empty Set)", "Before, After & Between"],
        "rules": [
            "Zero (0) means having no objects in the group (empty set).",
            "The number that comes before is 1 less (n - 1); after is 1 more (n + 1).",
            "Between is the number sitting in the middle of two consecutive numbers."
        ],
        "exampleQuestion": "Which number comes directly BETWEEN 13 and 15?",
        "exampleExplanation": "Counting in order: 13, 14, 15. The number in between is 14.",
        "exampleAnswer": "14",
        "funFact": "The word 'Zero' comes from the Arabic 'sifr', which translated the Sanskrit word 'shunya' (void)!",
        "mascotAdvice": "Say the counting sequence softly: the number right in the middle is the 'between' number!"
    },
    {
        "board": "icse", "grade": "Class 1", "chapterNumber": 3,
        "title": "Addition within 20", "icon": "➕",
        "description": "Adding single and teen numbers, number line jumps, vertical addition, and word problems.",
        "keyConcepts": ["Adding on the Number Line", "Vertical Column Addition", "Making 10 to Add", "Addition Story Problems"],
        "rules": [
            "To add on a number line, start at the first number and jump forward.",
            "Adding 0 to any number gives the number itself: a + 0 = a.",
            "Order property: Changing order does not change sum: 8 + 5 = 5 + 8 = 13."
        ],
        "exampleQuestion": "Ananya has 8 color pencils and buys 6 more. How many color pencils does she have now?",
        "exampleExplanation": "Add: 8 + 6 = 14 color pencils in total.",
        "exampleAnswer": "14 color pencils",
        "funFact": "The plus symbol '+' first appeared in print in an arithmetic textbook by Johannes Widmann in 1489!",
        "mascotAdvice": "Count on from the larger number: start at 8, count 6 more on fingers: 9, 10, 11, 12, 13, 14!"
    },
    {
        "board": "icse", "grade": "Class 1", "chapterNumber": 4,
        "title": "Subtraction within 20", "icon": "➖",
        "description": "Taking away, backward counting on the number line, vertical subtraction, and finding differences.",
        "keyConcepts": ["Subtraction as Taking Away", "Jumping Backward on Number Line", "Vertical Subtraction", "Subtracting from Teen Numbers"],
        "rules": [
            "To subtract on a number line, start at the minuend and jump backward.",
            "Subtracting 0 leaves the number unchanged: a - 0 = a.",
            "Subtracting a number from itself gives zero: a - a = 0."
        ],
        "exampleQuestion": "There are 15 cupcakes in a bakery box. 7 cupcakes are sold. How many cupcakes remain?",
        "exampleExplanation": "Subtract sold cupcakes: 15 - 7 = 8 cupcakes remain.",
        "exampleAnswer": "8 cupcakes",
        "funFact": "Kangaroos leap backward mentally in maths by counting hops on a number track!",
        "mascotAdvice": "Start at 15 on your number line and take 7 backward hops: you will land on 8!"
    },
    {
        "board": "icse", "grade": "Class 1", "chapterNumber": 5,
        "title": "Numbers up to 100 & Place Value", "icon": "🔟",
        "description": "Tens and ones, place value charts, expanded notation, and counting up to 100.",
        "keyConcepts": ["Tens and Ones (T & O)", "Place Value Representation", "Expanded Notation (e.g. 64 = 60 + 4)", "Counting to 100 on Grid"],
        "rules": [
            "10 Ones = 1 Ten; 10 Tens = 1 Hundred (100).",
            "In a 2-digit number, the right digit is Ones and the left digit is Tens.",
            "Expanded form: 75 = 7 Tens + 5 Ones = 70 + 5."
        ],
        "exampleQuestion": "What is the expanded form of the number 83?",
        "exampleExplanation": "8 is in the Tens place (80) and 3 is in the Ones place (3): 83 = 80 + 3.",
        "exampleAnswer": "80 + 3",
        "funFact": "In computing, 100 is represented in binary as 1100100!",
        "mascotAdvice": "Read the tens place first, then the ones place: 8 tens is eighty, plus three is eighty-three!"
    },
    {
        "board": "icse", "grade": "Class 1", "chapterNumber": 6,
        "title": "Comparison of Numbers", "icon": "🐊",
        "description": "Greater than (>), less than (<), equal to (=), ascending order, and descending order.",
        "keyConcepts": ["Symbols >, <, and =", "Ascending Order (Least to Greatest)", "Descending Order (Greatest to Least)", "Comparing 2-Digit Numbers"],
        "rules": [
            "To compare two 2-digit numbers, look at the Tens digit first.",
            "If the Tens digits are equal, compare the Ones digits (e.g. 58 > 52 because 8 > 2).",
            "Ascending order steps UP like climbing a ladder; Descending order steps DOWN."
        ],
        "exampleQuestion": "Arrange these numbers in ASCENDING order (smallest to largest): 42, 19, 65, 33",
        "exampleExplanation": "Compare tens: 19 (1 ten), 33 (3 tens), 42 (4 tens), 65 (6 tens). Order: 19, 33, 42, 65.",
        "exampleAnswer": "19, 33, 42, 65",
        "funFact": "The greater-than '>' and less-than '<' symbols were invented by English mathematician Thomas Harriot in 1631!",
        "mascotAdvice": "The crocodile mouth always opens wide to eat the bigger number!"
    },
    {
        "board": "icse", "grade": "Class 1", "chapterNumber": 7,
        "title": "2D & 3D Shapes", "icon": "🔺",
        "description": "Plane shapes: circle, square, rectangle, triangle; solid shapes: sphere, cube, cuboid, cylinder, cone.",
        "keyConcepts": ["2D Plane Figures (Sides & Corners)", "3D Solids (Cube, Sphere, Cylinder, Cone)", "Rolling vs Sliding", "Straight vs Curved Edges"],
        "rules": [
            "A square has 4 equal straight sides and 4 corners.",
            "A rectangle has 4 sides where opposite sides are equal.",
            "A circle has 1 curved boundary and no corners.",
            "A sphere (ball) has only 1 curved surface and can roll in any direction."
        ],
        "exampleQuestion": "How many corners does a triangle have?",
        "exampleExplanation": "A triangle has 3 straight sides that meet at 3 sharp corners (vertices).",
        "exampleAnswer": "3 corners",
        "funFact": "Soap bubbles naturally form spheres because a sphere minimizes the surface area for a given volume!",
        "mascotAdvice": "Flat shapes you draw on paper (2D); chunky shapes you can hold in your hand (3D)!"
    },
    {
        "board": "icse", "grade": "Class 1", "chapterNumber": 8,
        "title": "Measurement of Length & Weight", "icon": "⚖️",
        "description": "Non-standard units of length (handspans, cubits, footsteps) and comparing weights with balance pans.",
        "keyConcepts": ["Handspan, Pace, Footstep", "Longer vs Shorter", "Heavier vs Lighter", "Simple Balance Scale"],
        "rules": [
            "When measuring with handspans, place thumb to outstretched pinky finger without gaps.",
            "On a balance scale, the pan holding the heavier object tilts downwards.",
            "When two objects weigh the same, the balance pointer stays upright in the middle."
        ],
        "exampleQuestion": "An apple and a watermelon are placed on a balance scale. Which fruit goes DOWN?",
        "exampleExplanation": "The watermelon is much heavier than the apple, so its pan sinks down.",
        "exampleAnswer": "The watermelon (heavier side sinks down)",
        "funFact": "Ancient Indian weights from Mohenjo-daro were made of polished chert stone cubes of exact standard mass!",
        "mascotAdvice": "The heavier side always pushes down on the scale!"
    },
    {
        "board": "icse", "grade": "Class 1", "chapterNumber": 9,
        "title": "Time and Calendar", "icon": "⏰",
        "description": "Reading the analog clock to the exact hour, days of the week, months, and seasons.",
        "keyConcepts": ["Clock Hour Hand and Minute Hand", "Reading 'o'clock'", "7 Days of the Week", "12 Months of the Year"],
        "rules": [
            "When the long minute hand points to 12, the short hour hand tells the hour (e.g. 5 o'clock).",
            "There are 7 days in a week: Monday to Sunday.",
            "There are 12 months in a year: January to December."
        ],
        "exampleQuestion": "The clock's long hand points to 12 and the short hand points to 9. What time is it?",
        "exampleExplanation": "Long hand on 12 means o'clock: with the short hand on 9, it is 9 o'clock.",
        "exampleAnswer": "9 o'clock",
        "funFact": "The word 'Clock' comes from the Celtic and Old French word 'cloche', meaning bell!",
        "mascotAdvice": "Short hand = Hour; Long hand = Minute!"
    },
    {
        "board": "icse", "grade": "Class 1", "chapterNumber": 10,
        "title": "Money & Data Representation", "icon": "🪙",
        "description": "Indian coins and currency notes, small shopping exchanges, tally counting, and pictographs.",
        "keyConcepts": ["Indian Currency (₹1, ₹2, ₹5, ₹10 coins)", "Adding Money Amounts", "Simple Pictographs with Key", "Counting and Sorting Data"],
        "rules": [
            "₹10 can be made with two ₹5 coins (5 + 5 = 10).",
            "In pictographs, count each icon according to the key.",
            "Tally marks group items into sets of 5 for quick counting."
        ],
        "exampleQuestion": "Kabir has one ₹10 note and two ₹5 coins. How much total money does he have?",
        "exampleExplanation": "Add the values: ₹10 + ₹5 + ₹5 = ₹10 + ₹10 = ₹20.",
        "exampleAnswer": "₹20",
        "funFact": "The oldest known coins were made in Lydia (modern Turkey) around 600 BCE from an alloy of gold and silver!",
        "mascotAdvice": "Add the largest notes first, then add the coins!"
    },

    # ==================== Class 2 (ICSE) ====================
    {
        "board": "icse", "grade": "Class 2", "chapterNumber": 1,
        "title": "3-Digit Numbers up to 999", "icon": "🔢",
        "description": "Hundreds, tens, and ones; reading and writing 3-digit numbers in figures and words, place value, and face value.",
        "keyConcepts": ["Hundreds, Tens, Ones (H T O)", "Place Value vs Face Value", "Expanded Notation of 3-Digit Numbers", "Comparing & Ordering Numbers up to 999"],
        "rules": [
            "10 Tens = 1 Hundred (100); 10 Hundreds = 1 Thousand (1,000).",
            "In 482: Place value of 4 is 400, 8 is 80, 2 is 2. Face value of 4 is simply 4.",
            "Largest 3-digit number is 999; Smallest 3-digit number is 100."
        ],
        "exampleQuestion": "In the number 675, what is the PLACE VALUE of the digit 7?",
        "exampleExplanation": "7 is in the Tens place, so its place value is 7 × 10 = 70.",
        "exampleAnswer": "70 (7 tens)",
        "funFact": "The word 'Hundred' originally meant 120 in Old Norse, known as the 'long hundred'!",
        "mascotAdvice": "Place value depends on the position: H, T, O. Face value is the digit itself!"
    },
    {
        "board": "icse", "grade": "Class 2", "chapterNumber": 2,
        "title": "Addition of 2 & 3-Digit Numbers", "icon": "➕",
        "description": "Addition without regrouping, addition with carrying over tens and hundreds, and word problems.",
        "keyConcepts": ["Addition with Regrouping (Carry Over)", "Properties of Addition", "Adding 3 Numbers", "Real-World Story Problems"],
        "rules": [
            "Always add columns from right to left: Ones first, then Tens, then Hundreds.",
            "If the Ones sum is 10 or more, carry the Tens digit to the Tens column.",
            "If the Tens sum is 10 or more, carry 1 to the Hundreds column."
        ],
        "exampleQuestion": "Find the total sum of these two 3-digit numbers: 247 + 138",
        "exampleExplanation": "Ones: 7 + 8 = 15 (write 5, carry 1). Tens: 1 + 4 + 3 = 8. Hundreds: 2 + 1 = 3. Total = 385.",
        "exampleAnswer": "385",
        "funFact": "Cash registers were invented in 1879 by James Ritty to accurately add customer bills and prevent theft!",
        "mascotAdvice": "Never forget to add the carried-over 1 to the next column!"
    },
    {
        "board": "icse", "grade": "Class 2", "chapterNumber": 3,
        "title": "Subtraction of 2 & 3-Digit Numbers", "icon": "➖",
        "description": "Subtraction with borrowing from tens and hundreds, checking subtraction by addition, and word problems.",
        "keyConcepts": ["Subtraction with Regrouping (Borrowing)", "Checking Subtraction (Difference + Subtrahend = Minuend)", "Subtracting across Zeroes", "Difference Word Problems"],
        "rules": [
            "Subtract Ones first, then Tens, then Hundreds.",
            "If the top digit is smaller than the bottom digit, borrow 1 from the next left column.",
            "Check: Result + Subtracted Number must equal the original Top Number."
        ],
        "exampleQuestion": "Solve: 452 - 128",
        "exampleExplanation": "Ones: cannot do 2 - 8, borrow 1 from 5: 12 - 8 = 4. Tens: 4 - 2 = 2. Hundreds: 4 - 1 = 3. Result = 324.",
        "exampleAnswer": "324",
        "funFact": "Ancient Babylonian accountants carved subtraction calculations into clay tablets over 3,800 years ago!",
        "mascotAdvice": "When borrowing, slash the lender digit and write its new smaller value above it!"
    },
    {
        "board": "icse", "grade": "Class 2", "chapterNumber": 4,
        "title": "Concept of Multiplication", "icon": "✖️",
        "description": "Multiplication as repeated addition, arrays of rows and columns, and tables of 2, 3, 4, 5, 10.",
        "keyConcepts": ["Multiplication as Repeated Addition", "Array Model (Rows × Columns)", "Multiplication Tables (2 to 10)", "Multiplication Properties (Zero and One)"],
        "rules": [
            "Multiplication is fast repeated addition: 5 × 4 = 4 + 4 + 4 + 4 + 4 = 20.",
            "Any number multiplied by 0 is 0: a × 0 = 0.",
            "Any number multiplied by 1 is the number itself: a × 1 = a.",
            "Changing order of factors gives the same product: 3 × 6 = 6 × 3 = 18."
        ],
        "exampleQuestion": "There are 5 boxes with 6 crayons in each box. How many crayons are there in total?",
        "exampleExplanation": "Multiply boxes by crayons: 5 × 6 = 30 crayons.",
        "exampleAnswer": "30 crayons",
        "funFact": "Egg cartons are designed in 2 × 6 arrays because 12 eggs pack into an efficient, shock-resistant grid!",
        "mascotAdvice": "Think of multiplication as rows of soldiers: Rows × Columns = Total!"
    },
    {
        "board": "icse", "grade": "Class 2", "chapterNumber": 5,
        "title": "Concept of Division", "icon": "➗",
        "description": "Equal distribution and equal grouping, division sign (÷), and relationship between multiplication and division.",
        "keyConcepts": ["Equal Sharing & Grouping", "Division Symbol (÷)", "Division as Inverse of Multiplication", "Division Fact Families"],
        "rules": [
            "Division means sharing a collection into equal parts: 18 ÷ 3 = 6.",
            "Every multiplication fact has two division facts: if 4 × 5 = 20, then 20 ÷ 4 = 5 and 20 ÷ 5 = 4.",
            "Any number divided by itself equals 1 (e.g. 7 ÷ 7 = 1)."
        ],
        "exampleQuestion": "16 cookies are distributed equally among 4 children. How many cookies does each child receive?",
        "exampleExplanation": "Divide total cookies by children: 16 ÷ 4 = 4 cookies each.",
        "exampleAnswer": "4 cookies each",
        "funFact": "The word 'Divide' comes from the Latin 'dividere', which means to force apart into portions!",
        "mascotAdvice": "Recite the multiplication table of the divisor until you reach the total number!"
    },
    {
        "board": "icse", "grade": "Class 2", "chapterNumber": 6,
        "title": "Geometry: Shapes and Solids", "icon": "📐",
        "description": "Straight and curved lines, plane figures, vertices and edges, solid figures: cube, cuboid, cylinder, cone, sphere.",
        "keyConcepts": ["Horizontal, Vertical, Slanting Lines", "Faces, Edges, and Vertices", "Flat Surfaces vs Curved Surfaces", "Geometric Solids"],
        "rules": [
            "A cube has 6 flat square faces, 12 straight edges, and 8 vertices.",
            "A cylinder has 2 flat circular faces and 1 curved surface.",
            "A cone has 1 flat circular base, 1 curved surface, and 1 vertex tip."
        ],
        "exampleQuestion": "How many flat faces, edges, and vertices does a standard playing die (cube) have?",
        "exampleExplanation": "A cube has 6 square faces, 12 straight edges, and 8 corner vertices.",
        "exampleAnswer": "6 faces, 12 edges, 8 vertices",
        "funFact": "The giant Giant's Causeway in Northern Ireland consists of 40,000 interlocking geometric basalt columns!",
        "mascotAdvice": "Face is the flat wall; Edge is where two walls meet; Vertex is the sharp corner point!"
    },
    {
        "board": "icse", "grade": "Class 2", "chapterNumber": 7,
        "title": "Measurement: Length, Mass & Capacity", "icon": "📏",
        "description": "Standard units of length (meter, cm), mass (kilogram, g), and capacity (liter, mL).",
        "keyConcepts": ["1 Meter (m) = 100 Centimeters (cm)", "1 Kilogram (kg) = 1,000 Grams (g)", "1 Liter (L) = 1,000 Milliliters (mL)", "Choosing Appropriate Units"],
        "rules": [
            "Use meters (m) for room lengths, cm for pencils and notebooks.",
            "Use kilograms (kg) for body weight, grams (g) for feathers and rings.",
            "Use liters (L) for buckets and petrol, milliliters (mL) for spoons of medicine."
        ],
        "exampleQuestion": "Which unit would you use to measure the weight of a gold coin: grams (g) or kilograms (kg)?",
        "exampleExplanation": "A gold coin is small and light: it is measured in grams (g).",
        "exampleAnswer": "Grams (g)",
        "funFact": "The International Prototype Kilogram was kept in a triple vacuum vault near Paris for 130 years!",
        "mascotAdvice": "Meters, Kilograms, and Liters are for big things; cm, grams, and mL are for small things!"
    },
    {
        "board": "icse", "grade": "Class 2", "chapterNumber": 8,
        "title": "Time and Reading Clocks", "icon": "⏰",
        "description": "Reading clock to the hour and half-hour, concept of AM and PM, days in a month, and calendars.",
        "keyConcepts": ["Half Past (30 Minutes)", "Quarter Past and Quarter To", "AM (Midnight to Noon) & PM (Noon to Midnight)", "Reading Calendar Dates"],
        "rules": [
            "1 hour = 60 minutes; Half hour = 30 minutes.",
            "When the minute hand points to 6, it is 'half past' the hour.",
            "AM is used from 12 midnight to 12 noon; PM is used from 12 noon to 12 midnight."
        ],
        "exampleQuestion": "The hour hand is between 4 and 5, and the minute hand points directly to 6. What time is it?",
        "exampleExplanation": "Minute hand on 6 indicates 30 minutes: the time is 4:30 (half past 4).",
        "exampleAnswer": "4:30 (Half past 4)",
        "funFact": "Big Ben in London has minute hands that are 4.3 meters long and travel about 190 km each year!",
        "mascotAdvice": "Each number on a clock equals 5 minutes: 6 × 5 = 30 minutes (half past)!"
    },
    {
        "board": "icse", "grade": "Class 2", "chapterNumber": 9,
        "title": "Money: Rupees and Paise", "icon": "💵",
        "description": "Indian currency, adding and subtracting money, making change, and simple shopping bills.",
        "keyConcepts": ["1 Rupee = 100 Paise", "Writing Currency (₹ and p)", "Adding and Subtracting Money", "Calculating Bill Total & Change"],
        "rules": [
            "₹1 = 100 paise; ₹5 = 500 paise.",
            "To add money, add the rupees together and paise together.",
            "Change to return = Amount Tendered - Total Bill."
        ],
        "exampleQuestion": "A pencil costs ₹8 and a drawing book costs ₹25. If you give a ₹50 note, how much change do you receive?",
        "exampleExplanation": "Total bill = ₹8 + ₹25 = ₹33. Change = ₹50 - ₹33 = ₹17.",
        "exampleAnswer": "₹17 change",
        "funFact": "The Reserve Bank of India prints banknotes with security features including watermarks and fluorescent ink!",
        "mascotAdvice": "Calculate total cost first, then subtract from the note you handed to the shopkeeper!"
    },
    {
        "board": "icse", "grade": "Class 2", "chapterNumber": 10,
        "title": "Data Handling & Patterns", "icon": "📊",
        "description": "Tally marks, pictographs, organizing survey data, and repeating/growing patterns.",
        "keyConcepts": ["Tally Frequency Tables", "Pictographs (Symbols Representing Units)", "Identifying Pattern Rules", "Growing and Decreasing Patterns"],
        "rules": [
            "Tally marks group in bundles of 5: |||| with a diagonal cross slash.",
            "Always check the pictograph key at the bottom to see what 1 icon represents.",
            "A pattern rule describes how to get from one step to the next."
        ],
        "exampleQuestion": "In a school library pictograph, 1 📚 symbol represents 5 books. If a shelf has 4 📚 symbols, how many books are there?",
        "exampleExplanation": "Multiply symbols by key value: 4 × 5 = 20 books.",
        "exampleAnswer": "20 books",
        "funFact": "DNA molecules store all genetic instructions using repeating patterns of 4 chemical bases!",
        "mascotAdvice": "Always check the scale key first: one picture could mean 2, 5, or 10 items!"
    },

    # ==================== Class 3 (ICSE) ====================
    {
        "board": "icse", "grade": "Class 3", "chapterNumber": 1,
        "title": "4-Digit Numbers & Place Value", "icon": "🔢",
        "description": "Numbers up to 9,999, Thousands place (Th H T O), expanded notation, successor and predecessor.",
        "keyConcepts": ["Thousands Place (Th H T O)", "Place Value & Face Value up to 9,999", "Expanded & Standard Form", "Successor (+1) & Predecessor (-1)"],
        "rules": [
            "10 Hundreds = 1 Thousand (1,000).",
            "Smallest 4-digit number is 1,000; Largest 4-digit number is 9,999.",
            "Successor of a number = Number + 1; Predecessor = Number - 1.",
            "In 7,385: Place value of 7 is 7,000, 3 is 300, 8 is 80, 5 is 5."
        ],
        "exampleQuestion": "What is the predecessor of the smallest 4-digit number (1,000)?",
        "exampleExplanation": "Predecessor means 1 less: 1,000 - 1 = 999 (the largest 3-digit number).",
        "exampleAnswer": "999",
        "funFact": "Mount Everest is 8,849 meters tall—a magnificent 4-digit number of altitude!",
        "mascotAdvice": "Line up digits under Th (Thousands), H (Hundreds), T (Tens), and O (Ones)!"
    },
    {
        "board": "icse", "grade": "Class 3", "chapterNumber": 2,
        "title": "Roman Numerals", "icon": "🏛️",
        "description": "Reading and writing Roman numerals from I to XX (1 to 20), rules of repetition, addition, and subtraction.",
        "keyConcepts": ["Basic Symbols: I = 1, V = 5, X = 10", "Rule of Repetition (Maximum 3 Times)", "Rule of Addition (Symbol on Right)", "Rule of Subtraction (Symbol on Left)"],
        "rules": [
            "Symbol I can be repeated up to 3 times (III = 3). Symbol V is NEVER repeated.",
            "Addition: When a smaller symbol is written to the right of a larger symbol, add it: VI = 5 + 1 = 6; XII = 10 + 2 = 12.",
            "Subtraction: When a smaller symbol is written to the left of a larger symbol, subtract it: IV = 5 - 1 = 4; IX = 10 - 1 = 9."
        ],
        "exampleQuestion": "Write the Hindu-Arabic number 19 in Roman numerals:",
        "exampleExplanation": "19 = 10 + 9. 10 is X and 9 is IX. Combining gives XIX.",
        "exampleAnswer": "XIX",
        "funFact": "Roman numerals have no symbol for zero because ancient Romans only counted physical quantities!",
        "mascotAdvice": "Smaller on right means ADD; smaller on left means SUBTRACT!"
    },
    {
        "board": "icse", "grade": "Class 3", "chapterNumber": 3,
        "title": "Addition of 4-Digit Numbers", "icon": "➕",
        "description": "Addition of 4-digit numbers with and without regrouping, properties of addition, and multi-step word problems.",
        "keyConcepts": ["4-Digit Column Addition", "Carrying across Tens, Hundreds, Thousands", "Estimating Sums by Rounding", "Multi-Step Story Problems"],
        "rules": [
            "Add column by column from right to left: Ones -> Tens -> Hundreds -> Thousands.",
            "If a column sum exceeds 9, carry the excess digit to the immediate left column.",
            "Rounding to nearest 100: If the tens digit is 5 or more, round UP; if less than 5, round DOWN."
        ],
        "exampleQuestion": "Add: 3,458 + 2,764",
        "exampleExplanation": "Ones: 8+4=12 (write 2, carry 1). Tens: 1+5+6=12 (write 2, carry 1). Hundreds: 1+4+7=12 (write 2, carry 1). Thousands: 1+3+2=6. Total = 6,222.",
        "exampleAnswer": "6,222",
        "funFact": "The world's fastest mental calculator added ten 10-digit numbers in just 18.2 seconds!",
        "mascotAdvice": "Write carried-over numbers neatly at the top of each column so you don't forget them!"
    },
    {
        "board": "icse", "grade": "Class 3", "chapterNumber": 4,
        "title": "Subtraction of 4-Digit Numbers", "icon": "➖",
        "description": "Subtraction with borrowing across multiple zeroes, checking answers, and finding differences.",
        "keyConcepts": ["4-Digit Subtraction with Borrowing", "Subtracting Across Multiple Zeroes (e.g. 5,000 - 2,345)", "Checking Subtraction with Addition", "Difference Problems"],
        "rules": [
            "Subtract from right to left.",
            "Subtracting across zero: Borrow from the first non-zero digit to the left; intermediate zeroes become 9, and the target digit becomes 10+.",
            "Check: Difference + Subtrahend = Minuend."
        ],
        "exampleQuestion": "Calculate: 4,000 - 1,635",
        "exampleExplanation": "Borrow from 4: 4 becomes 3, zeroes become 9, 9, 10. Ones: 10-5=5. Tens: 9-3=6. Hundreds: 9-6=3. Thousands: 3-1=2. Result = 2,365.",
        "exampleAnswer": "2,365",
        "funFact": "Subtracting across zeroes was called the 'Rule of the Nine' by Arabic mathematicians 1,000 years ago!",
        "mascotAdvice": "Across zeroes: the end zero becomes 10, all middle zeroes become 9, and the lender loses 1!"
    },
    {
        "board": "icse", "grade": "Class 3", "chapterNumber": 5,
        "title": "Multiplication", "icon": "✖️",
        "description": "Multiplying 2 and 3-digit numbers by 1-digit and 2-digit numbers, lattice method, and product estimation.",
        "keyConcepts": ["Tables up to 15", "Multiplying by 10, 100, 1000", "Column Multiplication (Multi-digit by 1-digit)", "Distributive Property in Multiplication"],
        "rules": [
            "To multiply a number by 10, append 1 zero (e.g. 45 × 10 = 450); by 100, append 2 zeroes (45 × 100 = 4,500).",
            "Multiplicand × Multiplier = Product.",
            "Distributive property: 4 × 23 = 4 × (20 + 3) = (4 × 20) + (4 × 3) = 80 + 12 = 92."
        ],
        "exampleQuestion": "Find the product: 125 × 6",
        "exampleExplanation": "6 × 5 = 30 (write 0, carry 3). 6 × 2 = 12 + 3 = 15 (write 5, carry 1). 6 × 1 = 6 + 1 = 7. Product = 750.",
        "exampleAnswer": "750",
        "funFact": "Ancient Egyptians multiplied numbers by successively doubling and adding the required powers of two!",
        "mascotAdvice": "Break complex multiplication into tens and ones: multiply separately and add!"
    },
    {
        "board": "icse", "grade": "Class 3", "chapterNumber": 6,
        "title": "Division", "icon": "➗",
        "description": "Long division, dividend, divisor, quotient, remainder, and verifying Division Algorithm.",
        "keyConcepts": ["Long Division Method", "Terms: Dividend, Divisor, Quotient, Remainder", "Division Algorithm: Dividend = (Divisor × Quotient) + Remainder", "Dividing by 10 (Quotient and Remainder trick)"],
        "rules": [
            "Dividend = (Divisor × Quotient) + Remainder.",
            "The Remainder must ALWAYS be strictly less than the Divisor (R < Divisor).",
            "When dividing by 10: The last digit is the Remainder, and remaining digits form the Quotient (e.g. 748 ÷ 10 -> Q = 74, R = 8)."
        ],
        "exampleQuestion": "Divide 87 by 5 and state the Quotient and Remainder:",
        "exampleExplanation": "87 ÷ 5: 5 × 17 = 85. 87 - 85 = 2. So Quotient = 17, Remainder = 2. Check: (5 × 17) + 2 = 85 + 2 = 87.",
        "exampleAnswer": "Quotient = 17, Remainder = 2",
        "funFact": "Division is the only basic arithmetic operation that is calculated from left to right (highest place value first)!",
        "mascotAdvice": "Remember Dad, Mom, Sister, Brother: Divide, Multiply, Subtract, Bring down!"
    },
    {
        "board": "icse", "grade": "Class 3", "chapterNumber": 7,
        "title": "Fractions", "icon": "🍕",
        "description": "Fraction as part of a whole and part of a collection, halves, thirds, fourths, numerator and denominator.",
        "keyConcepts": ["Numerator & Denominator (N/D)", "Unit Fractions (1/2, 1/3, 1/4)", "Fraction of a Collection", "Like Fractions (Same Denominator)"],
        "rules": [
            "Fraction = Numerator ÷ Denominator.",
            "Denominator (bottom) tells how many equal parts the whole is divided into.",
            "Numerator (top) tells how many equal parts are selected or shaded.",
            "To find 1/4 of 24 apples: divide 24 by 4 = 6 apples."
        ],
        "exampleQuestion": "What is 1/3 of a collection of 18 colorful balloons?",
        "exampleExplanation": "Divide the total collection by the denominator: 18 ÷ 3 = 6 balloons.",
        "exampleAnswer": "6 balloons",
        "funFact": "The horizontal line separating numerator and denominator in a fraction is called the 'vinculum'!",
        "mascotAdvice": "D is for Down (Denominator is at the bottom); N is for North (Numerator is on top)!"
    },
    {
        "board": "icse", "grade": "Class 3", "chapterNumber": 8,
        "title": "Geometry: Shapes, Lines & Angles", "icon": "📐",
        "description": "Point, line segment, ray, line, open and closed curves, properties of polygons, and 3D solids.",
        "keyConcepts": ["Line, Ray, Line Segment Definitions", "Open vs Closed Figures", "Properties of Square, Rectangle, Triangle, Circle", "Solids: Cube, Cylinder, Cone, Sphere"],
        "rules": [
            "A line segment has 2 definite endpoints and a measurable length.",
            "A ray has 1 fixed starting endpoint and goes on endlessly in 1 direction.",
            "A circle has a center point; every point on the boundary is at an equal distance (radius) from the center."
        ],
        "exampleQuestion": "How many endpoints does a line segment have compared to a ray?",
        "exampleExplanation": "A line segment has 2 endpoints; a ray has only 1 endpoint.",
        "exampleAnswer": "Line segment has 2 endpoints; ray has 1 endpoint",
        "funFact": "The word 'Geometry' comes from the Greek 'geo' (Earth) and 'metron' (measure)!",
        "mascotAdvice": "Use a sharp pencil and ruler to draw crisp line segments with marked endpoints!"
    },
    {
        "board": "icse", "grade": "Class 3", "chapterNumber": 9,
        "title": "Measurement: Metric System", "icon": "📏",
        "description": "Length (m, cm, km), mass (kg, g), capacity (L, mL), and standard conversions with addition & subtraction.",
        "keyConcepts": ["1 km = 1,000 m; 1 m = 100 cm", "1 kg = 1,000 g", "1 L = 1,000 mL", "Converting Higher to Lower Units (Multiply by 100 or 1000)"],
        "rules": [
            "To convert larger units to smaller units, MULTIPLY (e.g. km to m: × 1,000; m to cm: × 100).",
            "To convert smaller units to larger units, DIVIDE (e.g. m to km: ÷ 1,000; cm to m: ÷ 100).",
            "Always align meters with meters and cm with cm before adding or subtracting."
        ],
        "exampleQuestion": "A marathon runner completes 4 km and 350 m. How many meters did the runner travel in total?",
        "exampleExplanation": "Convert km to m: 4 km = 4 × 1,000 = 4,000 m. Add 350 m: 4,000 + 350 = 4,350 m.",
        "exampleAnswer": "4,350 meters",
        "funFact": "The metric system was officially adopted during the French Revolution in 1799 to replace hundreds of confusing local units!",
        "mascotAdvice": "Write two separate columns (m and cm, or kg and g) when adding metric quantities!"
    },
    {
        "board": "icse", "grade": "Class 3", "chapterNumber": 10,
        "title": "Time and Calendar", "icon": "⏰",
        "description": "Reading clock to 5-minute intervals, quarter past and quarter to, duration of events, and leap years.",
        "keyConcepts": ["Reading Clock to 5 Minutes", "Quarter Past (15 min) & Quarter To (45 min)", "Calculating Time Durations", "Calendar & Leap Year Rule (Divisible by 4)"],
        "rules": [
            "1 hour = 60 minutes.",
            "Quarter past means 15 minutes past the hour; Quarter to means 15 minutes before the next hour.",
            "Duration of an activity = End Time - Start Time.",
            "A leap year has 366 days and occurs every 4 years (February has 29 days)."
        ],
        "exampleQuestion": "A cartoon show starts at 5:15 PM and ends at 6:00 PM. How long did the cartoon show run?",
        "exampleExplanation": "From 5:15 PM to 6:00 PM is 45 minutes (three 15-minute quarters).",
        "exampleAnswer": "45 minutes",
        "funFact": "The Earth takes approximately 365 days, 5 hours, 48 minutes, and 46 seconds to circle the Sun!",
        "mascotAdvice": "Multiply the number the minute hand points to by 5 to find exact minutes past the hour!"
    },
    {
        "board": "icse", "grade": "Class 3", "chapterNumber": 11,
        "title": "Money & Data Handling", "icon": "💵",
        "description": "Converting rupees and paise, preparing cash memos, reading pictographs and bar graphs.",
        "keyConcepts": ["₹1 = 100 paise (Conversion: ₹ to p × 100, p to ₹ ÷ 100)", "Creating Cash Memos & Bills", "Bar Graphs with Grid Scale", "Tally Charts & Data Interpretation"],
        "rules": [
            "To convert rupees to paise, multiply by 100 (₹4.50 = 450 paise).",
            "To convert paise to rupees, put a point two digits from the right (375 paise = ₹3.75).",
            "In bar graphs: Bar height is directly proportional to frequency count."
        ],
        "exampleQuestion": "Convert 650 paise into Rupees and paise:",
        "exampleExplanation": "Divide by 100: 650 ÷ 100 = ₹6.50 (6 Rupees and 50 paise).",
        "exampleAnswer": "₹6.50 (6 Rupees 50 paise)",
        "funFact": "The oldest known paper money was issued during the Song Dynasty in China in the 11th century!",
        "mascotAdvice": "When writing rupees and paise, the dot always separates rupees on the left from paise on the right!"
    },

    # ==================== Class 4 (ICSE) ====================
    {
        "board": "icse", "grade": "Class 4", "chapterNumber": 1,
        "title": "Large Numbers & Place Value", "icon": "🔢",
        "description": "Numbers up to 7 digits (Ten Lakhs / Millions), Indian & International systems, place value, and comparison.",
        "keyConcepts": ["Indian Place Value (Lakhs, Ten Lakhs)", "International Place Value (Millions)", "Periods and Commas Placement", "Successor, Predecessor & Expanded Form"],
        "rules": [
            "Indian System periods: Ones (H, T, O), Thousands (T-Th, Th), Lakhs (T-L, L). Commas: 3, 2, 2.",
            "International System periods: Ones (H, T, O), Thousands (H-Th, T-Th, Th), Millions (H-M, T-M, M). Commas: 3, 3, 3.",
            "10 Lakhs = 1 Million; 1 Crore = 10 Millions.",
            "The place value of 0 is ALWAYS 0, regardless of the position it occupies."
        ],
        "exampleQuestion": "Write the numeral for 'Five lakh forty-two thousand six hundred eight' with proper Indian commas:",
        "exampleExplanation": "Lakhs period: 5. Thousands period: 42. Ones period: 608. Numeral = 5,42,608.",
        "exampleAnswer": "5,42,608",
        "funFact": "A googol is the number 1 followed by 100 zeros, which inspired the company name Google!",
        "mascotAdvice": "Indian system groups by 3 then 2s; International system always groups by 3s!"
    },
    {
        "board": "icse", "grade": "Class 4", "chapterNumber": 2,
        "title": "Roman Numerals", "icon": "🏛️",
        "description": "Reading and writing Roman numerals up to C (100), rules of addition and subtraction.",
        "keyConcepts": ["Symbols: I=1, V=5, X=10, L=50, C=100", "Rules of Repetition (Max 3 Times)", "Rules of Addition (Right) & Subtraction (Left)", "Writing 2-Digit Numbers in Roman Numerals"],
        "rules": [
            "I, X, C can be repeated up to 3 times. V and L are NEVER repeated.",
            "I can be subtracted from V and X only (IV=4, IX=9).",
            "X can be subtracted from L and C only (XL=40, XC=90).",
            "V and L are NEVER subtracted."
        ],
        "exampleQuestion": "Write the number 49 in Roman numerals:",
        "exampleExplanation": "Break into tens and ones: 49 = 40 + 9. 40 is XL, and 9 is IX. Combining gives XLIX.",
        "exampleAnswer": "XLIX",
        "funFact": "Super Bowl championships in American football are famously numbered using Roman numerals (e.g. Super Bowl LVIII)!",
        "mascotAdvice": "Always split into Tens and Ones first: 40 + 9 = XL + IX = XLIX (never write IL)!"
    },
    {
        "board": "icse", "grade": "Class 4", "chapterNumber": 3,
        "title": "Operations on Large Numbers", "icon": "➕",
        "description": "Addition and subtraction of numbers up to 6 digits, estimation of sums and differences, and word problems.",
        "keyConcepts": ["Addition of 5 & 6-Digit Numbers", "Subtraction with Multi-Column Regrouping", "Rounding to Nearest 1,000 & 10,000", "Multi-Step Word Problems"],
        "rules": [
            "Always align digits according to their place values before adding or subtracting.",
            "Minuend - Subtrahend = Difference; Check: Difference + Subtrahend = Minuend.",
            "To round to nearest 1,000: Check hundreds digit. If 5 or more, round up; if less than 5, round down."
        ],
        "exampleQuestion": "A town has a population of 3,45,670. If 1,28,450 are children, how many adults live in the town?",
        "exampleExplanation": "Subtract children from total: 3,45,670 - 1,28,450 = 2,17,220 adults.",
        "exampleAnswer": "2,17,220 adults",
        "funFact": "National census counts in India record over 1.4 billion people using large-number subtraction and addition databases!",
        "mascotAdvice": "Line up commas and place values vertically before performing column addition or subtraction!"
    },
    {
        "board": "icse", "grade": "Class 4", "chapterNumber": 4,
        "title": "Multiplication & Division", "icon": "✖️",
        "description": "Multiplication by 2 and 3-digit numbers, long division by 2-digit divisors, quotient and remainder.",
        "keyConcepts": ["Multiplication by 2-Digit Numbers", "Lattice & Column Multiplication", "Long Division by 2-Digit Divisors", "Verifying Division Algorithm"],
        "rules": [
            "Dividend = (Divisor × Quotient) + Remainder.",
            "Remainder must always be smaller than the Divisor.",
            "Multiplying by multiples of 10: 24 × 300 = (24 × 3) × 100 = 72 × 100 = 7,200."
        ],
        "exampleQuestion": "A school orders 35 boxes of books. Each box contains 124 books. What is the total number of books?",
        "exampleExplanation": "Multiply: 124 × 35 = 124 × (30 + 5) = 3,720 + 620 = 4,340 books.",
        "exampleAnswer": "4,340 books",
        "funFact": "The word 'Multiplication' comes from Latin 'multi' (many) and 'plicare' (to fold)!",
        "mascotAdvice": "Don't forget the zero placeholder when multiplying by the tens digit!"
    },
    {
        "board": "icse", "grade": "Class 4", "chapterNumber": 5,
        "title": "Factors and Multiples", "icon": "🧩",
        "description": "Prime & composite numbers, divisibility tests (2, 3, 5, 9, 10), prime factorisation, HCF and LCM.",
        "keyConcepts": ["Factors & Multiples Definition", "Prime vs Composite Numbers", "Divisibility Rules for 2, 3, 5, 6, 9, 10", "Highest Common Factor (HCF)", "Lowest Common Multiple (LCM)"],
        "rules": [
            "A factor divides a number completely with zero remainder.",
            "1 is a factor of every number; Every number is a multiple of itself.",
            "HCF is the greatest factor common to two or more numbers.",
            "LCM is the smallest positive multiple common to two or more numbers.",
            "HCF × LCM = Product of the two numbers."
        ],
        "exampleQuestion": "Find the HCF of 18 and 24:",
        "exampleExplanation": "Factors of 18: 1, 2, 3, 6, 9, 18. Factors of 24: 1, 2, 3, 4, 6, 8, 12, 24. Common factors: 1, 2, 3, 6. Highest = 6.",
        "exampleAnswer": "6",
        "funFact": "Cicadas stay underground for exactly 13 or 17 years (both prime numbers!) so predators cannot sync with their lifecycles!",
        "mascotAdvice": "Factors are FEW (they are smaller or equal); Multiples are MANY (they grow bigger and bigger)!"
    },
    {
        "board": "icse", "grade": "Class 4", "chapterNumber": 6,
        "title": "Fractions", "icon": "🍕",
        "description": "Types of fractions (proper, improper, mixed, unit, like, unlike), equivalent fractions, and addition & subtraction.",
        "keyConcepts": ["Proper, Improper & Mixed Fractions", "Equivalent Fractions by Multiplication/Division", "Comparing Like & Unlike Fractions", "Addition & Subtraction of Like/Unlike Fractions"],
        "rules": [
            "Proper Fraction: Numerator < Denominator; Improper: Numerator ≥ Denominator.",
            "To convert improper to mixed: Divide numerator by denominator -> Quotient Remainder/Divisor.",
            "To find equivalent fraction: Multiply or divide both numerator and denominator by the same non-zero number.",
            "Like fractions addition: Keep denominator the same, add numerators: a/c + b/c = (a + b)/c."
        ],
        "exampleQuestion": "Convert the improper fraction 17/5 into a mixed fraction:",
        "exampleExplanation": "Divide 17 by 5: 17 ÷ 5 = 3 with remainder 2. So 17/5 = 3 2/5.",
        "exampleAnswer": "3 2/5",
        "funFact": "Musical notes are named by fractions: whole note, half note, quarter note, eighth note, and sixteenth note!",
        "mascotAdvice": "Never add denominators! Only add or subtract the numerators!"
    },
    {
        "board": "icse", "grade": "Class 4", "chapterNumber": 7,
        "title": "Decimals", "icon": "🔘",
        "description": "Tenths and hundredths, place value chart, decimal fractions, comparing decimals, and addition/subtraction.",
        "keyConcepts": ["Tenths (1/10 = 0.1) & Hundredths (1/100 = 0.01)", "Decimal Place Value Chart", "Converting Fractions to Decimals", "Adding & Subtracting Decimals"],
        "rules": [
            "1 tenth = 0.1; 1 hundredth = 0.01.",
            "7/10 = 0.7; 45/100 = 0.45; 3/100 = 0.03.",
            "To compare decimals, compare whole number parts first; then tenths, then hundredths.",
            "Line up the decimal points vertically when adding or subtracting."
        ],
        "exampleQuestion": "Convert 7/100 into decimal form:",
        "exampleExplanation": "Dividing by 100 shifts the decimal point 2 places to the left: 7/100 = 0.07.",
        "exampleAnswer": "0.07",
        "funFact": "Olympic sprint races measure finishes down to thousandths of a second (0.001 s) to decide gold medal winners!",
        "mascotAdvice": "Don't confuse 7/10 (0.7) with 7/100 (0.07)—the zero in the tenths place matters!"
    },
    {
        "board": "icse", "grade": "Class 4", "chapterNumber": 8,
        "title": "Unitary Method & Money", "icon": "💵",
        "description": "Unitary method problems, calculating cost of 1 to find many, preparing bills, and money transactions.",
        "keyConcepts": ["Unitary Method (Divide to find 1, Multiply for many)", "Preparing Cash Memos and Invoices", "Multi-Step Shopping Problems", "Profit and Loss Basics"],
        "rules": [
            "Unitary Method Rule: Cost of 1 unit = Total Cost ÷ Total Quantity.",
            "Cost of required units = Cost of 1 unit × Required Quantity.",
            "Total Bill = Sum of (Item Quantity × Rate per Unit).",
            "Balance returned = Money Paid - Total Bill."
        ],
        "exampleQuestion": "If 8 identical pens cost ₹96, what is the cost of 5 such pens?",
        "exampleExplanation": "Step 1: Cost of 1 pen = ₹96 ÷ 8 = ₹12. Step 2: Cost of 5 pens = 5 × ₹12 = ₹60.",
        "exampleAnswer": "₹60",
        "funFact": "Wholesale markets use the unitary method to price tons of wheat per quintal and per kilogram!",
        "mascotAdvice": "Always find the cost of ONE item first by division, then multiply to find the required count!"
    },
    {
        "board": "icse", "grade": "Class 4", "chapterNumber": 9,
        "title": "Metric Measures", "icon": "📏",
        "description": "Conversions of Length (km, m, cm, mm), Mass (kg, g), Capacity (L, mL), and arithmetic operations.",
        "keyConcepts": ["Length: 1 km = 1,000 m, 1 m = 100 cm, 1 cm = 10 mm", "Mass: 1 kg = 1,000 g", "Capacity: 1 L = 1,000 mL", "Adding & Subtracting Compound Metric Units"],
        "rules": [
            "Higher to lower unit -> MULTIPLY (km -> m × 1,000; kg -> g × 1,000; L -> mL × 1,000).",
            "Lower to higher unit -> DIVIDE (m -> km ÷ 1,000; g -> kg ÷ 1,000; mL -> L ÷ 1,000).",
            "Keep units in separate aligned columns when performing column addition."
        ],
        "exampleQuestion": "A water tank contains 45 L 750 mL of water. If 18 L 250 mL is used, how much water remains?",
        "exampleExplanation": "Liters: 45 - 18 = 27 L. Milliliters: 750 - 250 = 500 mL. Remaining = 27 L 500 mL.",
        "exampleAnswer": "27 L 500 mL",
        "funFact": "The metre was redefined in 1983 as the distance light travels in a vacuum in 1/299,792,458 of a second!",
        "mascotAdvice": "Borrowing in metric: 1 kg borrowed gives 1,000 grams; 1 meter borrowed gives 100 centimeters!"
    },
    {
        "board": "icse", "grade": "Class 4", "chapterNumber": 10,
        "title": "Time and Calendar", "icon": "⏰",
        "description": "12-hour clock (AM/PM) vs 24-hour railway clock, converting hours, minutes, seconds, elapsed time.",
        "keyConcepts": ["12-Hour vs 24-Hour Railway Time", "Converting Units: Hours <-> Minutes <-> Seconds", "Elapsed Time Calculation", "Leap Year Rules and Calendar Months"],
        "rules": [
            "1 hour = 60 minutes; 1 minute = 60 seconds; 1 day = 24 hours.",
            "24-Hour Railway Clock: Add 12 to PM hours (e.g. 7:30 PM = 19:30 hours).",
            "To convert 24-hour time to 12-hour: If hours > 12, subtract 12 and write PM (e.g. 15:45 = 3:45 PM).",
            "Elapsed Duration = Arrival/End Time - Departure/Start Time."
        ],
        "exampleQuestion": "A train departs at 08:30 hours and reaches its destination at 14:15 hours. How long was the journey?",
        "exampleExplanation": "From 08:30 to 14:15: 08:30 to 13:30 is 5 hours; 13:30 to 14:15 is 45 minutes. Total journey = 5 hours 45 minutes.",
        "exampleAnswer": "5 hours 45 minutes",
        "funFact": "Railway timetables use 24-hour time worldwide to eliminate dangerous confusion between AM and PM!",
        "mascotAdvice": "If the hour is 13 or higher, subtract 12 to find the PM time instantly!"
    },
    {
        "board": "icse", "grade": "Class 4", "chapterNumber": 11,
        "title": "Geometry: Angles and Polygons", "icon": "📐",
        "description": "Types of angles (acute, right, obtuse, straight), measuring angles, types of polygons, and circle terms.",
        "keyConcepts": ["Acute (<90°), Right (90°), Obtuse (>90°), Straight (180°)", "Protractor Angle Measurement", "Polygon Classification (Triangle, Quadrilateral, Pentagon)", "Circle: Center, Radius, Diameter, Chord"],
        "rules": [
            "Right angle = exactly 90°; Acute angle < 90°; Obtuse angle is between 90° and 180°.",
            "Diameter of a circle = 2 × Radius (d = 2r); Radius = Diameter ÷ 2.",
            "Chord is a line segment connecting any two points on a circle boundary. The diameter is the longest chord."
        ],
        "exampleQuestion": "If the radius of a circular dinner plate is 14 cm, what is its diameter?",
        "exampleExplanation": "Diameter = 2 × Radius = 2 × 14 = 28 cm.",
        "exampleAnswer": "28 cm",
        "funFact": "Protractor angles are divided into 360 degrees because ancient Babylonian astronomers estimated 360 days in a solar year!",
        "mascotAdvice": "Radius is from center to edge (halfway); Diameter goes all the way across through the center!"
    },
    {
        "board": "icse", "grade": "Class 4", "chapterNumber": 12,
        "title": "Perimeter and Area", "icon": "🟩",
        "description": "Perimeter of rectilinear figures, formula for perimeter of rectangle and square, area by unit square grids.",
        "keyConcepts": ["Perimeter = Total Boundary Length", "Perimeter of Rectangle = 2 × (Length + Width)", "Perimeter of Square = 4 × Side", "Area = Surface Enclosed (cm², m²)"],
        "rules": [
            "Perimeter of Rectangle = 2 × (Length + Breadth).",
            "Perimeter of Square = 4 × Side.",
            "Area of Rectangle = Length × Breadth (L × B).",
            "Area of Square = Side × Side (S²).",
            "Perimeter is measured in units (cm, m); Area is measured in square units (cm², m²)."
        ],
        "exampleQuestion": "A rectangular swimming pool is 25 meters long and 10 meters wide. What is its perimeter?",
        "exampleExplanation": "Perimeter = 2 × (Length + Breadth) = 2 × (25 + 10) = 2 × 35 = 70 meters.",
        "exampleAnswer": "70 meters",
        "funFact": "The perimeter of the Pentagon building in Washington D.C. is approximately 1.4 kilometers around its outer boundary!",
        "mascotAdvice": "Perimeter is walking the boundary fence; Area is laying tiles on the floor inside!"
    },
    {
        "board": "icse", "grade": "Class 4", "chapterNumber": 13,
        "title": "Data Representation", "icon": "📊",
        "description": "Tally marks, pictographs with scale, drawing bar graphs, reading titles, scales, and labels.",
        "keyConcepts": ["Frequency Tables with Tally Marks", "Pictographs with Key Values", "Horizontal & Vertical Bar Graphs", "Reading Scale Intervals"],
        "rules": [
            "All bars in a bar graph must have equal width and equal uniform spacing.",
            "The height of the bar represents the numerical frequency.",
            "Always include the Title, Axis Labels, and Scale Unit."
        ],
        "exampleQuestion": "On a bar graph, 1 cm represents 8 books. If the Science bar is 5 cm tall, how many Science books are there?",
        "exampleExplanation": "Multiply height by scale: 5 cm × 8 books/cm = 40 books.",
        "exampleAnswer": "40 books",
        "funFact": "Florence Nightingale created polar area diagrams during the Crimean War in 1858 to convince the government to build sanitary hospitals!",
        "mascotAdvice": "Look straight across from the top of the bar with a ruler to read the number on the axis accurately!"
    },

    # ==================== Class 5 (ICSE) ====================
    {
        "board": "icse", "grade": "Class 5", "chapterNumber": 1,
        "title": "Large Numbers up to 9 Digits", "icon": "🔢",
        "description": "Crores and Ten Crores, Billions, period grouping, comparison, and rounding off large numbers.",
        "keyConcepts": ["Numbers up to 9 Digits (Crores & Billions)", "Indian vs International System Equivalence", "Rounding Off to Nearest 10,000 and 1,00,000", "Face Value & Place Value"],
        "rules": [
            "Indian System: Ones (3), Thousands (2), Lakhs (2), Crores (2).",
            "International System: Ones (3), Thousands (3), Millions (3), Billions (3).",
            "100 Millions = 10 Crores; 1 Billion = 100 Crores = 1,000 Millions.",
            "Rounding rule: If the digit to the right is 5 or more, round up; otherwise round down."
        ],
        "exampleQuestion": "How many millions make 5 crores?",
        "exampleExplanation": "1 crore = 10 million. Therefore, 5 crores = 5 × 10 = 50 million.",
        "exampleAnswer": "50 million",
        "funFact": "India's human population exceeds 1.4 billion, which is 140 crores in the Indian number system!",
        "mascotAdvice": "Always place commas starting from the rightmost digit!"
    },
    {
        "board": "icse", "grade": "Class 5", "chapterNumber": 2,
        "title": "Roman Numerals to 1,000", "icon": "🏛️",
        "description": "Reading and writing Roman numerals up to M (1,000), symbols D (500) and M (1,000), and rules.",
        "keyConcepts": ["Symbols: I=1, V=5, X=10, L=50, C=100, D=500, M=1000", "Repetition Rules (I, X, C, M)", "Subtraction Rules (IV, IX, XL, XC, CD, CM)", "Conversion between Hindu-Arabic and Roman"],
        "rules": [
            "I can be subtracted from V and X only; X from L and C only; C from D and M only.",
            "V, L, D are NEVER repeated and NEVER subtracted.",
            "CD = 500 - 100 = 400; CM = 1000 - 100 = 900.",
            "A smaller numeral between two greater numerals is always subtracted from the numeral on its right (e.g. XIV = 10 + (5-1) = 14)."
        ],
        "exampleQuestion": "Write the year 1995 in Roman numerals:",
        "exampleExplanation": "1995 = 1000 + 900 + 90 + 5. 1000=M, 900=CM, 90=XC, 5=V. Combining gives MCMXCV.",
        "exampleAnswer": "MCMXCV",
        "funFact": "Movie production studios still display copyright years in Roman numerals at the end of film credits (e.g. MMXXIV = 2024)!",
        "mascotAdvice": "Break the number into thousands, hundreds, tens, and ones: 1000 + 900 + 90 + 5 = M + CM + XC + V!"
    },
    {
        "board": "icse", "grade": "Class 5", "chapterNumber": 3,
        "title": "Fundamental Operations", "icon": "🧮",
        "description": "Four operations on multi-digit numbers, order of operations (BODMAS), estimation, and complex word problems.",
        "keyConcepts": ["Multiplication & Division of Multi-Digit Numbers", "BODMAS / PEMDAS Order of Operations", "Estimating Products and Quotients", "Multi-Step Practical Word Problems"],
        "rules": [
            "BODMAS Rule: Brackets () -> Orders/Of -> Division (÷) -> Multiplication (×) -> Addition (+) -> Subtraction (-).",
            "Multiplication and division have equal priority (work left to right); addition and subtraction have equal priority (left to right).",
            "Dividend = (Divisor × Quotient) + Remainder."
        ],
        "exampleQuestion": "Evaluate using BODMAS: 25 + 15 ÷ 3 × 4 - 8",
        "exampleExplanation": "1. Division: 15 ÷ 3 = 5 -> 25 + 5 × 4 - 8. 2. Multiplication: 5 × 4 = 20 -> 25 + 20 - 8. 3. Addition: 25 + 20 = 45. 4. Subtraction: 45 - 8 = 37.",
        "exampleAnswer": "37",
        "funFact": "Modern supercomputers follow the exact same BODMAS order of operations when executing billions of calculations per second!",
        "mascotAdvice": "Always do Division and Multiplication BEFORE you do Addition and Subtraction!"
    },
    {
        "board": "icse", "grade": "Class 5", "chapterNumber": 4,
        "title": "Factors, Multiples & Divisibility", "icon": "🧩",
        "description": "Divisibility tests for 2, 3, 4, 5, 6, 8, 9, 10, 11; prime factorisation (factor tree & division), HCF and LCM.",
        "keyConcepts": ["Divisibility Rules for 4, 8, 11", "Prime Factorisation by Division Method", "HCF by Division Method", "LCM by Common Division Method", "Properties of HCF and LCM"],
        "rules": [
            "Divisibility by 4: Last 2 digits form a number divisible by 4.",
            "Divisibility by 8: Last 3 digits form a number divisible by 8.",
            "Divisibility by 11: Difference between sum of odd placed digits and sum of even placed digits is 0 or multiple of 11.",
            "HCF × LCM = Product of the two numbers."
        ],
        "exampleQuestion": "Is the number 3,476 divisible by 4?",
        "exampleExplanation": "Check the last 2 digits: 76. 76 ÷ 4 = 19 (exact, remainder 0). Yes, 3,476 is divisible by 4.",
        "exampleAnswer": "Yes (last 2 digits 76 are divisible by 4)",
        "funFact": "Prime factorisation is so difficult for massive 500-digit numbers that it forms the foundation of all modern internet banking encryption!",
        "mascotAdvice": "To find HCF of two numbers quickly, use continuous long division until remainder becomes zero!"
    },
    {
        "board": "icse", "grade": "Class 5", "chapterNumber": 5,
        "title": "Fractions & Operations", "icon": "🍰",
        "description": "Addition, subtraction, multiplication, and division of fractions, reciprocal, and simplifying complex fractions.",
        "keyConcepts": ["Multiplication of Fractions (N×N / D×D)", "Reciprocal (Multiplicative Inverse)", "Division of Fractions (Multiply by Reciprocal)", "Fractions of Quantities in Real Life"],
        "rules": [
            "(a/b) × (c/d) = (a × c) / (b × d).",
            "Reciprocal of a/b is b/a (provided a, b ≠ 0). Product of a fraction and its reciprocal is always 1.",
            "Division rule: (a/b) ÷ (c/d) = (a/b) × (d/c).",
            "Always simplify the final fraction to lowest terms by dividing by the HCF."
        ],
        "exampleQuestion": "Solve: (5/8) × (4/15)",
        "exampleExplanation": "Multiply and simplify: (5 × 4) / (8 × 15) = 20 / 120 = 1/6.",
        "exampleAnswer": "1/6",
        "funFact": "Stock markets in the United States traded stock prices in fractional sixteenths (like 15 3/16) until the year 2001!",
        "mascotAdvice": "Cancel out common factors between numerators and denominators BEFORE multiplying to save time!"
    },
    {
        "board": "icse", "grade": "Class 5", "chapterNumber": 6,
        "title": "Decimals: Operations & Rounding", "icon": "🔘",
        "description": "Multiplication and division of decimals by 10, 100, 1000 and by decimals, rounding off to tenths and hundredths.",
        "keyConcepts": ["Multiplication of Decimals", "Division of Decimals", "Shifting Decimals by Powers of 10", "Rounding to Nearest Tenth and Hundredth"],
        "rules": [
            "Multiplying by 10 shifts decimal 1 place RIGHT; by 100 shifts 2 places RIGHT.",
            "Dividing by 10 shifts decimal 1 place LEFT; by 100 shifts 2 places LEFT.",
            "To divide a decimal by another decimal, multiply both by 10, 100... to make the divisor a whole number.",
            "In decimal multiplication, count total decimal places in both factors: 0.3 × 0.04 = 0.012 (3 decimal places)."
        ],
        "exampleQuestion": "Solve: 2.5 × 0.04",
        "exampleExplanation": "Multiply as whole numbers: 25 × 4 = 100. Count decimal places: 1 + 2 = 3 decimal places. Result = 0.100 = 0.1.",
        "exampleAnswer": "0.1",
        "funFact": "GPS satellites calculate locations to 9 decimal places of precision, accurate to within a few centimeters on Earth!",
        "mascotAdvice": "Count the total decimal digits in both numbers, multiply like regular integers, then place the decimal back!"
    },
    {
        "board": "icse", "grade": "Class 5", "chapterNumber": 7,
        "title": "Introduction to Percentages", "icon": "💹",
        "description": "Meaning of percentage (per hundred), converting fractions and decimals to %, and finding % of a quantity.",
        "keyConcepts": ["Meaning of Percent (%) = Parts per 100", "Converting Fractions & Decimals to %", "Converting % to Fraction in Lowest Terms", "Finding X% of a Number"],
        "rules": [
            "Percent means 'per hundred'. The symbol is %.",
            "To convert fraction to percentage: Multiply by 100% (e.g. 4/5 × 100% = 80%).",
            "To convert % to fraction: Divide by 100 (e.g. 25% = 25/100 = 1/4).",
            "To find X% of Y: Formula = (X / 100) × Y."
        ],
        "exampleQuestion": "In an exam of 80 total marks, Priya scores 75%. How many marks did Priya score?",
        "exampleExplanation": "Calculate: 75% of 80 = (75 ÷ 100) × 80 = (3/4) × 80 = 60 marks.",
        "exampleAnswer": "60 marks",
        "funFact": "Batteries on smartphones display charge as a percentage, representing remaining chemical voltage capacity!",
        "mascotAdvice": "75% is 3/4; 50% is 1/2; 25% is 1/4; 10% is 1/10—memorize these benchmark fractions!"
    },
    {
        "board": "icse", "grade": "Class 5", "chapterNumber": 8,
        "title": "Unitary Method", "icon": "⚖️",
        "description": "Direct variation unitary method, multi-step problem solving, time-work, and cost-quantity calculations.",
        "keyConcepts": ["Finding Value of 1 Unit by Division", "Finding Value of Multiple Units by Multiplication", "Direct Proportion Situations", "Real-Life Consumer Math"],
        "rules": [
            "Unitary Method Principle: First find the value of a single unit, then use that to find the value of any number of units.",
            "Unit Cost = Total Cost ÷ Total Number of Items.",
            "Total Cost = Unit Cost × Required Number of Items."
        ],
        "exampleQuestion": "A factory produces 360 lightbulbs in 6 hours. How many lightbulbs will it produce in 9 hours at the same rate?",
        "exampleExplanation": "Step 1: In 1 hour = 360 ÷ 6 = 60 bulbs. Step 2: In 9 hours = 9 × 60 = 540 lightbulbs.",
        "exampleAnswer": "540 lightbulbs",
        "funFact": "Car speedometers use the unitary method: traveling 60 km in 1 hour means you travel 1 km every single minute!",
        "mascotAdvice": "Divide down to ONE, then multiply up to the TARGET!"
    },
    {
        "board": "icse", "grade": "Class 5", "chapterNumber": 9,
        "title": "Money: Profit and Loss", "icon": "💰",
        "description": "Cost Price (CP), Selling Price (SP), Profit, Loss, and calculating Profit or Loss in rupees.",
        "keyConcepts": ["Cost Price (CP) & Selling Price (SP)", "Profit = SP - CP (when SP > CP)", "Loss = CP - SP (when CP > SP)", "Overhead Expenses (Transportation, Labor)"],
        "rules": [
            "Profit occurs when Selling Price (SP) is greater than Cost Price (CP): Profit = SP - CP.",
            "Loss occurs when Cost Price (CP) is greater than Selling Price (SP): Loss = CP - SP.",
            "Effective CP = Original Buying Price + Overhead Expenses (repairs, transport).",
            "SP = CP + Profit; SP = CP - Loss."
        ],
        "exampleQuestion": "A shopkeeper buys a bicycle for ₹2,400 and spends ₹100 on transportation. He sells it for ₹2,800. What is his profit?",
        "exampleExplanation": "Total CP = ₹2,400 + ₹100 = ₹2,500. Profit = SP - CP = ₹2,800 - ₹2,500 = ₹300.",
        "exampleAnswer": "₹300 profit",
        "funFact": "Overhead expenses must always be added to the cost price—merchants have tracked overheads since the Silk Road era!",
        "mascotAdvice": "Always add extra expenses (repairs, shipping) to CP before comparing with SP!"
    },
    {
        "board": "icse", "grade": "Class 5", "chapterNumber": 10,
        "title": "Metric Measures & Temperature", "icon": "🌡️",
        "description": "Comprehensive metric conversions, word problems, temperature measurement in Celsius and Fahrenheit.",
        "keyConcepts": ["Metric Prefixes: Kilo, Hecto, Deca, Base, Deci, Centi, Milli", "Celsius (°C) and Fahrenheit (°F) Scales", "Clinical Thermometer (Normal Body Temp: 37°C / 98.6°F)", "Boiling & Freezing Points of Water"],
        "rules": [
            "Freezing point of pure water: 0°C (32°F); Boiling point of water: 100°C (212°F).",
            "Normal human body temperature: 37°C (98.6°F).",
            "Metric ladder: King Henry Died By Drinking Chocolate Milk (Kilo, Hecto, Deka, Base, Deci, Centi, Milli)."
        ],
        "exampleQuestion": "What is the boiling point of pure water on the Celsius temperature scale?",
        "exampleExplanation": "On the Celsius scale, pure water boils at 100°C at standard atmospheric pressure.",
        "exampleAnswer": "100°C",
        "funFact": "Anders Celsius originally created the scale upside down: 0° was boiling water and 100° was freezing ice!",
        "mascotAdvice": "Normal body temp is 37°C (98.6°F); fever is above 38°C (100.4°F)!"
    },
    {
        "board": "icse", "grade": "Class 5", "chapterNumber": 11,
        "title": "Time, Distance and Speed", "icon": "🚀",
        "description": "Relationship between Speed, Distance, and Time; units (km/h and m/s), average speed, and travel journeys.",
        "keyConcepts": ["Speed = Distance / Time", "Distance = Speed × Time", "Time = Distance / Speed", "Converting km/h to m/s (Multiply by 5/18)"],
        "rules": [
            "Speed = Distance ÷ Time.",
            "Distance = Speed × Time; Time = Distance ÷ Speed.",
            "To convert km/h to m/s: Multiply by 5/18 (e.g. 72 km/h × 5/18 = 20 m/s).",
            "To convert m/s to km/h: Multiply by 18/5 (e.g. 10 m/s × 18/5 = 36 km/h)."
        ],
        "exampleQuestion": "A car travels a distance of 180 km in 3 hours. What is its speed in km/h?",
        "exampleExplanation": "Speed = Distance ÷ Time = 180 km ÷ 3 hours = 60 km/h.",
        "exampleAnswer": "60 km/h",
        "funFact": "The cheetah is the fastest land animal, accelerating from 0 to 96 km/h in just 3 seconds!",
        "mascotAdvice": "Use the DST triangle: Cover D to get S × T; Cover S to get D / T; Cover T to get D / S!"
    },
    {
        "board": "icse", "grade": "Class 5", "chapterNumber": 12,
        "title": "Geometry: Angles, Triangles & Circles", "icon": "📐",
        "description": "Constructing angles with protractor, angle sum property of triangle (180°), types of triangles and parts of circles.",
        "keyConcepts": ["Angle Sum Property of Triangle = 180°", "Classification of Triangles (Equilateral, Isosceles, Scalene)", "Acute, Right, Obtuse Triangles", "Circle: Radius, Diameter, Circumference, Arc, Sector"],
        "rules": [
            "The sum of all three interior angles of ANY triangle is ALWAYS 180°.",
            "Equilateral triangle has 3 equal sides and three 60° angles.",
            "A triangle CANNOT have more than one right angle or more than one obtuse angle.",
            "Diameter = 2 × Radius; Circumference ≈ 3.14 × Diameter."
        ],
        "exampleQuestion": "Two angles of a triangle are 50° and 60°. What is the measure of the third angle?",
        "exampleExplanation": "Sum of angles in a triangle = 180°. Third angle = 180° - (50° + 60°) = 180° - 110° = 70°.",
        "exampleAnswer": "70°",
        "funFact": "Bermuda Triangle is a famous triangular oceanic region of 1.3 million square kilometers!",
        "mascotAdvice": "Add the two known angles together and subtract from 180° to find the third missing angle!"
    },
    {
        "board": "icse", "grade": "Class 5", "chapterNumber": 13,
        "title": "Perimeter, Area & Volume", "icon": "📦",
        "description": "Perimeter and Area of rectangles and squares, introduction to volume of cubes and cuboids (cm³).",
        "keyConcepts": ["Area of Rectangle = L × W, Square = S²", "Perimeter of Rectangle = 2(L + W), Square = 4S", "Volume of Cuboid = L × W × H", "Volume of Cube = S³ (Cubic Units cm³)"],
        "rules": [
            "Area of Rectangle = Length × Breadth; Area of Square = Side × Side.",
            "Volume of Cuboid = Length × Breadth × Height (L × B × H).",
            "Volume of Cube = Side × Side × Side (S³).",
            "1 cubic meter (1 m³) = 1,000,000 cm³; 1 liter = 1,000 cm³."
        ],
        "exampleQuestion": "Find the volume of a wooden cube with side 5 cm:",
        "exampleExplanation": "Volume of cube = Side³ = 5 × 5 × 5 = 125 cm³.",
        "exampleAnswer": "125 cm³",
        "funFact": "A standard Olympic swimming pool holds approximately 2,500,000 liters (2,500 m³) of water!",
        "mascotAdvice": "Length is 1D (cm), Area is 2D (cm²), Volume is 3D (cm³)!"
    },
    {
        "board": "icse", "grade": "Class 5", "chapterNumber": 14,
        "title": "Data Handling: Pie Charts & Line Graphs", "icon": "📈",
        "description": "Circle graphs (pie charts), line graphs for trends over time, reading temperature and stock charts.",
        "keyConcepts": ["Pie Charts (Fractions of 360°)", "Line Graphs (Trends over Time)", "Interpreting Double Bar Graphs", "Extracting Conclusions from Data"],
        "rules": [
            "In a pie chart, the entire circle represents 100% or 360°.",
            "Half circle = 50% = 180°; Quarter circle = 25% = 90°.",
            "A line graph is ideal for showing changes and trends over continuous time intervals (e.g. temperature over a week)."
        ],
        "exampleQuestion": "On a pie chart showing a family budget, food occupies half the circle (180°). What percentage of the budget is spent on food?",
        "exampleExplanation": "Half the circle = 180° out of 360° = 180/360 = 50% of the total budget.",
        "exampleAnswer": "50%",
        "funFact": "Electrocardiograms (ECGs) used by cardiologists are high-speed line graphs tracking electrical heart rhythms!",
        "mascotAdvice": "Follow the line on a line graph from left to right to see if the trend goes up, down, or stays flat!"
    }
]
