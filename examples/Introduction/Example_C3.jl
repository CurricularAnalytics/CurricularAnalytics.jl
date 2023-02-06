using CurricularAnalytics
# # create learning outcomes
l = Array{LearningOutcome}(undef, 12)
l[1] = LearningOutcome("Conceptualize engineering problems as computational problems","L1_task",3)
l[2] = LearningOutcome("Design computer programs using modular programming","L2_task",3)
l[3] = LearningOutcome("Understand the basics of data structures","L3_task",3)
l[4] = LearningOutcome("Solve a resistive network that is excited by an AC or a DC source","L4_task",3)
l[5] = LearningOutcome("Solve first-order circuits involving resistors and a capacitor or an inductor","L5_task",3)
l[6] = LearningOutcome("Derive the complex impedance associated with a resistive, inductive and capacitive load","L6_task",3)
l[7] = LearningOutcome("Apply knowledge of mathematics, science and engineering","L7_task",3)
l[8] = LearningOutcome("Design and conduct experiments, as well as analyze and interpret data","L8_task",3)
l[9] = LearningOutcome("Identify, formulate and solve engineering problems","L9_task",3)
l[10] = LearningOutcome("Know how to construct basic gates (inverter, AND, OR) using NMOS and PMOS switches","L10_task",3)
l[11] = LearningOutcome("Know the cause of delays associated with logic gates","L11_task",3)
l[12] = LearningOutcome("Know number representations in different bases, and methods for converting from one base to another","L12_task",3)
# learning_outcomes of course 1
add_lo_requisite!(l[1],l[2],pre)
add_lo_requisite!(l[1],l[3],pre)
# learning_outcomes of course 2
add_lo_requisite!(l[4],l[5],pre)
add_lo_requisite!(l[4],l[6],pre)
# learning_outcomes of course 3
add_lo_requisite!(l[7],l[8],pre)
add_lo_requisite!(l[7],l[9],pre)
# learning_outcomes of course 4
add_lo_requisite!(l[10],l[11],pre)
add_lo_requisite!(l[10],l[12],pre)
# create the courses
c = Array{Course}(undef, 4)
# term 1
c[1] = Course("Computer Programming for Engineering Applications", 3, prefix = "ECE ", learning_outcomes = [l[1],l[2],l[3]],num = "175")
# term 2
c[2] = Course("Elements of Electrical Engineering", 3, prefix = "ECE", learning_outcomes = [l[4],l[5],l[6]],num ="207")
c[3] = Course("Basic Circuits", 3, prefix = "ECE", learning_outcomes = [l[7],l[8],l[9]], num = "220" )
#test1
# term 3
c[4] = Course("Digital Logic", 3, prefix = "ECE", learning_outcomes = [l[10],l[11],l[12]], num = "274A")
# term 1
add_requisite!(c[1],c[2],pre)
add_requisite!(c[1],c[3],pre)
# term 2
add_requisite!(c[2],c[4],pre)
curric = Curriculum("Example Curricula c1", c, learning_outcomes = l)
print(curric.courses)
# print(curric.learning_outcomes)
# print(curric.graph)
# print(curric.lo_graph)
# errors = IOBuffer()
# if is_valid(curric, errors)
#     println("Curriculum $(curric.name) is valid")
#     println("  delay factor = $(delay_factor(curric))")
#     println("  blocking factor = $(blocking_factor(curric))")
#     println("  centrality factor = $(centrality(curric))")
#     println("  curricular complexity = $(complexity(curric))")
# else
#     println("Curriculum $(curric.name) is not valid:")
#     print(String(take!(errors)))
# end
# terms = Array{Term}(undef, 3)
# terms[1] = Term([c[1]])
# terms[2] = Term([c[2],c[3]])
# terms[3] = Term([c[4]])
# dp = DegreePlan("Example Curricula c1", curric, terms)
# basic_metrics(dp)
# dp.metrics