# This is an example curriculum in ECE Department at UA

using CurricularAnalytics
using MetaGraphs
using Graphs

# # create learning outcomes
l = Array{LearningOutcome}(undef, 368)

# ECE 175
l[1] = LearningOutcome("Conceptualize engineering problems as computational problems","task",3)
l[2] = LearningOutcome("Handle the C programming language (syntax, IDE)","L2_task",3)
l[3] = LearningOutcome("Design computer programs using modular programming","L3_task",3)
l[4] = LearningOutcome("Understand the basics of data structures","L4_task",3)
l[5] = LearningOutcome("Perform dynamic memory management","L5_task",3)
l[6] = LearningOutcome("Implement algorithms for searching and sorting one-dimensional arrays","L6_task",3)
l[7] = LearningOutcome("Design computer programs using recursive programming techniques","task",3)
l[8] = LearningOutcome("Understand fundamental software notation and coding principles","task",3)
l[9] = LearningOutcome("Perform code debugging","task",3)
ece175_lo = l[1:9]

# ECE 207
l[10] = LearningOutcome("Solve a resistive network that is excited by an AC or a DC source","task",3)
l[11] = LearningOutcome("Solve first-order circuits involving resistors and a capacitor or an inductor","task",3)
l[12] = LearningOutcome("Derive the differential equations associated with a circuit containing one or two energy storage elements","task",3)
l[13] = LearningOutcome("Derive the complex impedance associated with a resistive, inductive and capacitive load","task",3)
l[14] = LearningOutcome("Use the ideal op-amp properties to derive the transfer function of an op-amp circuit","task",3)
l[15] = LearningOutcome("Select a current limiting resistor in an LED circuit","task",3)
l[16] = LearningOutcome("Create a transistor-based circuit to supply the necessary current to power a DC motor","task",3)
l[17] = LearningOutcome("Analyze a circuit containing one or more diodes","task",3)
l[18] = LearningOutcome("Determine the output of a collection of logic gates for a given input pattern","task",3)
l[19] = LearningOutcome("Analyze an AC circuit containing resistors, inductors and capacitors","task",3)
l[20] = LearningOutcome("State the current/voltage relationships of resistors, inductors and capacitors","task",3)
l[21] = LearningOutcome("Analyze a circuit containing a transformer","task",3)
l[22] = LearningOutcome("Design a low-pass filter with a particular bandwidth","task",3)
l[23] = LearningOutcome("Convert between decimal numbers and binary numbers","task",3)
ece207_lo = l[10:23]

# ECE 220
l[24] = LearningOutcome("Apply knowledge of mathematics, science and engineering","task",3)
l[25] = LearningOutcome("Design and conduct experiments, as well as analyze and interpret data","task",3)
l[26] = LearningOutcome("Identify, formulate and solve engineering problems","task",3)
l[27] = LearningOutcome("Communicate effectively in writing","task",3)
l[28] = LearningOutcome("Use the techniques, skills and modern engineering tools necessary for engineering practice","task",3)
ece220_lo = l[24:28]

# ECE 274A
l[29] = LearningOutcome("Give precise definitions of a Boolean algebra, Boolean functions, implicants and prime implicants, and the SOP and POS canonical forms of representation","task",3)
l[30] = LearningOutcome("Know how to construct basic gates (inverter, AND, OR) using NMOS and PMOS switches","task",3)
l[31] = LearningOutcome("Know the cause of delays associated with logic gates","task",3)
l[32] = LearningOutcome("Know number representations in different bases, and methods for converting from one base to another","task",3)
l[33] = LearningOutcome("Know the different binary representations of signed integers (2s complement, 1s complement, sign magnitude), methods of conversion, and basic arithmetic operations (addition, subtraction, multiplication, division)","task",3)
l[34] = LearningOutcome("Use Karnaugh maps and Quine-McCluskey tabular minimization technique for identifying all the prime implicants, and solve the covering problem to find a minimal gate, two-level implementation, for both completely specified and incompletely specified logic functions","task",3)
l[35] = LearningOutcome("Understand the principles behind the heuristic methods for two level logic minimization","task",3)
l[36] = LearningOutcome("Construct logic circuits of basic components such as adders, multipliers, decoders and multiplexors","task",3)
l[37] = LearningOutcome("Have an understanding of programmable devices such as FPGAs, and know how to use them to implement digital circuits","task",3)
l[38] = LearningOutcome("Have an understanding of the concept of state in functions that have history dependence","task",3)
l[39] = LearningOutcome("Understand the structure and operation of basic flip flops and latches","task",3)
l[40] = LearningOutcome("Know the structure and operation of ROMs and RAMs","task",3)
l[41] = LearningOutcome("Define a finite state machine and know what functions can and cannot be described as finite state machines","task",3)
l[42] = LearningOutcome("Be able to precisely define a Mealy and a Moore machine, and transform one to the other","task",3)
l[43] = LearningOutcome("Know how to construct tabular and graph representations of finite state machines for an informal description, including state diagrams and state machine charts","task",3)
l[44] = LearningOutcome("Have an understanding of the concept of machine equivalence, and be able to minimize a fully specified state table","task",3)
l[45] = LearningOutcome("Be able to take an informal word description of a sequential process and synthesize a state machine that performs the function","task",3)
l[46] = LearningOutcome("Know how to determine the clock period of a state machine","task",3)
l[47] = LearningOutcome("Understand the principles of register-transfer level (RTL) design and high-level state machines","task",3)
l[48] = LearningOutcome("Be able to take an informal word description of a digital circuit, design a high-level state machine for that circuit, and synthesize the high-level state machine to a final circuit implementation","task",3)
l[49] = LearningOutcome("Be able to design circuits using Verilog","task",3)
ece274A_lo = l[29:49]

