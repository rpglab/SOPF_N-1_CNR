# SOPF
This repo implements four different Stochastic Optimal Power Flow (SOPF) models in AMPL. The test case used here is a modified IEEE 24-bus system; but these codes can work on any other systems.



(i) Model 1, R-SOPF, a relaxed SOPF model that assums infinite network capacity.

(ii) Model 2, N-SOPF, a normal SOPF model that enforces base-case network constraints only.

(iii) Model 3, E-SOPF, a N-1 SOPF model that enforces both base-case network constraints and contingency-case network constraints.

(iv) Model 4, E-SOPFwNR, a N-1 SOPF w. CTS model that implements corrective transmission switching in post-contingency cases beyong the N-1 SOPF model.


The following paper provides more details about these four models: 

<a class="off" href="https://ieeexplore.ieee.org/document/9299954" target="_blank">Xingpeng Li and Qianxue Xia, “Stochastic Optimal Power Flow with Network Reconfiguration: Congestion Management and Facilitating Grid Integration of Renewables”, IEEE PES T&D Conference & Exposition, (Virtually), Chicago, IL, USA, Oct. 2020. (DOI: 10.1109/TD39804.2020.9299954)</a>

## Citation:
If you use these codes for your work, please cite the following paper:

Xingpeng Li and Qianxue Xia, “Stochastic Optimal Power Flow with Network Reconfiguration: Congestion Management and Facilitating Grid Integration of Renewables”, *IEEE PES T&D Conference & Exposition*, (Virtually), Chicago, IL, USA, Oct. 2020.

## Contact:
Dr. Xingpeng Li

University of Houston

Email: xli83@central.uh.edu

Website: https://rpglab.github.io/


## License:
This work is licensed under the terms of the Creative Commons Attribution 4.0 (CC BY 4.0) license. 
https://creativecommons.org/licenses/by/4.0/


## Disclaimer:
The author doesn’t make any warranty for the accuracy, completeness, or usefulness of any information disclosed and the author assumes no liability or responsibility for any errors or omissions for the information (data/code/results etc) disclosed.
