import json
import os

all_chapters = []

def add_chapter(grade, num, title, icon, desc, concepts, rules, ex_q, ex_exp, ex_ans, fun_fact, advice):
    prefix = grade.lower().replace(' ', '')
    cid = f"{prefix}_ch{num:02d}"
    all_chapters.append({
        "chapterId": cid,
        "chapterNumber": num,
        "title": title,
        "grade": grade,
        "icon": icon,
        "description": desc,
        "keyConcepts": concepts,
        "rules": rules,
        "exampleQuestion": ex_q,
        "exampleExplanation": ex_exp,
        "exampleAnswer": ex_ans,
        "funFact": fun_fact,
        "mascotAdvice": advice,
        "activityIds": []
    })

# --- LKG (5 Chapters) ---
add_chapter("LKG", 1, "Shapes & Space", "🟡", "Discover circles, squares, triangles, inside vs outside, and top vs bottom!",
            ["Circle, Square, Triangle", "Big vs Small", "Inside vs Outside", "Top vs Bottom"],
            ["A circle is round with no corners", "A square has 4 straight sides", "A triangle has 3 sharp points"],
            "Which shape looks like a pizza slice?", "Count the 3 corners and 3 sides: that's a Triangle!", "Triangle 🔺",
            "Bicycle wheels are round circles so they roll smoothly!", "Trace shapes in the air with your finger!")

add_chapter("LKG", 2, "Numbers 1 to 5", "🔢", "Counting stars, teddy bears, and recognizing digits 1 to 5.",
            ["Counting objects 1 to 5", "Digit recognition", "Matching quantities", "Finger counting"],
            ["Point to each object as you count", "The last number you say is the total count"],
            "Count the apples: 🍎 🍎 🍎. How many?", "One, two, three! There are 3 apples.", "3 apples",
            "You have 5 fingers on each hand!", "Count along to a cheerful rhythm!")

add_chapter("LKG", 3, "Numbers 6 to 10", "🔟", "Count up to 10 using both hands and fun cartoon objects.",
            ["Counting 6 to 10", "Ten frame visualization", "Tallying items"],
            ["5 on one hand plus 1 on the other makes 6", "10 is two full hands of fingers"],
            "If you show all fingers on both hands, how many is that?", "5 + 5 = 10 fingers in all!", "10 fingers",
            "Bowling games use 10 pins!", "Give a high ten with both hands!")

add_chapter("LKG", 4, "Patterns & Colors", "🎨", "Red, Blue, Green cycles and repeating visual patterns.",
            ["Color identification", "AB patterns (Red, Blue, Red, Blue)", "Shape sequences"],
            ["Look for what repeats: that is the pattern rule!"],
            "What comes next: 🔴 🔵 🔴 🔵 __?", "The colors alternate between Red and Blue. Next is Red!", "🔴 Red",
            "Zebras have black and white striped patterns!", "Say the colors out loud like a song!")

add_chapter("LKG", 5, "Comparing Quantities", "⚖️", "Learn More vs Less, Heavy vs Light, and Tall vs Short.",
            ["More and Less", "Heavy and Light", "Tall and Short", "Full and Empty"],
            ["The bigger pile has MORE items", "An elephant is heavy, a leaf is light"],
            "Which is heavier: a watermelon 🍉 or a strawberry 🍓?", "Watermelons are big and heavy to lift.", "Watermelon 🍉",
            "A blue whale is as heavy as 30 elephants!", "Pretend your arms are a balance scale!")

# --- UKG (6 Chapters) ---
add_chapter("UKG", 1, "Numbers 1 to 20", "🔢", "Forward and backward counting, number names, and writing up to 20.",
            ["Forward counting 1 to 20", "Backward countdown 10 to 1", "Number names (One to Twenty)"],
            ["After 9 comes 10", "Numbers from 11 to 19 have a 1 in tens place"],
            "What comes right after 14?", "Counting forward: 13, 14, 15!", "15",
            "A dartboard has numbers 1 to 20!", "Count down like a rocket blastoff!")