# ECE 275
l[50] = LearningOutcome("Write, test and debug large software programs using C and C++ programming languages","task",3)
l[51] = LearningOutcome("Understand the compilation and linking process for software programs","task",3)
l[52] = LearningOutcome("Use commercial integrated-development environment (IDEs) for software development","task",3)
l[53] = LearningOutcome("Distinguish between statically allocated memory and dynamically allocated memory","task",3)
l[54] = LearningOutcome("Understand the C program memory organization and differentiate the location in which variables are stored within memory.","task",3)
l[55] = LearningOutcome("Trace the behavior of a function call using the program stack","task",3)
l[56] = LearningOutcome("Understand and use C programming constructs, including structs, pointers, strings, memory allocation, file IO and command line arguments.","task",3)
l[57] = LearningOutcome("Understand the relation between pointers and memory addresses","task",3)
l[58] = LearningOutcome("Create software programs that heavily use pointers and dynamic memory allocation","task",3)
l[59] = LearningOutcome("Implement data structures and supporting algorithms for common data structures, including lists, queues, stacks, trees and graphs","task",3)
l[60] = LearningOutcome("Create software programs to solve engineering problems using common data structures and algorithms","task",3)
l[61] = LearningOutcome("Analyze software code to determine the asymptotic runtime","task",3)
l[62] = LearningOutcome("Select appropriate data structures and algorithms to solve programing problems considering the asymptotic runtime","task",3)
l[63] = LearningOutcome("Understand the role of encapsulation, abstraction and code organization in the software design process","task",3)
l[64] = LearningOutcome("Understand and use C++ programming constructs, including classes, constructors and destructors, streams, references, operator overloading and dynamic memory allocation","task",3)
l[65] = LearningOutcome("Have a basic knowledge of the standard template library (STL)","task",3)
ece275_lo = l[50:65]

# ECE 304A
l[66] = LearningOutcome("Design a current mirror to meet specified compliance voltage, AC ripple requirements, and so on","task",3)
l[67] = LearningOutcome("Design differential amplifiers using active or resistive loads to meet large-signal swing and small-signal gain specifications","task",3)
l[68] = LearningOutcome("Design output stages to meet power delivery, efficiency and heating specifications","task",3)
l[69] = LearningOutcome("Relate capacitance in devices to the frequency performance of circuits, including the Miller effect","task",3)
l[70] = LearningOutcome("Use multiple stages (like the cascode, or voltage follower input and output stages) to avoid frequency limitations","task",3)
l[71] = LearningOutcome("Design a cascade of differential amplifiers that meets large signal and gain requirements","task",3)
l[72] = LearningOutcome("Use the methods of open- and short-circuit time constants to estimate bandwidth","task",3)
l[73] = LearningOutcome("Determine the loop gain of a feedback amplifier using return ratio","task",3)
l[74] = LearningOutcome("Determine the loaded gain of a feedback amplifier using two-ports","task",3)
l[75] = LearningOutcome("Design the four types of amplifier (voltage, current, transconductance and transresistance) based upon two-port theory and T-section resistor feedback networks","task",3)
l[76] = LearningOutcome("Relate feedback to frequency performance and stability using Bode plots","task",3)
l[77] = LearningOutcome("Design a stable circuit using Miller compensation","task",3)
l[78] = LearningOutcome("Design circuits to work for a range of device parameter variations","task",3)
l[79] = LearningOutcome("Build working circuit prototypes","task",3)
l[80] = LearningOutcome("Test and troubleshoot a prototype","task",3)
l[81] = LearningOutcome("Keep lab notebooks using standards required for use in a patent dispute","task",3)
l[82] = LearningOutcome("Write clear technical reports that meet professional standards","task",3)
l[83] = LearningOutcome("Use a variety of measurement instruments and techniques","task",3)
l[84] = LearningOutcome("Work closely with a colleague","task",3)
ece304A_lo = l[66:84]

# ECE 310
l[85] = LearningOutcome("Perform matrix algebra","task",3)
l[86] = LearningOutcome("Understand rank, basis, linear transformations, vector spaces, eigenvalues","task",3)
l[87] = LearningOutcome("Solve systems of linear equations","task",3)
l[88] = LearningOutcome("Describe basic principles of probability theory","task",3)
l[89] = LearningOutcome("Understand random variables, probability distributions, means and variances","task",3)
ece310_lo = l[85:89]

# ECE 320A
l[90] = LearningOutcome("Calculate the complex power, in terms of real and reactive components, in single-phase sinusoidal, steady-state systems","task",3)
l[91] = LearningOutcome("Design a reactive load that improves a system’s power factor","task",3)
l[92] = LearningOutcome("Convert wye-connected reactive loads to delta-connected reactive loads and vice versa","task",3)
l[93] = LearningOutcome("Solve for line currents, line voltages, phase currents, and phase voltages in arbitrarily interconnected balanced, three-phase circuits","task",3)
l[94] = LearningOutcome("Convert a given electrical circuit into its s-domain equivalent representation","task",3)
l[95] = LearningOutcome("Apply the Laplace transform operator to generic waveforms and calculate the inverse Laplace transform of a given s-domain function","task",3)
l[96] = LearningOutcome("Solve for currents and voltages in generic RLC circuits","task",3)
l[97] = LearningOutcome("Model RLC circuits with transfer functions","task",3)
l[98] = LearningOutcome("Calculate the output waveform from an input waveform and a system’s transfer function","task",3)
l[99] = LearningOutcome("Apply the initial value and final value theorems","task",3)
l[100] = LearningOutcome("Convolve two waveforms","task",3)
l[101] = LearningOutcome("Design simple passive frequency selective filters","task",3)
l[102] = LearningOutcome("Sketch the Bode diagrams associated with a transfer function","task",3)
l[103] = LearningOutcome("Design active frequency selective filters","task",3)
l[104] = LearningOutcome("Develop a Fourier series expansion for a periodic waveform","task",3)
l[105] = LearningOutcome("Calculate, using the Fourier series concept, a linear system’s output response when a periodic input waveform is applied to the linear system, if time permits","task",3)
ece320A_lo = l[90:105]

# ECE 330B
l[106] = LearningOutcome("Use Matlab for data manipulation, data plotting, and basic programming","task",3)
l[107] = LearningOutcome("Use Gnuplot to generate 2-D and 3-D plots","task",3)
l[108] = LearningOutcome("Work with Numerical Recipes and the GNU Scientific Library","task",3)
l[109] = LearningOutcome("Numerically differentiate and integrate functions with several techniques of different accuracy and efficiency","task",3)
l[110] = LearningOutcome("Transform systems of differential equations and solve them numerically with several techniques of increasing numerical accuracy","task",3)
l[111] = LearningOutcome("Solve systems of linear equations efficiently and invert matrices","task",3)
l[112] = LearningOutcome("Determine roots of functions numerically with several methods","task",3)
l[113] = LearningOutcome("Perform least squares optimization","task",3)
l[114] = LearningOutcome("Perform linear, polynomial and general curve fits","task",3)
l[115] = LearningOutcome("Solve optimization problems amenable to linear programming","task",3)
l[116] = LearningOutcome("Solve high-dimensional multivariate optimization problems in the presence of multiple/infinite local minima that cannot be solved with deterministic, gradient descent-based optimization techniques","task",3)
ece330B_lo = l[106:116]

