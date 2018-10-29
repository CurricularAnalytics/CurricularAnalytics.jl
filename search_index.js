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
    "location": "curriculum/#CurricularAnalytics.add_requisite!",
    "page": "Creating Curricula",
    "title": "CurricularAnalytics.add_requisite!",
    "category": "function",
    "text": "add_requisite!(rc, tc, requisite_type)\n\nAdd course rc as a requisite, of type requisite_type, for target course tc.\n\nRequisite types\n\nOne of the following requisite types must be specified for rc:\n\npre : a prerequisite course that must be passed before tc can be attempted.\nco  : a co-requisite course that may be taken before or at the same time as tc.\nstrict_co : a strict co-requisite course that must be taken at the same time as tc.\n\n\n\n\n\nadd_requisite!([rc1, rc2, ...], tc, [requisite_type1, requisite_type2, ...])\n\nAdd a collection of requisites to target course tc.\n\nRequisite types\n\nThe following requisite types may be specified for rc:\n\npre : a prerequisite course that must be passed before tc can be attempted.\nco  : a co-requisite course that may be taken before or at the same time as tc.\nstrict_co : a strict co-requisite course that must be taken at the same time as tc.\n\n\n\n\n\n"
},

{
    "location": "curriculum/#CurricularAnalytics.delete_requisite!",
    "page": "Creating Curricula",
    "title": "CurricularAnalytics.delete_requisite!",
    "category": "function",
    "text": "delete_requisite!(rc, tc)\n\nRemove course rc as a requisite for target course tc.  If rc is not an existing requisite for tc, an error is thrown.\n\nRequisite types\n\nThe following requisite types may be specified for rc:\n\npre : a prerequisite course that must be passed before tc can be attempted.\nco  : a co-requisite course that may be taken before or at the same time as tc.\nstrict_co : a strict co-requisite course that must be taken at the same time as tc.\n\n\n\n\n\n"
},

{
    "location": "curriculum/#CurricularAnalytics.create_graph!",
    "page": "Creating Curricula",
    "title": "CurricularAnalytics.create_graph!",
    "category": "function",
    "text": "create_graph!(c::Curriculum)\n\nCreate a curriculum directed graph from a curriculum specification. The graph is stored as a  LightGraph.jl implemenation within the Curriculum data object.\n\n\n\n\n\n"
},

{
    "location": "curriculum/#CurricularAnalytics.isvalid_curriculum",
    "page": "Creating Curricula",
    "title": "CurricularAnalytics.isvalid_curriculum",
    "category": "function",
    "text": "isvalid_curriculum(c::Curriculum, errors::IOBuffer)\n\nTests whether or not the curriculum graph associated with curriculum c is valid.  Returns  a boolean value, with true indicating the curriculum is valid, and false indicating it  is not.\n\nIf c is not valid, the reason(s) why are written to the errors buffer. To view these  reasons, use:\n\njulia> errors = IOBuffer()\njulia> isvalid_curriculum(c, errors)\njulia> println(String(take!(errors)))\n\nThere are two reasons why a curriculum graph might not be valid:\n\nCycles : If a curriculum graph contains a directed cycle, it is not possible to complete the curriculum.\nExtraneous Requisites : These are redundant requisites that introduce spurious complexity. If a curriculum has the prerequisite relationships c_1 rightarrow c_2 rightarrow c_3  and c_1 rightarrow c_3, and c_1 and c_2 are not co-requisites, then c_1  rightarrow c_3 is redundant and therefore extraneous.   \n\n\n\n\n\n"
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
    "location": "metrics/#CurricularAnalytics.blocking_factor",
    "page": "Curricular Metrics",
    "title": "CurricularAnalytics.blocking_factor",
    "category": "function",
    "text": "blocking_factor(c::Curriculum, course::Int)\n\nThe blocking factor associated with course v_i in curriculum c, G_c = (VE), denoted b_c(v_i), is  given by: b_c(v_i) = sum_v_j in V I(v_iv_j) where I is the indicator function:\n\n\n\n\n\n"
},

{
    "location": "metrics/#Curricular-Metrics-1",
    "page": "Curricular Metrics",
    "title": "Curricular Metrics",
    "category": "section",
    "text": "blocking_factor"
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
