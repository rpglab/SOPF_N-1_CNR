# N-1 SOPF w. CNR/CTS
# by Xingpeng.Li
# run command: include SOPFwCAwCTS.mod;

# Use reset to clear memory for AMPL
reset;

# Declare set
set BUS; # an index list for generator
set BRANCH; # an index list for generator
set GEN; # an index list for generator
set RES; # an index list for generator

param numScenario = 10;
set SCENARIO = {1..numScenario}; # an index list for scenarios

# Bus Data
param bus_Pd {BUS}; # Real Power Demand 

# Generator data
param gen_bus {GEN};  # GEN location
param gen_Pmin {GEN};
param gen_Pmax {GEN};
param gen_PgInit {GEN};   # GEN initial output
param gen_st {GEN};   # GEN status
param gen_FastUnit {GEN};  # 1 fast unit; 0 non-fast unit
param gen_ERamp {GEN};     # 15 Min Energy Ramp for dispatch
param gen_SPRamp {GEN};     # 10 Min Spin Ramp for contingency response
param gen_OpCost {GEN};
param gen_NLCost {GEN};
param gen_SuCost {GEN};
#param gen_SdCost {GEN};

# Branch Data
param branch_fbus    {BRANCH}; # from bus for line
param branch_tbus    {BRANCH}; # to bus for line
param branch_x       {BRANCH}; # line reactance
param branch_rateA   {BRANCH}; # long term thermal rating
param branch_rateC   {BRANCH}; # short term thermal rating
param branch_radial   {BRANCH}; # short term thermal rating

# Scenario data
param res_bus {RES};               # RES unit location
param res_PgInit {RES};            # RES initial generation
param res_PgFC {SCENARIO, RES};    # RES generation forecast amount ratio to the initial generation
param scenarioProb {SCENARIO};     # RES generation scenario probability

param BaseMVA = 100;  # base MVA
param PenaltyLS = 10^6; # penalty if shed load
set CONTINGENCY = {k in BRANCH: branch_radial[k] == 0};

# Declare Variable
param loadShed {BUS, SCENARIO} = 0;
#var loadShed {BUS, SCENARIO} >= 0;
var u {GEN, SCENARIO} binary;
var Pg {GEN, SCENARIO};
var reserve {GEN, SCENARIO} >= 0;
var PgRES {RES, SCENARIO} >= 0;
var bus_angle {BUS, SCENARIO};        # Variable for Bus Angles
var line_flow {BRANCH, SCENARIO};     # Variable for all line flows

var bus_angle_c {BUS, SCENARIO, CONTINGENCY};        # Variable for Bus Angles
var line_flow_c {BRANCH, SCENARIO, CONTINGENCY};     # Variable for all line flows
#var loadShed_c {BUS, SCENARIO, CONTINGENCY} >= 0;

param bigM = 10^4;
param maxNumCTS = 1;
var line_St_c_CTS {SCENARIO, CONTINGENCY, BRANCH} binary;     # Variable for line under a specific scenario and a specific contingency


# Define objective function
minimize Cost: sum{g in GEN, s in SCENARIO} scenarioProb[s] * ( gen_OpCost[g]*Pg[g,s]*BaseMVA + gen_NLCost[g]*u[g,s] + gen_SuCost[g]*(u[g,s] - gen_st[g]) )
                  + sum{n in BUS, s in SCENARIO} scenarioProb[s]*loadShed[n,s]*PenaltyLS;
             
# Nodal power balance constraints
subject to PowerBal{n in BUS, s in SCENARIO}: # Node Balance Constraint, steady-state
	sum{k in BRANCH: branch_tbus[k] == n}line_flow[k,s]       # flows into bus
	- sum{k in BRANCH: branch_fbus[k] == n}line_flow[k,s]     # flows out of bus
	+ sum{g in GEN: gen_bus[g] == n}Pg[g,s]                   # traditional units
	+ sum{g in RES: res_bus[g] == n}PgRES[g,s] = bus_Pd[n] - loadShed[n,s];   # supply and load at bus

# Traditional generator constraints
subject to slowGenSt {g in GEN, s in SCENARIO: gen_FastUnit[g] == 0}:    # slow units' status remain the same
	u[g,s] = gen_st[g];