# ECE 340A
l[117] = LearningOutcome("Identify the major signal types and obtain their key properties, such as energy, power, correlation, cross-correlation, auto-correlation","task",3)
l[118] = LearningOutcome("Obtain Fourier series for periodic signals","task",3)
l[119] = LearningOutcome("Sketch the magnitude and phase spectra for periodic signals and identify the discrete frequency components","task",3)
l[120] = LearningOutcome("Obtain Fourier transform for aperiodic signals and use it to sketch magnitude and phase spectra","task",3)
l[121] = LearningOutcome("Use Fourier transform theorems to describe frequency-domain effects of specific operations in the time-domain, such as time-shift, scaling, convolution, and so on","task",3)
l[122] = LearningOutcome("Calculate the bandwidth and the signal-to-noise ratio of a signal at the output of a linear time-invariant system","task",3)
l[123] = LearningOutcome("Explain the operation of amplitude and angle modulation systems in the time and frequency domains","task",3)
l[124] = LearningOutcome("Sketch the magnitude spectra and compute the bandwidth and power requirements for such signals","task",3)
l[125] = LearningOutcome("Evaluate a given analog or digital communication system in terms of the complexity of the transmitters and receivers and the power and bandwidth requirements of the system","task",3)
l[126] = LearningOutcome("Design a basic analog or digital communications system","task",3)
ece340A_lo = l[117:126]

# ECE 351C
l[127] = LearningOutcome("Design and analyze simple circuits involving diodes and transistors both analytically (by hand) to meet given specifications, and to verify and evaluate such designs using a computer simulation program, such as PSPICE","task",3)
l[128] = LearningOutcome("Design and analyze simple circuits involving diodes, such as clippers and rectifiers","task",3)
l[129] = LearningOutcome("Design and analyze simple linear amplifier circuits using MOS transistors","task",3)
l[130] = LearningOutcome("Design and analyze simple linear amplifier circuits using bipolar junction transistors","task",3)
l[131] = LearningOutcome("Design and analyze simple logic circuits using either BJTs or MOSFETs","task",3)    
ece351C_lo = l[127:131]    

# ECE 352
l[132] = LearningOutcome("Understand basic cubic crystal structure and origin of semiconductor characteristics: conduction band, valence band, energy gap, dopant atoms, host atoms, intrinsic and extrinsic materials, fixed charges and mobile carriers","task",3)
l[133] = LearningOutcome("Understand density of states and Fermi-Dirac distribution functions, effective mass, semiconductor band gap and carrier statistics, kinetic and potential carrier energies","task",3)
l[134] = LearningOutcome("Calculate properties of intrinsic and extrinsic semiconductor materials, e.g., Fermi levels and carrier concentrations","task",3)
l[135] = LearningOutcome("Apply principles of carrier drift to determine field dependent transport, conductivity, resistivity, resistance and sheet resistance.","task",3)
l[136] = LearningOutcome("Apply principles of carrier diffusion to determine carrier gradient dependent transport and derive the Einstein relation","task",3)
l[137] = LearningOutcome("Understand band diagrams and determine carrier potential and kinetic energies.","task",3)
l[138] = LearningOutcome("Use defect densities and carrier recombination processes to calculate generation and recombination rates in semiconductor devices and materials","task",3)
l[139] = LearningOutcome("Apply continuity equation to solve dynamics of carrier transport and recombination in semiconductor devices and materials","task",3)
l[140] = LearningOutcome("Calculate carrier densities, quasi Fermi levels, and currents in biased metal-semiconductor and p-n junctions","task",3)
l[141] = LearningOutcome("Determine device/material parameters given an experimental energy diagram characteristic for MS, p-n junction and MOS capacitor structures","task",3)
l[142] = LearningOutcome("Extract MOS transistor parameters from device process variables such as substrate doping and channel length","task",3)
l[143] = LearningOutcome("Understand device capacitance functions","task",3)
l[144] = LearningOutcome("Identify deviations in ideal and real device characteristics","task",3)
ece352_lo = l[132:144]

# ECE 369A
l[145] = LearningOutcome("Understand the fundamentals of computer architecture","task",3)
l[146] = LearningOutcome("Explore the computer architecture field on their own","task",3)
l[147] = LearningOutcome("Articulate the design issues involved in computer architecture at theoretical and application levels","task",3)
l[148] = LearningOutcome("Design and implement single-cycle and pipelined datapaths for a given instruction set architecture","task",3)
l[149] = LearningOutcome("Evaluate the close relation between instruction set architecture design, datapath design, and algorithm design","task",3)
l[150] = LearningOutcome("Understand the performance trade-offs involved in designing the memory subsystem, including cache, main memory and virtual memory","task",3)
l[151] = LearningOutcome("Discuss the modern multicore architectures, such as the NVIDIA graphics processing unit","task",3)
l[152] = LearningOutcome("Evaluate analytically the performance of a hypothetical architecture","task",3)
ece369A_lo = l[145:152]

# ECE 372A
l[153] = LearningOutcome("Explain the basics of an embedded computer system","task",3)
l[154] = LearningOutcome("Write and debug C programs for a microcontroller","task",3)
l[155] = LearningOutcome("Understand memory and memory-mapped addresses in embedded systems","task",3)
l[156] = LearningOutcome("Interface with hardware components using a microcontroller","task",3)
l[157] = LearningOutcome("Understand timing and interrupts in embedded systems","task",3)
l[158] = LearningOutcome("Have knowledge of common hardware communication protocols","task",3)
ece372A_lo = l[153:158]

# ECE 373
l[159] = LearningOutcome("Understand the fundamentals of OO programming vs. procedural programming","task",3)
l[160] = LearningOutcome("Understand the connections between various UML diagrams for a consistent design","task",3)
l[161] = LearningOutcome("Perform a design criticism","task",3)
l[162] = LearningOutcome("Engineer and develop software systems through object-oriented methods","task",3)
ece373_lo = l[159:162]

