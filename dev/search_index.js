var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Curricular-Analytics-Toolbox-1",
    "page": "Getting Started",
    "title": "Curricular Analytics Toolbox",
    "category": "section",
    "text": "CurricularAnalytics.jl is a toolbox for studying, analyzing and comparing academic program curricula and  their associated degree plans. The toolbox was built using the Julia programming language. For assistance in installing the toolbox, see the Installation section. We welcome contributions and usage examples. If you would like to contribute to the toolbox, please see the Contributor Guide. To cite this toolbox, please see How to Cite CurricularAnalytics.jl."
},

{
    "location": "index.html#Terminology-1",
    "page": "Getting Started",
    "title": "Terminology",
    "category": "section",
    "text": "A basic understanding of the terminology associated with curricula and degree programs will greatly facilitate the use of this toolbx.A curriculum for an academic program consists of the set of courses that a student must complete in order to earn the degree associated with that program. By successfully completing a course, a student should attain the learning outcoes associated with the course, while also earning the number of credit hours associated with the course. For instance, most associates degree programs require a student to earn a minimum of 60 credit hours, and most bachelors degree programs require a student to earn a minimum of 120 credit hours. In order to attain the learning outcomes associated with course B, a student may first need to attain some of  the learning outcomes associated with some other course, say A. In order to capture this requirement, course A is listed as a prerequisite for course B. That is, students may not enroll in course B unless they have successfully completed course A.  More generally, we refer to these types of requirements as requisites, and we differentiate between three types:Prerequisite : course A must be completed prior to attempting course B`.\nCo-requisite : course A may be taken prior to or at the same time as attempting course B.\nStrict co-requisite : course A must be taken at the same time as course B.A degree plan is term-by-term arrangement for taking all of the courses in a curriculum, layed out so as to satisfy all requisite relationships. A term is typically offered either in the semester (two terms/academic year) or quarter (three terms/academic year) format. It is common for schools to offer two-year degree plans for associates degrees and four-year degree plans for bachelors degrees.It is important to note that a degree plan may contain more courses than are stipulated in the curriculum. For instance, a student may not have the background necessary to take the first math course in a curriculum, necessitating that addition of a prerequisite math class as a part of the degree plan."
},

{
    "location": "index.html#–-Example-–-1",
    "page": "Getting Started",
    "title": "– Example –",
    "category": "section",
    "text": "Consider the Basket Weaving curriculum, consisting of the following four courses:BW 101 : Introduction to Baskets, 3 credits\nBW 101L : Introduction to Baskets Lab, 1 credit; co-requisite: BW 101 \nBW 111 : Basic Basket Forms, 3 credits; prerequisite: BW 101\nBW 201 : Advanced Basketry, 3 credits; prerequisite: BW 111 The following degree plan completes this curriculum in two terms while satisfying all of the requisite relationships:Term 1: BW 101, BW 101L\nTerm 2: BW 111, BW 201"
},

{
    "location": "index.html#Toolbox-Overview-1",
    "page": "Getting Started",
    "title": "Toolbox Overview",
    "category": "section",
    "text": "The toolbox represents curricula as graphs, allowing various graph-theoretic measures to be applied in order to quantify the complexity of curricula. In addition to analyzing curricular complexity, the toolbox supports the ability to visualize curricula and degree plans, to compare and contrast curricula, to create optimal degree plans for completing curricula that satisfy particular constraints, and to simulate the impact of various events on student progression through a curriculum. The basic data types used in the CurricularAnalytics.jl libraries are described in CurricularAnalytics.jl Data Types. This section also describes a number of convenient functions that can be used to create curricula and degree plans. Functions that can be used to read and write curricula and degree plans to/from permament storage in a variety of formats are described in Persisting Curricula & Degree Plans. Metrics that have been developed to quanitfy the complexity of curricula are described in Curricular Metrics, and functions that can be used study degree plans, and to create degree plans according to various optimzation criteria are described in Optimizing Degree Plans.Visualization-related functions are described in Visualizing Curricula and Degree Plans.Detailed examples and tutorials can be found in the Curricular Analytics Notebooks repository."
},

{
    "location": "install.html#",
    "page": "Installing the Toolbox",
    "title": "Installing the Toolbox",
    "category": "page",
    "text": ""
},

{
    "location": "install.html#Installation-1",
    "page": "Installing the Toolbox",
    "title": "Installation",
    "category": "section",
    "text": "... Coming soon ..."
},

{
    "location": "types.html#",
    "page": "Data Types",
    "title": "Data Types",
    "category": "page",
    "text": ""
},

{
    "location": "types.html#CurricularAnalytics.jl-Data-Types-1",
    "page": "Data Types",
    "title": "CurricularAnalytics.jl Data Types",
    "category": "section",
    "text": "This section describes the basic data types associated with the CurricularAnalytics.jl toolbox. These are used to construct courses (with associated learning outcomes), curricula and degree plans. "
},

{
    "location": "types.html#CurricularAnalytics.Course",
    "page": "Data Types",
    "title": "CurricularAnalytics.Course",
    "category": "type",
    "text": "The Course data type is used to represent a single course consisting of a given number  of credit hours.  To instantiate a Course use:\n\nCourse(name, credit_hours; <keyword arguments>)\n\nArguments\n\nRequired:\n\nname::AbstractString : the name of the course.\ncredit_hours::int : the number of credit hours associated with the course.\n\nKeyword:\n\nprefix::AbstractString : the prefix associated with the course.\nnum::AbstractString : the number associated with the course.\ninstitution:AbstractString : the name of the institution offering the course.\ncanonical_name::AbstractString : the common name used for the course.\n\nExamples:\n\njulia> Course(\"Calculus with Applications\", 4, prefix=\"MA\", num=\"112\", canonical_name=\"Calculus I\")\n\n\n\n\n\n"
},

