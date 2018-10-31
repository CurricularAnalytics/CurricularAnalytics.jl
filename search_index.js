var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "page",
    "text": ""
},

{
    "location": "#CurricularAnalytics-1",
    "page": "Getting Started",
    "title": "CurricularAnalytics",
    "category": "section",
    "text": "CurricularAnalytics.jl is a toolbox for studying and analyzing academic program curricula using the Julia programming language.  The toolbox represents curricula as graphs, allowing various graph-theoretic measures to be applied in order to quantify the complexity of curricula. In addition to analyzing curricular complexity, the toolbox supports the ability to visualize curricula, to compare and contrast curricula, to create optimal degree plans for completing curricula that satisfy particular constraints, and to simulate the impact of various events on student progression through a curriculum. "
},

{
    "location": "#Basic-toolbox-functionality-1",
    "page": "Getting Started",
    "title": "Basic toolbox functionality",
    "category": "section",
    "text": "The basic data types used in the CurricularAnalytics.jl libraries are described in CurricularAnalytics Data Types. The toolbox includes a number of convenient functions that can be used to create a curriculum graph; these are described in Creating Curricula. In addition, functions that can be used to create a degree plan from a curriculum are described in [Creating Degree Plans]. Detailed example and tutorials on how to create and analyze curricula and degree plans can be found in the CurricularAnalytics Tutorial Notebooks repository."
},

{
    "location": "types/#",
    "page": "CurricularAnalytics Data Types",
    "title": "CurricularAnalytics Data Types",
    "category": "page",
    "text": ""
},

{
    "location": "types/#CurricularAnalytics.Course",
    "page": "CurricularAnalytics Data Types",
    "title": "CurricularAnalytics.Course",
    "category": "type",
    "text": "The Course data type is used to represent a single course consisting of a given number  of credit hours.  To instantiate a Course use:\n\nCourse(name, credit_hours; <keyword arguments>)\n\nArguments\n\nname::AbstractString : the name of the course.\ncredit_hours::int : the number of credit hours associated with the course.\nprefix::AbstractString : the prefix associated with the course.\nnum::AbstractString : the number associated with the course.\ninstitution:AbstractString : the name of the institution offering the course.\ncanonical_name::AbstractString : the common name used for the course.\n\nExamples:\n\njulia> Course(\"Calculus with Applications\", 4; prefix=\"MA\", num=\"112\", canonical_name=\"Calculus I\")\n\n\n\n\n\n"
},

{
    "location": "types/#CurricularAnalytics.Curriculum",
    "page": "CurricularAnalytics Data Types",
    "title": "CurricularAnalytics.Curriculum",
    "category": "type",
    "text": "The Curriculum data type is used to represent the collection of courses that must be be completed in order to earn a particualr degree.  To instantiate a Curriculum use:\n\nCurriculum(name, courses; <keyword arguments>)\n\nArguments\n\nname::AbstractString : the name of the curriculum.\ncourses::Array{Course} : the collection of required courses that comprise the curriculum.\ndegree_type::Degree : the type of degree, allowable    types: AA, AS, AAS, BA, BS (default).\ninstitution:AbstractString : the name of the institution offering the curriculum.\nsystem_type::System : the type of system the institution uses, allowable    types: semester (default), quarter.\nCIP::AbstractString : the Classification of Instructional Programs (CIP) code for the    curriculum.  See: https://nces.ed.gov/ipeds/cipcode\n\nExamples:\n\njulia> Curriculum(\"Biology\", courses; institution=\"South Harmon Tech\", degree_type=AS, CIP=\"26.0101\")\n\n\n\n\n\n"
},

{
    "location": "types/#CurricularAnalytics.LearningOutcome",
    "page": "CurricularAnalytics Data Types",
    "title": "CurricularAnalytics.LearningOutcome",
    "category": "type",
    "text": "The LearningOutcome data type is used to associate a set of learning outcomes with  a course or a curriculum. To instantiate a LearningOutcome use:\n\nLearningOutcome(name, description, hours)\n\nArguments\n\nname::AbstractString : the name of the learning outcome.\ndescription::AbstractString : detailed description of the learning outcome.\nhours::int : number of class (contact) hours needed to attain the learning outcome. \n\nExamples:\n\njulia> LearningOutcome(\"M1\", \"Learner will demonstrate the ability to ...\", 12)\n\n\n\n\n\n"
},

{
    "location": "types/#CurricularAnalytics.Term",
    "page": "CurricularAnalytics Data Types",
    "title": "CurricularAnalytics.Term",
    "category": "type",
    "text": "The Term data type is used to represent a single term within a DegreePlan. To  instantiate a Term use:\n\nTerm([c1, c2, ...])\n\nwhere c1, c2, ... are Course data objects\n\n\n\n\n\n"
},

