import json

# Load existing chapters
with open(r'd:\AI Learning\assets\curriculum\chapters_data.json', 'r', encoding='utf-8') as f:
    chapters = json.load(f)

# Comprehensive dictionary mapping (grade, title) -> rich specific pedagogical data
chapter_details = {
    # --- Class 4 ---
    ("Class 4", "Building with Bricks"): {
        "concepts": ["3D Brick Faces & Vertices", "Floor & Wall Patterns", "Jaali & Jharokha Arches", "Brick Kiln Calculations"],
        "rules": [
            "A standard cuboid brick has 6 rectangular faces, 12 edges, and 8 vertices (corners).",
            "Opposite faces of a brick are equal in shape and size.",
            "Jaali patterns are perforated brick screens; Jharokhas are arched brick windows."
        ],
        "exampleQuestion": "A brick kiln sells 1,000 bricks for ₹2,500. How much does 1 brick cost?",
        "exampleExplanation": "Divide the total cost by the number of bricks: ₹2,500 ÷ 1,000 = ₹2.50 per brick.",
        "exampleAnswer": "₹2.50 per brick",
        "funFact": "Ancient Indus Valley bricks from 4,500 years ago used the exact same 4:2:1 ratio (Length:Width:Height) used today!",
        "advice": "Remember: A brick's face is a 2D rectangle, but the whole brick is a 3D cuboid solid!"
    },
    ("Class 4", "Long and Short"): {
        "concepts": ["Metric Length Conversion", "Ruler & Tape Measurement", "Marathon Distance Tracking", "Height Comparisons"],
        "rules": [
            "1 kilometer (km) = 1,000 meters (m)",
            "1 meter (m) = 100 centimeters (cm)",
            "To convert km to m, multiply by 1,000; to convert m to km, divide by 1,000."
        ],
        "exampleQuestion": "A marathon race is 40 km long. If an athlete runs 28 km 450 m, how much distance remains?",
        "exampleExplanation": "Convert 40 km to 39 km 1,000 m. Subtract: (39 - 28) km and (1,000 - 450) m = 11 km 550 m.",
        "exampleAnswer": "11 km 550 m",
        "funFact": "The official marathon distance (42.195 km) commemorates the legendary run from Marathon to Athens in ancient Greece!",
        "advice": "Always align meters with meters and kilometers with kilometers before subtracting!"
    },
    ("Class 4", "A Trip to Bhopal"): {
        "concepts": ["Bus Seating & Capacity", "Diesel Refueling Calculations", "Ticket Price Estimation", "Time & Distance Journey"],
        "rules": [
            "Total Cost = Number of Units × Cost per Unit",
            "Buses Needed = Total Passengers ÷ Bus Capacity (round up for remainders)",
            "Distance = Speed × Time; Speed = Distance ÷ Time"
        ],
        "exampleQuestion": "210 students go on a school trip. Each mini bus has 35 seats. How many mini buses are needed?",
        "exampleExplanation": "Divide total students by seat capacity: 210 ÷ 35 = 6 mini buses.",
        "exampleAnswer": "6 mini buses",
        "funFact": "The ancient Bhimbetka rock shelters near Bhopal have cave paintings over 30,000 years old!",
        "advice": "Round up when calculating vehicle capacity—everyone needs a seat on the bus!"
    },
    ("Class 4", "Tick-Tick-Tick"): {
        "concepts": ["12-Hour AM/PM vs 24-Hour Railway Clock", "Minute Hand Increments (Multiples of 5)", "Elapsed Duration Calculation", "Medicine Expiry Dates"],
        "rules": [
            "1 hour = 60 minutes; 1 minute = 60 seconds",
            "24-Hour Railway Time: Add 12 to PM hours (e.g. 5:30 PM = 17:30 hours)",
            "Elapsed Time = End Time - Start Time"
        ],
        "exampleQuestion": "A train departs at 17:15 and arrives at 21:45. How long was the journey?",
        "exampleExplanation": "Subtract departure from arrival: (21 - 17) hours and (45 - 15) mins = 4 hours 30 minutes.",
        "exampleAnswer": "4 hours 30 minutes",
        "funFact": "The second hand was added to clocks around 1560 to time astronomical events accurately!",
        "advice": "Each number on a clock face represents 5 minutes: from 12 to 1 is 5 min, 12 to 6 is 30 min!"
    },
    ("Class 4", "The Way the World Looks"): {
        "concepts": ["Aerial Top View vs Front/Side View", "Floor Plans & Route Maps", "Dice Opposite Faces Rule (Sum to 7)", "Perspective & Vanishing Points"],
        "rules": [
            "Top View (Bird's Eye): Shows shape and layout looking directly down from above.",
            "Front View: Shows height and width when facing straight ahead.",
            "Golden Dice Rule: Opposite numbers on any standard 6-sided dice always add up to 7."
        ],
        "exampleQuestion": "On a standard 6-sided dice, the number on the top face is 2. What number is on the bottom face?",
        "exampleExplanation": "Opposite faces of a dice always add up to 7: 7 - 2 = 5.",
        "exampleAnswer": "5",
        "funFact": "Architects always draw 2D top-view blueprints before building three-dimensional houses!",
        "advice": "Objects look bigger and wider when near you, and look smaller and narrower far away!"
    },
    ("Class 4", "The Junk Seller"): {
        "concepts": ["Reading Scrap Rate Lists", "Calculating Change & Currency Notes", "Multiplication with Box Method", "Simple Loans & Weekly Interest"],
        "rules": [
            "Total Amount = Quantity (kg) × Rate per kg (₹)",
            "Profit = Selling Price (SP) - Cost Price (CP)",
            "Loss = Cost Price (CP) - Selling Price (SP)"
        ],
        "exampleQuestion": "Kiran buys 42 kg of waste paper at ₹14 per kg. How much money does she pay?",
        "exampleExplanation": "Multiply using expanded form: (42 × 10) + (42 × 4) = 420 + 168 = ₹588.",
        "exampleAnswer": "₹588",
        "funFact": "Recycling 1 ton of newspaper saves 17 mature trees and 7,000 gallons of water!",
        "advice": "Break double-digit multiplication into tens and ones (e.g. 42 × 14 = 42×10 + 42×4) for easy mental math!"
    },
    ("Class 4", "Jugs and Mugs"): {
        "concepts": ["Liquid Capacity & Volume", "Measuring in mL vs Liters", "Sum of Fractional Capacities", "Daily Hydration Estimates"],
        "rules": [
            "1 Liter (L) = 1,000 milliliters (mL)",
            "Half Liter = 500 mL; Quarter Liter = 250 mL; 3/4 Liter = 750 mL",
            "To convert Liters to mL, multiply by 1,000; mL to Liters, divide by 1,000."
        ],
        "exampleQuestion": "A doctor prescribes 5 mL of syrup, 3 times a day for 6 days. How much syrup is consumed in total?",
        "exampleExplanation": "Daily dose = 5 mL × 3 = 15 mL. Total for 6 days = 15 mL × 6 = 90 mL.",
        "exampleAnswer": "90 mL",
        "funFact": "An adult human body contains approximately 40 liters of water—about 60% of body mass!",
        "advice": "Eyedrops and medicines are measured in mL; buckets, water tanks, and milk packets are measured in Liters!"
    },
    ("Class 4", "Carts and Wheels"): {
        "concepts": ["Circle Center, Radius, and Diameter", "Drawing Circles with Compass & String", "Tracing Circular Objects", "Wheel Size and Axle Centers"],
        "rules": [
            "Diameter = 2 × Radius (d = 2r)",
            "Radius = Diameter ÷ 2 (r = d / 2)",
            "Every point on a circle is at an exact equal distance from its center point."
        ],
        "exampleQuestion": "If the radius of a cart wheel is 35 cm, what is its diameter?",
        "exampleExplanation": "Diameter is twice the radius: 35 cm × 2 = 70 cm.",
        "exampleAnswer": "70 cm",
        "funFact": "The wheel was invented around 3500 BC in Mesopotamia and transformed human civilization!",
        "advice": "When using a compass, keep the metal pointer completely fixed and rotate only the pencil arm!"
    },
    ("Class 4", "Halves and Quarters"): {
        "concepts": ["Equal Parts of a Whole", "Fraction of a Collection", "Equivalent Fractions (2/4 = 1/2)", "Fractions of Meters and Rupees"],
        "rules": [
            "Half = 1/2 (one part out of two equal parts)",
            "Quarter = 1/4 (one part out of four equal parts)",
            "Three-quarters = 3/4 (three parts out of four equal parts)",
            "2/4 is equivalent to 1/2; 4/4 makes 1 whole."
        ],
        "exampleQuestion": "There are 24 candies in a jar. If you give 1/4 of them to a friend, how many candies do they get?",
        "exampleExplanation": "Divide total candies by 4: 24 ÷ 4 = 6 candies.",
        "exampleAnswer": "6 candies",
        "funFact": "The word fraction comes from the Latin 'fractus', meaning 'broken into pieces'!",
        "advice": "Fractions only work when every single part is exactly the same size!"
    },
    ("Class 4", "Play with Patterns"): {
        "concepts": ["Rotational Symmetry (Quarter & Half Turns)", "Tile & Floor Tessellations", "Magic Squares (Row/Col Sum)", "Secret Alphabet Codes"],
        "rules": [
            "Half Turn (180°): Inverts an object upside down.",
            "Quarter Turn (90°): Rotates an object a quarter circle clockwise or counter-clockwise.",
            "Magic Square Rule: Every row, column, and diagonal adds up to the exact same magic sum.",
            "Even numbers end in 0, 2, 4, 6, 8; Odd numbers end in 1, 3, 5, 7, 9."
        ],
        "exampleQuestion": "In a 3×3 magic square using digits 1 to 9, every row sums to 15. What number belongs in the center cell?",
        "exampleExplanation": "The center cell of a 1-9 magic square is always the average (middle number), which is 5.",
        "exampleAnswer": "5",
        "funFact": "In 1514, artist Albrecht Dürer created an engraving with a magic square where the date 1514 appears in the bottom row!",
        "advice": "Identify the pattern engine: is it adding, alternating, flipping, or turning 90 degrees?"
    },
    ("Class 4", "Tables and Shares"): {
        "concepts": ["Equal Sharing & Division", "Dividend, Divisor, Quotient, Remainder", "Multiplication & Division as Inverse", "Array Arrangements"],
        "rules": [
            "Dividend = (Divisor × Quotient) + Remainder",
            "The Remainder must always be strictly less than the Divisor (R < D).",
            "Inverse Operation: If 8 × 7 = 56, then 56 ÷ 8 = 7 and 56 ÷ 7 = 8."
        ],
        "exampleQuestion": "95 marbles are shared equally among 8 children. How many marbles does each child get, and how many remain?",
        "exampleExplanation": "95 ÷ 8: 8 × 11 = 88, Remainder = 95 - 88 = 7. Each child gets 11 marbles, with 7 marbles left over.",
        "exampleAnswer": "11 marbles each, 7 left over",
        "funFact": "Ancient Egyptians divided numbers by creating tables of successive doublings and halves!",
        "advice": "Check your division: Multiply Quotient × Divisor and add Remainder. You must get the Dividend back!"
    },
    ("Class 4", "How Heavy? How Light?"): {
        "concepts": ["Kilograms and Grams Conversion", "Pan Balance Equilibrium", "Standard Weights (50g to 1kg)", "Postal Rate Calculations"],
        "rules": [
            "1 kilogram (kg) = 1,000 grams (g)",
            "Half kg = 500 g; Quarter kg = 250 g; 3/4 kg = 750 g",
            "To convert kg to g, multiply by 1,000; g to kg, divide by 1,000."
        ],
        "exampleQuestion": "A parcel weighs 1 kg 450 g. What is its total weight in grams?",
        "exampleExplanation": "Convert 1 kg to 1,000 g and add 450 g: 1,000 + 450 = 1,450 grams.",
        "exampleAnswer": "1,450 grams",
        "funFact": "The kilogram was originally defined as the mass of one liter of pure water at freezing point!",
        "advice": "On a balance scale, heavier objects sink lower while lighter objects rise up!"
    },
    ("Class 4", "Fields and Fences"): {
        "concepts": ["Perimeter as Boundary Length", "Wire Fencing Calculations", "Comparing Different Shapes with Same Boundary", "Square Grid Perimeter"],
        "rules": [
            "Perimeter = Total distance along the outer boundary of a closed shape.",
            "Perimeter of Rectangle = 2 × (Length + Width)",
            "Perimeter of Square = 4 × Side length",
            "Perimeter of Triangle = Sum of all 3 sides"
        ],
        "exampleQuestion": "A farmer has a rectangular field 25 m long and 15 m wide. How many meters of wire are needed to fence it with 2 rounds of wire?",
        "exampleExplanation": "1 round = Perimeter = 2 × (25 + 15) = 2 × 40 = 80 m. For 2 rounds: 80 × 2 = 160 meters.",
        "exampleAnswer": "160 meters",
        "funFact": "The Great Wall of China is the longest perimeter barrier in the world, stretching over 21,000 kilometers!",
        "advice": "Walk along the outer boundary with your pencil tip to add every outer edge once and only once!"
    },
    ("Class 4", "Smart Charts"): {
        "concepts": ["Tally Marks Recording", "Chapati Chart (Pie Graph) Fractions", "Bar Graph Scale and Comparison", "Survey Data Interpretation"],
        "rules": [
            "1 tally mark = | ; 5 tally marks = 卌 (four upright bars crossed by one diagonal bar).",
            "Chapati Chart (Pie Chart): Half circle = 1/2 (50%); quarter circle = 1/4 (25%).",
            "Bar Chart: The height of the bar directly represents the count or quantity."
        ],
        "exampleQuestion": "In a survey of 40 students, a Chapati chart shows half like cricket and quarter like football. How many students like cricket?",
        "exampleExplanation": "Half of 40 students = 40 ÷ 2 = 20 students.",
        "exampleAnswer": "20 students",
        "funFact": "Scottish engineer William Playfair invented the bar graph in 1786 and the pie chart in 1801!",
        "advice": "Always inspect the chart key: 1 picture symbol often represents 5, 10, or 100 units rather than just 1!"
    },

    # --- Class 3 ---
    ("Class 3", "Where to Look From"): {
        "concepts": ["Top View, Side View, Front View", "Dot Grid Drawings", "Mirror Halves & Symmetry", "Isometric Perspective"],
        "rules": [
            "Top view looks directly from above (e.g. a cup looks like a circle from top).",
            "Mirror halves: If you place a mirror on the line of symmetry, you see the complete picture."
        ],
        "exampleQuestion": "What shape does a cylindrical drinking glass look like from the top view?",
        "exampleExplanation": "Looking directly down into a glass, you see a circle.",
        "exampleAnswer": "A circle ⭕",
        "funFact": "Drones and satellite maps rely completely on top views to guide navigation!",
        "advice": "Look at ordinary objects like tables, spoons, and shoes from the top, front, and side!"
    },
    ("Class 3", "Fun with Numbers"): {
        "concepts": ["3-Digit Numbers", "Place Value (Hundreds, Tens, Ones)", "Expanded Form", "Century in Cricket (100 runs)"],
        "rules": [
            "Place value: In 345, 3 is hundreds (300), 4 is tens (40), and 5 is ones (5).",
            "1 Century = 100 runs; Half Century = 50 runs."
        ],
        "exampleQuestion": "Sachin scored 96 runs in a cricket match. How many more runs does he need to complete a century?",
        "exampleExplanation": "A century is 100 runs: 100 - 96 = 4 runs needed.",
        "exampleAnswer": "4 runs",
        "funFact": "The concept of zero as both a placeholder and number was pioneered by ancient Indian mathematicians!",
        "advice": "Write numbers in expanded form (300 + 40 + 5) to easily see each digit's true value!"
    },
    ("Class 3", "Give and Take"): {
        "concepts": ["2-Digit and 3-Digit Addition", "Subtraction with Regrouping", "Jump 10 on Number Grid", "Token Card Method"],
        "rules": [
            "To add 10, jump down one row on a 100-chart.",
            "Always align columns: Ones under Ones, Tens under Tens, Hundreds under Hundreds."
        ],
        "exampleQuestion": "A shopkeeper had 153 kites. He sold 38 kites. How many kites are left?",
        "exampleExplanation": "Subtract 38 from 153: 153 - 38 = 115 kites remaining.",
        "exampleAnswer": "115 kites",
        "funFact": "Mental math tricks let you add 38 by adding 40 and subtracting 2!",
        "advice": "Add or subtract the ones column first before moving to tens!"
    },
    ("Class 3", "Long and Short"): {
        "concepts": ["Centimeters and Meters", "Measuring with Ruler", "Non-standard vs Standard Units", "Body Part Measurements"],
        "rules": [
            "1 meter (m) = 100 centimeters (cm)",
            "Use centimeters (cm) for small items (pencil, eraser) and meters (m) for large items (room, tree)."
        ],
        "exampleQuestion": "A pencil is 14 cm long. If you sharpen and use 5 cm of it, how long is it now?",
        "exampleExplanation": "Subtract used length from original length: 14 - 5 = 9 cm.",
        "exampleAnswer": "9 cm",
        "funFact": "A standard school ruler is typically 15 centimeters or 30 centimeters long!",
        "advice": "Always start measuring from the 0 mark on your ruler, not the very physical edge!"
    },
    ("Class 3", "Shapes and Designs"): {
        "concepts": ["Straight Edges vs Curved Edges", "Corners (Vertices)", "Tangram 7-Piece Puzzle", "Tiling Patterns (Tessellations)"],
        "rules": [
            "Triangles have 3 straight edges and 3 corners.",
            "Circles have 1 curved edge and zero corners.",
            "Tiling patterns must cover a floor without leaving any gaps or overlaps."
        ],
        "exampleQuestion": "How many corners does a standard square sheet of origami paper have?",
        "exampleExplanation": "A square has 4 sides and 4 corners (vertices).",
        "exampleAnswer": "4 corners",
        "funFact": "Tangram is an ancient Chinese puzzle made of 7 flat shapes called tans!",
        "advice": "Count corners by touching each pointy vertex with your fingertip!"
    },
    ("Class 3", "Fun with Give and Take"): {
        "concepts": ["Checking Subtraction with Addition", "Mental Subtraction Strategies", "Story Problems with Money", "Secret Number Puzzles"],
        "rules": [
            "To check subtraction: Difference + Subtrahend must equal the Minuend.",
            "Subtracting 9 is the same as subtracting 10 and adding 1."
        ],
        "exampleQuestion": "Check if 236 - 114 = 122 is correct using addition.",
        "exampleExplanation": "Add difference and subtrahend: 122 + 114 = 236. It matches perfectly!",
        "exampleAnswer": "Correct ✓ (122 + 114 = 236)",
        "funFact": "The equals sign '=' was invented in 1557 by Robert Recorde to avoid writing 'is equal to' repeatedly!",
        "advice": "Always verify subtraction by adding the answer back to the number you subtracted!"
    },
    ("Class 3", "Time Goes On"): {
        "concepts": ["Reading Clock Hours and Minutes", "Calendar Dates and Months", "Birthdays and Age Calculations", "Timeline of Events"],
        "rules": [
            "1 hour = 60 minutes; 1 day = 24 hours.",
            "1 year = 12 months = 365 days (366 in a leap year).",
            "Months with 31 days: Jan, Mar, May, Jul, Aug, Oct, Dec."
        ],
        "exampleQuestion": "If today is 15th August, what date will it be exactly one week later?",
        "exampleExplanation": "1 week = 7 days. Add 7 days: 15 + 7 = 22nd August.",
        "exampleAnswer": "22nd August",
        "funFact": "Leap years have 366 days and happen every 4 years because Earth takes 365.24 days to orbit the Sun!",
        "advice": "Use the knuckle trick to remember which months have 31 days (knuckles) and 30 days (valleys)!"
    },
    ("Class 3", "Who is Heavier?"): {
        "concepts": ["Kilograms (kg) and Grams (g)", "Balance Scale Equilibrium", "Estimating Weights", "Comparing Quantities"],
        "rules": [
            "1 kilogram (kg) = 1,000 grams (g)",
            "1 kg of cotton and 1 kg of iron weigh the EXACT SAME amount (1 kg)."
        ],
        "exampleQuestion": "Which is heavier: a 500 g packet of biscuits or a 1 kg bag of sugar?",
        "exampleExplanation": "1 kg = 1,000 g, which is greater than 500 g. The 1 kg sugar bag is heavier.",
        "exampleAnswer": "1 kg bag of sugar",
        "funFact": "A hummingbird weighs only about 3 grams—lighter than a nickel coin!",
        "advice": "Don't confuse size with weight: a big balloon is lighter than a small steel ball!"
    },
    ("Class 3", "How Many Times?"): {
        "concepts": ["Multiplication as Repeated Addition", "Times Tables (2 to 10)", "Stick Multiplication Method", "Flower Petal & Wheel Patterns"],
        "rules": [
            "Multiplication is repeated addition: 4 × 3 = 3 + 3 + 3 + 3 = 12.",
            "Any number multiplied by 0 equals 0: n × 0 = 0.",
            "Any number multiplied by 1 equals itself: n × 1 = n."
        ],
        "exampleQuestion": "There are 5 cars in a parking lot. Each car has 4 wheels. How many wheels are there in total?",
        "exampleExplanation": "5 cars × 4 wheels per car = 20 wheels.",
        "exampleAnswer": "20 wheels",
        "funFact": "The word multiplication comes from the Latin 'multi' (many) and 'plicare' (to fold)!",
        "advice": "Think of 6 × 4 as 6 groups of 4 items!"
    },
    ("Class 3", "Play with Patterns"): {
        "concepts": ["Repeating & Growing Patterns", "Odd and Even Numbers", "Secret Code Messages", "Number Sequences"],
        "rules": [
            "Even numbers end in 0, 2, 4, 6, 8 (can be paired up).",
            "Odd numbers end in 1, 3, 5, 7, 9 (always leaves 1 unpaired).",
            "Odd + Odd = Even; Even + Even = Even; Odd + Even = Odd."
        ],
        "exampleQuestion": "What is the next number in the pattern: 12, 16, 20, 24, __?",
        "exampleExplanation": "The rule is adding 4 each step: 24 + 4 = 28.",
        "exampleAnswer": "28",
        "funFact": "Sunflower seed heads follow Fibonacci spiral patterns found throughout nature!",
        "advice": "Find the gap between consecutive numbers to unlock the pattern rule!"
    },
    ("Class 3", "Jugs and Mugs"): {
        "concepts": ["Liters and Milliliters", "Measuring Capacities", "Estimating Water Use", "Pouring and Sharing Volumes"],
        "rules": [
            "1 Liter (L) = 1,000 milliliters (mL)",
            "Two 500 mL bottles make 1 full Liter."
        ],
        "exampleQuestion": "How many 200 mL glasses of water are needed to fill a 1 Liter water bottle?",
        "exampleExplanation": "1 Liter = 1,000 mL. 1,000 ÷ 200 = 5 glasses.",
        "exampleAnswer": "5 glasses",
        "funFact": "A single raindrop contains roughly 0.05 mL of water!",
        "advice": "Small sips and medicines are measured in mL; jugs and buckets use Liters!"
    },
    ("Class 3", "Can We Share?"): {
        "concepts": ["Division as Equal Sharing", "Grouping Objects", "Jumping Back on Number Line", "Sharing into Equal Bowls"],
        "rules": [
            "Division means sharing a total into equal groups.",
            "Dividing by 1 gives the same number: 18 ÷ 1 = 18.",
            "You cannot divide any number by 0."
        ],
        "exampleQuestion": "Share 18 lollipops equally among 3 children. How many lollipops does each child receive?",
        "exampleExplanation": "Divide 18 by 3: 18 ÷ 3 = 6 lollipops each.",
        "exampleAnswer": "6 lollipops each",
        "funFact": "Division symbol '÷' is called an obelus and was first used in math in 1659!",
        "advice": "Think backwards using multiplication: What times 3 equals 18? 6 × 3 = 18!"
    },
    ("Class 3", "Smart Charts"): {
        "concepts": ["Tally Marks (Groups of 5)", "Pictographs (Picture Graphs)", "Collecting Survey Data", "Interpreting Bar Charts"],
        "rules": [
            "Tally marks group in 5s: |||| with a slash = 5.",
            "In pictographs, always check what 1 symbol represents (e.g. 1 🚗 = 5 cars)."
        ],
        "exampleQuestion": "If 1 star symbol ⭐ represents 4 books read, how many books do 3 stars ⭐⭐⭐ represent?",
        "exampleExplanation": "Multiply the number of stars by the scale: 3 × 4 = 12 books.",
        "exampleAnswer": "12 books",
        "funFact": "Cavemen recorded hunting tallies on animal bones over 20,000 years ago!",
        "advice": "Bundle tallies into groups of five: 5, 10, 15, 20 makes counting lightning fast!"
    },
    ("Class 3", "Rupees and Paise"): {
        "concepts": ["Indian Coins and Notes", "Paise to Rupee Conversion", "Cash Memos & Shopping Bills", "Making Change"],
        "rules": [
            "1 Rupee (₹) = 100 paise (p)",
            "Two 50-paise coins make ₹1.",
            "Change = Money Paid - Total Bill"
        ],
        "exampleQuestion": "You buy a toy for ₹35 and give the shopkeeper a ₹50 note. How much change do you receive?",
        "exampleExplanation": "Subtract bill from payment: ₹50 - ₹35 = ₹15 change.",
        "exampleAnswer": "₹15 change",
        "funFact": "Indian currency notes feature 15 different languages written on the language panel!",
        "advice": "Add the cost of items first, then subtract from the note you gave to find your change!"
    },

    # --- Class 5 ---
    ("Class 5", "The Fish Tale"): {
        "concepts": ["Large Numbers (Lakhs & Crores)", "Speed, Distance, Time for Fishing Boats", "Fish Drying Weights (1/3 rule)", "Women's Meenkar Bank"],
        "rules": [
            "1 Lakh = 1,00,000 (five zeroes); 1 Crore = 1,00,00,000 (seven zeroes)",
            "Distance = Speed × Time; Time = Distance ÷ Speed",
            "When fresh fish is dried, it becomes 1/3 of its original weight."
        ],
        "exampleQuestion": "A motor boat travels at a speed of 20 km per hour. How far can it go in 3 and a half hours?",
        "exampleExplanation": "Distance = Speed × Time = 20 × 3.5 = 70 km.",
        "exampleAnswer": "70 km",
        "funFact": "The Whale Shark is the largest fish in the world—growing up to 18 meters long and weighing over 20,000 kg!",
        "advice": "When fish is dried, divide weight by 3: 6,000 kg of fresh fish yields 2,000 kg of dried fish!"
    },
    ("Class 5", "Shapes and Angles"): {
        "concepts": ["Right Angle (90°), Acute (<90°), Obtuse (>90°)", "Clock Hands Angles", "Degree Clock & Protractor", "Yoga Angles"],
        "rules": [
            "Right angle = exactly 90° (forms an 'L' shape).",
            "Acute angle = less than 90° (sharp, smaller than 'L').",
            "Obtuse angle = greater than 90° and less than 180° (wide open).",
            "Straight angle = exactly 180°."
        ],
        "exampleQuestion": "What type of angle is formed between the clock hands at 3:00 o'clock?",
        "exampleExplanation": "At 3:00, the hour hand points to 3 and minute hand to 12, forming an exact 90° Right Angle.",
        "exampleAnswer": "Right angle (90°)",
        "funFact": "The 360-degree circle was chosen by ancient Babylonians because their calendar had about 360 days in a year!",
        "advice": "Use your thumb and index finger to form an 'L' shape—that's your pocket 90-degree tester!"
    },
    ("Class 5", "How Many Squares?"): {
        "concepts": ["Area by Grid Squares (cm²)", "Perimeter vs Area Comparison", "Stamp & Postcard Surface Sizes", "Tangram Shapes Area"],
        "rules": [
            "Area of Rectangle = Length × Width (measured in square units, cm² or m²)",
            "Area of Square = Side × Side",
            "Perimeter is the boundary fence; Area is the surface space enclosed inside."
        ],
        "exampleQuestion": "A postage stamp is 4 cm long and 3 cm wide. What is its area?",
        "exampleExplanation": "Area = Length × Width = 4 cm × 3 cm = 12 cm².",
        "exampleAnswer": "12 cm²",
        "funFact": "Shapes with the exact same perimeter can have completely different areas!",
        "advice": "Always write cm² (or square cm) for area, but plain cm for perimeter!"
    },
    ("Class 5", "Parts and Wholes"): {
        "concepts": ["Fractions & Equivalent Fractions", "Mixed Fractions", "Patterns in Parts (Rupee & Flags)", "Chocolate Sharing Puzzles"],
        "rules": [
            "Equivalent fractions: Multiply or divide both numerator and denominator by the same non-zero number (e.g. 1/2 = 2/4 = 3/6).",
            "To add fractions with the same denominator, add numerators: a/c + b/c = (a+b)/c."
        ],
        "exampleQuestion": "A chocolate bar has 12 pieces. Manju gives 1/4 to Raji and 1/3 to Sugatha. How many pieces does Manju have left?",
        "exampleExplanation": "Raji gets: 12 × 1/4 = 3. Sugatha gets: 12 × 1/3 = 4. Total given = 3 + 4 = 7 pieces. Left = 12 - 7 = 5 pieces.",
        "exampleAnswer": "5 pieces",
        "funFact": "The Indian National Flag's saffron, white, and green stripes each occupy exactly 1/3 of the flag's area!",
        "advice": "Convert fractions to equal denominators before comparing or adding them!"
    },
    ("Class 5", "Does it Look the Same?"): {
        "concepts": ["Rotational Symmetry (1/2, 1/4, 1/3, 1/6 Turns)", "Mirror Reflection Lines", "Windmill Blades Symmetry", "Letter & Digit Symmetry"],
        "rules": [
            "1/2 Turn (180°): Rotate half a circle. S, H, I, N, O, X look the same after a half turn.",
            "1/4 Turn (90°): Rotate a quarter circle.",
            "An equilateral triangle looks identical after 1/3 turn (120°); a regular hexagon after 1/6 turn (60°)."
        ],
        "exampleQuestion": "Which English capital letters look identical after a 1/2 (half) turn?",
        "exampleExplanation": "Letters H, I, N, O, S, X, Z look the exact same when flipped 180° upside down.",
        "exampleAnswer": "H, I, N, O, S, X, Z",
        "funFact": "Snowflakes have natural 6-fold (1/6 turn) rotational symmetry due to water crystal bonding!",
        "advice": "Hold your book upside down to test if an image has 1/2 turn symmetry!"
    },
    ("Class 5", "Be My Multiple, I'll Be Your Factor"): {
        "concepts": ["Multiples and Common Multiples", "Factors and Factor Trees", "LCM (Least Common Multiple)", "HCF (Highest Common Factor)"],
        "rules": [
            "A Multiple of a number is obtained by multiplying it by 1, 2, 3... (e.g. multiples of 4: 4, 8, 12, 16...)",
            "A Factor divides a number completely with zero remainder.",
            "1 is a factor of every number; Every number is a multiple of itself."
        ],
        "exampleQuestion": "Find the smallest common multiple (LCM) of 4 and 6.",
        "exampleExplanation": "Multiples of 4: 4, 8, 12, 16... Multiples of 6: 6, 12, 18... The smallest shared multiple is 12.",
        "exampleAnswer": "12",
        "funFact": "Cicadas stay underground for prime numbers of years (13 or 17 years) so predators cannot synchronize with their lifecycle!",
        "advice": "List the multiples of the larger number first, and check which one is divisible by the smaller number!"
    },
    ("Class 5", "Can You See the Pattern?"): {
        "concepts": ["Number Patterns & Magic Squares", "Palindrome Numbers (121, 383)", "Calendar Magic 3x3 Squares", "Secret Digit Tricks"],
        "rules": [
            "Palindrome: A number or word that reads the same forwards and backwards (e.g. 121, 646, RADAR).",
            "Calendar 3×3 square: The sum of all 9 numbers is always 9 × (the center number)."
        ],
        "exampleQuestion": "In a 3×3 box on a calendar month, the center date is 14. What is the sum of all 9 dates in the box?",
        "exampleExplanation": "Use the calendar golden rule: Sum = 9 × Center = 9 × 14 = 126.",
        "exampleAnswer": "126",
        "funFact": "Any 2-digit number added to its reverse often turns into a palindrome in 1 or 2 steps (e.g. 43 + 34 = 77)!",
        "advice": "In any 3×3 magic calendar grid, the center number is the key to the entire sum!"
    },
    ("Class 5", "Mapping Your Way"): {
        "concepts": ["Map Scales (e.g. 1 cm = 2 km)", "Directions (North, South, East, West)", "Rajpath & India Gate Parade Route", "Enlarging/Reducing on Grids"],
        "rules": [
            "Map Scale: Real Distance = Map Distance (cm) × Scale Value.",
            "Standard Map Orientation: North is up, South is down, East is right, West is left."
        ],
        "exampleQuestion": "On a city map, the scale is 1 cm = 4 km. If two metro stations are 6 cm apart on the map, what is their actual distance?",
        "exampleExplanation": "Actual Distance = 6 cm × 4 km/cm = 24 km.",
        "exampleAnswer": "24 km",
        "funFact": "Google Maps uses high-resolution satellite imagery combined with vector scales to map every meter on Earth!",
        "advice": "Remember the compass directions clockwise: North, East, South, West (Never Eat Soggy Waffles)!"
    },
    ("Class 5", "Boxes and Sketches"): {
        "concepts": ["3D Cube Nets", "Deep Drawings vs Floor Plans", "Isometric Sketches", "Open vs Closed Boxes"],
        "rules": [
            "A cube net consists of 6 connected squares that fold into a closed cube box.",
            "Opposite faces of a dice net cannot touch each other along an edge; they must be separated by one square."
        ],
        "exampleQuestion": "How many flat square faces must a net have to fold into a complete closed cube?",
        "exampleExplanation": "A closed cube has 6 faces, so its unfolding net must have exactly 6 squares.",
        "exampleAnswer": "6 squares",
        "funFact": "There are exactly 11 distinct folding nets that can form a cube!",
        "advice": "Mentally fold up each flap of the net to verify whether two flaps collide or overlap!"
    },
    ("Class 5", "Tenths and Hundredths"): {
        "concepts": ["Decimals (0.1, 0.01)", "Millimeters to Centimeters (1 mm = 0.1 cm)", "Indian Rupee Paise Decimals (50p = ₹0.50)", "Comparing Decimal Numbers"],
        "rules": [
            "1 cm = 10 mm ⟹ 1 mm = 0.1 cm (one tenth of a cm)",
            "1 Rupee = 100 paise ⟹ 1 paisa = ₹0.01 (one hundredth of a rupee)",
            "When comparing decimals, align decimal points and compare from largest place value (left) to smallest (right)."
        ],
        "exampleQuestion": "The length of an ant is 6 mm. Express this length in centimeters as a decimal.",
        "exampleExplanation": "Since 10 mm = 1 cm, 6 mm = 6/10 cm = 0.6 cm.",
        "exampleAnswer": "0.6 cm",
        "funFact": "Olympic sprint timers measure elapsed times down to 0.001 (one thousandth) of a second!",
        "advice": "0.5 and 0.50 represent the exact same value (half); the extra zero at the end does not change the amount!"
    },
    ("Class 5", "Area and Its Boundary"): {
        "concepts": ["Area of Rectangle & Square", "Perimeter of Polygons", "Tiling Surface Area", "Optimizing Fencing vs Area"],
        "rules": [
            "Area of Rectangle = Length × Width (L × W)",
            "Area of Square = Side × Side (S²)",
            "Perimeter of Rectangle = 2 × (Length + Width)",
            "Perimeter of Square = 4 × Side"
        ],
        "exampleQuestion": "A square playground has sides of 20 meters. What are its perimeter and area?",
        "exampleExplanation": "Perimeter = 4 × 20 = 80 m. Area = 20 × 20 = 400 m².",
        "exampleAnswer": "Perimeter = 80 m, Area = 400 m²",
        "funFact": "Among all rectangles with a fixed perimeter, a perfect square always encloses the MAXIMUM area!",
        "advice": "Perimeter is distance around the border (meters); Area is the flat carpet inside (square meters)!"
    },
    ("Class 5", "Smart Charts"): {
        "concepts": ["Bar Charts & Scale Intervals", "Family Trees (Generations)", "Temperature Line Graphs", "Attendance Records"],
        "rules": [
            "In a bar graph, all bars must have equal width and equal spacing.",
            "The height of the bar is read using the vertical axis scale.",
            "Family tree: Horizontal lines connect siblings, vertical lines connect parents to children."
        ],
        "exampleQuestion": "On a bar chart of favorite fruits, 1 unit length on the axis equals 5 children. If the mango bar is 6 units tall, how many children love mangoes?",
        "exampleExplanation": "Multiply bar height by axis scale: 6 units × 5 children/unit = 30 children.",
        "exampleAnswer": "30 children",
        "funFact": "Florence Nightingale invented the Polar Area Diagram in 1858 to convince hospitals to improve sanitation!",
        "advice": "Use a straight ruler horizontally across from the top of the bar to the axis numbers to read values accurately!"
    },
    ("Class 5", "Ways to Multiply and Divide"): {
        "concepts": ["Column Multiplication (Bela's Method)", "Multi-digit Division with Remainders", "Farmer & Worker Wage Problems", "Quotient Estimation"],
        "rules": [
            "Distributive Multiplication: 65 × 31 = (65 × 30) + (65 × 1) = 1950 + 65 = 2015.",
            "Dividend = (Divisor × Quotient) + Remainder.",
            "Remainder must always be smaller than the Divisor."
        ],
        "exampleQuestion": "A factory worker earns ₹245 each day. How much does he earn in the entire month of January (31 days)?",
        "exampleExplanation": "Multiply: 245 × 31 = (245 × 30) + (245 × 1) = 7,350 + 245 = ₹7,595.",
        "exampleAnswer": "₹7,595",
        "funFact": "Computers multiply large numbers in nanoseconds by adding binary 0s and 1s!",
        "advice": "Don't forget the zero placeholder when multiplying by the tens digit!"
    },
    ("Class 5", "How Big? How Heavy?"): {
        "concepts": ["Volume of Cubes & Cuboids", "Measuring Volume by Unit Cubes (cm³)", "Water Displacement Volume", "Weight Comparison"],
        "rules": [
            "Volume of Cuboid = Length × Width × Height (L × W × H)",
            "Volume of Cube = Side × Side × Side (S³)",
            "Water displacement: The volume of water displaced by a submerged object equals the volume of that object."
        ],
        "exampleQuestion": "A rectangular shoe box is 20 cm long, 10 cm wide, and 8 cm high. What is its volume?",
        "exampleExplanation": "Volume = Length × Width × Height = 20 × 10 × 8 = 1,600 cm³.",
        "exampleAnswer": "1,600 cm³ (cubic centimeters)",
        "funFact": "Greek scholar Archimedes shouted 'Eureka!' when he discovered water displacement while stepping into a bath!",
        "advice": "Volume measures 3D space and is always written in cubic units (cm³ or m³)!"
    },
}

# Update all matching chapters
updated_count = 0
for ch in chapters:
    key = (ch['grade'], ch['title'])
    if key in chapter_details:
        details = chapter_details[key]
        ch['keyConcepts'] = details['concepts']
        ch['rules'] = details['rules']
        ch['exampleQuestion'] = details['exampleQuestion']
        ch['exampleExplanation'] = details['exampleExplanation']
        ch['exampleAnswer'] = details['exampleAnswer']
        ch['funFact'] = details['funFact']
        ch['mascotAdvice'] = details['advice']
        updated_count += 1

print(f"Updated {updated_count} chapters with unique formulas, rules, and worked examples!")

# Write updated json
with open(r'd:\AI Learning\assets\curriculum\chapters_data.json', 'w', encoding='utf-8') as f:
    json.dump(chapters, f, indent=2, ensure_ascii=False)

print("Saved enriched chapters_data.json successfully!")
