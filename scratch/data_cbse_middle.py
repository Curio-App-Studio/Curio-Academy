# CBSE Middle School Curriculum (Class 6, 7, 8)
# Authentic NCERT Mathematics Syllabus

cbse_middle_chapters = [
    # ==================== Class 6 (CBSE) ====================
    {
        "board": "cbse", "grade": "Class 6", "chapterNumber": 1,
        "title": "Knowing Our Numbers", "icon": "🔢",
        "description": "Large numbers up to 8 digits, Indian & International place value system, estimation, and Roman numerals.",
        "keyConcepts": ["Indian System (Lakhs, Crores)", "International System (Millions, Billions)", "Rounding Off to Nearest 10, 100, 1000", "Roman Numerals (I to C)"],
        "rules": [
            "Indian System periods: Ones (3), Thousands (2), Lakhs (2), Crores (2) — e.g., 2,34,56,789.",
            "International System periods: Ones (3), Thousands (3), Millions (3) — e.g., 23,456,789.",
            "1 Crore = 10 Million; 1 Million = 10 Lakhs.",
            "Roman rules: I=1, V=5, X=10, L=50, C=100, D=500, M=1000. Symbols V, L, D are never repeated or subtracted."
        ],
        "exampleQuestion": "How many lakhs make 1 million in the International system?",
        "exampleExplanation": "1 million = 1,000,000. In Indian system, 10,00,000 is 10 lakhs. So 10 lakhs make 1 million.",
        "exampleAnswer": "10 lakhs",
        "funFact": "The word 'Million' was popularized in Italy around 1300 from 'mille' (thousand) plus the augmentative suffix '-one' (great thousand)!",
        "mascotAdvice": "Place commas from the right: Indian system is 3, 2, 2, 2; International system is always groups of 3!"
    },
    {
        "board": "cbse", "grade": "Class 6", "chapterNumber": 2,
        "title": "Whole Numbers", "icon": "0️⃣",
        "description": "Natural numbers vs whole numbers, number line operations, and closure, commutative, associative properties.",
        "keyConcepts": ["Natural vs Whole Numbers (0, 1, 2...)", "Predecessor and Successor", "Properties of Addition & Multiplication", "Division by Zero is Undefined"],
        "rules": [
            "Natural numbers (N) start from 1, 2, 3... Whole numbers (W) start from 0, 1, 2...",
            "0 is the smallest whole number; there is no greatest whole number.",
            "Commutative property: a + b = b + a and a × b = b × a.",
            "Distributive property: a × (b + c) = (a × b) + (a × c).",
            "Division by zero is not defined in mathematics (a ÷ 0 has no meaning)."
        ],
        "exampleQuestion": "Using the distributive property, calculate 12 × 105:",
        "exampleExplanation": "12 × 105 = 12 × (100 + 5) = (12 × 100) + (12 × 5) = 1,200 + 60 = 1,260.",
        "exampleAnswer": "1,260",
        "funFact": "Aryabhata and Brahmagupta gave the world the concept and mathematical rules of zero in ancient India!",
        "mascotAdvice": "Break awkward numbers into 100 + X or 1,000 + X to multiply mentally using distributivity!"
    },
    {
        "board": "cbse", "grade": "Class 6", "chapterNumber": 3,
        "title": "Playing with Numbers", "icon": "🧩",
        "description": "Factors, multiples, prime & composite numbers, divisibility tests, HCF, LCM, and co-prime numbers.",
        "keyConcepts": ["Factors & Multiples", "Prime & Composite Numbers", "Divisibility Rules (2, 3, 4, 5, 6, 8, 9, 11)", "HCF and LCM Applications"],
        "rules": [
            "Divisibility by 3: Sum of all digits is a multiple of 3.",
            "Divisibility by 9: Sum of all digits is divisible by 9.",
            "Divisibility by 11: Difference between sums of odd and even placed digits is 0 or divisible by 11.",
            "HCF × LCM = Product of the two numbers (for two positive integers a and b)."
        ],
        "exampleQuestion": "The HCF of two numbers is 6 and their LCM is 36. If one number is 12, what is the other number?",
        "exampleExplanation": "Formula: HCF × LCM = Number1 × Number2. So 6 × 36 = 12 × X -> 216 = 12X -> X = 216 ÷ 12 = 18.",
        "exampleAnswer": "18",
        "funFact": "2 is the only even prime number in the entire universe; all other even numbers can be divided by 2!",
        "mascotAdvice": "Prime numbers have exactly two factors: 1 and itself. 1 is neither prime nor composite!"
    },
    {
        "board": "cbse", "grade": "Class 6", "chapterNumber": 4,
        "title": "Basic Geometrical Ideas", "icon": "📐",
        "description": "Points, line segments, rays, intersecting and parallel lines, curves, polygons, and angles.",
        "keyConcepts": ["Point, Line, Line Segment, Ray", "Parallel vs Intersecting Lines", "Open and Closed Curves", "Interior, Exterior & Boundary of Polygons"],
        "rules": [
            "A line segment has 2 fixed end points and a definite length.",
            "A ray starts at 1 end point and extends indefinitely in 1 direction.",
            "A line extends infinitely in both directions and has no end points.",
            "Parallel lines never intersect, no matter how far they are extended (distance between them is constant)."
        ],
        "exampleQuestion": "A ray has how many fixed end points?",
        "exampleExplanation": "A ray has exactly 1 fixed starting end point (origin) and extends infinitely in the other direction.",
        "exampleAnswer": "1 end point",
        "funFact": "Euclid of Alexandria wrote 'Elements' in 300 BCE, organizing all geometry from just 5 basic postulates!",
        "mascotAdvice": "Remember: Segment has 2 stops, Ray has 1 stop, Line has 0 stops!"
    },
    {
        "board": "cbse", "grade": "Class 6", "chapterNumber": 5,
        "title": "Understanding Elementary Shapes", "icon": "📐",
        "description": "Measuring angles with protractor, types of triangles, quadrilaterals, 3D shapes: faces, edges, vertices.",
        "keyConcepts": ["Right, Straight, Complete Angles", "Classification of Triangles (by Sides & Angles)", "Quadrilateral Family (Parallelogram, Rhombus, Trapezium)", "Faces, Edges & Vertices of 3D Solids"],
        "rules": [
            "Acute angle < 90°; Right angle = 90°; Obtuse angle between 90° and 180°; Straight angle = 180°.",
            "Equilateral triangle: All 3 sides and 3 angles equal (60° each).",
            "Isosceles triangle: 2 sides equal; Scalene triangle: all sides different.",
            "A cuboid has 6 faces, 12 edges, and 8 vertices."
        ],
        "exampleQuestion": "What fraction of a complete clockwise revolution does the hour hand of a clock turn through when it goes from 3 to 9?",
        "exampleExplanation": "From 3 to 9 is 6 hour marks = 180° = half of 360° = 1/2 of a revolution.",
        "exampleAnswer": "1/2 of a revolution (180°)",
        "funFact": "Triangles are the most rigid structural shapes in engineering, which is why bridges and crane arms are made of triangular trusses!",
        "mascotAdvice": "Right angle is a quarter turn (90°); straight angle is a half turn (180°)!"
    },
    {
        "board": "cbse", "grade": "Class 6", "chapterNumber": 6,
        "title": "Integers", "icon": "➖",
        "description": "Negative numbers, number line, absolute value, and addition and subtraction of integers.",
        "keyConcepts": ["Positive & Negative Integers", "Number Line Representation", "Additive Inverse", "Rules of Signs in Addition & Subtraction"],
        "rules": [
            "Numbers to the right of 0 on a number line are positive (+); to the left are negative (-).",
            "Every integer has an additive inverse: Additive inverse of (+a) is (-a), and (+a) + (-a) = 0.",
            "Adding two negative integers gives a negative integer: (-a) + (-b) = -(a + b).",
            "Subtracting an integer is the same as adding its additive inverse: a - (-b) = a + b."
        ],
        "exampleQuestion": "Calculate: (-15) + (-8) - (-10)",
        "exampleExplanation": "(-15) + (-8) = -23. Then -23 - (-10) = -23 + 10 = -13.",
        "exampleAnswer": "-13",
        "funFact": "Ancient Indian astronomer Brahmagupta defined negative numbers as 'debts' and positive numbers as 'fortunes'!",
        "mascotAdvice": "Subtracting a negative is like taking away a debt: two negatives make a positive! -(-x) = +x."
    },
    {
        "board": "cbse", "grade": "Class 6", "chapterNumber": 7,
        "title": "Fractions", "icon": "🍕",
        "description": "Proper, improper, and mixed fractions, equivalent fractions, simplest form, like and unlike addition.",
        "keyConcepts": ["Proper, Improper & Mixed Fractions", "Equivalent Fractions (Multiplying N and D)", "Simplest Form (HCF cancellation)", "Like & Unlike Fraction Operations"],
        "rules": [
            "Proper fraction: Numerator < Denominator (value < 1). Improper fraction: Numerator ≥ Denominator (value ≥ 1).",
            "To convert improper fraction to mixed: Quotient + Remainder/Divisor (e.g. 7/3 = 2 1/3).",
            "Equivalent fractions: Multiply or divide numerator and denominator by the same non-zero number.",
            "To add unlike fractions, first find the LCM of denominators to make them like fractions."
        ],
        "exampleQuestion": "Simplify to simplest form: 18/24",
        "exampleExplanation": "HCF of 18 and 24 is 6. Divide both by 6: 18 ÷ 6 = 3, 24 ÷ 6 = 4. Result = 3/4.",
        "exampleAnswer": "3/4",
        "funFact": "Ancient Egyptians only used unit fractions with numerator 1 (like 1/2, 1/3, 1/4), writing 3/4 as 1/2 + 1/4!",
        "mascotAdvice": "Never add denominators! 1/4 + 2/4 = (1+2)/4 = 3/4, NOT 3/8!"
    },
    {
        "board": "cbse", "grade": "Class 6", "chapterNumber": 8,
        "title": "Decimals", "icon": "🔘",
        "description": "Tenths, hundredths, thousandths, converting between fractions and decimals, and decimal arithmetic.",
        "keyConcepts": ["Place Value (Tenths 1/10, Hundredths 1/100)", "Converting Fractions to Decimals", "Comparing Decimal Numbers", "Addition & Subtraction of Decimals"],
        "rules": [
            "1 tenth = 0.1 = 1/10; 1 hundredth = 0.01 = 1/100; 1 thousandth = 0.001 = 1/1000.",
            "Adding trailing zeros after the decimal point does not change the value (0.5 = 0.50 = 0.500).",
            "When adding or subtracting decimals, always line up the decimal points vertically!"
        ],
        "exampleQuestion": "Solve: 4.25 + 18.7",
        "exampleExplanation": "Align decimal points: 04.25 + 18.70 = 22.95.",
        "exampleAnswer": "22.95",
        "funFact": "The decimal point was popularized by Scottish mathematician John Napier in 1617 in his books on logarithms!",
        "mascotAdvice": "Line up the decimal dot like buttons on a shirt before adding or subtracting!"
    },
    {
        "board": "cbse", "grade": "Class 6", "chapterNumber": 9,
        "title": "Data Handling", "icon": "📊",
        "description": "Recording data, tally charts, pictographs with scale, and drawing bar graphs.",
        "keyConcepts": ["Tally Marks (Frequency Table)", "Pictographs with Scale Key", "Bar Graphs (Equal Width & Spacing)", "Reading & Interpreting Graphs"],
        "rules": [
            "In a bar graph, all bars must have equal width and equal uniform spacing between them.",
            "The height (or length) of each bar represents the frequency value according to the chosen scale.",
            "Scale should be chosen based on the minimum and maximum data values."
        ],
        "exampleQuestion": "On a bar graph scale, 1 cm represents 10 students. How long will the bar be for 45 students?",
        "exampleExplanation": "Divide data value by scale unit: 45 ÷ 10 = 4.5 cm.",
        "exampleAnswer": "4.5 cm",
        "funFact": "William Playfair invented the bar chart in 1786 to compare Scotland's imports and exports with other nations!",
        "mascotAdvice": "Always label both axes clearly: title the graph, label what each axis measures, and state the scale!"
    },
    {
        "board": "cbse", "grade": "Class 6", "chapterNumber": 10,
        "title": "Mensuration", "icon": "📏",
        "description": "Perimeter of polygons and area of regular figures, rectangles, and squares.",
        "keyConcepts": ["Perimeter = Total Boundary Length", "Perimeter of Rectangle = 2 × (L + W)", "Perimeter of Regular Polygons", "Area of Rectangle = L × W, Area of Square = S²"],
        "rules": [
            "Perimeter of Rectangle = 2 × (Length + Breadth).",
            "Perimeter of Square = 4 × Side; Perimeter of Equilateral Triangle = 3 × Side.",
            "Area of Rectangle = Length × Breadth (measured in square units: cm², m²).",
            "Area of Square = Side × Side."
        ],
        "exampleQuestion": "A rectangular garden has length 25 m and breadth 15 m. Find its perimeter and area:",
        "exampleExplanation": "Perimeter = 2 × (25 + 15) = 2 × 40 = 80 m. Area = 25 × 15 = 375 m².",
        "exampleAnswer": "Perimeter = 80 m, Area = 375 m²",
        "funFact": "The word 'Mensuration' comes from the Latin 'mensura', meaning 'to measure'!",
        "mascotAdvice": "Perimeter is fence length (meters); Area is carpet surface (square meters)!"
    },
    {
        "board": "cbse", "grade": "Class 6", "chapterNumber": 11,
        "title": "Algebra", "icon": "🔤",
        "description": "Introduction to variables, matchstick patterns, algebraic expressions, and simple equations.",
        "keyConcepts": ["Variables (Letters x, y, n representing unknowns)", "Matchstick Patterns & General Rules", "Algebraic Expressions (2n + 1)", "Solving Equations by Trial and Error"],
        "rules": [
            "A variable is an unknown quantity that can take different numerical values.",
            "If n matchsticks make 1 letter 'L' (2 sticks), then n 'L's require 2n matchsticks.",
            "An equation has an equal sign (=) with LHS = RHS.",
            "To solve x + 5 = 12: subtract 5 from both sides -> x = 12 - 5 = 7."
        ],
        "exampleQuestion": "A student forms letter 'C' using 3 matchsticks. How many matchsticks are needed to form 'n' letters 'C'?",
        "exampleExplanation": "Each 'C' needs 3 sticks: for n letters, total matchsticks = 3 × n = 3n.",
        "exampleAnswer": "3n matchsticks",
        "funFact": "The word 'Algebra' comes from Arabic 'al-jabr', meaning 'reunion of broken parts', from Al-Khwarizmi's famous 820 CE treatise!",
        "mascotAdvice": "Treat an equation like a balanced scale: whatever operation you do to one side, do to the other!"
    },
    {
        "board": "cbse", "grade": "Class 6", "chapterNumber": 12,
        "title": "Ratio and Proportion", "icon": "⚖️",
        "description": "Comparing quantities by division, equivalent ratios, proportion tests, and the unitary method.",
        "keyConcepts": ["Ratio (a : b in simplest form)", "Equivalent Ratios", "Proportion (a : b = c : d -> ad = bc)", "Unitary Method (Value of 1 to find many)"],
        "rules": [
            "A ratio compares two quantities of the same kind having the same units.",
            "Ratio of a to b is written as a : b and simplified like a fraction a/b.",
            "Four terms a, b, c, d are in proportion if Product of Extremes = Product of Means (a × d = b × c).",
            "Unitary Method: First find the value of 1 unit by division, then find required units by multiplication."
        ],
        "exampleQuestion": "If 6 notebooks cost ₹120, what is the cost of 10 such notebooks?",
        "exampleExplanation": "Cost of 1 notebook = ₹120 ÷ 6 = ₹20. Cost of 10 notebooks = 10 × ₹20 = ₹200.",
        "exampleAnswer": "₹200",
        "funFact": "The Golden Ratio (1 : 1.618), denoted by Phi (φ), appears in Greek temples, spiral galaxies, and nautilus shells!",
        "mascotAdvice": "Always convert both quantities to the same units before forming a ratio (e.g. convert km to m)!"
    },
    {
        "board": "cbse", "grade": "Class 6", "chapterNumber": 13,
        "title": "Symmetry", "icon": "🦋",
        "description": "Line of symmetry, folding shapes, multiple lines of symmetry, and mirror reflection.",
        "keyConcepts": ["Line of Symmetry (Axis of Symmetry)", "Symmetry in Regular Polygons", "Mirror Reflections & Inversion", "Kaleidoscopes"],
        "rules": [
            "A shape has line symmetry if folding along the line makes both halves coincide perfectly.",
            "A regular polygon of n sides has exactly n lines of symmetry (e.g. square has 4, equilateral triangle has 3).",
            "An isosceles triangle has 1 line of symmetry; a scalene triangle has 0."
        ],
        "exampleQuestion": "How many lines of symmetry does a regular hexagon have?",
        "exampleExplanation": "A regular hexagon has 6 equal sides and 6 equal angles, so it has exactly 6 lines of symmetry.",
        "exampleAnswer": "6 lines of symmetry",
        "funFact": "Snowflakes always crystallize with 6-fold radial symmetry because of the hexagonal bond angle of water molecules!",
        "mascotAdvice": "Fold imaginary shapes in your mind: if the left half covers the right half exactly, that fold is a line of symmetry!"
    },
    {
        "board": "cbse", "grade": "Class 6", "chapterNumber": 14,
        "title": "Practical Geometry", "icon": "📐",
        "description": "Using ruler, compass, divider, and set-squares to construct circles, segments, and perpendiculars.",
        "keyConcepts": ["Circle Construction with Compass", "Copying a Line Segment", "Perpendicular Bisector Construction", "Constructing Angles (60°, 90°, 120°)"],
        "rules": [
            "To draw a circle of radius r, set the compass needle and pencil tip exactly r cm apart on a ruler.",
            "The perpendicular bisector divides a line segment into two equal halves at right angles (90°).",
            "An angle bisector divides an angle into two equal halves."
        ],
        "exampleQuestion": "What is the measure of each angle formed when a 90° right angle is bisected with compass?",
        "exampleExplanation": "Bisecting means dividing into 2 equal halves: 90° ÷ 2 = 45°.",
        "exampleAnswer": "45°",
        "funFact": "Ancient Greek geometers solved complex constructions using ONLY an unmarked straightedge and a compass!",
        "mascotAdvice": "Keep your compass screw tight and your pencil sharp for crisp, accurate geometric arcs!"
    },

    # ==================== Class 7 (CBSE) ====================
    {
        "board": "cbse", "grade": "Class 7", "chapterNumber": 1,
        "title": "Integers", "icon": "➖",
        "description": "Properties of addition, subtraction, multiplication, and division of positive and negative integers.",
        "keyConcepts": ["Sign Rules in Multiplication & Division", "Closure, Commutative & Associative Properties", "Distributive Property over Addition", "Division Rules with Negatives"],
        "rules": [
            "(+) × (+) = (+); (-) × (-) = (+); (+) × (-) = (-); (-) × (+) = (-).",
            "Multiplying an odd number of negative integers gives a NEGATIVE product.",
            "Multiplying an even number of negative integers gives a POSITIVE product.",
            "a ÷ (-b) = -(a ÷ b); 0 ÷ a = 0 (for a ≠ 0)."
        ],
        "exampleQuestion": "Evaluate: (-4) × (-5) × (-2)",
        "exampleExplanation": "There are 3 (odd count) negative signs: (-4) × (-5) = +20. Then (+20) × (-2) = -40.",
        "exampleAnswer": "-40",
        "funFact": "Submarines measure depths in negative integers (e.g. -300 meters) relative to sea level!",
        "mascotAdvice": "Count the minus signs first: odd count means negative answer, even count means positive answer!"
    },
    {
        "board": "cbse", "grade": "Class 7", "chapterNumber": 2,
        "title": "Fractions and Decimals", "icon": "🍰",
        "description": "Multiplication and division of fractions, reciprocal of fractions, and decimal multiplication & division.",
        "keyConcepts": ["Fraction Multiplication (N×N / D×D)", "Reciprocal & Fraction Division (Multiply by Inverse)", "Decimal Multiplication (Counting Decimal Places)", "Decimal Division by 10, 100, 1000"],
        "rules": [
            "(a/b) × (c/d) = (a × c) / (b × d).",
            "To divide by a fraction, multiply by its reciprocal: (a/b) ÷ (c/d) = (a/b) × (d/c).",
            "In decimal multiplication, the number of decimal places in the product equals the sum of decimal places in factors.",
            "Dividing by 10 shifts decimal 1 place LEFT; multiplying by 10 shifts 1 place RIGHT."
        ],
        "exampleQuestion": "Solve: (3/4) ÷ (9/8)",
        "exampleExplanation": "Multiply by reciprocal of 9/8: (3/4) × (8/9) = (3 × 8) / (4 × 9) = 24/36 = 2/3.",
        "exampleAnswer": "2/3",
        "funFact": "In music theory, time signatures like 3/4 and 4/4 are fractions representing beats in a measure!",
        "mascotAdvice": "Flip the second fraction and multiply! Keep, Change, Flip (KCF)!"
    },
    {
        "board": "cbse", "grade": "Class 7", "chapterNumber": 3,
        "title": "Data Handling", "icon": "📈",
        "description": "Arithmetic Mean, Range, Mode, Median, double bar graphs, and probability basics.",
        "keyConcepts": ["Arithmetic Mean = Sum / Count", "Range = Highest - Lowest", "Mode (Most Frequent Value)", "Median (Middle Value)", "Probability = Favourable / Total"],
        "rules": [
            "Mean = (Sum of all observations) ÷ (Total number of observations).",
            "Range = Highest observation - Lowest observation.",
            "Mode is the observation that occurs most frequently.",
            "To find Median, arrange data in ascending order; the middle value is the Median.",
            "Probability of an event P(E) = (Number of favourable outcomes) ÷ (Total possible outcomes)."
        ],
        "exampleQuestion": "Find the Mean of the scores: 6, 8, 10, 12, 14",
        "exampleExplanation": "Sum = 6 + 8 + 10 + 12 + 14 = 50. Total observations = 5. Mean = 50 ÷ 5 = 10.",
        "exampleAnswer": "10",
        "funFact": "Weather forecasters use arithmetic mean and probability algorithms to predict rainfall percentages!",
        "mascotAdvice": "Always sort your data from smallest to largest first before finding the Median or Range!"
    },
    {
        "board": "cbse", "grade": "Class 7", "chapterNumber": 4,
        "title": "Simple Equations", "icon": "⚖️",
        "description": "Forming equations from real statements, solving equations by transposition, and word puzzles.",
        "keyConcepts": ["Forming Linear Equations", "Transposition Method (Changing Signs Across =)", "Balancing Both Sides", "Solving Word Problems"],
        "rules": [
            "An equation remains unchanged if the same number is added, subtracted, multiplied, or divided on both sides.",
            "Transposition: When a term moves across '=', '+' becomes '-', '-' becomes '+', '×' becomes '÷', '÷' becomes '×'.",
            "Linear equation in one variable has the highest power of variable as 1."
        ],
        "exampleQuestion": "Solve the equation for x: 3x + 7 = 25",
        "exampleExplanation": "Transpose 7: 3x = 25 - 7 -> 3x = 18. Divide by 3: x = 18 ÷ 3 = 6.",
        "exampleAnswer": "x = 6",
        "funFact": "The '=' sign was chosen by mathematician Robert Recorde because two parallel lines are the most equal things in the universe!",
        "mascotAdvice": "Move constants to the right side and keep variables on the left side!"
    },
    {
        "board": "cbse", "grade": "Class 7", "chapterNumber": 5,
        "title": "Lines and Angles", "icon": "📐",
        "description": "Complementary and supplementary angles, adjacent angles, linear pairs, vertically opposite angles, and transversals.",
        "keyConcepts": ["Complementary Angles (Sum = 90°)", "Supplementary Angles (Sum = 180°)", "Vertically Opposite Angles (Equal)", "Parallel Lines & Transversal Angles"],
        "rules": [
            "Two angles are Complementary if their sum is 90°.",
            "Two angles are Supplementary if their sum is 180°.",
            "Vertically opposite angles formed by intersecting lines are ALWAYS equal.",
            "When a transversal intersects parallel lines: Corresponding angles are equal, Alternate interior angles are equal, Co-interior angles sum to 180°."
        ],
        "exampleQuestion": "An angle is 35°. What is the measure of its COMPLEMENTARY angle?",
        "exampleExplanation": "Complementary angles add to 90°: Complement = 90° - 35° = 55°.",
        "exampleAnswer": "55°",
        "funFact": "Perpendicular laser beams at LIGO travel 4 km at exact 90° angles to detect gravitational waves from colliding black holes!",
        "mascotAdvice": "C for Complementary = Corner (90°); S for Supplementary = Straight line (180°)!"
    },
    {
        "board": "cbse", "grade": "Class 7", "chapterNumber": 6,
        "title": "The Triangle and its Properties", "icon": "🔺",
        "description": "Medians and altitudes, exterior angle theorem, angle sum property (180°), and Pythagoras theorem.",
        "keyConcepts": ["Medians and Altitudes", "Exterior Angle Theorem", "Angle Sum Property = 180°", "Triangle Inequality Property", "Pythagoras Theorem (Right Triangles)"],
        "rules": [
            "Angle Sum Property: The sum of the 3 interior angles of any triangle is ALWAYS 180°.",
            "Exterior Angle Theorem: An exterior angle of a triangle equals the sum of its two interior opposite angles.",
            "Triangle Inequality: Sum of the lengths of any two sides of a triangle must be strictly GREATER than the third side (a + b > c).",
            "Pythagoras Theorem (in right triangle): Hypotenuse² = Base² + Perpendicular² (h² = b² + p²)."
        ],
        "exampleQuestion": "In a right-angled triangle, the two perpendicular sides are 3 cm and 4 cm. What is the length of the hypotenuse?",
        "exampleExplanation": "Pythagoras theorem: h² = 3² + 4² = 9 + 16 = 25. h = √25 = 5 cm.",
        "exampleAnswer": "5 cm",
        "funFact": "The 3-4-5 right triangle was used by ancient Egyptian rope-stretchers to make perfect square corners for pyramids!",
        "mascotAdvice": "Check triangle possibility: test if smaller side + middle side > largest side!"
    },
    {
        "board": "cbse", "grade": "Class 7", "chapterNumber": 7,
        "title": "Congruence of Triangles", "icon": "📐",
        "description": "Congruence of plane figures, line segments, angles, and triangle congruence criteria: SSS, SAS, ASA, RHS.",
        "keyConcepts": ["Concept of Congruence (Exact Copies)", "SSS (Side-Side-Side) Criterion", "SAS (Side-Angle-Side) Criterion", "ASA (Angle-Side-Angle) Criterion", "RHS (Right-Hypotenuse-Side) Criterion"],
        "rules": [
            "Two figures are congruent (≅) if they have the exact same shape and size.",
            "SSS Criterion: All 3 corresponding sides of two triangles are equal.",
            "SAS Criterion: 2 sides and the INCLUDED angle between them are equal.",
            "ASA Criterion: 2 angles and the INCLUDED side between them are equal.",
            "RHS Criterion: In right triangles, Hypotenuse and one side are equal."
        ],
        "exampleQuestion": "In triangles ABC and PQR, AB=PQ, BC=QR, and CA=RP. Which congruence criterion proves △ABC ≅ △PQR?",
        "exampleExplanation": "All three corresponding sides are equal: this is the SSS (Side-Side-Side) criterion.",
        "exampleAnswer": "SSS Criterion",
        "funFact": "Mass-manufactured car parts must be strictly congruent so any replacement spark plug or door fits identically!",
        "mascotAdvice": "Make sure for SAS that the angle is IN BETWEEN the two sides, not outside!"
    },
    {
        "board": "cbse", "grade": "Class 7", "chapterNumber": 8,
        "title": "Comparing Quantities", "icon": "💹",
        "description": "Ratios to percentages, profit and loss percentages, simple interest, and percentage increase/decrease.",
        "keyConcepts": ["Converting Fractions & Decimals to %", "Profit and Loss % Formulas", "Simple Interest: I = (P × R × T) / 100", "Amount = Principal + Interest"],
        "rules": [
            "To convert fraction to percentage, multiply by 100% (e.g. 3/5 × 100% = 60%).",
            "Profit = SP - CP (when SP > CP); Profit % = (Profit / CP) × 100.",
            "Loss = CP - SP (when CP > SP); Loss % = (Loss / CP) × 100.",
            "Simple Interest Formula: SI = (P × R × T) / 100, where P = Principal, R = Rate per annum, T = Time in years.",
            "Total Amount A = P + SI."
        ],
        "exampleQuestion": "Find the Simple Interest on ₹2,000 for 3 years at 5% per annum:",
        "exampleExplanation": "Formula: SI = (P × R × T) / 100 = (2000 × 5 × 3) / 100 = 30000 / 100 = ₹300.",
        "exampleAnswer": "₹300",
        "funFact": "The word 'Percent' comes from the Latin 'per centum', meaning 'by the hundred'!",
        "mascotAdvice": "Profit % and Loss % are ALWAYS calculated on the Cost Price (CP), never on SP!"
    },
    {
        "board": "cbse", "grade": "Class 7", "chapterNumber": 9,
        "title": "Rational Numbers", "icon": "🔢",
        "description": "Positive and negative rational numbers, standard form, representation on number line, and operations.",
        "keyConcepts": ["Rational Number Definition (p/q, q ≠ 0)", "Standard Form (D is positive, HCF=1)", "Equivalent Rational Numbers", "Four Operations on Rational Numbers"],
        "rules": [
            "A rational number is any number that can be expressed as p/q, where p and q are integers and q ≠ 0.",
            "Every integer and fraction is a rational number.",
            "Standard Form: Denominator q is positive and p, q have no common factor other than 1.",
            "Additive inverse of p/q is -p/q; Multiplicative inverse (reciprocal) of p/q is q/p."
        ],
        "exampleQuestion": "Write -18/24 in standard form:",
        "exampleExplanation": "Divide numerator and denominator by their HCF (6): (-18 ÷ 6) / (24 ÷ 6) = -3/4.",
        "exampleAnswer": "-3/4",
        "funFact": "Between any two rational numbers, there are infinitely many other rational numbers—this is the density property!",
        "mascotAdvice": "If the denominator is negative (e.g. 5/-7), multiply top and bottom by -1 to get standard form -5/7!"
    },
    {
        "board": "cbse", "grade": "Class 7", "chapterNumber": 10,
        "title": "Practical Geometry", "icon": "📐",
        "description": "Constructing parallel lines and constructing triangles given SSS, SAS, ASA, and RHS measurements.",
        "keyConcepts": ["Parallel Line through a Point (Alternate Angles)", "Constructing Triangles with SSS", "Constructing Triangles with SAS", "Constructing Right Triangles with RHS"],
        "rules": [
            "To construct a parallel line, use equal alternate interior angles with compass arcs.",
            "A triangle can be constructed uniquely if 3 independent measurements satisfying inequality properties are given.",
            "Always draw a rough freehand sketch with given labels before constructing with ruler and compass."
        ],
        "exampleQuestion": "Can a triangle be constructed with side lengths 2 cm, 3 cm, and 6 cm?",
        "exampleExplanation": "No! Triangle inequality requires 2 + 3 > 6, but 5 < 6. These sides cannot meet to form a triangle.",
        "exampleAnswer": "No, because 2 + 3 is not greater than 6",
        "funFact": "Bridge trusses use triangle geometry because triangles cannot deform without bending or breaking their sides!",
        "mascotAdvice": "Always draw a quick rough sketch with measurements first so you know where each point goes!"
    },
    {
        "board": "cbse", "grade": "Class 7", "chapterNumber": 11,
        "title": "Perimeter and Area", "icon": "🟩",
        "description": "Area of parallelogram, area of triangle, circumference and area of circles, and path area problems.",
        "keyConcepts": ["Area of Parallelogram = Base × Height", "Area of Triangle = ½ × Base × Height", "Circumference of Circle = 2 × π × r", "Area of Circle = π × r²", "Area of Shaded Borders & Paths"],
        "rules": [
            "Area of Parallelogram = Base × Height (b × h).",
            "Area of Triangle = ½ × Base × Height (½ × b × h).",
            "Circumference of Circle C = 2πr = πd (where π ≈ 22/7 or 3.14).",
            "Area of Circle A = πr².",
            "Area of circular ring / path = π(R² - r²)."
        ],
        "exampleQuestion": "Find the circumference of a circular bicycle wheel with radius r = 14 cm (use π = 22/7):",
        "exampleExplanation": "Circumference = 2 × π × r = 2 × (22/7) × 14 = 2 × 22 × 2 = 88 cm.",
        "exampleAnswer": "88 cm",
        "funFact": "Pi (π) is an irrational number with infinite non-repeating decimals; supercomputers have calculated it past 100 trillion digits!",
        "mascotAdvice": "Area of triangle is exactly half of a parallelogram with the same base and height: ½ × b × h!"
    },
    {
        "board": "cbse", "grade": "Class 7", "chapterNumber": 12,
        "title": "Algebraic Expressions", "icon": "🔣",
        "description": "Terms, factors, coefficients, like vs unlike terms, monomials, binomials, polynomials, and finding values.",
        "keyConcepts": ["Terms, Factors & Numerical Coefficients", "Like Terms vs Unlike Terms", "Monomial (1), Binomial (2), Trinomial (3)", "Addition & Subtraction of Expressions", "Evaluating Expressions for Given Variable Values"],
        "rules": [
            "Like terms have the exact same algebraic factors (e.g. 7xy and -3xy); unlike terms have different factors.",
            "Only LIKE terms can be combined by adding or subtracting their coefficients: 5x + 3x = 8x.",
            "Unlike terms cannot be added into one term: 5x + 3y remains 5x + 3y.",
            "Numerical coefficient of -7x²y is -7."
        ],
        "exampleQuestion": "Simplify by combining like terms: 5x² - 3x + 2x² + 7x - 4",
        "exampleExplanation": "Group like terms: (5x² + 2x²) + (-3x + 7x) - 4 = 7x² + 4x - 4.",
        "exampleAnswer": "7x² + 4x - 4",
        "funFact": "French mathematician François Viète was the first to use letters systematically for both known and unknown quantities in 1591!",
        "mascotAdvice": "Underline like terms with matching colors before adding: terms with x² together, terms with x together!"
    },
    {
        "board": "cbse", "grade": "Class 7", "chapterNumber": 13,
        "title": "Exponents and Powers", "icon": "⚡",
        "description": "Exponential notation, laws of exponents, multiplying and dividing powers, and scientific standard form.",
        "keyConcepts": ["Base and Exponent (aᵇ)", "Laws of Exponents: aᵐ × aⁿ = aᵐ⁺ⁿ", "aᵐ ÷ aⁿ = aᵐ⁻ⁿ", "(aᵐ)ⁿ = aᵐⁿ", "a⁰ = 1", "Standard Scientific Form (k × 10ⁿ)"],
        "rules": [
            "Product Law: aᵐ × aⁿ = aᵐ⁺ⁿ (bases must be identical).",
            "Quotient Law: aᵐ ÷ aⁿ = aᵐ⁻ⁿ.",
            "Power of a Power: (aᵐ)ⁿ = aᵐⁿ.",
            "Any non-zero base with zero exponent equals 1: a⁰ = 1.",
            "Standard scientific notation: A number between 1.0 and 10.0 multiplied by a power of 10."
        ],
        "exampleQuestion": "Simplify using laws of exponents: 2³ × 2⁴",
        "exampleExplanation": "Bases are the same (2), so add the exponents: 2^(3 + 4) = 2⁷ = 128.",
        "exampleAnswer": "2⁷ (or 128)",
        "funFact": "The distance from the Earth to the Sun is approximately 1.5 × 10⁸ km (150,000,000 km) in scientific notation!",
        "mascotAdvice": "Never multiply the base by the exponent: 2³ is 2 × 2 × 2 = 8, NOT 6!"
    },
    {
        "board": "cbse", "grade": "Class 7", "chapterNumber": 14,
        "title": "Symmetry", "icon": "💠",
        "description": "Rotational symmetry, center of rotation, angle of rotation, order of symmetry, and 2D figures.",
        "keyConcepts": ["Rotational Symmetry", "Center of Rotation & Angle of Rotation", "Order of Rotational Symmetry", "Figures with Both Line and Rotational Symmetry"],
        "rules": [
            "If a figure matches its original position after rotating by less than 360°, it has rotational symmetry.",
            "Order of Rotational Symmetry: The number of times the figure looks identical in one full 360° turn.",
            "Angle of Rotation = 360° ÷ Order of Symmetry.",
            "A square has order 4 (angle 90°); an equilateral triangle has order 3 (angle 120°)."
        ],
        "exampleQuestion": "What is the angle of rotation for a figure with rotational symmetry of order 4?",
        "exampleExplanation": "Angle of rotation = 360° ÷ Order = 360° ÷ 4 = 90°.",
        "exampleAnswer": "90°",
        "funFact": "Pinwheels, ceiling fans, and car wheels are classic examples of real-world rotational symmetry!",
        "mascotAdvice": "Rotate the shape 90°, 180°, 270°, 360°: count how many times it looks identical to start!"
    },
    {
        "board": "cbse", "grade": "Class 7", "chapterNumber": 15,
        "title": "Visualising Solid Shapes", "icon": "🧊",
        "description": "Nets for building 3D solids, drawing solids on isometric and oblique dot paper, and cross-sections.",
        "keyConcepts": ["3D Solids (Cubes, Cuboids, Cylinders, Cones, Pyramids)", "Nets of 3D Shapes", "Oblique vs Isometric Sketches", "Cross-sections by Slicing"],
        "rules": [
            "A net is a 2D flat pattern that can be folded to form a 3D solid.",
            "A cube net always consists of 6 connected squares.",
            "An isometric sketch uses an isometric dot grid where distances between adjacent dots are equal in all directions.",
            "Slicing a cylinder parallel to its base gives a circular cross-section; perpendicular slicing gives a rectangular cross-section."
        ],
        "exampleQuestion": "If you slice an ice-cream cone with a horizontal cut parallel to its base, what 2D cross-section shape is formed?",
        "exampleExplanation": "A horizontal slice parallel to the circular base produces a Circle.",
        "exampleAnswer": "A Circle ⭕",
        "funFact": "Medical CT scans take hundreds of 2D cross-sectional slices to build a complete 3D digital model of the human body!",
        "mascotAdvice": "Fold nets along the internal edges in your imagination to verify no faces overlap!"
    },

    # ==================== Class 8 (CBSE) ====================
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 1,
        "title": "Rational Numbers", "icon": "🔢",
        "description": "Properties of rational numbers (closure, commutativity, associativity, distributivity), identities, and inverses.",
        "keyConcepts": ["Properties of Rational Numbers", "Additive Identity (0) & Additive Inverse (-a/b)", "Multiplicative Identity (1) & Reciprocal (b/a)", "Rational Numbers between Two Rationals"],
        "rules": [
            "Closure Property: Sum, difference, and product of any two rational numbers is always a rational number.",
            "0 is the Additive Identity: a + 0 = 0 + a = a.",
            "1 is the Multiplicative Identity: a × 1 = 1 × a = a.",
            "The number 0 has NO reciprocal because 1/0 is undefined.",
            "Distributive property of multiplication over addition: a(b + c) = ab + ac."
        ],
        "exampleQuestion": "Find a rational number exactly halfway between 1/4 and 1/2:",
        "exampleExplanation": "Halfway mean = (1/4 + 1/2) ÷ 2 = (1/4 + 2/4) ÷ 2 = (3/4) ÷ 2 = 3/8.",
        "exampleAnswer": "3/8",
        "funFact": "Pythagoras believed all numbers were rational until his student Hippasus proved √2 cannot be written as a fraction!",
        "mascotAdvice": "To find rational numbers between two fractions, make their denominators equal by finding common multiples!"
    },
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 2,
        "title": "Linear Equations in One Variable", "icon": "⚖️",
        "description": "Solving linear equations with variables on both sides, reducing complex equations, and age/number word problems.",
        "keyConcepts": ["Equations with Variables on Both Sides", "Reducing Equations to Simpler Form", "Cross-Multiplication of Rational Equations", "Word Problems (Ages, Coins, Digits)"],
        "rules": [
            "Linear equation has degree 1: general form is ax + b = cx + d.",
            "Collect all variable terms on one side (LHS) and all constant terms on the other side (RHS).",
            "Cross-multiplication rule: If (ax + b) / (cx + d) = m / n, then n(ax + b) = m(cx + d).",
            "Always substitute your solution back into the original equation to check LHS = RHS."
        ],
        "exampleQuestion": "Solve for x: 5x + 9 = 2x + 24",
        "exampleExplanation": "Transpose 2x to LHS: 5x - 2x = 24 - 9 -> 3x = 15 -> x = 15 ÷ 3 = 5.",
        "exampleAnswer": "x = 5",
        "funFact": "Modern computer graphics algorithms solve systems of millions of linear equations every second to render 3D video game worlds!",
        "mascotAdvice": "Simplify brackets on both sides first, then gather variable terms on the left!"
    },
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 3,
        "title": "Understanding Quadrilaterals", "icon": "🔷",
        "description": "Polygons, sum of interior angles ((n-2)×180°), sum of exterior angles (360°), and properties of parallelograms.",
        "keyConcepts": ["Convex and Concave Polygons", "Sum of Interior Angles = (n - 2) × 180°", "Sum of Exterior Angles = 360°", "Properties of Parallelograms, Rhombus, Rectangle, Square, Kite"],
        "rules": [
            "Sum of interior angles of an n-sided polygon = (n - 2) × 180°.",
            "Sum of exterior angles of ANY convex polygon is ALWAYS 360°.",
            "Each exterior angle of a regular n-gon = 360° ÷ n.",
            "Parallelogram properties: Opposite sides equal, opposite angles equal, diagonals bisect each other.",
            "Rhombus diagonals bisect each other at RIGHT ANGLES (90°)."
        ],
        "exampleQuestion": "What is the measure of each exterior angle of a regular octagon (8-sided polygon)?",
        "exampleExplanation": "Formula: Exterior angle = 360° ÷ n = 360° ÷ 8 = 45°.",
        "exampleAnswer": "45°",
        "funFact": "The Pentagon building in Arlington, Virginia is a regular 5-sided polygon with interior angles of exactly 108° each!",
        "mascotAdvice": "Exterior angle sum is ALWAYS 360° for every polygon, whether it has 3 sides or 100 sides!"
    },
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 4,
        "title": "Practical Geometry", "icon": "📐",
        "description": "Constructing quadrilaterals given 4 sides and 1 diagonal, 3 sides and 2 diagonals, or 3 angles and 2 sides.",
        "keyConcepts": ["Constructing with 4 Sides and 1 Diagonal", "Constructing with 3 Sides and 2 Diagonals", "Constructing with 2 Adjacent Sides and 3 Angles", "Special Quadrilateral Constructions"],
        "rules": [
            "To construct a unique quadrilateral, at least 5 independent measurements are required.",
            "Divide the quadrilateral into two triangles using the diagonal as a base.",
            "Construct triangle 1 first using compass arcs, then construct triangle 2 on the same base."
        ],
        "exampleQuestion": "How many independent measurements are required to construct a unique quadrilateral?",
        "exampleExplanation": "Exactly 5 independent measurements (e.g. 4 sides and 1 diagonal, or 3 sides and 2 diagonals) are needed.",
        "exampleAnswer": "5 measurements",
        "funFact": "Surveyors use triangular triangulation based on these principles to map entire mountain ranges accurately!",
        "mascotAdvice": "Draw the diagonal first as your main baseline, then find the remaining vertices with compass arcs!"
    },
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 5,
        "title": "Data Handling", "icon": "📊",
        "description": "Organizing grouped data, frequency distribution tables, histograms, pie charts, and probability.",
        "keyConcepts": ["Grouped Frequency Distribution (Class Intervals)", "Histograms (Continuous Bars without Gaps)", "Pie Charts (Sector Angle = (Value/Total) × 360°)", "Probability of Single & Combined Events"],
        "rules": [
            "Class Interval: Class Mark (Mid-point) = (Upper Limit + Lower Limit) ÷ 2.",
            "In a histogram, bars are drawn adjacent to each other with NO spaces between them.",
            "Central angle of a component sector in a Pie Chart = (Component Value ÷ Total Value) × 360°.",
            "Probability P(E) = (Favourable Outcomes) ÷ (Total Outcomes). P(E) is always between 0 and 1."
        ],
        "exampleQuestion": "In a pie chart representing a student's daily routine, if sleep takes 8 hours out of 24 hours, what is the central sector angle?",
        "exampleExplanation": "Sector angle = (8 ÷ 24) × 360° = (1/3) × 360° = 120°.",
        "exampleAnswer": "120°",
        "funFact": "Pie charts were first published by William Playfair in 1801 in his Statistical Breviary!",
        "mascotAdvice": "Check your pie chart sectors: the sum of all central angles must add up to exactly 360°!"
    },
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 6,
        "title": "Squares and Square Roots", "icon": "2️⃣",
        "description": "Properties of square numbers, Pythagorean triplets, finding square roots by prime factorisation and long division.",
        "keyConcepts": ["Square Numbers & Ending Digits", "Pythagorean Triplets (2m, m²-1, m²+1)", "Square Root by Prime Factorisation", "Square Root by Long Division Method"],
        "rules": [
            "Square numbers can only end in digits 0, 1, 4, 5, 6, or 9 (never 2, 3, 7, 8).",
            "A number ending in an odd number of zeros can never be a perfect square.",
            "Pythagorean triplet formula for any natural number m > 1: (2m)², (m² - 1)², (m² + 1)² satisfy a² + b² = c².",
            "Square root of n: √n is the positive number which when multiplied by itself gives n."
        ],
        "exampleQuestion": "Find the square root of 144 using prime factorisation:",
        "exampleExplanation": "144 = 2 × 2 × 2 × 2 × 3 × 3 = (2 × 2) × (2 × 2) × (3 × 3). Take one from each pair: √144 = 2 × 2 × 3 = 12.",
        "exampleAnswer": "12",
        "funFact": "The symbol '√' for square root was introduced by mathematician Christoph Rudolff in 1525, derived from lowercase 'r' for 'radix'!",
        "mascotAdvice": "Pair digits from right to left in groups of two when setting up long division for square roots!"
    },
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 7,
        "title": "Cubes and Cube Roots", "icon": "3️⃣",
        "description": "Properties of cubes, Hardy-Ramanujan numbers (1729), cube roots by prime factorisation and estimation.",
        "keyConcepts": ["Cube Numbers (n³ = n × n × n)", "Hardy-Ramanujan Number 1729", "Prime Factorisation in Triplets", "Cube Root Symbol (∛)"],
        "rules": [
            "Cubes of even numbers are always even; cubes of odd numbers are always odd.",
            "If the prime factors of a number can be grouped in complete triplets of 3, the number is a perfect cube.",
            "Cube of a negative number is negative: (-a)³ = -a³.",
            "1729 is the smallest number expressible as the sum of two cubes in two different ways: 1729 = 1³ + 12³ = 9³ + 10³."
        ],
        "exampleQuestion": "Find the cube root of 216: ∛216",
        "exampleExplanation": "Prime factors: 216 = 2 × 2 × 2 × 3 × 3 × 3 = (2)³ × (3)³. Take one from each triplet: 2 × 3 = 6.",
        "exampleAnswer": "6",
        "funFact": "1729 is known as the Hardy-Ramanujan number after Srinivasa Ramanujan remarked on it during a hospital visit by G.H. Hardy!",
        "mascotAdvice": "Square root takes 1 from pairs of 2; cube root takes 1 from triplets of 3!"
    },
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 8,
        "title": "Comparing Quantities", "icon": "💰",
        "description": "Discounts, marked price, sales tax/GST, compound interest formula compounded annually and half-yearly.",
        "keyConcepts": ["Discount = Marked Price - Sale Price", "Discount % = (Discount / MP) × 100", "Sales Tax & GST Calculation", "Compound Interest Formula: A = P(1 + R/100)ⁿ", "Compounded Half-Yearly (Rate R/2, Periods 2n)"],
        "rules": [
            "Discount is always calculated on the Marked Price (MP): Discount = MP - SP.",
            "GST is added to the sale price: Bill Amount = SP + (GST % × SP).",
            "Compound Interest Amount Formula: A = P × (1 + R/100)ⁿ, where P = Principal, R = Rate %, n = years.",
            "Compound Interest CI = Amount - Principal (CI = A - P).",
            "When interest is compounded half-yearly: replace R by R/2 and n by 2n."
        ],
        "exampleQuestion": "A shirt with Marked Price ₹800 is sold with a 10% discount. What is the selling price?",
        "exampleExplanation": "Discount = 10% of ₹800 = ₹80. Selling Price = MP - Discount = ₹800 - ₹80 = ₹720.",
        "exampleAnswer": "₹720",
        "funFact": "Albert Einstein famously called compound interest the 'eighth wonder of the world'—he who understands it, earns it!",
        "mascotAdvice": "Discount is on Marked Price (MP), Tax is on Selling Price (SP), and Interest is on Principal (P)!"
    },
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 9,
        "title": "Algebraic Expressions and Identities", "icon": "🔣",
        "description": "Multiplying polynomials, standard identities: (a+b)², (a-b)², (a+b)(a-b), (x+a)(x+b), and geometric proofs.",
        "keyConcepts": ["Multiplication of Binomials by Polynomials", "Identity 1: (a + b)² = a² + 2ab + b²", "Identity 2: (a - b)² = a² - 2ab + b²", "Identity 3: (a + b)(a - b) = a² - b²", "Identity 4: (x + a)(x + b) = x² + (a + b)x + ab"],
        "rules": [
            "Identity 1: (a + b)² = a² + 2ab + b².",
            "Identity 2: (a - b)² = a² - 2ab + b².",
            "Identity 3: (a + b)(a - b) = a² - b² (Difference of two squares).",
            "Identity 4: (x + a)(x + b) = x² + (a + b)x + ab.",
            "An identity is an equality that is TRUE for ALL values of its variables."
        ],
        "exampleQuestion": "Use standard identity to evaluate: 103 × 97",
        "exampleExplanation": "Rewrite as (100 + 3)(100 - 3). Apply (a+b)(a-b) = a² - b²: 100² - 3² = 10,000 - 9 = 9,991.",
        "exampleAnswer": "9,991",
        "funFact": "These algebraic identities were proven geometrically by ancient Greek mathematicians using actual squares and rectangles of paper!",
        "mascotAdvice": "Don't forget the middle term: (a + b)² is a² + 2ab + b², NOT just a² + b²!"
    },
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 10,
        "title": "Visualising Solid Shapes", "icon": "🎲",
        "description": "Views of 3D shapes, mapping space and routes, polyhedrons, convex polyhedrons, and Euler's formula.",
        "keyConcepts": ["Polyhedrons vs Non-Polyhedrons", "Regular & Convex Polyhedrons", "Euler's Formula: F + V - E = 2", "Mapping Neighborhoods and Scales"],
        "rules": [
            "A polyhedron is a 3D solid bounded entirely by flat polygonal faces.",
            "Euler's Formula for any convex polyhedron: Faces (F) + Vertices (V) - Edges (E) = 2 (F + V - E = 2).",
            "Cylinders, cones, and spheres are NOT polyhedrons because they have curved surfaces.",
            "Prisms have two identical parallel polygonal bases connected by rectangular faces."
        ],
        "exampleQuestion": "A polyhedron has 6 faces and 8 vertices. How many edges does it have?",
        "exampleExplanation": "Apply Euler's formula: F + V - E = 2. 6 + 8 - E = 2 -> 14 - E = 2 -> E = 12 edges.",
        "exampleAnswer": "12 edges",
        "funFact": "Leonhard Euler discovered this fundamental topological relationship F + V - E = 2 in 1750!",
        "mascotAdvice": "Memorize Euler's formula: Faces + Vertices = Edges + 2 (F + V = E + 2)!"
    },
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 11,
        "title": "Mensuration", "icon": "📦",
        "description": "Area of trapezium and general quadrilaterals, surface area and volume of cube, cuboid, and right circular cylinder.",
        "keyConcepts": ["Area of Trapezium = ½ × (a + b) × h", "Area of Rhombus = ½ × d₁ × d₂", "Total Surface Area & Lateral Surface Area", "Volume of Cylinder = πr²h", "Surface Area of Cylinder: CSA = 2πrh, TSA = 2πr(r + h)"],
        "rules": [
            "Area of Trapezium = ½ × (Sum of parallel sides) × Distance between them = ½ × (a + b) × h.",
            "Area of Rhombus = ½ × d₁ × d₂ (where d₁, d₂ are diagonal lengths).",
            "Surface Area of Cube: LSA = 4a², TSA = 6a²; Volume of Cube = a³.",
            "Surface Area of Cuboid: TSA = 2(lb + bh + hl); Volume = l × b × h.",
            "Right Circular Cylinder: Curved Surface Area (CSA) = 2πrh; Total Surface Area (TSA) = 2πr(r + h); Volume = πr²h.",
            "1 liter = 1,000 cm³; 1 m³ = 1,000 liters."
        ],
        "exampleQuestion": "Find the volume of a right circular cylinder with radius r = 7 cm and height h = 10 cm (use π = 22/7):",
        "exampleExplanation": "Formula: Volume = π × r² × h = (22/7) × 7 × 7 × 10 = 22 × 7 × 10 = 1,540 cm³.",
        "exampleAnswer": "1,540 cm³",
        "funFact": "Archimedes was so proud of proving that a sphere has 2/3 the volume and surface area of its circumscribing cylinder that he requested it carved onto his tombstone!",
        "mascotAdvice": "Area takes square units (cm², m²); Volume takes cubic units (cm³, m³, liters)!"
    },
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 12,
        "title": "Exponents and Powers", "icon": "⚡",
        "description": "Powers with negative exponents, laws of exponents for negative exponents, and expressing small numbers in standard form.",
        "keyConcepts": ["Negative Exponents: a⁻ᵐ = 1 / aᵐ", "Laws of Exponents for All Integers", "Expressing Small Numbers in Standard Form (e.g. 0.000035 = 3.5 × 10⁻⁵)", "Comparing Very Large and Very Small Numbers"],
        "rules": [
            "Negative Exponent Rule: a⁻ᵐ = 1 / aᵐ and (a/b)⁻ᵐ = (b/a)ᵐ.",
            "aᵐ × aⁿ = aᵐ⁺ⁿ and aᵐ ÷ aⁿ = aᵐ⁻ⁿ (holds for all integer exponents).",
            "Very small decimals (like cell diameters) are written with negative powers of 10: 0.000007 m = 7 × 10⁻⁶ m.",
            "Moving the decimal point to the RIGHT produces a NEGATIVE power of 10."
        ],
        "exampleQuestion": "Evaluate the value of: (1/3)⁻²",
        "exampleExplanation": "Invert the base to make the exponent positive: (1/3)⁻² = (3/1)² = 3² = 9.",
        "exampleAnswer": "9",
        "funFact": "The size of a single coronavirus particle is approximately 1.2 × 10⁻⁷ meters in standard form!",
        "mascotAdvice": "Negative exponent means reciprocal: flip the fraction and remove the minus sign!"
    },
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 13,
        "title": "Direct and Inverse Proportions", "icon": "⚖️",
        "description": "Direct variation (x/y = k) vs inverse variation (x × y = k), worker-time problems, and speed-time applications.",
        "keyConcepts": ["Direct Proportion (x/y = k, constant ratio)", "Inverse Proportion (x × y = k, constant product)", "Speed, Distance, and Time Applications", "Workers and Time to Complete a Task"],
        "rules": [
            "Direct Proportion: When x increases, y increases in the same ratio. x₁/y₁ = x₂/y₂.",
            "Inverse Proportion: When x increases, y decreases proportionally. Product remains constant: x₁ × y₁ = x₂ × y₂.",
            "More workers take FEWER days to build a wall -> Inverse proportion.",
            "More distance traveled takes MORE petrol -> Direct proportion."
        ],
        "exampleQuestion": "If 15 workers can build a wall in 48 hours, how many workers are needed to do the same work in 30 hours?",
        "exampleExplanation": "Inverse proportion (Workers × Time = constant): 15 × 48 = X × 30 -> 720 = 30X -> X = 720 ÷ 30 = 24 workers.",
        "exampleAnswer": "24 workers",
        "funFact": "Boyle's Law in physics is an inverse proportion: Pressure × Volume = Constant for an ideal gas!",
        "mascotAdvice": "Ask: 'If one goes up, does the other go UP (direct: divide) or DOWN (inverse: multiply)?'"
    },
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 14,
        "title": "Factorisation", "icon": "✂️",
        "description": "Common factors, grouping terms, factorisation using identities, and division of algebraic expressions.",
        "keyConcepts": ["Method of Common Factors", "Factorisation by Regrouping Terms", "Using Identities: a² - b² = (a+b)(a-b)", "Factorising Quadratic Trinomials (Splitting the Middle Term)", "Polynomial Division"],
        "rules": [
            "Factorising means writing an algebraic expression as the product of its irreducible factors.",
            "Difference of squares: a² - b² = (a + b)(a - b).",
            "Perfect square trinomials: a² + 2ab + b² = (a + b)² and a² - 2ab + b² = (a - b)².",
            "Splitting middle term of x² + bx + c: Find two numbers p and q such that p + q = b and p × q = c."
        ],
        "exampleQuestion": "Factorise the algebraic expression: x² - 49",
        "exampleExplanation": "Recognize difference of squares: x² - 7² = (x + 7)(x - 7).",
        "exampleAnswer": "(x + 7)(x - 7)",
        "funFact": "RSA public-key cryptography (securing all online banking) relies on the fact that multiplying two huge primes is easy, but factorising their product is nearly impossible!",
        "mascotAdvice": "Always take out the Greatest Common Factor (GCF) from all terms before applying identities!"
    },
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 15,
        "title": "Introduction to Graphs", "icon": "📈",
        "description": "Cartesian coordinate system, plotting points (x, y), line graphs, reading distance-time and cost graphs.",
        "keyConcepts": ["Cartesian Coordinate System (X-axis, Y-axis)", "Origin (0, 0), Abscissa (x) and Ordinate (y)", "Plotting Ordered Pairs (x, y)", "Linear Graphs & Continuous Trends", "Reading Distance-Time Graphs"],
        "rules": [
            "The horizontal axis is the X-axis; the vertical axis is the Y-axis. They intersect at the Origin (0, 0).",
            "An ordered pair is written as (x, y): The first number x is the abscissa (distance along X-axis); the second number y is the ordinate.",
            "Points on the X-axis have y-coordinate = 0 (e.g. (4, 0)). Points on the Y-axis have x-coordinate = 0 (e.g. (0, 5)).",
            "A linear graph is a graph that consists of a single unbroken straight line.",
            "In distance-time graphs, the slope represents Speed: Slope = Distance ÷ Time."
        ],
        "exampleQuestion": "What are the coordinates of a point that lies on the Y-axis at a distance of 6 units above the X-axis?",
        "exampleExplanation": "On the Y-axis, the x-coordinate is always 0. The y-coordinate is 6. So the coordinates are (0, 6).",
        "exampleAnswer": "(0, 6)",
        "funFact": "René Descartes invented the Cartesian coordinate system in 1637 while lying in bed watching a fly crawl across ceiling tiles!",
        "mascotAdvice": "Remember the order: Walk along the hallway (X-axis) FIRST, then take the elevator up or down (Y-axis)!"
    },
    {
        "board": "cbse", "grade": "Class 8", "chapterNumber": 16,
        "title": "Playing with Numbers", "icon": "🎲",
        "description": "Numbers in general form (10a + b), games with numbers, cryptarithms (letters for digits), and divisibility tests.",
        "keyConcepts": ["Generalized Form of 2-Digit (10a + b) & 3-Digit Numbers", "Number Reversal Puzzles", "Cryptarithms (Letters for Digits)", "Tests of Divisibility by 2, 3, 5, 9, 10"],
        "rules": [
            "A 2-digit number ab is written in generalized form as 10a + b.",
            "A 3-digit number abc is written as 100a + 10b + c.",
            "Reversing a 2-digit number: (10a + b) + (10b + a) = 11(a + b), which is ALWAYS divisible by 11.",
            "In cryptarithms: Each letter stands for only ONE unique digit (0-9), and the leading first letter cannot be 0."
        ],
        "exampleQuestion": "In the addition cryptarithm: 3A + 25 = B2, find the values of digits A and B:",
        "exampleExplanation": "Units column: A + 5 ends in 2, so A = 7 (7 + 5 = 12, carry 1). Tens column: 1 + 3 + 2 = 6, so B = 6. Check: 37 + 25 = 62.",
        "exampleAnswer": "A = 7, B = 6",
        "funFact": "Sudoku and alphanumeric puzzles are based on cryptarithm logic, which is also used in computer error-detection codes!",
        "mascotAdvice": "In cryptarithms, look at the ones column first to find the single digit that satisfies the addition!"
    }
]