subject to fastGenSt {g in GEN, s in SCENARIO: gen_FastUnit[g] == 1}:    
	# u[g,s] >= gen_st[g];   # OFF fast units can turn on, && ON fast units remain ON. 
	u[g,s] = gen_st[g];    # fast units' status remain the same

subject to genRamp1 {g in GEN, s in SCENARIO}:    # OFF fast units can turn on while ON fast units remain ON. 
	Pg[g,s] - gen_PgInit[g] <= gen_ERamp[g];

subject to genRamp2 {g in GEN, s in SCENARIO}:    # OFF fast units can turn on while ON fast units remain ON. 
	-gen_ERamp[g] <= Pg[g,s] - gen_PgInit[g];

subject to PGen1 {g in GEN, s in SCENARIO}: # Gen min constraint for steady-state
	gen_Pmin[g] * u[g,s] <= Pg[g,s];

subject to PGen2 {g in GEN, s in SCENARIO}: # Gen max constraint for steady state
	Pg[g,s] <= gen_Pmax[g]*u[g,s];

# Renewable generator constraints
subject to Curtailment {g in RES, s in SCENARIO}:    
    PgRES[g,s] <= res_PgInit[g] * res_PgFC[s,g];

# Branch constraints
subject to Line_FlowEq{k in BRANCH, s in SCENARIO}:	#Line Flow Constraint for steady-state:
	(bus_angle[branch_fbus[k],s] - bus_angle[branch_tbus[k],s]) / branch_x[k] = line_flow[k,s];

subject to Thermal1{k in BRANCH, s in SCENARIO}:		# Thermal Constraint, steady-state
	branch_rateA[k] >= line_flow[k,s]; # based on Rate A

subject to Thermal2{k in BRANCH, s in SCENARIO}:		# Thermal Constraint 2, steady-state
	-branch_rateA[k] <= line_flow[k,s]; #based on Rate A

# Reserve constraints:
subject to unitReserve1{g in GEN, s in SCENARIO}: 
	reserve[g,s] <= gen_SPRamp[g]*u[g,s];

subject to unitReserve2{g in GEN, s in SCENARIO}:
	Pg[g,s] + reserve[g,s] <= gen_Pmax[g]*u[g,s];

subject to systemReserve{g in GEN, s in SCENARIO}:
	sum{m in GEN}reserve[m,s] >= Pg[g,s] + reserve[g,s];

subject to systemReserve2{g in RES, s in SCENARIO}:
	sum{m in GEN}reserve[m,s] >= PgRES[g,s];


### Post-Contingency constraints considering CTS
subject to PowerBal_c{n in BUS, s in SCENARIO, c in CONTINGENCY}: # Node Balance Constraint, steady-state
	sum{k in BRANCH: branch_tbus[k] == n}line_flow_c[k,s,c]       # flows into bus
	- sum{k in BRANCH: branch_fbus[k] == n}line_flow_c[k,s,c]     # flows out of bus
	+ sum{g in GEN: gen_bus[g] == n}Pg[g,s]                   # traditional units
	+ sum{g in RES: res_bus[g] == n}PgRES[g,s] = bus_Pd[n] - loadShed[n,s];   # supply and load at bus

subject to Line_FlowEq_c{k in BRANCH, s in SCENARIO, c in CONTINGENCY: k != c}:	#Line Flow Constraint for steady-state:
	line_flow_c[k,s,c] - (bus_angle_c[branch_fbus[k],s,c] - bus_angle_c[branch_tbus[k],s,c]) / branch_x[k] + (1-line_St_c_CTS[s,c,k])*bigM >= 0;

subject to Line_FlowEq_c1{k in BRANCH, s in SCENARIO, c in CONTINGENCY: k != c}:	#Line Flow Constraint for steady-state:
	line_flow_c[k,s,c] - (bus_angle_c[branch_fbus[k],s,c] - bus_angle_c[branch_tbus[k],s,c]) / branch_x[k] - (1-line_St_c_CTS[s,c,k])*bigM <= 0;