{
    "location": "types.html#CurricularAnalytics.add_requisite!",
    "page": "Data Types",
    "title": "CurricularAnalytics.add_requisite!",
    "category": "function",
    "text": "add_requisite!(rc, tc, requisite_type)\n\nAdd course rc as a requisite, of type requisite_type, for target course tc.\n\nRequisite types\n\nOne of the following requisite types must be specified for rc:\n\npre : a prerequisite course that must be passed before tc can be attempted.\nco  : a co-requisite course that may be taken before or at the same time as tc.\nstrict_co : a strict co-requisite course that must be taken at the same time as tc.\n\n\n\n\n\nadd_requisite!([rc1, rc2, ...], tc, [requisite_type1, requisite_type2, ...])\n\nAdd a collection of requisites to target course tc.\n\nRequisite types\n\nThe following requisite types may be specified for rc:\n\npre : a prerequisite course that must be passed before tc can be attempted.\nco  : a co-requisite course that may be taken before or at the same time as tc.\nstrict_co : a strict co-requisite course that must be taken at the same time as tc.\n\n\n\n\n\n"
},

{
    "location": "types.html#CurricularAnalytics.delete_requisite!",
    "page": "Data Types",
    "title": "CurricularAnalytics.delete_requisite!",
    "category": "function",
    "text": "delete_requisite!(rc, tc)\n\nRemove course rc as a requisite for target course tc.  If rc is not an existing requisite for tc, an error is thrown.\n\nRequisite types\n\nThe following requisite types may be specified for rc:\n\npre : a prerequisite course that must be passed before tc can be attempted.\nco  : a co-requisite course that may be taken before or at the same time as tc.\nstrict_co : a strict co-requisite course that must be taken at the same time as tc.\n\n\n\n\n\n"
},

{
    "location": "types.html#Courses-1",
    "page": "Data Types",
    "title": "Courses",
    "category": "section",
    "text": "CourseOnce a course has been created, requisites may be added to it, or deleted from it, using the following functions.add_requisite!\ndelete_requisite!Just like courses, learning outcomes can have requisite relationships between them."
},

{
    "location": "types.html#CurricularAnalytics.LearningOutcome",
    "page": "Data Types",
    "title": "CurricularAnalytics.LearningOutcome",
    "category": "type",
    "text": "The LearningOutcome data type is used to associate a set of learning outcomes with  a course or a curriculum. To instantiate a LearningOutcome use:\n\nLearningOutcome(name, description, hours)\n\nArguments\n\nname::AbstractString : the name of the learning outcome.\ndescription::AbstractString : detailed description of the learning outcome.\nhours::int : number of class (contact) hours needed to attain the learning outcome. \n\nExamples:\n\njulia> LearningOutcome(\"M1\", \"Learner will demonstrate the ability to ...\", 12)\n\n\n\n\n\n"
},

{
    "location": "types.html#Learning-Outcomes-1",
    "page": "Data Types",
    "title": "Learning Outcomes",
    "category": "section",
    "text": "LearningOutcome"
},

{
    "location": "types.html#CurricularAnalytics.Curriculum",
    "page": "Data Types",
    "title": "CurricularAnalytics.Curriculum",
    "category": "type",
    "text": "The Curriculum data type is used to represent the collection of courses that must be be completed in order to earn a particualr degree.  To instantiate a Curriculum use:\n\nCurriculum(name, courses; <keyword arguments>)\n\nArguments\n\nRequired:\n\nname::AbstractString : the name of the curriculum.\ncourses::Array{Course} : the collection of required courses that comprise the curriculum.\n\nKeyword:\n\ndegree_type::Degree : the type of degree, allowable    types: AA, AS, AAS, BA, BS (default).\ninstitution:AbstractString : the name of the institution offering the curriculum.\nsystem_type::System : the type of system the institution uses, allowable    types: semester (default), quarter.\nCIP::AbstractString : the Classification of Instructional Programs (CIP) code for the    curriculum.  See: https://nces.ed.gov/ipeds/cipcode\n\nExamples:\n\njulia> Curriculum(\"Biology\", courses, institution=\"South Harmon Tech\", degree_type=AS, CIP=\"26.0101\")\n\n\n\n\n\n"
},

{
    "location": "types.html#CurricularAnalytics.isvalid_curriculum",
    "page": "Data Types",
    "title": "CurricularAnalytics.isvalid_curriculum",
    "category": "function",
    "text": "isvalid_curriculum(c::Curriculum, errors::IOBuffer)\n\nTests whether or not the curriculum graph G_c associated with curriculum c is valid.  Returns  a boolean value, with true indicating the curriculum is valid, and false indicating it  is not.\n\nIf G_c is not valid, the reason(s) why are written to the errors buffer. To view these  reasons, use:\n\njulia> errors = IOBuffer()\njulia> isvalid_curriculum(c, errors)\njulia> println(String(take!(errors)))\n\nThere are two reasons why a curriculum graph might not be valid:\n\nCycles : If a curriculum graph contains a directed cycle, it is not possible to complete the curriculum.\nExtraneous Requisites : These are redundant requisites that introduce spurious complexity. If a curriculum has the prerequisite relationships c_1 rightarrow c_2 rightarrow c_3  and c_1 rightarrow c_3, and c_1 and c_2 are not co-requisites, then c_1  rightarrow c_3 is redundant and therefore extraneous.   \n\n\n\n\n\n"
},

{
    "location": "types.html#Curricula-1",
    "page": "Data Types",
    "title": "Curricula",
    "category": "section",
    "text": "To create a curriculum from a collection of courses, and their assoiated requsites, use:CurriculumThe following function can be used to ensure that a constructed curriculum is valid.isvalid_curriculum"
},

{
    "location": "types.html#CurricularAnalytics.Term",
    "page": "Data Types",
    "title": "CurricularAnalytics.Term",
    "category": "type",
    "text": "The Term data type is used to represent a single term within a DegreePlan. To  instantiate a Term use:\n\nTerm([c1, c2, ...])\n\nwhere c1, c2, ... are Course data objects\n\n\n\n\n\n"
},

{
    "location": "types.html#Terms-1",
    "page": "Data Types",
    "title": "Terms",
    "category": "section",
    "text": "Term"
},

