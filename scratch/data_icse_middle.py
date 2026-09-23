# ICSE Middle School Curriculum (Class 6, 7, 8)
# Aligned with CISCE Mathematics Guidelines

icse_middle_chapters = [
    # ==================== Class 6 (ICSE) ====================
    {
        "board": "icse", "grade": "Class 6", "chapterNumber": 1,
        "title": "Number System & Estimation", "icon": "🔢",
        "description": "7 and 8-digit numbers, Indian & International systems, place value, rounding off to nearest 10, 100, 1000, and brackets.",
        "keyConcepts": ["Numbers up to 8 Digits", "Indian & International Comparison", "Estimation of Sums, Differences & Products", "Use of Brackets in Calculations"],
        "rules": [
            "Indian periods: Ones (3), Thousands (2), Lakhs (2), Crores (2).",
            "International periods: Ones (3), Thousands (3), Millions (3).",
            "1 Crore = 10 Million; 1 Million = 10 Lakhs.",
            "BODMAS with brackets: Parentheses (), Curly Braces {}, Square Brackets [] evaluated from innermost to outermost."
        ],
        "exampleQuestion": "Round off 47,852 to the nearest THOUSAND:",
        "exampleExplanation": "Check the hundreds digit: 8 (which is ≥ 5). Round UP: 47,852 rounds up to 48,000.",
        "exampleAnswer": "48,000",
        "funFact": "The ancient Indus Valley civilization used standard decimal weights dating back to 2600 BCE!",
        "mascotAdvice": "Work through nested brackets from the inside out: round brackets () first, then curly {}, then square []!"
    },
    {
        "board": "icse", "grade": "Class 6", "chapterNumber": 2,
        "title": "Integers & Number Line", "icon": "➖",
        "description": "Positive and negative integers, representation on number line, ordering, absolute value, and addition & subtraction.",
        "keyConcepts": ["Integers (Z = {..., -2, -1, 0, 1, 2, ...})", "Absolute Value |x|", "Additive Inverse of an Integer", "Rules of Signs in Addition & Subtraction"],
        "rules": [
            "Absolute value |a| represents the distance of an integer from 0 on the number line and is ALWAYS positive: |-7| = 7.",
            "Adding a positive integer means moving RIGHT; adding a negative integer means moving LEFT.",
            "Additive inverse of x is -x, because x + (-x) = 0.",
            "Subtracting an integer means adding its additive inverse: a - (-b) = a + b."
        ],
        "exampleQuestion": "Evaluate the absolute value expression: |-12| + |5| - |-4|",
        "exampleExplanation": "|-12| = 12, |5| = 5, |-4| = 4. Expression = 12 + 5 - 4 = 17 - 4 = 13.",
        "exampleAnswer": "13",
        "funFact": "Temperature at the South Pole routinely drops below -60°C, where hot water thrown into the air turns instantly into ice crystals!",
        "mascotAdvice": "Absolute value strips away any minus sign: distance from zero is always positive!"
    },
    {
        "board": "icse", "grade": "Class 6", "chapterNumber": 3,
        "title": "Factors, HCF & LCM", "icon": "🧩",
        "description": "Divisibility tests for 2, 3, 4, 5, 6, 8, 9, 10, 11; prime factorisation, HCF by continuous division, and LCM.",
        "keyConcepts": ["Prime & Composite Numbers", "Divisibility Tests", "HCF by Division Method", "LCM by Common Division", "Relationship: HCF × LCM = Product of Numbers"],
        "rules": [
            "Divisibility by 6: Number must be divisible by BOTH 2 (even) and 3 (digit sum multiple of 3).",
            "Divisibility by 8: Last 3 digits form a number divisible by 8.",
            "Continuous division for HCF: Divide larger by smaller, then divide previous divisor by remainder until remainder is 0.",
            "HCF × LCM = Number1 × Number2."
        ],
        "exampleQuestion": "Find the HCF of 48 and 72 using division:",
        "exampleExplanation": "72 ÷ 48 = 1 remainder 24. Then 48 ÷ 24 = 2 remainder 0. The last divisor is 24, so HCF = 24.",
        "exampleAnswer": "24",
        "funFact": "Euclid's algorithm for computing HCF (written around 300 BCE) is one of the oldest and most widely used computer algorithms today!",
        "mascotAdvice": "Use prime factorisation trees to break down composite numbers into prime building blocks!"
    },
    {
        "board": "icse", "grade": "Class 6", "chapterNumber": 4,
        "title": "Fractions and Decimals", "icon": "🍰",
        "description": "Types of fractions, four operations on fractions, terminating and recurring decimals, and decimal arithmetic.",
        "keyConcepts": ["Proper, Improper & Mixed Fractions", "Four Operations on Fractions", "Terminating vs Non-Terminating Decimals", "Decimal Word Problems"],
        "rules": [
            "(a/b) × (c/d) = (a × c) / (b × d).",
            "(a/b) ÷ (c/d) = (a/b) × (d/c).",
            "A fraction p/q in lowest terms has a terminating decimal expansion if and only if prime factors of q are ONLY 2s and/or 5s.",
            "In decimal multiplication, sum the decimal places of the factors to position the decimal point in the product."
        ],
        "exampleQuestion": "Solve: (3/5) + (2/3) ÷ (5/6)",
        "exampleExplanation": "BODMAS: Division first: (2/3) ÷ (5/6) = (2/3) × (6/5) = 12/15 = 4/5. Now addition: 3/5 + 4/5 = 7/5 = 1 2/5.",
        "exampleAnswer": "7/5 (or 1 2/5)",
        "funFact": "1/3 = 0.333... is a recurring decimal where the digit 3 repeats infinitely!",
        "mascotAdvice": "BODMAS applies to fractions too: do division and multiplication before addition!"
    },
    {
        "board": "icse", "grade": "Class 6", "chapterNumber": 5,
        "title": "Sets & Venn Diagrams", "icon": "⭕",
        "description": "Definition of set, elements (∈, ∉), roster and set-builder notation, types of sets, and introductory Venn diagrams.",
        "keyConcepts": ["Definition of a Set (Well-Defined Collection)", "Elements & Notation (∈, ∉)", "Roster Method vs Set-Builder Method", "Finite, Infinite, Empty (Null) & Universal Sets", "Cardinality of a Set n(A)", "Venn Diagrams"],
        "rules": [
            "A set is a well-defined collection of distinct objects.",
            "Symbol '∈' means 'is an element of'; '∉' means 'is not an element of'.",
            "Cardinal number n(A) is the count of distinct elements in a finite set A.",
            "Empty set (null set) has zero elements, written as ∅ or {}. Cardinality n(∅) = 0.",
            "In Venn diagrams, the Universal set U is represented by a rectangle and subsets by circles inside it."
        ],
        "exampleQuestion": "If set A = {2, 3, 5, 7, 11}, what is the cardinal number n(A)?",
        "exampleExplanation": "Count the number of elements in set A: there are 5 prime numbers. So n(A) = 5.",
        "exampleAnswer": "n(A) = 5",
        "funFact": "Georg Cantor developed modern set theory in 1874, which mathematically proved that there are different sizes of infinity!",
        "mascotAdvice": "Elements inside a set are NEVER repeated: {1, 1, 2} is simply the set {1, 2}!"
    },
    {
        "board": "icse", "grade": "Class 6", "chapterNumber": 6,
        "title": "Ratio, Proportion & Unitary Method", "icon": "⚖️",
        "description": "Ratios in simplest form, comparing ratios, proportion (Product of Extremes = Means), and direct unitary method.",
        "keyConcepts": ["Ratio in Simplest Form (HCF cancellation)", "Comparing Two Ratios", "Proportion: a : b :: c : d (ad = bc)", "Direct Unitary Method"],
        "rules": [
            "A ratio has NO units because it is a comparison of two quantities in the same units.",
            "To compare two ratios a/b and c/d: cross-multiply; if a × d > b × c, then a/b > c/d.",
            "Four terms a, b, c, d are in proportion if and only if a × d = b × c (Product of Extremes = Product of Means).",
            "Unitary Method: Divide to find the value of 1 unit, then multiply to find the required amount."
        ],
        "exampleQuestion": "Check whether 3, 6, 12, 24 are in proportion:",
        "exampleExplanation": "Product of extremes = 3 × 24 = 72. Product of means = 6 × 12 = 72. Since extremes = means, they ARE in proportion.",
        "exampleAnswer": "Yes, they are in proportion (3 × 24 = 6 × 12 = 72)",
        "funFact": "High-definition television screens use a 16 : 9 aspect ratio, meaning for every 16 units of width, there are 9 units of height!",
        "mascotAdvice": "Product of outer extremes equals product of inner means: ad = bc!"
    },
    {
        "board": "icse", "grade": "Class 6", "chapterNumber": 7,
        "title": "Percentages & Simple Applications", "icon": "💹",
        "description": "Meaning of percentage, interconverting fractions, decimals, and %, finding percentage of a quantity, and word problems.",
        "keyConcepts": ["Percentage as Fraction with Denominator 100", "Interconverting Fractions, Decimals, %", "Finding X% of a Given Quantity", "Percentage Increase and Decrease"],
        "rules": [
            "x% = x / 100.",
            "To express one quantity 'a' as a percentage of another 'b': (a / b) × 100%.",
            "Percentage Increase = (Increase ÷ Original Value) × 100%.",
            "Percentage Decrease = (Decrease ÷ Original Value) × 100%."
        ],
        "exampleQuestion": "Out of 40 students in a class, 32 passed an exam. What percentage of students passed?",
        "exampleExplanation": "Formula: (Passed ÷ Total) × 100% = (32 ÷ 40) × 100% = (4/5) × 100% = 80%.",
        "exampleAnswer": "80%",
        "funFact": "Pure gold is defined as 24 carats (100% gold); 18-carat gold is 18/24 = 75% gold alloyed with copper or silver!",
        "mascotAdvice": "Always divide by the ORIGINAL starting value when calculating percent increase or decrease!"
    },
    {
        "board": "icse", "grade": "Class 6", "chapterNumber": 8,
        "title": "Introduction to Algebra", "icon": "🔤",
        "description": "Constants and variables, algebraic terms, like & unlike terms, operations on expressions, and linear equations in one variable.",
        "keyConcepts": ["Variables and Constants", "Algebraic Expressions & Terms", "Like Terms vs Unlike Terms", "Solving Simple Linear Equations by Transposition"],
        "rules": [
            "Constants have a fixed numerical value (e.g. 5, -3); Variables are represented by letters that can vary.",
            "Like terms have identical variable powers: 3x² and -5x² are like; 3x and 3y are unlike.",
            "Only like terms can be combined: 4x + 7x = 11x.",
            "Linear Equation: Transposing a term changes its sign (+ becomes -, × becomes ÷)."
        ],
        "exampleQuestion": "Solve the linear equation: 4x - 5 = 19",
        "exampleExplanation": "Transpose 5: 4x = 19 + 5 -> 4x = 24. Divide by 4: x = 24 ÷ 4 = 6.",
        "exampleAnswer": "x = 6",
        "funFact": "Diophantus of Alexandria (around 250 CE) is called the 'father of algebra' for introducing early algebraic symbolism!",
        "mascotAdvice": "Isolate the variable on one side by doing inverse operations step by step!"
    },
    {
        "board": "icse", "grade": "Class 6", "chapterNumber": 9,
        "title": "Geometry: Angles, Triangles & Circles", "icon": "📐",
        "description": "Types of angles, complementary and supplementary angles, angle sum of triangle (180°), construction of angles.",
        "keyConcepts": ["Complementary Angles (Sum = 90°)", "Supplementary Angles (Sum = 180°)", "Angle Sum Property of Triangle = 180°", "Circle: Radius, Diameter, Circumference, Arc, Chord"],
        "rules": [
            "Two angles are complementary if their sum is 90°; supplementary if their sum is 180°.",
            "Sum of the three angles of any triangle is ALWAYS 180°.",
            "Diameter = 2 × Radius; Circumference = 2πr.",
            "An exterior angle of a triangle equals the sum of its two interior opposite angles."
        ],
        "exampleQuestion": "An angle measures 62°. What is its SUPPLEMENTARY angle?",
        "exampleExplanation": "Supplementary angles sum to 180°: Supplement = 180° - 62° = 118°.",
        "exampleAnswer": "118°",
        "funFact": "The three angles of a triangle on a flat plane sum to 180°, but on a spherical globe (like Earth) they can sum to over 270°!",
        "mascotAdvice": "Complementary adds to 90° (Corner); Supplementary adds to 180° (Straight line)!"
    },
    {
        "board": "icse", "grade": "Class 6", "chapterNumber": 10,
        "title": "Mensuration: Perimeter & Area", "icon": "🟩",
        "description": "Perimeter of rectilinear figures, area of rectangle, square, triangle, and applications to paths and borders.",
        "keyConcepts": ["Perimeter = Total Boundary Length", "Perimeter: Rectangle = 2(L+W), Square = 4S", "Area: Rectangle = L × W, Square = S²", "Area of Triangle = ½ × Base × Height", "Border Path Calculations"],
        "rules": [
            "Perimeter of Rectangle = 2 × (Length + Breadth); Square = 4 × Side.",
            "Area of Rectangle = Length × Breadth; Square = Side².",
            "Area of Triangle = ½ × Base × Height.",
            "To find the area of a path around a garden: Area of outer rectangle - Area of inner rectangle."
        ],
        "exampleQuestion": "Find the area of a right-angled triangle with base 12 cm and height 8 cm:",
        "exampleExplanation": "Area of triangle = ½ × Base × Height = ½ × 12 × 8 = 6 × 8 = 48 cm².",
        "exampleAnswer": "48 cm²",
        "funFact": "Soccer fields vary in size, but FIFA regulation pitches must be between 100-110 m long and 64-75 m wide!",
        "mascotAdvice": "Area of triangle is always half the area of the bounding rectangle: ½ × b × h!"
    },
    {
        "board": "icse", "grade": "Class 6", "chapterNumber": 11,
        "title": "3D Solid Shapes & Symmetry", "icon": "🧊",
        "description": "Nets of 3D solids (cube, cuboid, cylinder, cone, pyramid), faces, edges, vertices, and reflection/rotational symmetry.",
        "keyConcepts": ["Faces, Edges & Vertices of Solids", "Euler's Formula: F + V - E = 2", "Nets of Cubes and Prisms", "Line Symmetry and Reflection"],
        "rules": [
            "Euler's Formula for polyhedrons: Faces + Vertices - Edges = 2 (F + V - E = 2).",
            "A rectangular prism (cuboid) has 6 faces, 8 vertices, and 12 edges (6 + 8 - 12 = 2).",
            "A triangular prism has 5 faces, 6 vertices, and 9 edges.",
            "A line of symmetry folds a shape into two identical mirror halves."
        ],
        "exampleQuestion": "A triangular prism has 5 faces and 6 vertices. Verify Euler's formula and find the number of edges:",
        "exampleExplanation": "Euler's formula: F + V - E = 2 -> 5 + 6 - E = 2 -> 11 - E = 2 -> E = 9 edges.",
        "exampleAnswer": "9 edges (5 + 6 - 9 = 2)",
        "funFact": "Carbon atoms can bond into a soccer-ball-shaped polyhedron called a 'Buckyball' with 32 faces and 60 vertices!",
        "mascotAdvice": "Test solids with Euler's check: Faces + Vertices must equal Edges + 2!"
    },
    {
        "board": "icse", "grade": "Class 6", "chapterNumber": 12,
        "title": "Data Handling: Mean & Bar Graphs", "icon": "📊",
        "description": "Collecting and organizing data, frequency distribution tables, Arithmetic Mean, and drawing single & double bar graphs.",
        "keyConcepts": ["Frequency Tables & Tally Marks", "Arithmetic Mean = Sum / Total Count", "Drawing Bar Graphs with Axis Scale", "Interpreting Double Bar Graphs"],
        "rules": [
            "Mean = (Sum of all observations) ÷ (Total number of observations).",
            "In bar graphs, all bars must have equal width and equal uniform spacing.",
            "Double bar graphs are used to compare two collections of data at a glance (e.g. term 1 vs term 2 marks)."
        ],
        "exampleQuestion": "Find the Mean of the numbers: 14, 18, 22, 26, 30",
        "exampleExplanation": "Sum = 14 + 18 + 22 + 26 + 30 = 110. Total numbers = 5. Mean = 110 ÷ 5 = 22.",
        "exampleAnswer": "22",
        "funFact": "The word 'Statistics' comes from the Italian 'statista', meaning statesman—originally the collection of state census data!",
        "mascotAdvice": "The Mean is the balance point of the data: add everything up and divide by the count!"
    }
]