{
    "location": "types/#CurricularAnalytics.DegreePlan",
    "page": "CurricularAnalytics Data Types",
    "title": "CurricularAnalytics.DegreePlan",
    "category": "type",
    "text": "The DegreePlan data type is used to represent the collection of courses that must be be completed in order to earn a particualr degree.  To instantiate a Curriculum use:\n\nDegreePlan(name, curriculum, terms, additional_courses)\n\nArguments\n\nname::AbstractString : the name of the degree plan.\ncurriculum::Curriculum : the curriculum the degree plan must satisfy.\nterms::Array{Term} : the arrangement of terms associated with the degree plan.\nadditional_courses::Array{Course} : additional courses in the degree plan that are not  a part of the curriculum. E.g., a prerequisite math class to the first required math  class in the curriculum.\n\nExamples:\n\njulia> DegreePlan(\"Biology 4-year Degree Plan\", curriculum, terms)\n\n\n\n\n\n"
},

{
    "location": "types/#CurricularAnalytics-Data-Types-1",
    "page": "CurricularAnalytics Data Types",
    "title": "CurricularAnalytics Data Types",
    "category": "section",
    "text": "Course\nCurriculum\nLearningOutcome\nTerm\nDegreePlan"
},

{
    "location": "curriculum/#",
    "page": "Creating Curricula",
    "title": "Creating Curricula",
    "category": "page",
    "text": ""
},

{
    "location": "curriculum/#Creating-Curricula-1",
    "page": "Creating Curricula",
    "title": "Creating Curricula",
    "category": "section",
    "text": "add_requisite!\ndelete_requisite!\ncreate_graph!\nisvalid_curriculum"
},

{
    "location": "degreeplan/#",
    "page": "Creating Degree Plans",
    "title": "Creating Degree Plans",
    "category": "page",
    "text": ""
},

{
    "location": "degreeplan/#Creating-Degree-Plans-1",
    "page": "Creating Degree Plans",
    "title": "Creating Degree Plans",
    "category": "section",
    "text": ""
},

{
    "location": "persistence/#",
    "page": "Reading/Writing Curricula & Degree Plans",
    "title": "Reading/Writing Curricula & Degree Plans",
    "category": "page",
    "text": ""
},

{
    "location": "persistence/#Reading/Writing-Degree-Plans-1",
    "page": "Reading/Writing Curricula & Degree Plans",
    "title": "Reading/Writing Degree Plans",
    "category": "section",
    "text": ""
},

{
    "location": "plotting/#",
    "page": "Visualizing Degree Plans",
    "title": "Visualizing Degree Plans",
    "category": "page",
    "text": ""
},

{
    "location": "plotting/#Visualizing-Degree-Plans-1",
    "page": "Visualizing Degree Plans",
    "title": "Visualizing Degree Plans",
    "category": "section",
    "text": ""
},

{
    "location": "metrics/#",
    "page": "Curricular Metrics",
    "title": "Curricular Metrics",
    "category": "page",
    "text": ""
},

{
    "location": "metrics/#CurricularAnalytics",
    "page": "Curricular Metrics",
    "title": "CurricularAnalytics",
    "category": "module",
    "text": "The curriculum-based metrics in this toolbox are based upon the graph structure of a  curriculum.  Specifically, assume curriculum c consists of n courses c_1 ldots c_n, and that there are m requisite (prerequisite or co-requsitie) relationships between these courses.  A curriculum graph G_c = (VE) is formed by  creating a vertex set V = v_1 ldots v_n (i.e., one vertex for each course) along with an edge set E = e_1 ldots e_m, where a directed edge from vertex v_i to v_j is in E if course c_i is a requisite for course c_j.\n\n\n\n\n\n"
},

{
    "location": "metrics/#CurricularAnalytics.isvalid_curriculum",
    "page": "Curricular Metrics",
    "title": "CurricularAnalytics.isvalid_curriculum",
    "category": "function",
    "text": "isvalid_curriculum(c::Curriculum, errors::IOBuffer)\n\nTests whether or not the curriculum graph associated with curriculum c is valid.  Returns  a boolean value, with true indicating the curriculum is valid, and false indicating it  is not.\n\nIf c is not valid, the reason(s) why are written to the errors buffer. To view these  reasons, use:\n\njulia> errors = IOBuffer()\njulia> isvalid_curriculum(c, errors)\njulia> println(String(take!(errors)))\n\nThere are two reasons why a curriculum graph might not be valid:\n\nCycles : If a curriculum graph contains a directed cycle, it is not possible to complete the curriculum.\nExtraneous Requisites : These are redundant requisites that introduce spurious complexity. If a curriculum has the prerequisite relationships c_1 rightarrow c_2 rightarrow c_3  and c_1 rightarrow c_3, and c_1 and c_2 are not co-requisites, then c_1  rightarrow c_3 is redundant and therefore extraneous.   \n\n\n\n\n\n"
},