{
    "location": "types.html#CurricularAnalytics.DegreePlan",
    "page": "Data Types",
    "title": "CurricularAnalytics.DegreePlan",
    "category": "type",
    "text": "The DegreePlan data type is used to represent the collection of courses that must be be completed in order to earn a particualr degree.  To instantiate a Curriculum use:\n\nDegreePlan(name, curriculum, terms, additional_courses)\n\nArguments\n\nname::AbstractString : the name of the degree plan.\ncurriculum::Curriculum : the curriculum the degree plan must satisfy.\nterms::Array{Term} : the arrangement of terms associated with the degree plan.\nadditional_courses::Array{Course} : additional courses in the degree plan that are not  a part of the curriculum. E.g., a prerequisite math class to the first required math  class in the curriculum.\n\nExamples:\n\njulia> DegreePlan(\"Biology 4-year Degree Plan\", curriculum, terms)\n\n\n\n\n\n"
},

{
    "location": "types.html#CurricularAnalytics.isvalid_degree_plan",
    "page": "Data Types",
    "title": "CurricularAnalytics.isvalid_degree_plan",
    "category": "function",
    "text": "isvalid_degree_plan(plan::DegreePlan, errors::IOBuffer)\n\nTests whether or not the degree plan plan is valid.  Returns a boolean value, with true indicating the  degree plan is valid, and false indicating it is not.\n\nIf plan is not valid, the reason(s) why are written to the errors buffer. To view these  reasons, use:\n\njulia> errors = IOBuffer()\njulia> isvalid_degree_plan(plan, errors)\njulia> println(String(take!(errors)))\n\nThere are two reasons why a curriculum graph might not be valid:\n\nRequisites not satsified : A prerequisite for a course occurs in a later term than the course itself.\nIncomplete plan : There are course in the curriculum not included in the degree plan.\nRedundant plan : The same course appears in the degree plan multiple times. \n\n\n\n\n\n"
},

{
    "location": "types.html#Degree-Plans-1",
    "page": "Data Types",
    "title": "Degree Plans",
    "category": "section",
    "text": "To create a degree plan that satisfies the courses associated with a particular curriculum, use:DegreePlanThe following function can be used to ensure that a constructed degree plan is valid.isvalid_degree_plan"
},

{
    "location": "persistence.html#",
    "page": "Reading/Writing Curricula & Degree Plans",
    "title": "Reading/Writing Curricula & Degree Plans",
    "category": "page",
    "text": ""
},

{
    "location": "persistence.html#Persisting-Curricula-and-Degree-Plans-1",
    "page": "Reading/Writing Curricula & Degree Plans",
    "title": "Persisting Curricula & Degree Plans",
    "category": "section",
    "text": "... Coming soon ..."
},

{
    "location": "visualize.html#",
    "page": "Visualizing Curricula & Degree Plans",
    "title": "Visualizing Curricula & Degree Plans",
    "category": "page",
    "text": ""
},

{
    "location": "visualize.html#CurricularAnalytics.visualize",
    "page": "Visualizing Curricula & Degree Plans",
    "title": "CurricularAnalytics.visualize",
    "category": "function",
    "text": "visualize(degree_plan; <keyword arguments>))\n\nFunction used to visualize degree plans. \n\nArguments\n\nRequired:\n\ndegree_plan::DegreePlan : the name of the curriculum.\n\nKeyword:\n\nwindow : funtion argument that specifies the window to render content in.   Default is Window().\nchanged : callback function argument, called whenever the curriculum is modified through\n\nthe interface.     Default is nothing.\n\nfile_name : name of the file, in JSON format, that will the degree plan, including modifications.    Default is recent-visualization.json.\n\n\n\n\n\n"
},

{
    "location": "visualize.html#Visualizing-Curricula-and-Degree-Plans-1",
    "page": "Visualizing Curricula & Degree Plans",
    "title": "Visualizing Curricula and Degree Plans",
    "category": "section",
    "text": "visualize"
},

{
    "location": "metrics.html#",
    "page": "Curricular Metrics",
    "title": "Curricular Metrics",
    "category": "page",
    "text": ""
},

{
    "location": "metrics.html#CurricularAnalytics",
    "page": "Curricular Metrics",
    "title": "CurricularAnalytics",
    "category": "module",
    "text": "The curriculum-based metrics in this toolbox are based upon the graph structure of a  curriculum.  Specifically, assume curriculum c consists of n courses c_1 ldots c_n, and that there are m requisite (prerequisite or co-requsitie) relationships between these courses.   A curriculum graph G_c = (VE) is formed by creating a vertex set V = v_1 ldots v_n  (i.e., one vertex for each course) along with an edge set E = e_1 ldots e_m, where a  directed edge from vertex v_i to v_j is in E if course c_i is a requisite for course c_j.\n\n\n\n\n\n"
},

{
    "location": "metrics.html#CurricularAnalytics.blocking_factor",
    "page": "Curricular Metrics",
    "title": "CurricularAnalytics.blocking_factor",
    "category": "function",
    "text": "blocking_factor(c::Curriculum, course::Int)\n\nThe blocking factor associated with course c_i in curriculum c with curriculum graph G_c = (VE) is defined as:\n\nb_c(v_i) = sum_v_j in V I(v_iv_j)\n\nwhere I(v_iv_j) is the indicator function, which is 1 if  v_i leadsto v_j,  and 0 otherwise. Here v_i leadsto v_j denotes that a directed path from vertex v_i to v_j exists in G_c, i.e., there is a requisite pathway from course  c_i to c_j in curriculum c.\n\n\n\n\n\nblocking_factor(c::Curriculum)\n\nThe blocking factor associated with curriculum c is defined as:\n\nb(G_c) = sum_v_i in V b_c(v_i)\n\nwhere G_c = (VE) is the curriculum graph associated with curriculum c.\n\n\n\n\n\n"
},