# ECE 381A
l[163] = LearningOutcome("Perform vector calculus operations such as the gradient, the divergence and the curl","task",3)
l[164] = LearningOutcome("Identify and list Maxwell's equations in time domain, as well as associated boundary conditions","task",3)
l[165] = LearningOutcome("Apply Coulomb's law to find the force on a charge caused by other charges","task",3)
l[166] = LearningOutcome("Apply Gauss' law to determine the electric field caused by a simple charge distribution","task",3)
l[167] = LearningOutcome("Calculate the electrostatic potential of simple charge distributions","task",3)
l[168] = LearningOutcome("Explain the effects of conducting and dielectric materials on field quantities","task",3)
l[169] = LearningOutcome("List the boundary conditions for the electric field vectors on the interface of two different materials","task",3)
l[170] = LearningOutcome("Calculate the energy stored in an electrostatic field.","task",3)
l[171] = LearningOutcome("Identify Poisson's and Laplace's equations and solve them to find electrostatic potentials and fields","task",3)
l[172] = LearningOutcome("Calculate the capacitance for basic configurations that reduce to one-dimensional systems","task",3)
l[173] = LearningOutcome("Apply the method of images to find electrostatic potentials and fields of simple charge distributions above perfect conductors","task",3)
l[174] = LearningOutcome("Describe the conservation of charge and Ohm's laws and write them in vector calculus format","task",3)
l[175] = LearningOutcome("Apply Ampere's force law to calculate the force between constant currents of simple configurations","task",3)
l[176] = LearningOutcome("Apply the Biot-Savart law to calculate the magnetic flux density caused by a simple current configuration","task",3)
l[177] = LearningOutcome("Apply Ampere's law to calculate the magnetic field produced by simple current configurations","task",3)
l[178] = LearningOutcome("Identify the magnetostatic potential and flux","task",3)
l[179] = LearningOutcome("Identify and list different magnetic materials","task",3)      
ece381A_lo = l[163:179]  

# ECE 407
l[180] = LearningOutcome("Use circuit simulator (i.e., SPICE) and layout editor (i.e., Cadence tool) to design inverters, adders and latches","task",3)
l[181] = LearningOutcome("Apply static and dynamic design styles to implement combinational and sequential circuits","task",3)
l[182] = LearningOutcome("Understand Moore's law, yield, process variations, design robustness, leakage and time to market","task",3)
l[183] = LearningOutcome("Understand the tradeoffs among system performance, area consumption, and cost","task",3)
l[184] = LearningOutcome("Compare and evaluate different designs and understand the technology scaling issues","task",3)
l[185] = LearningOutcome("Formulate problems or model systems in device physics, signal processing and related disciplines, such as information, biology and biomedical engineering","task",3)
l[186] = LearningOutcome("Evaluate timing, reliability and flexibility of circuits and systems with different models","task",3)   
ece407_lo = l[180:186]  

# ECE 411
l[187] = LearningOutcome("Use Matlab for data manipulation, data plotting, and programming","task",3)
l[188] = LearningOutcome("Numerically differentiate and integrate functions with several techniques of different accuracy and efficiency","task",3)
l[189] = LearningOutcome("Transform systems of differential equations and solve them numerically with several techniques of increasing numerical accuracy","task",3)
l[190] = LearningOutcome("Solve systems of linear equations efficiently","task",3)
l[191] = LearningOutcome("Understand the underlying theory for a variety of systems in physics and biology, model these systems by deriving the necessary mathematical equations describing these systems, understand and apply the necessary numerical methods to solve the underlying equations, and program the system equations and numerical methods in Matlab to simulate the systems","task",3)
l[192] = LearningOutcome("Formulate problems or model systems in physics, biology and related disciplines, and solve them numerically or in simulation","task",3)
l[193] = LearningOutcome("Know and assess the validity, limits and pitfalls of numerical simulations","task",3)
ece411_lo = l[187:193]

# ECE 414A
l[194] = LearningOutcome("Compute basic solar irradiance characteristics","task",3)
l[195] = LearningOutcome("Understand circuit properties of photovoltaic cells","task",3)
l[196] = LearningOutcome("Understand the physical parameters of solar cell operation","task",3)
l[197] = LearningOutcome("Understand the properties of solar cells and modules and the basic design properties affecting their performance","task",3)
l[198] = LearningOutcome("Design a photovoltaic system to meet specific requirements","task",3)
l[199] = LearningOutcome("Have a basic understanding of thin-film and multijunction PV cells","task",3)
l[200] = LearningOutcome("Have a basic understanding of solar concentrators","task",3)
ece414A_lo = l[194:200]

# ECE 429
l[201] = LearningOutcome("State and apply the definitions of the following system properties: linearity, time invariance, causality, and BIBO stability.","task",3)
l[202] = LearningOutcome("Describe the distinctions between analog, continuous-time, discrete-time and digital signals, and describe the basic operations involved in analog-digital (A/D) and digital-analog (D/A) conversion.","task",3)
l[203] = LearningOutcome("State and apply the definition of a periodic discrete-time signal.","task",3)
l[204] = LearningOutcome("State the sampling theorem and explain aliasing.","task",3)
l[205] = LearningOutcome("Apply simple discrete-time signals to filters to obtain the output response.","task",3)
l[206] = LearningOutcome("Convolve discrete-time signals.","task",3)
l[207] = LearningOutcome("Calculate the z-transform X(z) of a simple signal x(n) (such as an exponential and sinusoid): specify the region of convergence (ROC) of X(z).","task",3)
l[208] = LearningOutcome("Apply z-transform theorems.","task",3)
l[209] = LearningOutcome("Given the transfer function H(z) and ROC of an LTI system, find the system poles (and zeros) and state whether or not the system is BIBO stable.","task",3)
l[210] = LearningOutcome("Compute the discrete-time Fourier transform (DTFT) of a signal.","task",3)
l[211] = LearningOutcome("Use the frequency response of a discrete-time system.","task",3)
l[212] = LearningOutcome("Knowing the poles and zeros of a transfer function, make a rough sketch of the gain response.","task",3)
l[213] = LearningOutcome("Design digital filters.","task",3)
l[214] = LearningOutcome("Apply DFT properties to compute the DFT and IDFT of simple signals.","task",3)
l[215] = LearningOutcome("Design the parameters associated with DFT implementation (sampling rate and record length) to provide an accurate analysis of the frequency and strength of dominant frequency components present in some given, unknown signal (e.g., for spectral analysis of a signal).","task",3)
l[216] = LearningOutcome("Explain the need for zero padding and tapered windows when doing spectral analysis of real-world signals. Explain the terms picket fence effect and spectral leakage.","task",3)
l[217] = LearningOutcome("Compare the characteristics (advantages and disadvantages) of IIR and FIR filters.","task",3)
l[218] = LearningOutcome("Explain (using frequency domain sketches) the application of oversampling and subsequent decimation for recording in digital audio systems.","task",3)
ece429_lo = l[201:218]

# ECE 434
l[219] = LearningOutcome("By the end of this course the student will be able to classify optical properties and electrical properties of materials according to material type, structure and physical properties.","task",3)
ece434_lo = l[219:219]

