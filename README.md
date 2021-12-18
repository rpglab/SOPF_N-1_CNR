# SOPF
This repo implements four different Stochastic Optimal Power Flow (SOPF) models in AMPL. 

(i) Model 1, R-SOPF, a relaxed SOPF model that assums infinite network capacity.

(ii) Model 2, N-SOPF, a normal SOPF model that enforces base-case network constraints only.

(iii) Model 3, E-SOPF, a N-1 SOPF model that enforces both base-case network constraints and contingency-case network constraints.

(iv) Model 4, E-SOPFwNR, a N-1 SOPF w. CTS model that implements corrective transmission switching in post-contingency cases beyong the N-1 SOPF model.

The test case used here is a modified IEEE RTS-96 reliability test system (24-bus) that was initially developed by the IEEE reliability subcommittee and published in 1979 and later enhanced in 1996. Reference: "The IEEE Reliability Test System-1996. A report prepared by the Reliability Test System Task Force of the Application of Probability Methods Subcommittee" and link: https://ieeexplore.ieee.org/document/780914.
Though only tested on this single system here, these codes can work on any other systems.

For the most complex model (E-SOPFwNR), the code takes 130 seconds (~2 minutes) on a laptop: Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz, 32 GB RAM, Windows 10.

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
The authors do not make any warranty for the accuracy, completeness, or usefulness of any information disclosed; and the authors assume no liability or responsibility for any errors or omissions for the information (data/code/results etc) disclosed.