{
    "location": "metrics.html#CurricularAnalytics.delay_factor",
    "page": "Curricular Metrics",
    "title": "CurricularAnalytics.delay_factor",
    "category": "function",
    "text": "delay_factor(c::Curriculum, course::Int)\n\nThe delay factor associated with course c_k in curriculum c with curriculum graph G_c = (VE) is the number of vertices in the longest path  in G_c that passes through v_k. If (p) denotes the number of vertices in the directed path p in G_c, then we can define the delay factor of  course c_k as:\n\nd_c(v_k) = max_ijlmleft(v_i  oversetp_lleadsto v_k oversetp_mleadsto v_j)right\n\nwhere v_i oversetpleadsto v_j denotes a directed path p in G_c from vertex  v_i to v_j.\n\n\n\n\n\ndelay_factor(c::Curriculum)\n\nThe delay factor associated with curriculum c is defined as:\n\nd(G_c) = sum_v_k in V d_c(v_k)\n\nwhere G_c = (VE) is the curriculum graph associated with curriculum c.\n\n\n\n\n\n"
},

{
    "location": "metrics.html#CurricularAnalytics.centrality",
    "page": "Curricular Metrics",
    "title": "CurricularAnalytics.centrality",
    "category": "function",
    "text": "centrality(c::Curriculum, course::Int)\n\nConsider a curriculum graph G_c = (VE), and a vertex v_i in V. Furthermore,  consider all paths between every pair of vertices v_j v_k in V that satisfy the  following conditions:\n\nv_i v_j v_k are distinct, i.e., v_i neq v_j v_i neq v_k and v_j neq v_k;\nthere is a path from v_j to v_k that includes v_i, i.e., v_j leadsto v_i leadsto v_k;\nv_j has in-degree zero, i.e., v_j is a \"source\"; and\nv_k has out-degree zero, i.e., v_k is a \"sink\".\n\nLet P_v_i = p_1 p_2 ldots denote the set of all directed paths that satisfy these  conditions.  Then the centrality of v_i is defined as    \n\nq(v_i) = sum_l=1^left P_v_i right (p_l)\n\nwhere (p) denotes the number of vertices in the directed path p in G_c.\n\n\n\n\n\ncentrality(c::Curriculum)\n\nComputes the total centrality associated with all of the courses in curriculum c,  with curriculum graph G_c = (VE).  \n\nq(c) = sum_v in V q(v)\n\n\n\n\n\n"
},

{
    "location": "metrics.html#CurricularAnalytics.complexity",
    "page": "Curricular Metrics",
    "title": "CurricularAnalytics.complexity",
    "category": "function",
    "text": "complexity(c::Curriculum, course::Int)\n\nThe complexity associated with course c_i in curriculum c with curriculum graph G_c = (VE) is defined as:\n\nh_c(v_i) = d_c(v_i) + b_c(v_i)\n\ni.e., as a linear combination of the course delay and blocking factors.\n\n\n\n\n\ncomplexity(c::Curriculum, course::Int)\n\nThe complexity associated with curriculum c with  curriculum graph G_c = (VE)  is defined as:\n\nh(G_c) = sum_v in V left(d_c(v) + b_c(v)right)\n\n\n\n\n\n"
},

{
    "location": "metrics.html#Curricular-Metrics-1",
    "page": "Curricular Metrics",
    "title": "Curricular Metrics",
    "category": "section",
    "text": "CurricularAnalytics\nblocking_factor\ndelay_factor\ncentrality\ncomplexity"
},

{
    "location": "metrics.html#Degree-Plan-Metrics-1",
    "page": "Curricular Metrics",
    "title": "Degree Plan Metrics",
    "category": "section",
    "text": "... coming soon ..."
},

{
    "location": "optimizing.html#",
    "page": "Optimizing Degree Plans",
    "title": "Optimizing Degree Plans",
    "category": "page",
    "text": ""
},

{
    "location": "optimizing.html#Optimizing-Degree-Plans-1",
    "page": "Optimizing Degree Plans",
    "title": "Optimizing Degree Plans",
    "category": "section",
    "text": "... Coming soon ..."
},

{
    "location": "simulating.html#",
    "page": "Simulating Student Flows",
    "title": "Simulating Student Flows",
    "category": "page",
    "text": ""
},

{
    "location": "simulating.html#Simulating-Student-Flows-1",
    "page": "Simulating Student Flows",
    "title": "Simulating Student Flows",
    "category": "section",
    "text": "... Coming soon ..."
},

{
    "location": "contributing.html#",
    "page": "Contributing",
    "title": "Contributing",
    "category": "page",
    "text": ""
},

{
    "location": "contributing.html#Contributor-Guide-1",
    "page": "Contributing",
    "title": "Contributor Guide",
    "category": "section",
    "text": "We welcome all contributors and ask that you read these guidelines before starting to work on this project. Following these guidelines will facilitate collaboration and improve the speed at which your contributions gets merged."
},

{
    "location": "contributing.html#Bug-reports-1",
    "page": "Contributing",
    "title": "Bug reports",
    "category": "section",
    "text": "If you encounter code in this toolbox that does not function properly please file a bug report. The report should be raised as a github issue with a minimal working example that reproduces the error message or erroneous result. The example should include any data needed, and if the issue is incorrectness, please post the correct result along with the incorrect result produced by the toolbox.Please include version numbers of all relevant libraries and Julia itself."
},

