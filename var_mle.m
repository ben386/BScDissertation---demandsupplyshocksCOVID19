clear all;

%Set working directory for Lenza & Primiceri scripts
addpath([cd '\varMLE'])
addpath([cd '\subroutines']) %on a PC
addpath([cd '\subroutines/DERIVESTsuite'])  %on a PC
addpath([cd '\subroutines_additional'])  %on a PC
pwd;

%Reading csv data file
Ylog = xlsread("gdpinfCOVID.csv", 'gdpinfCOVID', 'C2:D152');

%Setting parameter values
[T, n] = size(Ylog); %Sample size and no. of endo variables
Tcovid = T - 2; %When the COVID episode began
lags = 2; %No. of lags

%Maximum likelihood estimation
res = var_covid_mle(Ylog,lags,Tcovid); 

%Saving regression output
%myfilename = "regoutput.txt";
%save(myfilename, "res");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SVAR Estimation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Setting working directory for VAR toolbox
addpath(genpath('VAR-Toolbox-main/v3dot0/'))

%The COVID hyperparameters
s0 = res.vol(1);
s1 = res.vol(2);
s2 = res.vol(3);

%Scaling the endogenous variables 
CovYlog = Ylog;
CovYlog(end,:) = CovYlog(end,:)/s2;
CovYlog(end-1,:) = CovYlog(end-1,:)/s1;
CovYlog(end-2,:) = CovYlog(end-2,:)/s0;

%Setting parameters and estimating the VAR
[nobs, nvar] = size(CovYlog);
det = 1;
nlags = 2;
[VAR, VARopt] = VARmodel(CovYlog, nlags, det);

%% Compute IRF, FEVD and HD%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VARopt.nsteps = 40; %Forecast horizon
VARopt.ident = 'long'; %BQ identification scheme
VARopt.vnames = ["GDP", "Inflation"]; %Labelling variables
VARopt.FigSize = [26,12]; %Calibrating figure size

%Compute IR

[IR, VAR] = VARir(VAR, VARopt);

%Compute error bands

[IRinf, IRsup, IRmed, IRbar] = VARirband(VAR, VARopt);

%Plot

VARirplot(IRbar, VARopt, IRinf, IRsup);


%% Compute Historical Decompositions%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

HistDecomp = VARhdLP(VAR, VARopt, [s0, s1, s2]); 

% HistDecomp.shock is structured as [nobs x shock x var]

% Plot 

VARhdplot(HistDecomp, VARopt);

%csvwrite("GDPHD.csv", GDPshockdata);
%csvwrite("INFHD.csv", INFshockdata);