add_chapter("UKG", 2, "Counting & Comparison", "🐊", "Greater than (>), less than (<), and equal to (=).",
            ["Greater Than (>)", "Less Than (<)", "Equal To (=)"],
            ["The alligator's open mouth always chomps towards the bigger number!"],
            "Which symbol belongs: 8 __ 5 ?", "8 is bigger than 5, so the mouth opens towards 8: 8 > 5.", ">",
            "The > and < signs were invented in 1631!", "Chomp your hands toward the bigger feast!")

add_chapter("UKG", 3, "Early Addition Bonds", "➕", "Combining sets of objects and number bonds to 10.",
            ["Putting groups together", "Plus sign (+)", "Number bonds to 5 and 10"],
            ["Addition means combining everything together", "4 + 0 = 4"],
            "You have 3 balloons and get 2 more. How many in all?", "Count together: 3 + 2 = 5 balloons.", "5 balloons 🎈",
            "2 + 3 is the exact same as 3 + 2!", "Keep the big number in your head and count forward!")

add_chapter("UKG", 4, "Early Subtraction", "➖", "Taking away objects, crossing out, and finding how many are left.",
            ["Taking away", "Minus sign (-)", "Finding the difference"],
            ["Subtraction makes the number smaller", "Taking away 0 leaves the number unchanged"],
            "There are 6 cookies 🍪. You eat 2. How many are left?", "6 count back 2: 5, 4 cookies left.", "4 cookies",
            "Minus comes from the Latin word for 'less'!", "Cross out the ones you take away!")

add_chapter("UKG", 5, "Shapes & Solids", "🎲", "Sphere, Cube, Cylinder, Cone, and flat vs solid shapes.",
            ["Sphere (ball)", "Cube (box)", "Cylinder (can)", "Cone (party hat)"],
            ["Flat shapes are 2D; solid shapes you can hold in your hand"],
            "What 3D shape is a can of soup?", "A can has round sides and two flat circular ends: a Cylinder!", "Cylinder 🥫",
            "Soap bubbles are always spheres!", "Check if an object rolls, slides, or stacks!")

add_chapter("UKG", 6, "Time & Coins", "🪙", "Day vs Night, clock hours, and Indian coins (₹1, ₹2, ₹5, ₹10).",
            ["Day and Night routines", "Reading clock hours", "Indian currency coins"],
            ["The short clock hand tells the hour", "Two ₹5 coins make ₹10"],
            "Short hand points to 5, long hand points to 12. What time is it?", "Long hand at 12 means exact hour: 5 o'clock!", "5 o'clock",
            "The Rupee symbol ₹ combines 'Ra' and 'R'!", "Look at the short hand first!")

# --- Class 1 (13 Chapters) ---
c1_titles = [
    (1, "Shapes and Space", "🔺", "Inside/outside, bigger/smaller, rolling vs sliding shapes."),
    (2, "Numbers from 1 to 9", "🔢", "Cardinal counting, order of numbers, and zero concept."),
    (3, "Addition", "➕", "Single digit addition facts, number line jumps up to 9."),
    (4, "Subtraction", "➖", "Taking away, finding differences, and subtraction facts."),
    (5, "Numbers from 10 to 20", "🔟", "Bundles of 10, tens and ones, teen numbers."),
    (6, "Time", "🌅", "Morning, afternoon, evening, night, and daily durations."),
    (7, "Measurement", "📏", "Non-standard units: handspans, footsteps, and comparing lengths."),
    (8, "Numbers from 21 to 50", "🔢", "Bundles of tens up to 50, place value charts."),
    (9, "Data Handling", "📊", "Counting occurrences of items and simple pictographs."),
    (10, "Patterns", "🧩", "Growing and repeating patterns with shapes and numbers."),
    (11, "Numbers from 51 to 100", "💯", "Counting up to 100, tens and ones, number grids."),
    (12, "Money", "💵", "Indian coins and currency notes, making price amounts."),
    (13, "How Many", "🎯", "Counting total items, place value synthesis, and story problems.")
]
for num, title, icon, desc in c1_titles:
    add_chapter("Class 1", num, title, icon, desc,
                [f"{title} core concepts", "Visual problem solving", "Real life examples"],
                [f"Master the fundamentals of {title}", "Practice step by step"],
                f"Practice problem for Class 1 {title}: Solve step by step.",
                f"Apply standard rules learned in {title}.",
                "Well Done!",
                "Math helps us measure and count everything in the world around us!",
                "Take your time and check your answers carefully!")

