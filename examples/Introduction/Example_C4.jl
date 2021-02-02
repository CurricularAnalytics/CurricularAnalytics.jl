## Curriculum assoicated with curricula c1, page 9, Heileman, G. L., Slim, A., Hickman, M.,  and Abdallah, C. T. (2018). 
##Curricular Analytics: A Framework for Quantifying the Impact of Curricular Reforms and Pedagogical Innovations 
##https://arxiv.org/pdf/1811.09676.pdf

using CurricularAnalytics

# # create learning outcomes
l = Array{LearningOutcome}(undef, 39)
l[1] = LearningOutcome("MA_LO1","Use derivatives to analyze and graph algebraic and transcendental functions",3)
l[2] = LearningOutcome("MA_LO2","Select and apply models and differentiation techniques to applications involving, but not limited to, optimization and related rates",3)
l[3] = LearningOutcome("MA_LO3","Apply the Fundamental Theorem of Calculus to evaluate integrals",3)
l[4] = LearningOutcome("MA_LO4","Use estimation techniques to approximate rates of change, area, and total change",3)
l[5] = LearningOutcome("MA_LO5","techniques of analytical and numerical integration",3)
l[6] = LearningOutcome("MA_LO6","apply the definite integral to problems arising in geometry and in either physics or probability",3)
l[7] = LearningOutcome("MA_LO7","work with the concept of infinite series and be able to calculate and use Taylor series",3)
l[8] = LearningOutcome("MA_LO8","analyze first order differential equations from a graphical and algebraic point of view and model physical and biological situations by differential equations",3)
l[9] = LearningOutcome("MA_LO9","Recognize and sketch surfaces in three-dimensional space",3)
l[10] = LearningOutcome("MA_LO10","Recognize and apply the algebraic and geometric properties of vectors and vector functions in two and three dimensions",3)
l[11] = LearningOutcome("MA_LO11","Compute dot products and cross products and interpret their geometric meaning",3)
l[12] = LearningOutcome("MA_LO12","Compute partial derivatives of functions of several variables and explain their meaning",3)
l[13] = LearningOutcome("MA_LO13","Compute directional derivatives and gradients of scalar functions and explain their meaning",3)
l[14] = LearningOutcome("MA_LO14","Compute and classify the critical points",3)
l[15] = LearningOutcome("MA_LO15","Parameterize curves in 2- and 3-space",3)
l[16] = LearningOutcome("MA_LO16","Set up and evaluate double and triple integrals using a variety of coordinate systems",3)
l[17] = LearningOutcome("MA_LO17","Evaluate integrals through scalar or vector fields and explain some physical interpretation of these integrals",3)
l[18] = LearningOutcome("MA_LO18","Recognize and apply Fundamental theorem of line integrals, Green’s theorem, Divergence Theorem, and Stokes’ theorem",3)
l[19] = LearningOutcome("MA_LO19","Recognize the proper technique and solve initial value problems for first order equations",3)
l[20] = LearningOutcome("MA_LO20","Solve initial value problems for higher order linear homogeneous and inhomogeneous equations",3)
l[21] = LearningOutcome("MA_LO21","Solve linear homogeneous systems using eigenvalues and eigenvectors",3)
l[22] = LearningOutcome("MA_LO22","Use Laplace Transforms to solve first and second order linear equations and linear systems",3)
l[23] = LearningOutcome("MA_LO23","Solve linear, variable coefficient equations using infinite series",3)
l[24] = LearningOutcome("PH_LO1","Recognize the vocabulary and units of mechanics",3)
l[25] = LearningOutcome("PH_LO2","Understand the concepts, laws, and principles used in mechanics and generate associations between the concepts and laws. Apply concepts and laws to both qualitative and quantitative problems",3)
l[26] = LearningOutcome("PH_LO3","Work cooperatively within a group on problem solving",3)
l[27] = LearningOutcome("PH_LO4","Use fundamental physical principles to understand how everyday objects work",3)
l[28] = LearningOutcome("PH_LO5","Understand Coulomb’s and Gauss’ Laws",3)
l[29] = LearningOutcome("PH_LO6","Basic understanding of electric fields and potentials, electrical and magnetic properties of matter",3)
l[30] = LearningOutcome("PH_LO7","Use of Ampere’s and Faraday’s Laws to understand induced electromotive forces",3)
l[31] = LearningOutcome("PH_LO8","Ability to analyze elementary DC and AC circuits",3)
l[32] = LearningOutcome("PH_LO9","Understand electromagnetic waves and Maxwell’s equations",3)
l[33] = LearningOutcome("EE_LO1","Understand ideal basic circuit elements, power, and energy",3)
l[34] = LearningOutcome("EE_LO2","Ability to construct basic electrical circuits, and apply Omh’s law and Kirchhoff’s laws",3)
l[35] = LearningOutcome("EE_LO3","Ability to analyze simple resistive circuits, voltage divider circuits, and current-divider circuits",3)
l[36] = LearningOutcome("EE_LO4","Understand various techniques of circuit analysis and Thevenin and Norton equivalent circuits",3)
l[37] = LearningOutcome("EE_LO5","Understand the functions of operational amplifiers, inductors, and capacitors",3)
l[38] = LearningOutcome("EE_LO6","Understand first-order RL and RC circuits, and the natural and step responses of RLC circuits",3)
l[39] = LearningOutcome("EE_LO7","Ability to perform sinusoidal steady-state circuit analysis",3)

