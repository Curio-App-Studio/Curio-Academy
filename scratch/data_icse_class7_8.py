# ICSE Class 7 and Class 8 Curriculum Data
# Aligned with CISCE Mathematics Guidelines

icse_class7_8_chapters = [
    # ==================== Class 7 (ICSE) ====================
    {
        "board": "icse", "grade": "Class 7", "chapterNumber": 1,
        "title": "Integers & Rational Numbers", "icon": "🔢",
        "description": "Rules of signs in multiplication/division, closure, commutativity, associativity, and standard form of rational numbers.",
        "keyConcepts": ["Sign Rules: (-) × (-) = (+)", "Distributive Property: a(b+c) = ab + ac", "Rational Number Definition (p/q, q ≠ 0)", "Standard Form & Density Property"],
        "rules": [
            "Multiplying an odd number of negative factors gives a negative product; even count gives positive.",
            "Division by 0 is undefined; 0 ÷ a = 0 (for a ≠ 0).",
            "A rational number is in standard form when denominator q > 0 and HCF(|p|, q) = 1.",
            "Between any two distinct rational numbers, there exist infinitely many rational numbers."
        ],
        "exampleQuestion": "Evaluate: (-3) × (-4) × (-5)",
        "exampleExplanation": "There are 3 negative signs (odd count): (-3) × (-4) = +12. Then (+12) × (-5) = -60.",
        "exampleAnswer": "-60",
        "funFact": "Richard Dedekind formalized real numbers in 1872 using 'Dedekind cuts' of rational numbers!",
        "mascotAdvice": "Odd count of negative signs = Negative result; Even count of negative signs = Positive result!"
    },
    {
        "board": "icse", "grade": "Class 7", "chapterNumber": 2,
        "title": "Fractions and Decimals", "icon": "🍰",
        "description": "Reciprocals, division of fractions, recurring decimals, rounding decimals, and operations with decimals.",
        "keyConcepts": ["Division of Fractions (Multiply by Reciprocal)", "Terminating vs Repeating (Recurring) Decimals", "Converting Recurring Decimals to Fractions", "Operations on Decimals"],
        "rules": [
            "(a/b) ÷ (c/d) = (a/b) × (d/c).",
            "A fraction has a terminating decimal expansion if its denominator factors only contain 2s and 5s.",
            "A bar notation like 0.3̄ denotes recurring decimal 0.333...",
            "In decimal multiplication, the count of decimal places in the answer equals the sum of decimal places in factors."
        ],
        "exampleQuestion": "Solve: (7/9) ÷ (14/27)",
        "exampleExplanation": "Multiply by reciprocal: (7/9) × (27/14) = (7 × 27) / (9 × 14) = (1 × 3) / (1 × 2) = 3/2 = 1 1/2.",
        "exampleAnswer": "3/2 (or 1 1/2)",
        "funFact": "The fraction 22/7 is famous as an Archimedean rational approximation of Pi (π ≈ 3.14159)!",
        "mascotAdvice": "Multiply by the flipped reciprocal: Keep, Change, Flip (KCF)!"
    },
    {
        "board": "icse", "grade": "Class 7", "chapterNumber": 3,
        "title": "Exponents and Powers", "icon": "⚡",
        "description": "Laws of indices, negative exponents, power of a product/quotient, and writing numbers in standard scientific notation.",
        "keyConcepts": ["Base and Index / Exponent", "Product Law: aᵐ × aⁿ = aᵐ⁺ⁿ", "Quotient Law: aᵐ ÷ aⁿ = aᵐ⁻ⁿ", "Power of Power: (aᵐ)ⁿ = aᵐⁿ", "Negative Exponent: a⁻ⁿ = 1/aⁿ", "Scientific Notation (A × 10ⁿ)"],
        "rules": [
            "aᵐ × aⁿ = aᵐ⁺ⁿ (bases must be identical).",
            "aᵐ ÷ aⁿ = aᵐ⁻ⁿ.",
            "(aᵐ)ⁿ = aᵐⁿ; (ab)ⁿ = aⁿbⁿ.",
            "a⁰ = 1 (for any non-zero base a).",
            "a⁻ⁿ = 1 / aⁿ."
        ],
        "exampleQuestion": "Simplify using laws of exponents: (3⁴ × 3²) ÷ 3⁵",
        "exampleExplanation": "Numerator: 3^(4 + 2) = 3⁶. Then divide: 3⁶ ÷ 3⁵ = 3^(6 - 5) = 3¹ = 3.",
        "exampleAnswer": "3",
        "funFact": "A googol is 10¹⁰⁰—a 1 followed by one hundred zeros, larger than the estimated number of atoms in the observable universe (10⁸⁰)!",
        "mascotAdvice": "Add powers when multiplying; subtract powers when dividing!"
    },
    {
        "board": "icse", "grade": "Class 7", "chapterNumber": 4,
        "title": "Sets & Venn Diagrams", "icon": "⭕",
        "description": "Union (∪), intersection (∩), disjoint sets, universal set, complement of a set (A'), and 2-circle Venn diagrams.",
        "keyConcepts": ["Union of Sets (A ∪ B)", "Intersection of Sets (A ∩ B)", "Disjoint Sets (A ∩ B = ∅)", "Complement of a Set A' = U - A", "Cardinality Formula: n(A ∪ B) = n(A) + n(B) - n(A ∩ B)"],
        "rules": [
            "Union A ∪ B contains all elements belonging to set A, set B, or both.",
            "Intersection A ∩ B contains ONLY the elements common to both sets.",
            "Cardinality formula: n(A ∪ B) = n(A) + n(B) - n(A ∩ B).",
            "Complement A' contains all elements in universal set U that are NOT in set A."
        ],
        "exampleQuestion": "If set A = {1, 2, 3, 4} and set B = {3, 4, 5, 6}, what is the intersection set A ∩ B?",
        "exampleExplanation": "The elements common to both sets A and B are 3 and 4: A ∩ B = {3, 4}.",
        "exampleAnswer": "{3, 4}",
        "funFact": "John Venn introduced Venn diagrams in 1880, which are now foundational to computer database search queries (AND, OR, NOT)!",
        "mascotAdvice": "Union (∪) means combine ALL unique elements; Intersection (∩) means take ONLY the shared overlap!"
    },
    {
        "board": "icse", "grade": "Class 7", "chapterNumber": 5,
        "title": "Commercial Mathematics", "icon": "💹",
        "description": "Ratio, proportion, percentage profit/loss, and Simple Interest: I = (P × R × T) / 100, Amount = P + I.",
        "keyConcepts": ["Profit % and Loss % on Cost Price", "Simple Interest Formula: I = (P × R × T) / 100", "Amount Formula: A = P + I", "Unitary Method in Commercial Transactions"],
        "rules": [
            "Profit % = (Profit / CP) × 100%; Loss % = (Loss / CP) × 100%.",
            "Profit % and Loss % are ALWAYS calculated on Cost Price (CP).",
            "Simple Interest Formula: I = (P × R × T) / 100, where P = Principal, R = Rate % per annum, T = Time in years.",
            "Total Amount A = P + I."
        ],
        "exampleQuestion": "A shopkeeper buys an item for ₹500 and sells it for ₹600. What is his Profit percentage?",
        "exampleExplanation": "Profit = SP - CP = ₹600 - ₹500 = ₹100. Profit % = (100 ÷ 500) × 100% = 20%.",
        "exampleAnswer": "20%",
        "funFact": "Commercial arithmetic in Renaissance Italy led directly to double-entry bookkeeping, invented by Luca Pacioli in 1494!",
        "mascotAdvice": "Never calculate Profit % on Selling Price—always divide by the Cost Price (CP)!"
    },
    {
        "board": "icse", "grade": "Class 7", "chapterNumber": 6,
        "title": "Speed, Distance and Time", "icon": "🚀",
        "description": "Formulas relating Speed, Distance, Time; unit conversions (km/h <-> m/s), trains crossing poles and bridges.",
        "keyConcepts": ["Speed = Distance / Time", "Distance = Speed × Time, Time = Distance / Speed", "Conversion: km/h to m/s (× 5/18)", "Conversion: m/s to km/h (× 18/5)", "Train Problems (Distance = Train Length + Platform Length)"],
        "rules": [
            "Speed = Distance ÷ Time.",
            "To convert km/h to m/s: Multiply by 5/18 (e.g. 90 km/h × 5/18 = 25 m/s).",
            "To convert m/s to km/h: Multiply by 18/5 (e.g. 20 m/s × 18/5 = 72 km/h).",
            "When a train of length L passes a platform of length P, total distance covered = L + P."
        ],
        "exampleQuestion": "Convert a vehicle speed of 54 km/h into meters per second (m/s):",
        "exampleExplanation": "Multiply by 5/18: 54 × (5/18) = 3 × 5 = 15 m/s.",
        "exampleAnswer": "15 m/s",
        "funFact": "Japan's Shinkansen bullet trains travel at 320 km/h (approx. 89 m/s) with an average delay of less than 1 minute per year!",
        "mascotAdvice": "Multiply by 5/18 to turn big km/h into small m/s; multiply by 18/5 to go back to km/h!"
    },
    {
        "board": "icse", "grade": "Class 7", "chapterNumber": 7,
        "title": "Algebraic Expressions", "icon": "🔣",
        "description": "Monomials, binomials, trinomials, degree of expressions, addition/subtraction, and multiplication of polynomials.",
        "keyConcepts": ["Degree of a Polynomial (Highest Power of Variable)", "Addition & Subtraction of Polynomials", "Multiplying Monomial by Polynomial", "Evaluating Polynomial Values"],
        "rules": [
            "Degree of a polynomial in one variable is the highest exponent of the variable.",
            "Like terms have the same variables with matching powers; only like terms can be added or subtracted.",
            "Distributive law for multiplication: a(b + c + d) = ab + ac + ad.",
            "Minus sign before a bracket reverses the sign of EVERY term inside upon opening: -(a - b) = -a + b."
        ],
        "exampleQuestion": "What is the degree of the polynomial: 4x³ - 7x² + 5x - 9?",
        "exampleExplanation": "The highest exponent of variable x is 3. Therefore, the degree of the polynomial is 3.",
        "exampleAnswer": "Degree = 3",
        "funFact": "Polynomial equations of degree 5 and higher cannot be solved by general radical formulas, as proven by Niels Henrik Abel in 1824!",
        "mascotAdvice": "Be careful when subtracting expressions: change the sign of every term being subtracted!"
    },
    {
        "board": "icse", "grade": "Class 7", "chapterNumber": 8,
        "title": "Linear Equations and Inequations", "icon": "⚖️",
        "description": "Solving linear equations by transposition, word problems, and introduction to linear inequations (<, ≤, >, ≥).",
        "keyConcepts": ["Linear Equation in One Variable: ax + b = c", "Transposition Rules across '='", "Linear Inequations (x < a, x ≥ a)", "Number Line Representation of Inequations"],
        "rules": [
            "Transposition: Term changes sign when moving across '=' (+ becomes -, - becomes +).",
            "In linear inequations: Multiplying or dividing both sides by a NEGATIVE number REVERSES the inequality sign (e.g. -2x < 6 -> x > -3).",
            "A strict inequality (<, >) is shown with an open circle on a number line; inclusive (≤, ≥) with a solid dot."
        ],
        "exampleQuestion": "Solve the linear equation: 5x - 3 = 2x + 12",
        "exampleExplanation": "Transpose 2x to left and -3 to right: 5x - 2x = 12 + 3 -> 3x = 15 -> x = 15 ÷ 3 = 5.",
        "exampleAnswer": "x = 5",
        "funFact": "Speed limits on highways are real-world linear inequations: Speed ≤ 80 km/h!",
        "mascotAdvice": "Remember: Multiplying or dividing by a negative number flips the inequality alligator mouth!"
    },
    {
        "board": "icse", "grade": "Class 7", "chapterNumber": 9,
        "title": "Lines, Angles & Transversals", "icon": "📐",
        "description": "Parallel lines cut by a transversal, corresponding angles, alternate interior angles, and co-interior angles.",
        "keyConcepts": ["Transversal Intersecting Parallel Lines", "Corresponding Angles (Equal: F-Shape)", "Alternate Interior Angles (Equal: Z-Shape)", "Co-interior Angles (Supplementary: Sum = 180°, C-Shape)"],
        "rules": [
            "Corresponding angles are equal (F-shape).",
            "Alternate interior angles are equal (Z-shape).",
            "Co-interior angles on the same side of transversal sum to 180° (C-shape).",
            "Vertically opposite angles are ALWAYS equal, even if lines are not parallel."
        ],
        "exampleQuestion": "Two parallel lines are cut by a transversal. If one interior angle is 70°, what is the measure of its co-interior angle?",
        "exampleExplanation": "Co-interior angles are supplementary (sum = 180°): Co-interior angle = 180° - 70° = 110°.",
        "exampleAnswer": "110°",
        "funFact": "Railway train tracks are parallel lines engineered with millimeter precision so train wheel flanges never derail!",
        "mascotAdvice": "Look for the letters: Z for Alternate angles (equal); F for Corresponding angles (equal); C for Co-interior (add to 180°)!"
    },
    {
        "board": "icse", "grade": "Class 7", "chapterNumber": 10,
        "title": "Triangles & Pythagoras Theorem", "icon": "🔺",
        "description": "Exterior angle theorem, angle sum property (180°), congruence criteria (SSS, SAS, ASA, RHS), and Pythagoras theorem.",
        "keyConcepts": ["Angle Sum Property = 180°", "Exterior Angle = Sum of Two Opposite Interior Angles", "Congruence Criteria (SSS, SAS, ASA, RHS)", "Pythagoras Theorem: h² = b² + p²"],
        "rules": [
            "Exterior angle of a triangle = Sum of two interior opposite angles.",
            "Angle sum property: ∠A + ∠B + ∠C = 180°.",
            "Pythagoras Theorem: In a right triangle, Hypotenuse² = Base² + Perpendicular² (c² = a² + b²).",
            "Pythagorean Triplets: 3-4-5, 5-12-13, 8-15-17, 7-24-25."
        ],
        "exampleQuestion": "A right-angled triangle has base 5 cm and perpendicular 12 cm. What is the length of its hypotenuse?",
        "exampleExplanation": "Pythagoras theorem: h² = 5² + 12² = 25 + 144 = 169. h = √169 = 13 cm.",
        "exampleAnswer": "13 cm",
        "funFact": "Pythagoras theorem was known and written in India in the Baudhayana Sulba Sutras around 800 BCE!",
        "mascotAdvice": "The hypotenuse is ALWAYS the side directly opposite the 90° right angle, and it is the longest side!"
    },
    {
        "board": "icse", "grade": "Class 7", "chapterNumber": 11,
        "title": "Perimeter & Area: Circles & Polygons", "icon": "🟩",
        "description": "Circumference and area of circle (2πr, πr²), area of triangle, parallelogram, rhombus, and circular ring paths.",
        "keyConcepts": ["Circumference of Circle = 2πr", "Area of Circle = πr²", "Area of Parallelogram = b × h", "Area of Rhombus = ½ × d₁ × d₂", "Area of Triangle = ½ × b × h", "Circular Rings: π(R² - r²)"],
        "rules": [
            "Circumference of Circle: C = 2πr = πd (where π ≈ 22/7 or 3.14).",
            "Area of Circle: A = πr².",
            "Area of Parallelogram = Base × Height.",
            "Area of Rhombus = ½ × (Product of diagonals) = ½ × d₁ × d₂.",
            "Area of circular ring / track = π(R² - r²)."
        ],
        "exampleQuestion": "Find the area of a circle with radius 7 cm (use π = 22/7):",
        "exampleExplanation": "Area = π × r² = (22/7) × 7 × 7 = 22 × 7 = 154 cm².",
        "exampleAnswer": "154 cm²",
        "funFact": "If you wrap a rope tightly around the Earth and add just 1 meter to its length, the entire ring lifts 16 cm off the ground everywhere!",
        "mascotAdvice": "Circumference is the distance around the boundary (2πr); Area is the flat space inside (πr²)!"
    },
    {
        "board": "icse", "grade": "Class 7", "chapterNumber": 12,
        "title": "Data Handling & Probability", "icon": "📊",
        "description": "Mean, Median, Mode, Range, double bar graphs, and theoretical probability of independent simple events.",
        "keyConcepts": ["Mean = Sum / Total Observations", "Median (Middle Value of Sorted Data)", "Mode (Most Frequent Observation)", "Probability P(E) = Favourable / Total"],
        "rules": [
            "Mean = Sum of observations ÷ Total number of observations.",
            "Median: Sort data in order. If n is odd, middle term is (n+1)/2. If n is even, average of n/2 and (n/2 + 1) terms.",
            "Mode: Value with highest frequency.",
            "Probability P(E) = (Favourable outcomes) ÷ (Total possible outcomes). 0 ≤ P(E) ≤ 1."
        ],
        "exampleQuestion": "A fair standard 6-sided die is rolled. What is the probability of getting an EVEN number?",
        "exampleExplanation": "Possible outcomes = {1, 2, 3, 4, 5, 6} (6 total). Favourable even outcomes = {2, 4, 6} (3 outcomes). P(Even) = 3/6 = 1/2.",
        "exampleAnswer": "1/2 (or 50%)",
        "funFact": "Probability theory was founded in 1654 in letters between mathematicians Pierre de Fermat and Blaise Pascal discussing dice games!",
        "mascotAdvice": "Always check probability answers: probability can NEVER be less than 0 or greater than 1!"
    },

    # ==================== Class 8 (ICSE) ====================
    {
        "board": "icse", "grade": "Class 8", "chapterNumber": 1,
        "title": "Rational Numbers", "icon": "🔢",
        "description": "Properties of rational numbers, closure, commutativity, associativity, distributivity, identities, and inserting rationals.",
        "keyConcepts": ["Closure, Commutative & Associative Properties", "Distributive Property of Multiplication", "Additive & Multiplicative Inverses", "Inserting n Rational Numbers between Rationals"],
        "rules": [
            "Rational numbers are closed under addition, subtraction, and multiplication (not closed under division because dividing by 0 is undefined).",
            "Additive Identity is 0: a + 0 = a. Additive Inverse of a/b is -a/b.",
            "Multiplicative Identity is 1: a × 1 = a. Multiplicative Inverse (reciprocal) of a/b is b/a (a, b ≠ 0).",
            "The number 0 has NO reciprocal."
        ],
        "exampleQuestion": "What is the multiplicative inverse (reciprocal) of -7/9?",
        "exampleExplanation": "Reciprocal flips the fraction while preserving sign: the reciprocal of -7/9 is -9/7, because (-7/9) × (-9/7) = 1.",
        "exampleAnswer": "-9/7",
        "funFact": "The word 'Rational' comes from 'Ratio'—meaning any number that can be expressed as a ratio of two integers!",
        "mascotAdvice": "Additive inverse flips the SIGN (+ to -); Multiplicative inverse flips the FRACTION (top to bottom)!"
    },
    {
        "board": "icse", "grade": "Class 8", "chapterNumber": 2,
        "title": "Exponents and Radicals", "icon": "⚡",
        "description": "Negative and fractional exponents, laws of indices, evaluating radicals, and standard scientific notation.",
        "keyConcepts": ["Negative Exponents: a⁻ⁿ = 1/aⁿ", "Fractional Exponents: a^(1/n) = ⁿ√a", "Laws of Exponents for All Rational Powers", "Scientific Form for Microscopic Quantities"],
        "rules": [
            "Negative Exponent: a⁻ⁿ = 1 / aⁿ and (a/b)⁻ⁿ = (b/a)ⁿ.",
            "Fractional Exponent: a^(m/n) = ⁿ√(aᵐ) = (ⁿ√a)ᵐ.",
            "aᵐ × aⁿ = aᵐ⁺ⁿ; aᵐ ÷ aⁿ = aᵐ⁻ⁿ.",
            "Any non-zero quantity raised to power 0 equals 1: a⁰ = 1."
        ],
        "exampleQuestion": "Evaluate the value of: 64^(1/3)",
        "exampleExplanation": "Power 1/3 means the cube root: ∛64 = 4 (since 4 × 4 × 4 = 64).",
        "exampleAnswer": "4",
        "funFact": "Computer memory uses powers of 2: 1 Kilobyte = 2¹⁰ bytes (1,024 bytes), 1 Megabyte = 2²⁰ bytes!",
        "mascotAdvice": "Fractional power: numerator is the power, denominator is the root! a^(2/3) = ∛(a²)."
    },
    {
        "board": "icse", "grade": "Class 8", "chapterNumber": 3,
        "title": "Squares, Square Roots & Cubes", "icon": "2️⃣",
        "description": "Properties of perfect squares, finding square roots by long division method, decimal square roots, and cube roots.",
        "keyConcepts": ["Square Root by Long Division Method", "Square Root of Decimals and Fractions", "Pythagorean Triplets: 2m, m²-1, m²+1", "Cube Roots by Prime Factorisation (Triplets)"],
        "rules": [
            "Square numbers end only in 0, 1, 4, 5, 6, 9 (never 2, 3, 7, 8).",
            "Pythagorean triplet for integer m > 1: (2m)², (m² - 1)², (m² + 1)² form a right triangle.",
            "Long division pairing: Group digits in pairs starting from the decimal point going left and right.",
            "Cube root ∛n: Factorise into prime factors and take 1 factor from each triplet of 3."
        ],
        "exampleQuestion": "Find the square root of 529 using long division or factorisation:",
        "exampleExplanation": "529 = 23 × 23. Therefore, √529 = 23.",
        "exampleAnswer": "23",
        "funFact": "A chessboard has 64 small squares, but counting squares of all sizes (1×1, 2×2... 8×8), there are 204 squares in total!",
        "mascotAdvice": "Memorize squares up to 25: 11²=121, 12²=144, 13²=169, 14²=196, 15²=225, 25²=625!"
    },
    {
        "board": "icse", "grade": "Class 8", "chapterNumber": 4,
        "title": "Sets & Venn Diagrams", "icon": "⭕",
        "description": "Subsets, proper subsets, power set, Cartesian product A × B, and solving 2-set and 3-set word problems with Venn diagrams.",
        "keyConcepts": ["Subsets (⊆) & Proper Subsets (⊂)", "Number of Subsets = 2ⁿ", "Cartesian Product of Sets (A × B)", "Venn Diagram Word Problems: n(A ∪ B) = n(A) + n(B) - n(A ∩ B)"],
        "rules": [
            "If a set has n elements, the total number of subsets is 2ⁿ.",
            "Cartesian Product A × B = {(a, b) : a ∈ A, b ∈ B}. n(A × B) = n(A) × n(B).",
            "n(A ∪ B) = n(A) + n(B) - n(A ∩ B).",
            "n(A only) = n(A) - n(A ∩ B)."
        ],
        "exampleQuestion": "How many total subsets does a set containing 3 elements have?",
        "exampleExplanation": "Formula for number of subsets is 2ⁿ: for n = 3, subsets = 2³ = 8.",
        "exampleAnswer": "8 subsets",
        "funFact": "Relational databases (SQL) used by Amazon and Google are built on Cartesian products and set operations!",
        "mascotAdvice": "Remember the empty set ∅ and the set itself are ALWAYS subsets of any set!"
    },
    {
        "board": "icse", "grade": "Class 8", "chapterNumber": 5,
        "title": "Commercial Math: Compound Interest", "icon": "💰",
        "description": "Compound interest formula A = P(1 + R/100)ⁿ, half-yearly compounding, depreciation, and sales tax / GST.",
        "keyConcepts": ["Compound Interest Formula: A = P(1 + R/100)ⁿ", "CI = Amount - Principal", "Compounding Semi-Annually (Rate R/2, Periods 2n)", "Depreciation Formula: V = V₀(1 - R/100)ⁿ", "Sales Tax & GST Calculations"],
        "rules": [
            "Amount Formula: A = P(1 + R/100)ⁿ, where P = Principal, R = Rate % p.a., n = time in years.",
            "Compound Interest CI = A - P = P[(1 + R/100)ⁿ - 1].",
            "When interest is compounded half-yearly: A = P(1 + (R/2)/100)²ⁿ.",
            "Depreciation (loss in value of vehicles/machinery): Value V = P(1 - R/100)ⁿ.",
            "GST Amount = (GST % ÷ 100) × Selling Price."
        ],
        "exampleQuestion": "Calculate the compound amount on ₹10,000 for 2 years at 10% per annum compounded annually:",
        "exampleExplanation": "A = 10,000 × (1 + 10/100)² = 10,000 × (1.1)² = 10,000 × 1.21 = ₹12,100.",
        "exampleAnswer": "₹12,100",
        "funFact": "If you invested $1 at 7% compound interest 2,000 years ago, it would be worth more than the total mass of the Earth in solid gold today!",
        "mascotAdvice": "Appreciation (growth) uses (1 + R/100); Depreciation (aging car/phone) uses (1 - R/100)!"
    },
    {
        "board": "icse", "grade": "Class 8", "chapterNumber": 6,
        "title": "Direct and Inverse Proportions", "icon": "⚖️",
        "description": "Direct variation (x/y = k) vs inverse variation (xy = k), speed-distance-time, pipes and cisterns, and workforce problems.",
        "keyConcepts": ["Direct Variation (x₁/y₁ = x₂/y₂)", "Inverse Variation (x₁y₁ = x₂y₂)", "Worker-Days Calculations", "Pipes and Cistern Filling Rates"],
        "rules": [
            "Direct Proportion: x/y = constant k. If x doubles, y doubles.",
            "Inverse Proportion: x × y = constant k. If x doubles, y is halved.",
            "Workers × Days = Total Work Done (constant for a given job).",
            "Speed × Time = Distance (Speed and Time are inversely proportional for a fixed distance)."
        ],
        "exampleQuestion": "If 12 men can complete a job in 20 days, how many men are needed to complete the same job in 15 days?",
        "exampleExplanation": "Inverse proportion: 12 × 20 = M × 15 -> 240 = 15M -> M = 240 ÷ 15 = 16 men.",
        "exampleAnswer": "16 men",
        "funFact": "Gear ratios in bicycles and cars are inverse proportions: smaller gears turn faster with more rotations per minute!",
        "mascotAdvice": "More workers take LESS time -> Inverse proportion (multiply: x₁y₁ = x₂y₂)!"
    },
    {
        "board": "icse", "grade": "Class 8", "chapterNumber": 7,
        "title": "Algebraic Special Products & Expansions", "icon": "🔣",
        "description": "Expansion identities: (a+b)², (a-b)², (a+b)(a-b), (x+a)(x+b), (a+b+c)², and cube expansions (a±b)³.",
        "keyConcepts": ["Standard Identities: (a ± b)² = a² ± 2ab + b²", "Difference of Squares: (a + b)(a - b) = a² - b²", "Trinomial Square: (a + b + c)² = a² + b² + c² + 2ab + 2bc + 2ca", "Cube Expansions: (a + b)³ = a³ + b³ + 3ab(a + b)"],
        "rules": [
            "(a + b)² = a² + 2ab + b².",
            "(a - b)² = a² - 2ab + b².",
            "(a + b)(a - b) = a² - b².",
            "(a + b + c)² = a² + b² + c² + 2ab + 2bc + 2ca.",
            "(a + b)³ = a³ + b³ + 3ab(a + b) = a³ + 3a²b + 3ab² + b³.",
            "(a - b)³ = a³ - b³ - 3ab(a - b) = a³ - 3a²b + 3ab² - b³."
        ],
        "exampleQuestion": "Expand using the standard identity: (2x + 3y)²",
        "exampleExplanation": "(2x + 3y)² = (2x)² + 2(2x)(3y) + (3y)² = 4x² + 12xy + 9y².",
        "exampleAnswer": "4x² + 12xy + 9y²",
        "funFact": "Blaise Pascal arranged the coefficients of these binomial expansions in his famous 'Pascal's Triangle' in 1654!",
        "mascotAdvice": "Never forget the middle term: (2x + 3y)² has the 2ab term (12xy) in the middle!"
    },
    {
        "board": "icse", "grade": "Class 8", "chapterNumber": 8,
        "title": "Factorisation of Algebraic Expressions", "icon": "✂️",
        "description": "Common factors, grouping terms, difference of two squares, factorising quadratic trinomials ax² + bx + c.",
        "keyConcepts": ["Taking out Common Monomials/Binomials", "Factorisation by Regrouping", "Difference of Two Squares: a² - b² = (a+b)(a-b)", "Factorising Quadratic Trinomials by Splitting the Middle Term"],
        "rules": [
            "Difference of Two Squares: a² - b² = (a + b)(a - b).",
            "Quadratic Trinomial x² + (p + q)x + pq = (x + p)(x + q).",
            "Splitting middle term: To factorise ax² + bx + c, find two numbers whose product is a × c and sum is b.",
            "Always check for a common monomial factor first before applying quadratic or identity methods."
        ],
        "exampleQuestion": "Factorise the quadratic expression: x² + 7x + 12",
        "exampleExplanation": "Find two numbers with sum = 7 and product = 12: numbers are 3 and 4 (3+4=7, 3×4=12). Factorisation = (x + 3)(x + 4).",
        "exampleAnswer": "(x + 3)(x + 4)",
        "funFact": "Modern computer algebra systems like Wolfram Alpha factorise polynomials with thousands of terms in milliseconds!",
        "mascotAdvice": "Look for two numbers that multiply to give the last number and add to give the middle number!"
    },
    {
        "board": "icse", "grade": "Class 8", "chapterNumber": 9,
        "title": "Linear Equations & Simultaneous Equations", "icon": "⚖️",
        "description": "Linear equations in one variable, eliminating denominators, and solving simultaneous linear equations by substitution & elimination.",
        "keyConcepts": ["Linear Equations with Fractional Coefficients", "Simultaneous Linear Equations in Two Variables (x and y)", "Method of Elimination by Equating Coefficients", "Method of Substitution"],
        "rules": [
            "Simultaneous equations have two linear equations with two unknowns (x and y) that are satisfied together.",
            "Elimination Method: Multiply equations to make coefficients of one variable equal, then add or subtract to eliminate it.",
            "Substitution Method: Express one variable in terms of the other from equation 1, then substitute into equation 2.",
            "Always substitute both found values back into both original equations to verify."
        ],
        "exampleQuestion": "Solve the simultaneous equations: x + y = 10 and x - y = 4",
        "exampleExplanation": "Add both equations: (x + y) + (x - y) = 10 + 4 -> 2x = 14 -> x = 7. Substitute into first equation: 7 + y = 10 -> y = 3.",
        "exampleAnswer": "x = 7, y = 3",
        "funFact": "GPS satellites solve simultaneous equations of signal travel times from at least 4 satellites to pinpoint your exact coordinates on Earth!",
        "mascotAdvice": "If coefficients are already equal (like +y and -y), just ADD the equations together to eliminate y immediately!"
    },
    {
        "board": "icse", "grade": "Class 8", "chapterNumber": 10,
        "title": "Linear Inequations in One Variable", "icon": "📈",
        "description": "Solving linear inequations in one variable, replacement sets, truth sets (solution sets), and number line graphs.",
        "keyConcepts": ["Inequality Symbols (<, ≤, >, ≥)", "Replacement Set & Solution Set", "Number Line Graphing (Open vs Solid Circles)", "Reversing Inequality on Negative Multiplication/Division"],
        "rules": [
            "If ax < b and a is negative, dividing by a reverses the sign: x > b/a.",
            "Replacement set is the set from which values of variable x are chosen (e.g. Natural numbers N, Whole numbers W, Integers Z, Real numbers R).",
            "On a number line: Strict inequalities (<, >) use an open circle ⭕; inclusive (≤, ≥) use a solid filled circle ⬤."
        ],
        "exampleQuestion": "Solve: 3x - 2 ≤ 10, where x ∈ N (Natural numbers)",
        "exampleExplanation": "3x ≤ 10 + 2 -> 3x ≤ 12 -> x ≤ 4. Since x is a Natural number (N = {1, 2, 3...}), the solution set is {1, 2, 3, 4}.",
        "exampleAnswer": "{1, 2, 3, 4}",
        "funFact": "Elevator weight alarms are programmed using linear inequations: Total Passenger Weight ≤ 800 kg!",
        "mascotAdvice": "Always check the replacement set (N, W, or Z): natural numbers cannot include 0 or negative numbers!"
    },
    {
        "board": "icse", "grade": "Class 8", "chapterNumber": 11,
        "title": "Geometry: Quadrilaterals & Circles", "icon": "🔷",
        "description": "Angle sum of quadrilateral (360°), properties of parallelogram, rectangle, rhombus, square, kite, and circle theorems.",
        "keyConcepts": ["Angle Sum of Quadrilateral = 360°", "Properties of Parallelogram Diagonals", "Rhombus: Diagonals Bisect at Right Angles (90°)", "Circle: Chord Properties & Tangent Introduction"],
        "rules": [
            "The sum of the four interior angles of ANY quadrilateral is ALWAYS 360°.",
            "In a parallelogram: Opposite sides are equal, opposite angles are equal, diagonals bisect each other.",
            "In a rhombus: All sides are equal, diagonals bisect each other perpendicularly at 90°.",
            "A perpendicular from the center of a circle to a chord BISECTS the chord."
        ],
        "exampleQuestion": "Three angles of a quadrilateral are 80°, 90°, and 110°. What is the measure of the fourth angle?",
        "exampleExplanation": "Sum of angles = 360°. Fourth angle = 360° - (80° + 90° + 110°) = 360° - 280° = 80°.",
        "exampleAnswer": "80°",
        "funFact": "Kite geometry is used in aerospace engineering: delta-wing fighter jets are engineered around symmetric quadrilateral shapes!",
        "mascotAdvice": "Remember: Rhombus diagonals ALWAYS meet at a sharp 90° right angle in the center!"
    },
    {
        "board": "icse", "grade": "Class 8", "chapterNumber": 12,
        "title": "Mensuration: Surface Area & Volume", "icon": "📦",
        "description": "Area of trapezium and general polygons, surface area and volume of cube, cuboid, and right circular cylinder.",
        "keyConcepts": ["Area of Trapezium = ½(a + b)h", "Surface Area: Cube = 6a², Cuboid = 2(lb+bh+hl)", "Cylinder: Curved Surface Area (CSA) = 2πrh, Total (TSA) = 2πr(r+h)", "Volume of Cylinder = πr²h", "Capacity Conversions: 1 L = 1,000 cm³"],
        "rules": [
            "Area of Trapezium = ½ × (Sum of parallel sides) × Distance between them = ½(a + b)h.",
            "Right Circular Cylinder: CSA = 2πrh; TSA = 2πr(r + h); Volume = πr²h.",
            "Volume of Cube = a³; Volume of Cuboid = l × b × h.",
            "1 liter = 1,000 cm³; 1 m³ = 1,000 liters."
        ],
        "exampleQuestion": "Find the total surface area (TSA) of a solid cylinder having radius 7 cm and height 10 cm (use π = 22/7):",
        "exampleExplanation": "TSA = 2πr(r + h) = 2 × (22/7) × 7 × (7 + 10) = 44 × 17 = 748 cm².",
        "exampleAnswer": "748 cm²",
        "funFact": "Aluminum soda cans are cylinders designed to maximize volume while minimizing aluminum metal surface area!",
        "mascotAdvice": "Curved surface area (CSA) is just the round label around the can; Total surface area (TSA) includes the top and bottom lids!"
    },
    {
        "board": "icse", "grade": "Class 8", "chapterNumber": 13,
        "title": "Coordinate Geometry & Linear Graphs", "icon": "📈",
        "description": "Cartesian coordinate axes, plotting points (x, y), quadrants I, II, III, IV, linear graphs, and slope/gradient basics.",
        "keyConcepts": ["Cartesian Axes (X-axis, Y-axis, Origin (0, 0))", "Abscissa (x) and Ordinate (y)", "Four Quadrants Signs: I(+,+), II(-,+), III(-,-), IV(+,-)", "Plotting Linear Graphs (Straight Lines)", "Interpreting Real-Life Trend Graphs"],
        "rules": [
            "Origin has coordinates (0, 0).",
            "Signs in Quadrants: Quadrant I (+, +), Quadrant II (-, +), Quadrant III (-, -), Quadrant IV (+, -).",
            "Any point on the X-axis has y = 0, written as (x, 0). Any point on the Y-axis has x = 0, written as (0, y).",
            "The equation of the X-axis is y = 0; the equation of the Y-axis is x = 0.",
            "Graph of y = mx + c is a straight line where m is the slope and c is the y-intercept."
        ],
        "exampleQuestion": "In which quadrant of the Cartesian plane does the point (-4, 7) lie?",
        "exampleExplanation": "The x-coordinate is negative (-4) and the y-coordinate is positive (+7): this is Quadrant II.",
        "exampleAnswer": "Quadrant II",
        "funFact": "Air traffic controllers monitor airplane flight paths using 3D Cartesian coordinates (x, y, and altitude z) in real time!",
        "mascotAdvice": "Remember: Quadrant I is top-right (+,+), Quadrant II is top-left (-,+), Quadrant III is bottom-left (-,-), Quadrant IV is bottom-right (+,-)!"
    },
    {
        "board": "icse", "grade": "Class 8", "chapterNumber": 14,
        "title": "Statistics: Grouped Data & Histograms", "icon": "📊",
        "description": "Grouped frequency distributions, class intervals, inclusive vs exclusive form, histograms, frequency polygons, and mean.",
        "keyConcepts": ["Continuous vs Discrete Class Intervals", "Class Mark (Mid-Value) = (Lower + Upper) / 2", "Drawing Histograms without Gaps", "Frequency Polygons", "Calculating Mean of Grouped Data (Direct Method: Σfx / Σf)"],
        "rules": [
            "Class Mark = (Upper class limit + Lower class limit) ÷ 2.",
            "Class Size (Width) = Upper class limit - Lower class limit.",
            "In histograms, the width of each bar equals the class interval and bars are drawn touching with NO gaps.",
            "Direct Method for Mean of grouped data: Mean = Σ(f × x) ÷ Σf, where x is the class mark and f is the frequency."
        ],
        "exampleQuestion": "What is the Class Mark (mid-point) of the class interval 20 - 30?",
        "exampleExplanation": "Class Mark = (Lower Limit + Upper Limit) ÷ 2 = (20 + 30) ÷ 2 = 50 ÷ 2 = 25.",
        "exampleAnswer": "25",
        "funFact": "Medical clinical trials use histograms and frequency distributions to measure the effectiveness of new vaccines!",
        "mascotAdvice": "Mid-point (class mark) is right in the middle: add the two limits and divide by 2!"
    },
    {
        "board": "icse", "grade": "Class 8", "chapterNumber": 15,
        "title": "Probability", "icon": "🎲",
        "description": "Random experiments, sample space, events, empirical vs theoretical probability, complementary events P(not E).",
        "keyConcepts": ["Sample Space S (All Possible Outcomes)", "Event E (Subset of Sample Space)", "Theoretical Probability P(E) = n(E) / n(S)", "Complementary Event: P(E) + P(not E) = 1", "Sure Event (P=1) and Impossible Event (P=0)"],
        "rules": [
            "Probability Formula: P(E) = (Number of favourable outcomes) ÷ (Total number of possible outcomes) = n(E) / n(S).",
            "Probability of any event is always between 0 and 1 inclusive: 0 ≤ P(E) ≤ 1.",
            "Probability of an impossible event is 0; Probability of a sure event is 1.",
            "Complementary events: P(E) + P(not E) = 1, so P(not E) = 1 - P(E)."
        ],
        "exampleQuestion": "A bag contains 5 red balls and 3 green balls. One ball is drawn at random. What is the probability that it is GREEN?",
        "exampleExplanation": "Total balls in sample space = 5 + 3 = 8. Favourable green balls = 3. P(Green) = 3/8.",
        "exampleAnswer": "3/8",
        "funFact": "Quantum mechanics tells us that subatomic particles like electrons don't exist at fixed points, but rather as probability clouds described by wavefunctions!",
        "mascotAdvice": "P(happening) + P(not happening) = 1. If chance of rain is 0.3, chance of NO rain is 1 - 0.3 = 0.7!"
    }
]
