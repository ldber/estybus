#Estimate Network Admittance Matrix (Ybus)

Proof of concept of estimating Ybus when voltage angle measurements are unavailable.

Code dependency: MATPOWER 7.1


Files:
	- syntheticdata.m Generates synthetic data for a small radial network.
	- estybus_pmu.m Estimates Ybus using voltage angle measurements. Simple regression problem.
	- estybus_smart.m Estimates Ybus without using voltage angle measurements.
	- checky.m Script that plots the error of Ybus estimates.