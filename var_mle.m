clear all;
addpath([cd '\varMLE'])
addpath([cd '\subroutines']) %on a PC
addpath([cd '\subroutines/DERIVESTsuite'])  %on a PC
addpath([cd '\subroutines_additional'])  %on a PC
pwd;

Ylog = xlsread("gdpinfCOVID.csv", 'gdpinfCOVID', 'C2:D152');

[T, n] = size(Ylog);
Tcovid = T - 2;
lags = 2;

res = var_covid_mle(Ylog,lags,Tcovid);

%myfilename = "regoutput.txt";
%save(myfilename, "res");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SVAR Estimation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('VAR-Toolbox-main/v3dot0/'))

s0 = res.vol(1);
s1 = res.vol(2);
s2 = res.vol(3);

CovYlog = Ylog;
CovYlog(end,:) = CovYlog(end,:)/s2;
CovYlog(end-1,:) = CovYlog(end-1,:)/s1;
CovYlog(end-2,:) = CovYlog(end-2,:)/s0;

[nobs, nvar] = size(CovYlog);
det = 1;
nlags = 2;
[VAR, VARopt] = VARmodel(CovYlog, nlags, det);

%% Compute IRF, FEVD and HD%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VARopt.nsteps = 40;
VARopt.ident = 'long';
VARopt.vnames = ["GDP", "Inflation"];
VARopt.FigSize = [26,12];

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