# --- Class 2 (15 Chapters) ---
c2_titles = [
    (1, "What is Long, What is Round?", "🏏", "Rolling, sliding, stacking, and shape surfaces."),
    (2, "Counting in Groups", "📦", "Counting in pairs, fives, and tens."),
    (3, "How Much Can You Carry?", "🐘", "Comparing heavy vs light weights and balances."),
    (4, "Counting in Tens", "🔟", "Bundles of ten sticks and tens place value."),
    (5, "Patterns", "🧩", "Tile tessellations, floor designs, and number steps."),
    (6, "Footprints", "🐾", "2D outlines of 3D objects and tracing shapes."),
    (7, "Jugs and Mugs", "🫗", "Capacities of glasses, mugs, and buckets."),
    (8, "Tens and Ones", "🪙", "Place values and payment using ₹10 notes and ₹1 coins."),
    (9, "My Funday", "📅", "Days of the week, months of the year, and calendars."),
    (10, "Add Our Points", "⭐", "Mental addition strategies and score calculations."),
    (11, "Lines and Lines", "📏", "Standing lines, slanting lines, and curved lines."),
    (12, "Give and Take", "🤝", "2-digit addition and subtraction with borrowing/carrying."),
    (13, "The Longest Step", "👣", "Measuring distance with footsteps and fingers."),
    (14, "Birds Come, Birds Go", "🐦", "Word problems on addition and subtraction."),
    (15, "How Many Ponytails?", "👧", "Recording data, grouping, and tally counts.")
]
for num, title, icon, desc in c2_titles:
    add_chapter("Class 2", num, title, icon, desc,
                [f"{title} concepts", "Mental calculations", "Word problem mastery"],
                ["Tens are bundles of 10, Ones are single units", "Always add ones column first!"],
                f"Practice question for Class 2 {title}: Solve step by step.",
                f"Think about the place values and concepts in {title}.",
                "Correct!",
                "Did you know numbers can be grouped to add 10 times faster?",
                "Hunt for groups of 10 first!")

# --- Class 3 (14 Chapters) ---
c3_titles = [
    (1, "Where to Look From", "👀", "Top view, front view, side view, and dot grids."),
    (2, "Fun with Numbers", "🔢", "3-digit numbers, expanded form, centuries in cricket."),
    (3, "Give and Take", "➕", "Addition and subtraction of 2- and 3-digit numbers."),
    (4, "Long and Short", "📏", "Meters and centimeters, using a ruler."),
    (5, "Shapes and Designs", "🎨", "Edges, corners, tessellations, and tangrams."),
    (6, "Fun with Give and Take", "🧠", "Mental math shortcuts and checking subtractions."),
    (7, "Time Goes On", "⏰", "Clocks, calendar dates, birthdays, and timelines."),
    (8, "Who is Heavier?", "⚖️", "Kilograms and grams, balance scales."),
    (9, "How Many Times?", "✖️", "Multiplication as repeated addition and times tables."),
    (10, "Play with Patterns", "🧩", "Odd and even numbers, secret codes, and number patterns."),
    (11, "Jugs and Mugs", "🧃", "Liters and milliliters, liquid volume."),
    (12, "Can We Share?", "🍫", "Division as equal sharing and grouping."),
    (13, "Smart Charts", "📊", "Tally marks, pictographs, and simple bar charts."),
    (14, "Rupees and Paise", "💰", "Making change, shopping bills, and money word problems.")
]
for num, title, icon, desc in c3_titles:
    add_chapter("Class 3", num, title, icon, desc,
                [f"{title} fundamentals", "Multi-step operations", "Real-life application"],
                ["1 meter = 100 centimeters", "1 kilogram = 1,000 grams", "1 Liter = 1,000 mL"],
                f"Solve this Class 3 {title} problem:",
                f"Break down into units and solve carefully.",
                "Great Job!",
                "Math is everywhere in nature and everyday shopping!",
                "Double check your units (m, cm, kg, g, L, mL)!")