# Specify relations among learning_outcomes
add_lo_requisite!(l[1],l[2],pre)
add_lo_requisite!(l[1],l[12],pre)
add_lo_requisite!(l[1],l[19],pre)

add_lo_requisite!(l[2],l[3],pre)
add_lo_requisite!(l[2],l[4],pre)
add_lo_requisite!(l[2],l[25],pre)

add_lo_requisite!(l[3],l[5],pre)

add_lo_requisite!(l[5],l[6],pre)
add_lo_requisite!(l[5],l[16],pre)

add_lo_requisite!(l[6],l[8],pre)

add_lo_requisite!(l[7],l[23],pre)

add_lo_requisite!(l[8],l[19],pre)
add_lo_requisite!(l[8],l[38],pre)

add_lo_requisite!(l[9],l[10],pre)

add_lo_requisite!(l[10],l[11],pre)
add_lo_requisite!(l[10],l[15],pre)

add_lo_requisite!(l[12],l[13],pre)

add_lo_requisite!(l[13],l[14],pre)

add_lo_requisite!(l[16],l[17],pre)

add_lo_requisite!(l[17],l[18],pre)

add_lo_requisite!(l[19],l[20],pre)

add_lo_requisite!(l[20],l[21],pre)

add_lo_requisite!(l[21],l[22],pre)
add_lo_requisite!(l[22],l[23],pre)

add_lo_requisite!(l[24],l[25],pre)

add_lo_requisite!(l[25],l[27],pre)
add_lo_requisite!(l[25],l[28],pre)

add_lo_requisite!(l[21],l[22],pre)
add_lo_requisite!(l[22],l[23],pre)

add_lo_requisite!(l[28],l[29],pre)
add_lo_requisite!(l[29],l[30],pre)
add_lo_requisite!(l[30],l[31],pre)

add_lo_requisite!(l[31],l[32],pre)
add_lo_requisite!(l[31],l[33],pre)

add_lo_requisite!(l[33],l[34],pre)
add_lo_requisite!(l[34],l[35],pre)
add_lo_requisite!(l[35],l[36],pre)

add_lo_requisite!(l[36],l[37],pre)
add_lo_requisite!(l[37],l[38],pre)
add_lo_requisite!(l[38],l[39],pre)


# create the courses
c = Array{Course}(undef, 8)

# term 1
c[1] = Course("Intro Mechanics", 3, prefix = "Physics ", learning_outcomes = [l[24],l[25],l[26],l[27]],num = "141")
c[2] = Course("Calculus I", 3, prefix = "Math ", learning_outcomes = [l[1],l[2],l[3],l[4]],num = "125")

# term 2
c[3] = Course("Intro Electricity and Magnetism", 3, prefix = "Physics", learning_outcomes = [l[28],l[29],l[30],l[31],l[32]],num ="241")
c[4] = Course("Calculus II", 3, prefix = "Math", learning_outcomes = [l[5],l[6],l[7],l[8]], num = "129" )
c[5] = Course("Intro to ODE", 3, prefix = "Math", learning_outcomes = [l[19],l[20],l[21],l[22],l[23]], num = "254" )

# term 3
c[6] = Course("Basic Circuits", 3, prefix = "ECE", learning_outcomes = [l[33],l[34],l[35],l[36],l[37],l[38],l[39]], num = "220")
c[7] = Course("Circuits Theory", 3, prefix = "ECE",  num = "320" )
c[8] = Course("Vector Calculus", 3, prefix = "Math", learning_outcomes = [l[9],l[11],l[12],l[13],l[14],l[15],l[16],l[17],l[18]], num = "223" )

# Specify relations among courses
add_requisite!(c[2],c[1],pre)
add_requisite!(c[2],c[4],pre)
add_requisite!(c[1],c[3],pre)
add_requisite!(c[4],c[3],pre)
add_requisite!(c[4],c[5],pre)
add_requisite!(c[3],c[6],pre)
add_requisite!(c[4],c[8],pre)
add_requisite!(c[5],c[7],pre)
add_requisite!(c[6],c[7],pre)

# Create a curriculum based on previous courses and learning_outcomes
# curric = Curriculum("Example Curricula c4", c)
curric = Curriculum("Example Curricula c4", c, learning_outcomes = l)
print(curric.courses)
# print(curric.learning_outcomes)
# print(curric.graph)
print(curric.lo_graph)

