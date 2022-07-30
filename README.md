# BScDissertation---demandsupplyshocksCOVID19
"Decomposing Demand and Supply Shocks under COVID-19 Volatility" by Benjamin O'Sullivan. 

+--------------------------------------------+

I estimate the contributions of demand and supply shocks on US
real output growth fluctuations during the COVID-19 pandemic. A time-varying
vector autoregressive model proposed by Lenza & Primiceri (2020) is used to
describe the joint dynamics of real output growth and inflation. The demand and
supply shocks are uncovered using a long-run identification scheme. Conducting
a historical decomposition of the structural model, I find that supply shocks were
more influential in driving real output growth fluctuations relative to demand
shocks during the early stages of the pandemic. These findings are in contrast to
certain studies that point towards demand dynamics playing a more prominent
role in determining the substantial reductions in output during the COVID-19
episode.

+--------------------------------------------+

***IMPORTANT***: the VAR toolbox from [Ambrogio Cesa-Bianchi](https://github.com/ambropo/VAR-Toolbox) and the replication codes for "How to Estimate a VAR after March 2020" from [Michele Lenza & Giorgio Primiceri](https://faculty.wcas.northwestern.edu/gep575/research.html) are required to successfully run the code. 

**Citation:** *Lenza, Michele & Primiceri, Giorgio E., 2020. "How to estimate a VAR after March 2020," Working Paper Series 2461, European Central Bank.*

1. var_mle.m - the main script which is used to estimate the VAR and SVAR, as well as to compute historical decompositions. 

2. VARhdLP.m - I have tweaked the VARhd.m script from Ambrogio Cesa-Bianchi's VAR toolbox to compute a historical decomposition of the estimated SVAR. 