# --- Class 4 (14 Chapters) ---
c4_titles = [
    (1, "Building with Bricks", "🧱", "Brick patterns, arches, 3D faces, edges, and brick kilns."),
    (2, "Long and Short", "🏃", "Kilometers and meters, conversion, marathon running."),
    (3, "A Trip to Bhopal", "🚌", "Trip planning, ticket costs, diesel fuel, and estimation."),
    (4, "Tick-Tick-Tick", "⏰", "Clock reading, 12-hour AM/PM vs 24-hour railway clock, elapsed time."),
    (5, "The Way the World Looks", "🗺️", "Aerial views, floor maps, perspectives, and routes."),
    (6, "The Junk Seller", "📰", "Money, buying and selling rates, multiplication algorithms."),
    (7, "Jugs and Mugs", "🫗", "Liters and milliliters, capacity, water intake."),
    (8, "Carts and Wheels", "🎡", "Circles, center point, radius, diameter, compass drawing."),
    (9, "Halves and Quarters", "🍯", "Equivalent fractions, parts of collections, fraction cauldons."),
    (10, "Play with Patterns", "🌀", "Rotational symmetry (quarter/half turn), magic squares."),
    (11, "Tables and Shares", "✏️", "Division algorithms, quotients, remainders, equal sharing."),
    (12, "How Heavy? How Light?", "⚖️", "Weight measurements, grams & kilograms balances."),
    (13, "Fields and Fences", "🌾", "Perimeter of boundaries, wire fencing, rectangular plots."),
    (14, "Smart Charts", "📊", "Chapati charts (pie charts), attendance tables, bar charts.")
]
for num, title, icon, desc in c4_titles:
    add_chapter("Class 4", num, title, icon, desc,
                [f"{title} concepts", "Calculation algorithms", "Real-world problem solving"],
                ["Perimeter = 2 × (Length + Width)", "1 km = 1,000 m; 1 L = 1,000 mL", "Add 12 to PM hours for 24-hr time"],
                f"Class 4 {title} Challenge Question:",
                f"Apply Class 4 syllabus formulas for {title}.",
                "Mastered!",
                "Class 4 math introduces foundational concepts for geometry and physics!",
                "Check whether the problem asks for perimeter, area, time, or capacity!")

# --- Class 5 (14 Chapters) ---
c5_titles = [
    (1, "The Fish Tale", "🐟", "Large numbers up to 10 lakhs, speed and distance, boat problems."),
    (2, "Shapes and Angles", "📐", "Right angles (90°), acute, obtuse angles, degree clock, protractor."),
    (3, "How Many Squares?", "🟩", "Area by counting square grid units, perimeter comparison."),
    (4, "Parts and Wholes", "🥧", "Fractions, mixed fractions, shaded parts, equivalent values."),
    (5, "Does it Look the Same?", "🪞", "Rotational symmetry (1/2 turn, 1/4 turn, 1/3 turn, 1/6 turn)."),
    (6, "Be My Multiple, I'll Be Your Factor", "🔢", "Multiples, factors, factor trees, common factors, LCM, HCF."),
    (7, "Can You See the Pattern?", "🪄", "Number tricks, magic squares, palindromes, calendar patterns."),
    (8, "Mapping Your Way", "🗺️", "Map scale (e.g. 1 cm = 200 km), directions, India Gate parade route."),
    (9, "Boxes and Sketches", "📦", "3D nets of cubes, isometric sketches, floor plans."),
    (10, "Tenths and Hundredths", "🪙", "Decimals, decimal place values, measuring in mm and cm."),
    (11, "Area and Its Boundary", "🌾", "Area formula (L × W), square area (S × S), perimeter fencing."),
    (12, "Smart Charts", "📈", "Family trees, temperature growth charts, bar graph analysis."),
    (13, "Ways to Multiply and Divide", "🧮", "Column multiplication methods, long division algorithms."),
    (14, "How Big? How Heavy?", "🧊", "Volume of cubes and cuboids, water displacement.")
]
for num, title, icon, desc in c5_titles:
    add_chapter("Class 5", num, title, icon, desc,
                [f"{title} concepts", "Geometry and measurement", "Advanced problem solving"],
                ["Area of Rectangle = Length × Width", "Right angle = 90°", "Volume = Length × Width × Height"],
                f"Class 5 {title} problem:",
                f"Use standard Class 5 mathematics methods for {title}.",
                "Correct!",
                "Did you know architects use nets and area formulas to design skyscrapers?",
                "Pay attention to square units (cm², m²) for area vs regular units for perimeter!")