subject to Line_FlowEq_c2{k in BRANCH, s in SCENARIO, c in CONTINGENCY: k == c}:		# Thermal Constraint 2, contingency-state
	line_flow_c[k,s,c] = 0; 

subject to Thermal_c1{k in BRANCH, s in SCENARIO, c in CONTINGENCY}:		# Thermal Constraint, contingency-state
	branch_rateC[k]*line_St_c_CTS[s,c,k] >= line_flow_c[k,s,c]; # based on Rate C

subject to Thermal_c2{k in BRANCH, s in SCENARIO, c in CONTINGENCY}:		# Thermal Constraint 2, contingency-state
	-branch_rateC[k]*line_St_c_CTS[s,c,k] <= line_flow_c[k,s,c]; #based on Rate C

subject to CTSconstraint {s in SCENARIO, c in CONTINGENCY}: 
    sum{k in BRANCH: k != c}(1 - line_St_c_CTS[s,c,k]) <= maxNumCTS; 


# Load data files
data dataFile_24.dat;

# Solver setting
option solver gurobi;
option gurobi_options('mipgap=0.0 timelim=900');
solve;

#display u, Pg;

option show_stats 1;

display _solve_system_time;
display _solve_user_time;
display _total_solve_time;
display _total_solve_elapsed_time; 

display {s in SCENARIO} (sum{g in GEN}Pg[g,s] + sum{g in RES}PgRES[g,s]) * BaseMVA;
display {s in SCENARIO} sum{g in RES}PgRES[g,s] * BaseMVA, {s in SCENARIO} sum{g in RES}(res_PgInit[g] * res_PgFC[s,g]) * BaseMVA;
display {s in SCENARIO} sum{g in RES}(res_PgInit[g] * res_PgFC[s,g] - PgRES[g,s]) * BaseMVA;
display {s in SCENARIO} sum{n in BUS}loadShed[n,s] * BaseMVA;
display {s in SCENARIO} sum{g in GEN}(u[g,s] - gen_st[g]);


param LMP {n in BUS};
let {n in BUS} LMP[n] := sum{s in SCENARIO}PowerBal[n,s].dual/BaseMVA;
display LMP;

param LMP_c {n in BUS};
let {n in BUS} LMP_c[n] := sum{s in SCENARIO, c in CONTINGENCY}PowerBal_c[n,s,c].dual/BaseMVA;
display LMP_c;

let {n in BUS} LMP[n] := LMP[n] + LMP_c[n];
display LMP;

param avgLMP; let avgLMP := 0;
param avgLMPLoadWeighted; let avgLMPLoadWeighted := 0;
param numBUS; let numBUS := 0;
for {n in BUS} {
    let avgLMP := avgLMP + LMP[n];
    let avgLMPLoadWeighted := avgLMPLoadWeighted + LMP[n]*bus_Pd[n];
    let numBUS := numBUS + 1;
}
let avgLMP := avgLMP/numBUS;
let avgLMPLoadWeighted := avgLMPLoadWeighted/(sum{n in BUS}bus_Pd[n]);
display avgLMP, avgLMPLoadWeighted;



param loadPayment; let loadPayment := 0;
param resGenRevenue; let resGenRevenue := 0;
param genRevenue; let genRevenue := 0;
param genProfit; let genProfit := 0;
param networkCongestionRevenue; let networkCongestionRevenue := 0;

let {n in BUS} loadPayment := loadPayment + LMP[n]*bus_Pd[n]*BaseMVA;
let {n in BUS} genRevenue := genRevenue + LMP[n]*sum{s in SCENARIO}scenarioProb[s]*sum{g in GEN: n == gen_bus[g]}Pg[g,s]*BaseMVA;
let {n in BUS} resGenRevenue := resGenRevenue + LMP[n]*sum{s in SCENARIO}scenarioProb[s]*sum{g in RES: n == res_bus[g]}PgRES[g,s]*BaseMVA;
let genProfit := genRevenue - Cost;
let networkCongestionRevenue := loadPayment - genRevenue - resGenRevenue;
display loadPayment, resGenRevenue, genRevenue, genProfit, networkCongestionRevenue;
display Cost;