{
    "location": "license.html#",
    "page": "License Information",
    "title": "License Information",
    "category": "page",
    "text": "                GNU GENERAL PUBLIC LICENSE\n                   Version 3, 29 June 2007Copyright (C) 2007 Free Software Foundation, Inc. http://fsf.org/  Everyone is permitted to copy and distribute verbatim copies  of this license document, but changing it is not allowed.                        PreambleThe GNU General Public License is a free, copyleft license for software and other kinds of works.The licenses for most software and other practical works are designed to take away your freedom to share and change the works.  By contrast, the GNU General Public License is intended to guarantee your freedom to share and change all versions of a program–to make sure it remains free software for all its users.  We, the Free Software Foundation, use the GNU General Public License for most of our software; it applies also to any other work released this way by its authors.  You can apply it to your programs, too.When we speak of free software, we are referring to freedom, not price.  Our General Public Licenses are designed to make sure that you have the freedom to distribute copies of free software (and charge for them if you wish), that you receive source code or can get it if you want it, that you can change the software or use pieces of it in new free programs, and that you know you can do these things.To protect your rights, we need to prevent others from denying you these rights or asking you to surrender the rights.  Therefore, you have certain responsibilities if you distribute copies of the software, or if you modify it: responsibilities to respect the freedom of others.For example, if you distribute copies of such a program, whether gratis or for a fee, you must pass on to the recipients the same freedoms that you received.  You must make sure that they, too, receive or can get the source code.  And you must show them these terms so they know their rights.Developers that use the GNU GPL protect your rights with two steps: (1) assert copyright on the software, and (2) offer you this License giving you legal permission to copy, distribute and/or modify it.For the developers\' and authors\' protection, the GPL clearly explains that there is no warranty for this free software.  For both users\' and authors\' sake, the GPL requires that modified versions be marked as changed, so that their problems will not be attributed erroneously to authors of previous versions.Some devices are designed to deny users access to install or run modified versions of the software inside them, although the manufacturer can do so.  This is fundamentally incompatible with the aim of protecting users\' freedom to change the software.  The systematic pattern of such abuse occurs in the area of products for individuals to use, which is precisely where it is most unacceptable.  Therefore, we have designed this version of the GPL to prohibit the practice for those products.  If such problems arise substantially in other domains, we stand ready to extend this provision to those domains in future versions of the GPL, as needed to protect the freedom of users.Finally, every program is threatened constantly by software patents. States should not allow patents to restrict development and use of software on general-purpose computers, but in those that do, we wish to avoid the special danger that patents applied to a free program could make it effectively proprietary.  To prevent this, the GPL assures that patents cannot be used to render the program non-free.The precise terms and conditions for copying, distribution and modification follow.                   TERMS AND CONDITIONSDefinitions.\"This License\" refers to version 3 of the GNU General Public License.\"Copyright\" also means copyright-like laws that apply to other kinds of works, such as semiconductor masks.\"The Program\" refers to any copyrightable work licensed under this License.  Each licensee is addressed as \"you\".  \"Licensees\" and \"recipients\" may be individuals or organizations.To \"modify\" a work means to copy from or adapt all or part of the work in a fashion requiring copyright permission, other than the making of an exact copy.  The resulting work is called a \"modified version\" of the earlier work or a work \"based on\" the earlier work.A \"covered work\" means either the unmodified Program or a work based on the Program.To \"propagate\" a work means to do anything with it that, without permission, would make you directly or secondarily liable for infringement under applicable copyright law, except executing it on a computer or modifying a private copy.  Propagation includes copying, distribution (with or without modification), making available to the public, and in some countries other activities as well.To \"convey\" a work means any kind of propagation that enables other parties to make or receive copies.  Mere interaction with a user through a computer network, with no transfer of a copy, is not conveying.An interactive user interface displays \"Appropriate Legal Notices\" to the extent that it includes a convenient and prominently visible feature that (1) displays an appropriate copyright notice, and (2) tells the user that there is no warranty for the work (except to the extent that warranties are provided), that licensees may convey the work under this License, and how to view a copy of this License.  If the interface presents a list of user commands or options, such as a menu, a prominent item in the list meets this criterion.Source Code.The \"source code\" for a work means the preferred form of the work for making modifications to it.  \"Object code\" means any non-source form of a work.A \"Standard Interface\" means an interface that either is an official standard defined by a recognized standards body, or, in the case of interfaces specified for a particular programming language, one that is widely used among developers working in that language.The \"System Libraries\" of an executable work include anything, other than the work as a whole, that (a) is included in the normal form of packaging a Major Component, but which is not part of that Major Component, and (b) serves only to enable use of the work with that Major Component, or to implement a Standard Interface for which an implementation is available to the public in source code form.  A \"Major Component\", in this context, means a major essential component (kernel, window system, and so on) of the specific operating system (if any) on which the executable work runs, or a compiler used to produce the work, or an object code interpreter used to run it.The \"Corresponding Source\" for a work in object code form means all the source code needed to generate, install, and (for an executable work) run the object code and to modify the work, including scripts to control those activities.  However, it does not include the work\'s System Libraries, or general-purpose tools or generally available free programs which are used unmodified in performing those activities but which are not part of the work.  For example, Corresponding Source includes interface definition files associated with source files for the work, and the source code for shared libraries and dynamically linked subprograms that the work is specifically designed to require, such as by intimate data communication or control flow between those subprograms and other parts of the work.The Corresponding Source need not include anything that users can regenerate automatically from other parts of the Corresponding Source.The Corresponding Source for a work in source code form is that same work.Basic Permissions.All rights granted under this License are granted for the term of copyright on the Program, and are irrevocable provided the stated conditions are met.  This License explicitly affirms your unlimited permission to run the unmodified Program.  The output from running a covered work is covered by this License only if the output, given its content, constitutes a covered work.  This License acknowledges your rights of fair use or other equivalent, as provided by copyright law.You may make, run and propagate covered works that you do not convey, without conditions so long as your license otherwise remains in force.  You may convey covered works to others for the sole purpose of having them make modifications exclusively for you, or provide you with facilities for running those works, provided that you comply with the terms of this License in conveying all material for which you do not control copyright.  Those thus making or running the covered works for you must do so exclusively on your behalf, under your direction and control, on terms that prohibit them from making any copies of your copyrighted material outside their relationship with you.Conveying under any other circumstances is permitted solely under the conditions stated below.  Sublicensing is not allowed; section 10 makes it unnecessary.Protecting Users\' Legal Rights From Anti-Circumvention Law.No covered work shall be deemed part of an effective technological measure under any applicable law fulfilling obligations under article 11 of the WIPO copyright treaty adopted on 20 December 1996, or similar laws prohibiting or restricting circumvention of such measures.When you convey a covered work, you waive any legal power to forbid circumvention of technological measures to the extent such circumvention is effected by exercising rights under this License with respect to the covered work, and you disclaim any intention to limit operation or modification of the work as a means of enforcing, against the work\'s users, your or third parties\' legal rights to forbid circumvention of technological measures.Conveying Verbatim Copies.You may convey verbatim copies of the Program\'s source code as you receive it, in any medium, provided that you conspicuously and appropriately publish on each copy an appropriate copyright notice; keep intact all notices stating that this License and any non-permissive terms added in accord with section 7 apply to the code; keep intact all notices of the absence of any warranty; and give all recipients a copy of this License along with the Program.You may charge any price or no price for each copy that you convey, and you may offer support or warranty protection for a fee.Conveying Modified Source Versions.You may convey a work based on the Program, or the modifications to produce it from the Program, in the form of source code under the terms of section 4, provided that you also meet all of these conditions:a) The work must carry prominent notices stating that you modified\nit, and giving a relevant date.\n\nb) The work must carry prominent notices stating that it is\nreleased under this License and any conditions added under section\n7.  This requirement modifies the requirement in section 4 to\n\"keep intact all notices\".\n\nc) You must license the entire work, as a whole, under this\nLicense to anyone who comes into possession of a copy.  This\nLicense will therefore apply, along with any applicable section 7\nadditional terms, to the whole of the work, and all its parts,\nregardless of how they are packaged.  This License gives no\npermission to license the work in any other way, but it does not\ninvalidate such permission if you have separately received it.\n\nd) If the work has interactive user interfaces, each must display\nAppropriate Legal Notices; however, if the Program has interactive\ninterfaces that do not display Appropriate Legal Notices, your\nwork need not make them do so.A compilation of a covered work with other separate and independent works, which are not by their nature extensions of the covered work, and which are not combined with it such as to form a larger program, in or on a volume of a storage or distribution medium, is called an \"aggregate\" if the compilation and its resulting copyright are not used to limit the access or legal rights of the compilation\'s users beyond what the individual works permit.  Inclusion of a covered work in an aggregate does not cause this License to apply to the other parts of the aggregate.Conveying Non-Source Forms.You may convey a covered work in object code form under the terms of sections 4 and 5, provided that you also convey the machine-readable Corresponding Source under the terms of this License, in one of these ways:a) Convey the object code in, or embodied in, a physical product\n(including a physical distribution medium), accompanied by the\nCorresponding Source fixed on a durable physical medium\ncustomarily used for software interchange.\n\nb) Convey the object code in, or embodied in, a physical product\n(including a physical distribution medium), accompanied by a\nwritten offer, valid for at least three years and valid for as\nlong as you offer spare parts or customer support for that product\nmodel, to give anyone who possesses the object code either (1) a\ncopy of the Corresponding Source for all the software in the\nproduct that is covered by this License, on a durable physical\nmedium customarily used for software interchange, for a price no\nmore than your reasonable cost of physically performing this\nconveying of source, or (2) access to copy the\nCorresponding Source from a network server at no charge.\n\nc) Convey individual copies of the object code with a copy of the\nwritten offer to provide the Corresponding Source.  This\nalternative is allowed only occasionally and noncommercially, and\nonly if you received the object code with such an offer, in accord\nwith subsection 6b.\n\nd) Convey the object code by offering access from a designated\nplace (gratis or for a charge), and offer equivalent access to the\nCorresponding Source in the same way through the same place at no\nfurther charge.  You need not require recipients to copy the\nCorresponding Source along with the object code.  If the place to\ncopy the object code is a network server, the Corresponding Source\nmay be on a different server (operated by you or a third party)\nthat supports equivalent copying facilities, provided you maintain\nclear directions next to the object code saying where to find the\nCorresponding Source.  Regardless of what server hosts the\nCorresponding Source, you remain obligated to ensure that it is\navailable for as long as needed to satisfy these requirements.\n\ne) Convey the object code using peer-to-peer transmission, provided\nyou inform other peers where the object code and Corresponding\nSource of the work are being offered to the general public at no\ncharge under subsection 6d.A separable portion of the object code, whose source code is excluded from the Corresponding Source as a System Library, need not be included in conveying the object code work.A \"User Product\" is either (1) a \"consumer product\", which means any tangible personal property which is normally used for personal, family, or household purposes, or (2) anything designed or sold for incorporation into a dwelling.  In determining whether a product is a consumer product, doubtful cases shall be resolved in favor of coverage.  For a particular product received by a particular user, \"normally used\" refers to a typical or common use of that class of product, regardless of the status of the particular user or of the way in which the particular user actually uses, or expects or is expected to use, the product.  A product is a consumer product regardless of whether the product has substantial commercial, industrial or non-consumer uses, unless such uses represent the only significant mode of use of the product.\"Installation Information\" for a User Product means any methods, procedures, authorization keys, or other information required to install and execute modified versions of a covered work in that User Product from a modified version of its Corresponding Source.  The information must suffice to ensure that the continued functioning of the modified object code is in no case prevented or interfered with solely because modification has been made.If you convey an object code work under this section in, or with, or specifically for use in, a User Product, and the conveying occurs as part of a transaction in which the right of possession and use of the User Product is transferred to the recipient in perpetuity or for a fixed term (regardless of how the transaction is characterized), the Corresponding Source conveyed under this section must be accompanied by the Installation Information.  But this requirement does not apply if neither you nor any third party retains the ability to install modified object code on the User Product (for example, the work has been installed in ROM).The requirement to provide Installation Information does not include a requirement to continue to provide support service, warranty, or updates for a work that has been modified or installed by the recipient, or for the User Product in which it has been modified or installed.  Access to a network may be denied when the modification itself materially and adversely affects the operation of the network or violates the rules and protocols for communication across the network.Corresponding Source conveyed, and Installation Information provided, in accord with this section must be in a format that is publicly documented (and with an implementation available to the public in source code form), and must require no special password or key for unpacking, reading or copying.Additional Terms.\"Additional permissions\" are terms that supplement the terms of this License by making exceptions from one or more of its conditions. Additional permissions that are applicable to the entire Program shall be treated as though they were included in this License, to the extent that they are valid under applicable law.  If additional permissions apply only to part of the Program, that part may be used separately under those permissions, but the entire Program remains governed by this License without regard to the additional permissions.When you convey a copy of a covered work, you may at your option remove any additional permissions from that copy, or from any part of it.  (Additional permissions may be written to require their own removal in certain cases when you modify the work.)  You may place additional permissions on material, added by you to a covered work, for which you have or can give appropriate copyright permission.Notwithstanding any other provision of this License, for material you add to a covered work, you may (if authorized by the copyright holders of that material) supplement the terms of this License with terms:a) Disclaiming warranty or limiting liability differently from the\nterms of sections 15 and 16 of this License; or\n\nb) Requiring preservation of specified reasonable legal notices or\nauthor attributions in that material or in the Appropriate Legal\nNotices displayed by works containing it; or\n\nc) Prohibiting misrepresentation of the origin of that material, or\nrequiring that modified versions of such material be marked in\nreasonable ways as different from the original version; or\n\nd) Limiting the use for publicity purposes of names of licensors or\nauthors of the material; or\n\ne) Declining to grant rights under trademark law for use of some\ntrade names, trademarks, or service marks; or\n\nf) Requiring indemnification of licensors and authors of that\nmaterial by anyone who conveys the material (or modified versions of\nit) with contractual assumptions of liability to the recipient, for\nany liability that these contractual assumptions directly impose on\nthose licensors and authors.All other non-permissive additional terms are considered \"further restrictions\" within the meaning of section 10.  If the Program as you received it, or any part of it, contains a notice stating that it is governed by this License along with a term that is a further restriction, you may remove that term.  If a license document contains a further restriction but permits relicensing or conveying under this License, you may add to a covered work material governed by the terms of that license document, provided that the further restriction does not survive such relicensing or conveying.If you add terms to a covered work in accord with this section, you must place, in the relevant source files, a statement of the additional terms that apply to those files, or a notice indicating where to find the applicable terms.Additional terms, permissive or non-permissive, may be stated in the form of a separately written license, or stated as exceptions; the above requirements apply either way.Termination.You may not propagate or modify a covered work except as expressly provided under this License.  Any attempt otherwise to propagate or modify it is void, and will automatically terminate your rights under this License (including any patent licenses granted under the third paragraph of section 11).However, if you cease all violation of this License, then your license from a particular copyright holder is reinstated (a) provisionally, unless and until the copyright holder explicitly and finally terminates your license, and (b) permanently, if the copyright holder fails to notify you of the violation by some reasonable means prior to 60 days after the cessation.Moreover, your license from a particular copyright holder is reinstated permanently if the copyright holder notifies you of the violation by some reasonable means, this is the first time you have received notice of violation of this License (for any work) from that copyright holder, and you cure the violation prior to 30 days after your receipt of the notice.Termination of your rights under this section does not terminate the licenses of parties who have received copies or rights from you under this License.  If your rights have been terminated and not permanently reinstated, you do not qualify to receive new licenses for the same material under section 10.Acceptance Not Required for Having Copies.You are not required to accept this License in order to receive or run a copy of the Program.  Ancillary propagation of a covered work occurring solely as a consequence of using peer-to-peer transmission to receive a copy likewise does not require acceptance.  However, nothing other than this License grants you permission to propagate or modify any covered work.  These actions infringe copyright if you do not accept this License.  Therefore, by modifying or propagating a covered work, you indicate your acceptance of this License to do so.Automatic Licensing of Downstream Recipients.Each time you convey a covered work, the recipient automatically receives a license from the original licensors, to run, modify and propagate that work, subject to this License.  You are not responsible for enforcing compliance by third parties with this License.An \"entity transaction\" is a transaction transferring control of an organization, or substantially all assets of one, or subdividing an organization, or merging organizations.  If propagation of a covered work results from an entity transaction, each party to that transaction who receives a copy of the work also receives whatever licenses to the work the party\'s predecessor in interest had or could give under the previous paragraph, plus a right to possession of the Corresponding Source of the work from the predecessor in interest, if the predecessor has it or can get it with reasonable efforts.You may not impose any further restrictions on the exercise of the rights granted or affirmed under this License.  For example, you may not impose a license fee, royalty, or other charge for exercise of rights granted under this License, and you may not initiate litigation (including a cross-claim or counterclaim in a lawsuit) alleging that any patent claim is infringed by making, using, selling, offering for sale, or importing the Program or any portion of it.Patents.A \"contributor\" is a copyright holder who authorizes use under this License of the Program or a work on which the Program is based.  The work thus licensed is called the contributor\'s \"contributor version\".A contributor\'s \"essential patent claims\" are all patent claims owned or controlled by the contributor, whether already acquired or hereafter acquired, that would be infringed by some manner, permitted by this License, of making, using, or selling its contributor version, but do not include claims that would be infringed only as a consequence of further modification of the contributor version.  For purposes of this definition, \"control\" includes the right to grant patent sublicenses in a manner consistent with the requirements of this License.Each contributor grants you a non-exclusive, worldwide, royalty-free patent license under the contributor\'s essential patent claims, to make, use, sell, offer for sale, import and otherwise run, modify and propagate the contents of its contributor version.In the following three paragraphs, a \"patent license\" is any express agreement or commitment, however denominated, not to enforce a patent (such as an express permission to practice a patent or covenant not to sue for patent infringement).  To \"grant\" such a patent license to a party means to make such an agreement or commitment not to enforce a patent against the party.If you convey a covered work, knowingly relying on a patent license, and the Corresponding Source of the work is not available for anyone to copy, free of charge and under the terms of this License, through a publicly available network server or other readily accessible means, then you must either (1) cause the Corresponding Source to be so available, or (2) arrange to deprive yourself of the benefit of the patent license for this particular work, or (3) arrange, in a manner consistent with the requirements of this License, to extend the patent license to downstream recipients.  \"Knowingly relying\" means you have actual knowledge that, but for the patent license, your conveying the covered work in a country, or your recipient\'s use of the covered work in a country, would infringe one or more identifiable patents in that country that you have reason to believe are valid.If, pursuant to or in connection with a single transaction or arrangement, you convey, or propagate by procuring conveyance of, a covered work, and grant a patent license to some of the parties receiving the covered work authorizing them to use, propagate, modify or convey a specific copy of the covered work, then the patent license you grant is automatically extended to all recipients of the covered work and works based on it.A patent license is \"discriminatory\" if it does not include within the scope of its coverage, prohibits the exercise of, or is conditioned on the non-exercise of one or more of the rights that are specifically granted under this License.  You may not convey a covered work if you are a party to an arrangement with a third party that is in the business of distributing software, under which you make payment to the third party based on the extent of your activity of conveying the work, and under which the third party grants, to any of the parties who would receive the covered work from you, a discriminatory patent license (a) in connection with copies of the covered work conveyed by you (or copies made from those copies), or (b) primarily for and in connection with specific products or compilations that contain the covered work, unless you entered into that arrangement, or that patent license was granted, prior to 28 March 2007.Nothing in this License shall be construed as excluding or limiting any implied license or other defenses to infringement that may otherwise be available to you under applicable patent law.No Surrender of Others\' Freedom.If conditions are imposed on you (whether by court order, agreement or otherwise) that contradict the conditions of this License, they do not excuse you from the conditions of this License.  If you cannot convey a covered work so as to satisfy simultaneously your obligations under this License and any other pertinent obligations, then as a consequence you may not convey it at all.  For example, if you agree to terms that obligate you to collect a royalty for further conveying from those to whom you convey the Program, the only way you could satisfy both those terms and this License would be to refrain entirely from conveying the Program.Use with the GNU Affero General Public License.Notwithstanding any other provision of this License, you have permission to link or combine any covered work with a work licensed under version 3 of the GNU Affero General Public License into a single combined work, and to convey the resulting work.  The terms of this License will continue to apply to the part which is the covered work, but the special requirements of the GNU Affero General Public License, section 13, concerning interaction through a network will apply to the combination as such.Revised Versions of this License.The Free Software Foundation may publish revised and/or new versions of the GNU General Public License from time to time.  Such new versions will be similar in spirit to the present version, but may differ in detail to address new problems or concerns.Each version is given a distinguishing version number.  If the Program specifies that a certain numbered version of the GNU General Public License \"or any later version\" applies to it, you have the option of following the terms and conditions either of that numbered version or of any later version published by the Free Software Foundation.  If the Program does not specify a version number of the GNU General Public License, you may choose any version ever published by the Free Software Foundation.If the Program specifies that a proxy can decide which future versions of the GNU General Public License can be used, that proxy\'s public statement of acceptance of a version permanently authorizes you to choose that version for the Program.Later license versions may give you additional or different permissions.  However, no additional obligations are imposed on any author or copyright holder as a result of your choosing to follow a later version.Disclaimer of Warranty.THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM \"AS IS\" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.Limitation of Liability.IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.Interpretation of Sections 15 and 16.If the disclaimer of warranty and limitation of liability provided above cannot be given local legal effect according to their terms, reviewing courts shall apply local law that most closely approximates an absolute waiver of all civil liability in connection with the Program, unless a warranty or assumption of liability accompanies a copy of the Program in return for a fee.                 END OF TERMS AND CONDITIONS\n\n        How to Apply These Terms to Your New ProgramsIf you develop a new program, and you want it to be of the greatest possible use to the public, the best way to achieve this is to make it free software which everyone can redistribute and change under these terms.To do so, attach the following notices to the program.  It is safest to attach them to the start of each source file to most effectively state the exclusion of warranty; and each file should have at least the \"copyright\" line and a pointer to where the full notice is found.<one line to give the program\'s name and a brief idea of what it does.>\nCopyright (C) <year>  <name of author>\n\nThis program is free software: you can redistribute it and/or modify\nit under the terms of the GNU General Public License as published by\nthe Free Software Foundation, either version 3 of the License, or\n(at your option) any later version.\n\nThis program is distributed in the hope that it will be useful,\nbut WITHOUT ANY WARRANTY; without even the implied warranty of\nMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\nGNU General Public License for more details.\n\nYou should have received a copy of the GNU General Public License\nalong with this program.  If not, see <http://www.gnu.org/licenses/>.Also add information on how to contact you by electronic and paper mail.If the program does terminal interaction, make it output a short notice like this when it starts in an interactive mode:<program>  Copyright (C) <year>  <name of author>\nThis program comes with ABSOLUTELY NO WARRANTY; for details type `show w\'.\nThis is free software, and you are welcome to redistribute it\nunder certain conditions; type `show c\' for details.The hypothetical commands show w\' andshow c\' should show the appropriate parts of the General Public License.  Of course, your program\'s commands might be different; for a GUI interface, you would use an \"about box\".You should also get your employer (if you work as a programmer) or school, if any, to sign a \"copyright disclaimer\" for the program, if necessary. For more information on this, and how to apply and follow the GNU GPL, see http://www.gnu.org/licenses/.The GNU General Public License does not permit incorporating your program into proprietary programs.  If your program is a subroutine library, you may consider it more useful to permit linking proprietary applications with the library.  If this is what you want to do, use the GNU Lesser General Public License instead of this License.  But first, please read http://www.gnu.org/philosophy/why-not-lgpl.html."
},