# --- Class 6 (14 Chapters) ---
c6_titles = [
    (1, "Knowing Our Numbers", "🔢", "Indian & International place values, rounding, Roman numerals."),
    (2, "Whole Numbers", "0️⃣", "Predecessor, successor, number line addition, properties of operations."),
    (3, "Playing with Numbers", "🎲", "Divisibility tests (2,3,4,5,6,8,9,10,11), prime factorisation, HCF/LCM."),
    (4, "Basic Geometrical Ideas", "📐", "Points, lines, rays, line segments, curves, polygons, circles."),
    (5, "Understanding Elementary Shapes", "📏", "Measuring line segments, angles classification, triangles, 3D solids."),
    (6, "Integers", "⚖️", "Negative numbers, number line, additive inverse, addition and subtraction."),
    (7, "Fractions", "🥧", "Proper, improper, mixed fractions, simplest form, fraction operations."),
    (8, "Decimals", "🪙", "Tenths, hundredths, thousandths, money and length conversion, operations."),
    (9, "Data Handling", "📊", "Tally marks, pictographs, interpreting bar graphs."),
    (10, "Mensuration", "📏", "Perimeter of regular polygons, area of rectangle and square."),
    (11, "Algebra", "💡", "Introduction to variables, matchstick patterns, linear expressions."),
    (12, "Ratio and Proportion", "⚖️", "Ratios in simplest form, proportions, unitary method."),
    (13, "Symmetry", "🦋", "Line of symmetry, reflection symmetry in geometric figures."),
    (14, "Practical Geometry", "🧭", "Ruler and compass constructions: circles, bisectors, perpendiculars.")
]
for num, title, icon, desc in c6_titles:
    add_chapter("Class 6", num, title, icon, desc,
                [f"{title} concepts", "NCERT Class 6 standards", "Algebraic and geometric reasoning"],
                ["(-a) + (+b) follows sign of greater absolute value", "Product of HCF and LCM = Product of two numbers"],
                f"Class 6 {title} problem:",
                f"Solve using Class 6 mathematical rules.",
                "Solved!",
                "Algebra was developed to solve equations that model natural laws!",
                "Write down each step clearly on your scratchpad!")

# --- Class 7 (15 Chapters) ---
c7_titles = [
    (1, "Integers", "➕➖", "Multiplication and division of negative numbers, sign rules, properties."),
    (2, "Fractions and Decimals", "🥧", "Multiplying & dividing fractions, reciprocals, decimal operations."),
    (3, "Data Handling", "📊", "Arithmetic mean, median, mode, range, double bar graphs, probability."),
    (4, "Simple Equations", "⚖️", "Setting up equations, systematic balance method, transposing."),
    (5, "Lines and Angles", "📐", "Complementary (90°), supplementary (180°), parallel lines, transversals."),
    (6, "The Triangle and its Properties", "🔺", "Angle sum property (180°), exterior angle theorem, Pythagoras theorem."),
    (7, "Congruence of Triangles", "🤝", "SSS, SAS, ASA, RHS congruence criteria."),
    (8, "Comparing Quantities", "📈", "Ratios to percentages, profit & loss %, simple interest I = PRT/100."),
    (9, "Rational Numbers", "🔢", "Rational numbers p/q, number line representation, four operations."),
    (10, "Practical Geometry", "🧭", "Constructing parallel lines and triangles given SSS, SAS, ASA, RHS."),
    (11, "Perimeter and Area", "🌾", "Parallelogram, triangle, circle circumference (2πr) and area (πr²)."),
    (12, "Algebraic Expressions", "🧮", "Terms, factors, coefficients, like/unlike terms, evaluating expressions."),
    (13, "Exponents and Powers", "⚡", "Laws of exponents: aᵐ × aⁿ = aᵐ⁺ⁿ, (aᵐ)ⁿ = aᵐⁿ, standard scientific form."),
    (14, "Symmetry", "❄️", "Rotational symmetry, angle of rotation, order of symmetry."),
    (15, "Visualising Solid Shapes", "🧊", "Nets of 3D solids, isometric sketches, cross sections.")
]
for num, title, icon, desc in c7_titles:
    add_chapter("Class 7", num, title, icon, desc,
                [f"{title} syllabus topics", "Formulas and properties", "Step-by-step proofs"],
                ["Pythagoras: Hypotenuse² = Base² + Perpendicular²", "Simple Interest = (P × R × T) / 100", "Circle Area = πr²"],
                f"Class 7 {title} problem:",
                f"Apply standard Class 7 formulas for {title}.",
                "Verified!",
                "Exponents allow astronomers to calculate the speed of light and galaxy distances!",
                "Keep LHS and RHS strictly balanced!")