# ECE 435A
l[220] = LearningOutcome("Understand and compute Shannon capacity of various communications channels","task",3)
l[221] = LearningOutcome("Write software and analyze source coding algorithms such as Huffman, arithmetic and Ziv-Lempel coding, and channel coding schemes as convolutional codes and linear block codes","task",3)
l[222] = LearningOutcome("Rigorously analyze and develop simulation models for coded digital communications systems such as PSK, ASK and QAM","task",3)
l[223] = LearningOutcome("Design optimal detectors in presence of AWGN","task",3)
ece435A_lo = l[220:223]

# ECE 441A
l[224] = LearningOutcome("Model – via differential equations or transfer functions – electrical, mechanical and electromechanical dynamical systems","task",3)
l[225] = LearningOutcome("Linearize a set of nonlinear dynamical equations","task",3)
l[226] = LearningOutcome("Create a second-order model from a system's step response","task",3)
l[227] = LearningOutcome("Construct all-integrator block diagrams from a transfer function, a set of differential equations, or a state-space representation and vice versa","task",3)
l[228] = LearningOutcome("Compute a state transition matrix from a system matrix","task",3)
l[229] = LearningOutcome("Describe -- in terms of percent overshoot -- settling time, steady-state error, rise-time or peak-time how the poles of a second-order continuous-time system influence the transient response","task",3)
l[230] = LearningOutcome("Translate design specifications into allowable dominant pole locations in the s-plane","task",3)
l[231] = LearningOutcome("Calculate a system's steady-state error and how the steady-state error can be influenced via system parameter changes","task",3)
l[232] = LearningOutcome("Construct and interpret the Routh array.","task",3)
l[233] = LearningOutcome("Determine the stability of a closed-loop system","task",3)
l[234] = LearningOutcome("Calculate a system's sensitivity with respect to different parameters","task",3)
l[235] = LearningOutcome("Sketch the root locus associated with a transfer function","task",3)
l[236] = LearningOutcome("Design analog controllers using root locus techniques","task",3)
l[237] = LearningOutcome("Design an analog PID controller to meet design specifications","task",3)
l[238] = LearningOutcome("Calculate the phase margin and gain margin of a system from its frequency response (Bode plots)","task",3)
l[239] = LearningOutcome("Design analog controllers using Bode plot techniques","task",3)
l[240] = LearningOutcome("Design full-state feedback gains to achieve acceptable closed-loop behavior","task",3)
ece441A_lo = l[224:240]

# ECE 442
l[241] = LearningOutcome("Convert a continuous-time system into a discrete-time system (frequency and time domain techniques)","task",3)
l[242] = LearningOutcome("Compute the z-transform of elementary signals and difference equations","task",3)
l[243] = LearningOutcome("Determine the poles of a second-order system based on the system's transient response (both continuous time and discrete time systems)","task",3)
l[244] = LearningOutcome("Determine the stability of a closed-loop system (both continuous time and discrete time systems)","task",3)
l[245] = LearningOutcome("Sketch the root locus associated with a system's transfer function (both G[s] and G[z])","task",3)
l[246] = LearningOutcome("Translate design specifications into allowable dominant pole locations in both the s-plane and the z-plane","task",3)
l[247] = LearningOutcome("Design controllers using root locus techniques (both continuous time and discrete time)","task",3)
l[248] = LearningOutcome("Incorporate time delay introduced by a zero-order hold and know how to accommodate this delay during a digital controller design","task",3)
l[249] = LearningOutcome("Obtain discrete equivalents of analog transfer functions","task",3)
l[250] = LearningOutcome("Apply full-state feedback to achieve acceptable closed-loop behavior for discrete-time systems","task",3)
l[251] = LearningOutcome("Design an estimator and use it to control a discrete-time system","task",3)
l[252] = LearningOutcome("Design a digital PID controller based on an existing analog PID controller","task",3)
l[253] = LearningOutcome("Transform between difference equations, block diagrams, and transfer functions associated with discrete systems","task",3)
l[254] = LearningOutcome("Compute closed-form expressions for output waveforms from discrete-time systems with inputs","task",3)
l[255] = LearningOutcome("Determine the steady-state error in continuous time and discrete time systems","task",3)
l[256] = LearningOutcome("Transform discrete-time systems between transfer function and state-space representations","task",3)
ece442_lo = l[241:256]

# ECE 456
l[257] = LearningOutcome("Understand the electromagnetic spectrum, wave equation and wave propagation in linear isotropic media and in anisotropic media.","task",3)
l[258] = LearningOutcome("Understand basic radiometric quantities and perform analyses of basic radiometric designs","task",3)
l[259] = LearningOutcome("USe matrix methods to model and interpret image formation and beam propagation (both plane wave and Gaussian beam) in an optical system","task",3)
l[260] = LearningOutcome("Understand the function and design of an optical resonator","task",3)
l[261] = LearningOutcome("Calculate resonator mode characteristics and determine mode stability in an optical resonator","task",3)
l[262] = LearningOutcome("Understand cavity Q, constructive and destructive interference","task",3)
l[263] = LearningOutcome("Interpret resonator output spectra, including calculating and interpreting cavity finesse, resolution, mode spacing, etc.","task",3)
l[264] = LearningOutcome("Understand the design and function of a Fabry-Perot etalon optical spectrum analyzer","task",3)
l[265] = LearningOutcome("Design an optical resonator (mirror curvature, size, separation, Gaussian beam characteristics in resonator) and understand sources of loss","task",3)
l[266] = LearningOutcome("Understand the function and design of laser gain media: gas, liquid, solid-state","task",3)
l[267] = LearningOutcome("Understand energy band diagrams, band gap, excited states, spontaneous emission, stimulated emission, state lifetimes, lineshape broadening: homogeneous and inhomogeneous, Einstein A and B coefficients, rate equations, exponential gain coefficient, population inversion, intensity","task",3)
l[268] = LearningOutcome("Design 3- and 4-level laser gain media based on desired design constraints","task",3)
l[269] = LearningOutcome("Understand the impact of placing the gain medium inside a resonator to produce a laser: laser gain profile, spectrum, threshold, population inversion, critical fluorescence power, stimulated emission power, output power","task",3)
l[270] = LearningOutcome("Understand the function and design of Q switch devices and methods and mode locking devices and methods","task",3)
l[271] = LearningOutcome("Discuss a variety of laser types (descriptions, pros, cons)","task",3)
ece456_lo = l[257:271]

# ECE 459
l[272] = LearningOutcome("Understand the basic concepts of physical and geometrical optics as they relate to engineering applications","task",3)
l[273] = LearningOutcome("Layout designs for basic optical systems","task",3)
l[274] = LearningOutcome("Understand the properties of optical waveguides and fibers","task",3)
l[275] = LearningOutcome("Understand the basic concepts of image analysis","task",3)
ece459_lo = l[272:275]