{
    "location": "metrics/#CurricularAnalytics.blocking_factor",
    "page": "Curricular Metrics",
    "title": "CurricularAnalytics.blocking_factor",
    "category": "function",
    "text": "blocking_factor(c::Curriculum, course::Int)\n\nThe blocking factor associated with course c_i in curriculum c with curriculum graph G_c = (VE) is defined as:\n\nb_c(v_i) = sum_v_j in V I(v_iv_j)\n\nwhere I(v_iv_j) is the indicator function, which is 1 if  v_i leadsto v_j,  and 0 otherwise. Here v_i leadsto v_j denotes that a directed path from vertex v_i to v_j exists in G_c, i.e., there is a requisite pathway from course  c_i to c_j in curriculum c.\n\n\n\n\n\n"
},

{
    "location": "metrics/#CurricularAnalytics.delay_factor",
    "page": "Curricular Metrics",
    "title": "CurricularAnalytics.delay_factor",
    "category": "function",
    "text": "delay_factor(c::Curriculum, course::Int)\n\nThe delay factor associated with course c_k in curriculum c with curriculum graph G_c = (VE) is the number of vertices in the longest path  in G_c that passes through v_k, i.e., \n\nd_c(v_k) = max_ijlmleft(v_i  oversetp_lleadsto v_k oversetp_mleadsto v_j)right\n\nwhere I(v_iv_j) is the indicator function, which is 1 if  v_i leadsto v_j,  and 0 otherwise. Here v_i leadsto v_j denotes that a directed path from vertex v_i to v_j exists in G_c, i.e., there is a requisite pathway from course  c_i to c_j in curriculum c.\n\n\n\n\n\ndelay_factor(c::Curriculum)\n\nThe delay_factor factor associated with curriculum c is defined as:\n\nd(G_c) = sum_v_k in V d_c(v_k)\n\nwhere G_c = (VE) is the curriculum graph associated with curriculum c.\n\n\n\n\n\n"
},

{
    "location": "metrics/#CurricularAnalytics.centrality",
    "page": "Curricular Metrics",
    "title": "CurricularAnalytics.centrality",
    "category": "function",
    "text": "centrality(c::Curriculum, course::Int)\n\nConsider a curriculum graph G_c = (VE), and a vertex v_i in V. Furthermore,  consider all paths between every pair of vertices v_j v_k in V` that satisfy the  following conditions:\n\nv_i v_j v_k are distinct, i.e., v_i neq v_j v_i neq v_k and v_j neq v_k;\nthere is a path from v_j to v_k that includes v_i, i.e., v_j leadsto v_i leadsto v_k;\nv_j has in-degree zero, i.e., v_j is a \"source\"; and\nv_k has out-degree zero, i.e., v_k is a \"sink\".\n\nLet P_v_i = p_1 p_2 ldots denote the set of all paths that satisfy these conditions.  Then the centrality of v_i is defined as    \n\nq(v_i) = sum_l=1^left P_v_i right (p_l)\n\n\n\n\n\n"
},

{
    "location": "metrics/#CurricularAnalytics.complexity",
    "page": "Curricular Metrics",
    "title": "CurricularAnalytics.complexity",
    "category": "function",
    "text": "complexity(c::Curriculum, course::Int)\n\nThe complexity associated with course c_i in curriculum c with curriculum graph G_c = (VE) is defined as:\n\n\n\n\n\n"
},

{
    "location": "metrics/#Curricular-Metrics-1",
    "page": "Curricular Metrics",
    "title": "Curricular Metrics",
    "category": "section",
    "text": "CurricularAnalytics\nisvalid_curriculum\nblocking_factor\ndelay_factor\ncentrality\ncomplexity"
},

{
    "location": "optimizing/#",
    "page": "Optimizing Degree Plans",
    "title": "Optimizing Degree Plans",
    "category": "page",
    "text": ""
},

{
    "location": "optimizing/#Optimizing-Degree-Plans-1",
    "page": "Optimizing Degree Plans",
    "title": "Optimizing Degree Plans",
    "category": "section",
    "text": ""
},

{
    "location": "simulating/#",
    "page": "Simulating Student Flows",
    "title": "Simulating Student Flows",
    "category": "page",
    "text": ""
},

{
    "location": "simulating/#Simulating-Student-Flows-1",
    "page": "Simulating Student Flows",
    "title": "Simulating Student Flows",
    "category": "section",
    "text": ""
},

{
    "location": "developing/#",
    "page": "Developer Notes",
    "title": "Developer Notes",
    "category": "page",
    "text": ""
},

{
    "location": "developing/#Developer-Notes-1",
    "page": "Developer Notes",
    "title": "Developer Notes",
    "category": "section",
    "text": ""
},

]}