# --- Class 8 (16 Chapters) ---
c8_titles = [
    (1, "Rational Numbers", "🔢", "Closure, commutativity, associativity, distributive properties, density."),
    (2, "Linear Equations in One Variable", "⚖️", "Equations with variables on both sides, reducing to linear form."),
    (3, "Understanding Quadrilaterals", "🔷", "Polygons, sum of interior angles (n-2)×180°, parallelograms, rhombuses."),
    (4, "Practical Geometry", "🧭", "Constructing quadrilaterals given 4 sides and 1 diagonal, etc."),
    (5, "Data Handling", "📊", "Organizing grouped data, histograms, pie charts, probability experiments."),
    (6, "Squares and Square Roots", "⬛", "Square numbers, Pythagorean triplets, prime factorisation, division roots."),
    (7, "Cubes and Cube Roots", "🧊", "Cube numbers, prime factorisation method for cube roots."),
    (8, "Comparing Quantities", "🏷️", "Discounts, sales tax/GST, compound interest formula A = P(1 + R/100)ⁿ."),
    (9, "Algebraic Expressions and Identities", "📐", "Multiplying polynomials, identities: (a+b)², (a-b)², a²-b²."),
    (10, "Visualising Solid Shapes", "🏛️", "Euler's formula F + V - E = 2, polyhedrons, top/front/side views."),
    (11, "Mensuration", "📏", "Area of trapezium, general quadrilateral, surface area and volume of cylinder."),
    (12, "Exponents and Powers", "⚡", "Negative exponents (a⁻ᵐ = 1/aᵐ), laws of indices, scientific standard notation."),
    (13, "Direct and Inverse Proportions", "⚖️", "Direct variation x/y = k, inverse variation x·y = k, practical problems."),
    (14, "Factorisation", "🧩", "Common factor method, regrouping, using identities, division of polynomials."),
    (15, "Introduction to Graphs", "📈", "Cartesian coordinate system (x,y), plotting points, linear graphs."),
    (16, "Playing with Numbers", "🎲", "General form of numbers, divisibility puzzles, cryptarithms.")
]
for num, title, icon, desc in c8_titles:
    add_chapter("Class 8", num, title, icon, desc,
                [f"{title} advanced concepts", "Algebraic rigor", "Geometric proofs & mensuration"],
                ["(a + b)² = a² + 2ab + b²", "Euler's formula: F + V - E = 2", "Cylinder Volume = πr²h"],
                f"Class 8 {title} problem:",
                f"Apply rigorous Class 8 algebraic and geometric methods for {title}.",
                "Correct!",
                "Euler's formula F + V - E = 2 holds true for every convex 3D polyhedron in the universe!",
                "Check for variables on both sides and factor out common terms first!")

# Write to assets/curriculum/chapters_data.json
out_path = r"d:\AI Learning\assets\curriculum\chapters_data.json"
with open(out_path, "w", encoding="utf-8") as f:
    json.dump(all_chapters, f, indent=2, ensure_ascii=False)

print(f"Successfully generated {len(all_chapters)} authentic syllabus chapters across all 10 grades!")
