[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.20328559.svg)](https://doi.org/10.5281/zenodo.20328559)

# Local Neural Operators for Equation-Free System-level analysis

This repository contains code for the paper:

**"Enabling Local Neural Operators to perform Equation-Free System-Level Analysis"**
*G. Fabiani, H. Vandecasteele, S. Goswami, C. Siettos, I.G. Kevrekidis*
\[[arXiv:2505.02308](https://arxiv.org/abs/2505.02308)]

**Accepted in Nature Machine Intelligence**

If you use or adapt this code for your research, please cite our paper.

⭐ An alternative title for this project could have been:
“Every numerical task you wished your Neural Operator could perform, and you did not know it could”.

This software implements data-driven **local Neural Operators (NOs)** trained on **short-time data**, learning **local time-stepping dynamics** (local in time). It also supports **local-in-space learning** via the **gap-tooth scheme**: a domain partitioning method with inactive gaps between patches.

We use state-of-the-art NOs, including **RandONets**, and compare them with **DeepONets**, for efficient operator learning from data.

We integrate **local NOs** with iterative numerical methods in the **Krylov subspace** to enable fixed-point computation, stability, and bifurcation analysis in nonlinear PDEs - without requiring closed-form equations. All bypassing derivation of explicit equations and their numerical solution. 🔥


<p align="center">
  <img src="https://raw.githubusercontent.com/Centrum-IntelliPhysics/local-neural-operator-time-stepper-instead-of-just-time-stepper/refs/heads/main/images/Schematic_Overview_4.png" width="600"/>
</p>

Case Studies
======

We apply the framework to:

* 1D Allen-Cahn equation
* Liouville-Bratu-Gelfand equation (see Folder Parabolic Bratu-Gelfand)
* FitzHugh-Nagumo system (simulated through a Lattice-Boltzmann method (LBM), thus learning the NO from "mesoscopic" data)
(see Folder with LBM)

The repository also includes some additional results:
* FHN simulated with centered Finite Differences, with training using DeepONets.
* Allen-Cahn tested with both DeepONets and Fourier Neural Operators.
* Some preliminary DeepONet results for the Bratu problem.
* Some attempt on a simple diffusion equation.

These results are not part of the paper, and the code is not well-documented and may not run properly.
They were part of early tests showing that high accuracy is critical for system-level tasks like computing steady-state eigenvalues — which is why they were eventually excluded.

Highlights
====
⚡Beyond simple simulations: Efficient bifurcation tracking and stability analysis from data 

🧠Matrix-free methods in the Krylov subspace for steady-state (Newton-GMRES) stability (Arnoldi) and bifurcation tracking (arc-length continuation) 

🌐A powerful framework for high-dimensional, complex systems without relying on traditional PDEs or explicit models

🔄Introduction of a Homotopy-based Embedding for handling parameter-dependent operator problems 

🏆In our illustrations, we used RandONets, a randomized neural operator, trained, in all examples, over large datasets in less than a minute (!), obtaining surprising accuracy! 

(We also compared with DeepONets, which benefit from our framework, but exhibited limited accuracy in stability analysis in our experiments. 🧐)

Abstract of the paper
=====
Neural Operators (NOs) provide a powerful framework for computations involving physical laws that can be modelled by (integro-) partial differential equations (PDEs), directly learning maps between infinite-dimensional function spaces that bypass both the explicit equation identification and their subsequent numerical solving. Still, NOs have so far primarily been employed to explore the dynamical behavior as surrogates of brute-force temporal simulations/predictions. Their potential for systematic rigorous numerical system-level tasks, such as fixed-point, stability, and bifurcation analysis - crucial for predicting irreversible transitions in real-world phenomena - remains largely unexplored. Toward this aim, inspired by the Equation-Free multiscale framework, we propose and implement a framework that integrates (local) NOs with advanced iterative numerical methods in the Krylov subspace, so as to perform efficient system-level stability and bifurcation analysis of large-scale dynamical systems. Beyond fixed point, stability, and bifurcation analysis enabled by local in time NOs, we also demonstrate the usefulness of local in space as well as in space-time ("patch") NOs in accelerating the computer-aided analysis of spatiotemporal dynamics. We illustrate our framework via three nonlinear PDE benchmarks: the 1D Allen-Cahn equation, which undergoes multiple concatenated pitchfork bifurcations; the Liouville-Bratu-Gelfand PDE, which features a saddle-node tipping point; and the FitzHugh-Nagumo (FHN) model, consisting of two coupled PDEs that exhibit both Hopf and saddle-node bifurcations.

Problem Statement: Learning parametric operators of PDEs with NOs
=======

We aim to learn nonlinear parametric operators  

$\mathcal{F}_\lambda: \mathcal{U} \times \mathbb{R}^p \rightarrow \mathcal{V}$  

where $\mathcal{U}, \mathcal{V} \subseteq C^1(\mathbb{R}^d)$ are function spaces, and $\lambda$ denotes input parameters.  
The operator maps an input function $u(\mathbf{x})$ to an output  

$v(\mathbf{y}) = \mathcal{F}_{\lambda}[u] (\mathbf{y}).$

Specifically, we learn the **solution operator** (or time-stepper) of a PDE evolution equation:  

$\frac{\partial u(\mathbf{x}, t)}{\partial t} = \mathcal{L}[u; \lambda](\mathbf{x}, t),$  

so that, for a given initial state $u_0(\mathbf{x})$, the learned NO approximates:  

$u(\mathbf{x}, \Delta t) \approx \mathcal{S}_{\Delta t} \[ u_0; \lambda \] (\mathbf{x})$

We discretize input and output functions using their values at selected sensor locations.  

The final goal is to enable **accurate and efficient operator learning** that supports system-level tasks such as fixed-point and bifurcation analysis.



Equation-Free computations with Neural Operators
=====

We learn the solution operator $\mathcal{S}_{\Delta t}$ over short time intervals $\Delta t$ (local in time) to improve training efficiency and accuracy.  
The full solution at time $T$ is then obtained by autoregressively applying the short-step operator:  

$u(\mathbf{x}, T) = \mathcal{S}\_{\Delta t} \circ \mathcal{S}\_{\Delta t} \circ \cdots \circ \mathcal{S}_{\Delta t} [ u_0, \lambda ]$, applied $T / \Delta t$ times.

To avoid error accumulation from long rollouts, steady states $u^*$ are found as fixed points of the time-stepper:  

$u^* = \mathcal{S}_T[u^*, \lambda]$
which satisfy  

$\psi(u; \lambda) = u - \mathcal{S}_T[ u, \lambda ] = 0.$  

We solve $\psi(u;\lambda)=0$ using Newton iterations:  

$\nabla \psi(u^{(k)}; \lambda) \delta^{(k)} = -\psi(u^{(k)}; \lambda), \quad u^{(k+1)} = u^{(k)} + \delta^{(k)},$  

with Jacobian-vector products approximated by finite differences:  
$\nabla \psi(u; \lambda) r \approx \frac{\psi(u + \epsilon r; \lambda) - \psi(u; \lambda)}{\epsilon}.$

Matrix-free methods like Newton-GMRES solve large systems efficiently.  
Pseudo-arclength continuation traces bifurcation branches, and Arnoldi iterations assess stability of steady states.


## From Local Neural Operators to Global Computations: Gap-Tooth and Projective Integration

We use short-time Neural Operators (NOs) locally in time and space to speed up computations for multiscale problems.

### Projective Integration (PI)

PI alternates between short bursts of fine-scale evolution using a trained NO time-stepper and extrapolation over longer intervals to advance slow dynamics:

$u\_{n,j} = \mathcal{S}\_{\Delta t} [ u_{n,j-1} ], \quad j = 1, \dots, k, \quad u\_{n,0} = u\_n$

$u\_{n+1} = u\_{n,k} + \Delta \tau \frac{u\_{n,k} - u_{n,k-1}}{\Delta t}, \quad \Delta \tau \gg \Delta t$

This reduces computational cost by exploiting scale separation in time.

### Gap-Tooth Scheme

Gap-Tooth exploits spatial smoothness by learning local NOs on small spatial patches (`teeth`) separated by gaps:

$u_{t+\Delta t} = \mathcal{S}_{\Delta t}^{\text{local}}[u_t]$

Each patch $T_i = \left[ x_i - \frac{\Delta x}{2},\ x_i + \frac{\Delta x}{2} \right]$ evolves independently with boundary conditions interpolated from neighboring patches. This enables large domain evolution by stitching local solutions.

### Patch Dynamics

Combining PI and Gap-Tooth yields patch dynamics: local-in-time and local-in-space NOs that scale efficiently for large space-time domains with multiscale features.


---

## MIT License

Copyright (c) 2025 The authors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

---

## Disclaimer

This software is provided "as is" without any express or implied warranties.
This includes, but is not limited to, warranties of merchantability, fitness for a particular purpose, and non-infringement.
The authors and copyright holders are not liable for any claims, damages, or other liabilities arising from the use of this software

Copyright (c) 2025 - The Authors

Last revised by G. Fabiani, June 19, 2025

---

For details on RandONets, see:
👉 [https://github.com/GianlucaFabiani/RandONets](https://github.com/GianlucaFabiani/RandONets)