# ECE 462
l[276] = LearningOutcome("Understand the techniques of quantitative analysis and evaluation of modern computing systems","task",3)
l[277] = LearningOutcome("Articulate cost-performance-energy trade-offs and good engineering design","task",3)
l[278] = LearningOutcome("Design and implement major component subsystems of high-performance computers: pipelining, instruction-level parallelism, memory hierarchies, input/output, and network-oriented interconnections","task",3)
l[279] = LearningOutcome("Undertake a major computing system analysis and design","task",3)
l[280] = LearningOutcome("Identify the types of parallelism (data, instruction, thread, request-level) that could be extracted from a given application","task",3)
l[281] = LearningOutcome("Identify the hardware architecture type that matches with the program architecture for a given application","task",3)
l[282] = LearningOutcome("Evaluate the close relation between the instruction set architecture design, datapath design, and algorithm design","task",3)
l[283] = LearningOutcome("Evaluate and analyze modern multicore architectures, including the datapath and memory subcomponents along with the hardware and software structures enabling cache coherence, dynamic scheduling and out-of-order execution","task",3)
l[284] = LearningOutcome("Quantify and the discuss design trade-offs involved in warehouse-scale computers in terms of cost, energy-efficiency, reliability, and network structure","task",3)
l[285] = LearningOutcome("Identify the relationship between the programming models, workloads and architectures for warehouse-scale computers (cloud computing)","task",3)
ece462_lo = l[276:285]

# ECE 466
l[286] = LearningOutcome("Understand propositional and first-order logic","task",3)
l[287] = LearningOutcome("Represent information in first-order logical formulas, and perform formula unification/matching","task",3)
l[288] = LearningOutcome("Understand forward and backward automated inference","task",3)
l[289] = LearningOutcome("Formulate problems as state-space search","task",3)
l[290] = LearningOutcome("Develop programs for breadth-first, depth-first, heuristic, and hill-climbing searches","task",3)
l[291] = LearningOutcome("Represent information in semantic networks","task",3)
l[292] = LearningOutcome("Understand constraint networks, constraint satisfaction, and develop programs for constraint satisfaction","task",3)
l[293] = LearningOutcome("Understand genetic operators, genetic optimization and genetic learning, and write programs for this purpose","task",3)
l[294] = LearningOutcome("Understand Bayes rules, Bayesian belief networks, and evidence accumulation","task",3)
ece466_lo = l[286:294]

# ECE 474A
l[295] = LearningOutcome("Understand the difference between heuristic and exact optimization methods, and be able to classify a variety of algorithms into these categories","task",3)
l[296] = LearningOutcome("Use the Quine-McCluskey tabular minimization technique for identifying all the prime implicants, and solve the covering problem using Petrick's method to find an optimal two-level implementation for both completely specified and incompletely specified logic functions","task",3)
l[297] = LearningOutcome("Use Quine-McCluskey with iterative and recursive consensus methods for identifying all the prime implicants (complete sum) and solve the covering problem using row/column dominance to find a minimal gate, two-level implementation for both completely specified and incompletely specified logic functions","task",3)
l[298] = LearningOutcome("Understand how generalized optimization algorithms can be adapted to the logic minimization problem","task",3)
l[299] = LearningOutcome("Use branch and bound along with MIS to solve the covering problem","task",3)
l[300] = LearningOutcome("Understand Espresso's representation of Boolean functions and basic operations on compact cubical format","task",3)
l[301] = LearningOutcome("Use Espresso's unate complement, complement and expand subprocedures","task",3)
l[302] = LearningOutcome("Understand a variety of scheduling algorithms, including ASAP, ALAP, Hu, LIST_L, LIST_R and force-directed","task",3)
l[303] = LearningOutcome("Understand a variety of methods used for resource sharing and binding","task",3)
l[304] = LearningOutcome("Understand the role of verification in CAD along with the different testing methods","task",3)
l[305] = LearningOutcome("Design logic minimization tools in C/C++ and output the resulting circuit implementation in Verilog or equivalent textual representation","task",3)
ece474A_lo = l[295:305]

# ECE 478
l[306] = LearningOutcome("Network design principles and performance metrics","task",3)
l[307] = LearningOutcome("The mechanisms and protocols for reliable data communication via a computer network","task",3)
l[308] = LearningOutcome("How to evaluate the performance of different network architectures and protocols.","task",3)
l[309] = LearningOutcome("Schematics of computer network architectures","task",3)
l[310] = LearningOutcome("Applications of computer networks.","task",3)
l[311] = LearningOutcome("The OSI layering model","task",3)
l[312] = LearningOutcome("Direct link networks","task",3)
l[313] = LearningOutcome("Medium access control","task",3)
l[314] = LearningOutcome("Wireless network technologies","task",3)
l[315] = LearningOutcome("Internetworking","task",3)
l[316] = LearningOutcome("End-to-end protocols","task",3)
l[317] = LearningOutcome("Congestion control and resource allocation","task",3)
l[318] = LearningOutcome("Network security","task",3)
ece478_lo = l[306:318]

# ECE 479
l[319] = LearningOutcome("Demonstrate the ability to solve combinatorially complex problems by using heuristic techniques","task",3)
l[320] = LearningOutcome("Construct knowledge representations and apply them as the foundation for design and analysis of complex computer-based systems","task",3)
l[321] = LearningOutcome("Demonstrate an understanding of planning techniques, construct plans and plan-generating systems","task",3)
l[322] = LearningOutcome("Design knowledge-based systems","task",3)
l[323] = LearningOutcome("Design and implement reasoning engines and theroem provers","task",3)
ece479_lo = l[319:323]

# ECE 484
l[324] = LearningOutcome("Have practice with foundational aspects of antenna engineering through homework and problem analysis; foundations are not extensive, yet the student will develop quality and critical thinking checks necessary for extended study and mastery of selected subjects in antenna engineering.","task",3)
l[325] = LearningOutcome("Have 10 or more hours of hands-on experience in antenna engineering (engineering, design, analysis) EDA tools","task",3)
l[326] = LearningOutcome("Be exposed to the historical aspects that relate to the current developments and future technology advances in antenna engineering","task",3)
l[327] = LearningOutcome("Become mindful of some nonantenna engineering aspects (manufacturability, reliability, consumer demand, constraints in materials) that influence future technology advances and contributions in research and industry","task",3)
ece484_lo = l[324:327]