{
    "location": "citing.html#",
    "page": "Citing CurricularAnalytics.jl",
    "title": "Citing CurricularAnalytics.jl",
    "category": "page",
    "text": ""
},

{
    "location": "citing.html#How-to-Cite-CurricularAnalytics.jl-1",
    "page": "Citing CurricularAnalytics.jl",
    "title": "How to Cite CurricularAnalytics.jl",
    "category": "section",
    "text": "We encourage you to cite our work if you have used our libraries, tools or datasets. Starring the repository on GitHub is also appreciated.To cite the latest version of the CurricularAnalytics Julia toolbox, @misc{CA:18,\n  author       = {Gregory L. Heileman and Hayden Free and {other contributors}},\n  title        = {CurricularAnalytics.jl},\n  year         = 2018,\n  doi          = {getDOI},\n  url          = {getURL}\n}For previous versions, please reference the zenodo site.To cite the definitive Curricular Analytics technical reference, please use the following BibTeX citation:@article{Heileman18,\n  author       = {Gregory L. Heileman and Chaouki T. Abdallah and Ahmad Slim and Michael Hickman},\n  title        = {Curricular Analytics: A Framework for Quantifying the Impact of Curricular Reforms and Pedagogical\nInnovationsl},\n  journal	= {to appear}\n  year         = 2018,\n  url          = {getURL}\n}"
},

]}