# ECE 486
l[328] = LearningOutcome("Have practice with foundational aspects of microwave engineering through homework and problem analysis; students will develop quality and critical thinking checks necessary for extended study and mastery of selected subjects in microwave engineering well beyond the extent of the semester-long class","task",3)
l[329] = LearningOutcome("Have 15 or more hours of hands-on experience in microwave engineering (engineering, design, analysis) EDA tools","task",3)
l[330] = LearningOutcome("Be exposed to the historical aspects that relate to current developments and future technology advances in microwave engineering","task",3)
l[331] = LearningOutcome("Become mindful of some nonmicrowave engineering aspects (manufacturability, consumer demand, constraints in materials) that influence future technology advances and contributions in research and industry","task",3)
ece486_lo = l[328:331]

# ECE 488
l[332] = LearningOutcome("Understand various modulation schemes, the basics of wireless transmitters and receivers, and the basics of antennas and the wireless link","task",3)
l[333] = LearningOutcome("Explain the operation of varactor frequency multiplier","task",3)
l[334] = LearningOutcome("Determine which active microwave circuit to use depending on the application","task",3)
l[335] = LearningOutcome("Identify potential limitations in the circuit fabrication process","task",3)
l[336] = LearningOutcome("Design a two-port negative resistor microwave oscillator","task",3)
l[337] = LearningOutcome("Explain how different fabrication steps can affect active circuit performance, and explain how each affects it","task",3)
l[338] = LearningOutcome("Perform microwave measurements for the active circuit of the design","task",3)
l[339] = LearningOutcome("Explain differences between simulated and measured data of active microwave","task",3)
l[340] = LearningOutcome("Apply the Nyquist test to determine conditions of unstable operations of a given circuit","task",3)
l[341] = LearningOutcome("Describe the operation of one-port negative resistance oscillators","task",3)
l[342] = LearningOutcome("Evaluate the dynamic range of a microwave amplifier","task",3)
l[343] = LearningOutcome("Distinguish between class A, B and C microwave amplifiers","task",3)
l[344] = LearningOutcome("Design various types of microwave amplifiers: low-noise, broadband, feedback and two-stage","task",3)
l[345] = LearningOutcome("Design a DC bias network for a microwave amplifier","task",3)
l[346] = LearningOutcome("Design a microwave amplifier for a specific power gain, input/output VSWR, and with good ac performance","task",3)
l[347] = LearningOutcome("Plot power gain circles for a two-port network","task",3)
l[348] = LearningOutcome("Design a microwave amplifier for a specific operating power gain and stability","task",3)
l[349] = LearningOutcome("Identify and evaluate the unilateral figure of merit","task",3)
l[350] = LearningOutcome("Outline the procedure for drawing the constant G-circles for unconditionally stable and potentially unstable cases","task",3)
l[351] = LearningOutcome("Explain when a two-port network is unilateral","task",3)
l[352] = LearningOutcome("Determine the stability of an amplifier from the transistor, matching networks and terminations","task",3)
l[353] = LearningOutcome("Calculate the input and output VSWR of a microwave amplifier","task",3)
l[354] = LearningOutcome("Identify the different power gain expressions of microwave amplifier circuits, and calculate from s-parameters","task",3)
l[355] = LearningOutcome("Apply signal flow graphs to evaluate scattering and other parameters of microwave circuits","task",3)
l[356] = LearningOutcome("Explain how to measure a transistor's s-parameters","task",3)
l[357] = LearningOutcome("Identify the small-signal electric models of microwave transistors","task",3)
l[358] = LearningOutcome("Describe the characteristics of bipolar and FET microwave transistors","task",3)
l[359] = LearningOutcome("Identify and design various types of microwave mixers, as well as parameters used for evaluating their performance","task",3)
l[360] = LearningOutcome("Explain how diodes can be used for RF/microwave signal detection and mixing","task",3)
l[361] = LearningOutcome("Describe the operation of a Schottky barrier diode","task",3)
l[362] = LearningOutcome("Explain the role and operation of the depletion and diffusion capacitance","task",3)
l[363] = LearningOutcome("Identify the diode equation, the small signal model and equivalent circuit","task",3)
l[364] = LearningOutcome("Create all active circuit designs in microstrip form","task",3)
l[365] = LearningOutcome("Apply single- or double-stub matching network designs for circuits in microstrip form","task",3)
l[366] = LearningOutcome("Design single- and double-stub matching networks for various loads","task",3)
l[367] = LearningOutcome("Design lumped element maltching networks","task",3)
l[368] = LearningOutcome("Understand fundamentals of RF systems","task",3)
ece488_lo = l[332:368]


# Add requisites for learning outcomes
add_lo_requisite!(l[1],l[2],pre)
add_lo_requisite!(l[5],l[9],pre)
add_lo_requisite!(l[10],l[20],pre)
add_lo_requisite!(l[29],l[32],pre)
add_lo_requisite!(l[50],l[56],pre)
add_lo_requisite!(l[66],l[79],pre)
add_lo_requisite!(l[87],l[89],pre)
add_lo_requisite!(l[90],l[92],pre)
add_lo_requisite!(l[103],l[105],pre)
add_lo_requisite!(l[106],l[116],pre)


# create the courses
c = Array{Course}(undef, 34)

c[1] = Course("Computer Programming for Engineering Applications", 3, prefix = "ECE ", learning_outcomes = ece175_lo,num = "175")
c[2] = Course("Elements of Electrical Engineering", 3, prefix = "ECE", learning_outcomes = ece207_lo,num ="207")
c[3] = Course("Basic Circuits", 3, prefix = "ECE", learning_outcomes = ece220_lo, num = "220" )
c[4] = Course("Digital Logic", 3, prefix = "ECE", learning_outcomes = ece274A_lo, num = "274A")
c[5] = Course("Computer Programming for Engineering Applications II", 3, prefix = "ECE", learning_outcomes = ece275_lo, num = "275")
c[6] = Course("Design of Electronic Circuits", 3, prefix = "ECE", learning_outcomes = ece304A_lo, num = "304A")
c[7] = Course("Applications of Engineering Mathematics", 3, prefix = "ECE", learning_outcomes = ece310_lo, num = "310")
c[8] = Course("Circuit Theory", 3, prefix = "ECE", learning_outcomes = ece320A_lo, num = "320A")
c[9] = Course("Computational Techniques", 3, prefix = "ECE", learning_outcomes = ece330B_lo, num = "330B")
c[10] = Course("Introduction to Communications", 3, prefix = "ECE", learning_outcomes = ece340A_lo, num = "340A")
c[11] = Course("Electronic Circuits", 3, prefix = "ECE", learning_outcomes = ece351C_lo, num = "351C")
c[12] = Course("Device Electronics", 3, prefix = "ECE", learning_outcomes = ece352_lo, num = "352")
c[13] = Course("Fundamentals of Computer Organization", 3, prefix = "ECE", learning_outcomes = ece369A_lo, num = "369A")
c[14] = Course("Microprocessor Organization", 3, prefix = "ECE", learning_outcomes = ece372A_lo, num = "372A")
c[15] = Course("Object-Oriented Software Design", 3, prefix = "ECE", learning_outcomes = ece373_lo, num = "373")
c[16] = Course("Introductory Electromagnetics", 3, prefix = "ECE", learning_outcomes = ece381A_lo, num = "381A")
c[17] = Course("Digital VLSI Systems Design", 3, prefix = "ECE", learning_outcomes = ece407_lo, num = "407")
c[18] = Course("Numeric Modeling of Physics & Biological Systems", 3, prefix = "ECE", learning_outcomes = ece411_lo, num = "411")
# c[19] = Course("Web Development and the Internet of Things", 3, prefix = "ECE", learning_outcomes = ece413_lo, num = "413")
c[19] = Course("Photovoltaic Solar Energy Systems", 3, prefix = "ECE", learning_outcomes = ece414A_lo, num = "414A")
c[20] = Course("Digital Signal Processing", 3, prefix = "ECE", learning_outcomes = ece429_lo, num = "429")
c[21] = Course("Electrical and Optical Properties of Materials", 3, prefix = "ECE", learning_outcomes = ece434_lo, num = "434")
c[22] = Course("Digital Communications Systems", 3, prefix = "ECE", learning_outcomes = ece435A_lo, num = "435A")
c[23] = Course("Automatic Control", 3, prefix = "ECE", learning_outcomes = ece441A_lo, num = "441A")
c[24] = Course("Digital Control Systems", 3, prefix = "ECE", learning_outcomes = ece442_lo, num = "442")
c[25] = Course("Optoelectronics", 3, prefix = "ECE", learning_outcomes = ece456_lo, num = "456")
c[26] = Course("Fundamentals of Optics for Electrical Engineers", 3, prefix = "ECE", learning_outcomes = ece459_lo, num = "459")
c[27] = Course("Computer Architecture and Design", 3, prefix = "ECE", learning_outcomes = ece462_lo, num = "462")
c[28] = Course("Knowledge-System Engineering", 3, prefix = "ECE", learning_outcomes = ece466_lo, num = "466")
# c[30] = Course("Fundamentals of Information and Network Security", 3, prefix = "ECE", learning_outcomes = ece471_lo, num = "471")
# c[31] = Course("Design, Modeling, and Simulation for High Technology Systems in Medicine", 3, prefix = "ECE", learning_outcomes = ece472_lo, num = "472")
c[29] = Course("Computer-Aided Logic Design", 3, prefix = "ECE", learning_outcomes = ece474A_lo, num = "474A")
c[30] = Course("Fundamentals of Computer Networks", 3, prefix = "ECE", learning_outcomes = ece478_lo, num = "478")
c[31] = Course("Principles of Artificial Intelligence", 3, prefix = "ECE", learning_outcomes = ece479_lo, num = "479")
c[32] = Course("Antenna Theory and Design", 3, prefix = "ECE", learning_outcomes = ece484_lo, num = "484")
c[33] = Course("Microwave Engineering I: Passive Circuit Design", 3, prefix = "ECE", learning_outcomes = ece486_lo, num = "486")
c[34] = Course("Microwave Engineering II: Active Circuit Design", 3, prefix = "ECE", learning_outcomes = ece488_lo, num = "488")

# Add requisites for each course if specified
add_requisite!(c[1],c[5],pre)
add_requisite!(c[11],c[6],pre)
add_requisite!(c[5],c[7],pre)
add_requisite!(c[3],c[7],pre) # or add_requisite!(c[2],c[7],pre)
add_requisite!(c[3],c[8],pre)
add_requisite!(c[1],c[9],pre)
add_requisite!(c[8],c[10],pre)
add_requisite!(c[8],c[11],pre)
add_requisite!(c[11],c[12],pre)
add_requisite!(c[1],c[13],pre)
add_requisite!(c[4],c[13],pre)
add_requisite!(c[2],c[14],pre) # or add_requisite!(c[3],c[14],pre)
add_requisite!(c[4],c[14],pre)
add_requisite!(c[5],c[14],pre)
add_requisite!(c[5],c[15],pre)
add_requisite!(c[3],c[16],pre)
add_requisite!(c[4],c[17],pre)
add_requisite!(c[11],c[17],pre)
add_requisite!(c[10],c[20],pre)
add_requisite!(c[10],c[22],pre)
add_requisite!(c[7],c[22],pre)
add_requisite!(c[10],c[23],pre)
add_requisite!(c[8],c[24],pre)
add_requisite!(c[12],c[25],pre)
add_requisite!(c[16],c[25],pre)
add_requisite!(c[16],c[26],pre)
add_requisite!(c[13],c[27],pre)
add_requisite!(c[4],c[29],pre)
add_requisite!(c[5],c[29],pre)
add_requisite!(c[5],c[30],pre)
add_requisite!(c[7],c[30],pre)
add_requisite!(c[15],c[31],pre)
add_requisite!(c[16],c[32],pre)
add_requisite!(c[16],c[33],pre)
add_requisite!(c[33],c[34],pre)

# Create curriculum based on previous courses and learning_outcomes
curric = Curriculum("Example ECE Department at UA ", c, learning_outcomes = l)

# mg = curric.course_learning_outcome_graph
# g = curric.graph
# g = curric.learning_outcome_graph

# print(curric.courses)
# print(curric.learning_outcomes)
# print(curric.graph)
# print(curric.lo_graph)

errors = IOBuffer()
if is_valid(curric, errors)
    println("Curriculum $(curric.name) is valid")
    println("  delay factor = $(delay_factor(curric))")
    println("  blocking factor = $(blocking_factor(curric))")
    println("  centrality factor = $(centrality(curric))")
    println("  curricular complexity = $(complexity(curric))")
else
    println("Curriculum $(curric.name) is not valid:")
    print(String(take!(errors)))
end

# terms = Array{Term}(undef, 3)
# terms[1] = Term([c[1]])
# terms[2] = Term([c[2],c[3]])
# terms[3] = Term([c[4]])
# dp = DegreePlan("Example ECE Department at UA", curric, terms)
# basic_metrics(dp)
# dp.metrics