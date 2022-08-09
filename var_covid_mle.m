function r = var_covid_mle(y,lags,Tcovid)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function computes the MLE parameter estimates of a VAR,
% augmented with a change in volatility at the time of Covid (March 2020).
%
% y:        data matrix
% lags:     number of lags in the VAR
% Tcovid:   observation corresponding to March 2020 (for example, if the
%           sample ends in May 2020, and the VAR is monthly, Tcovid should
%           be set to length(y)-2)
%
% Last modified: 07/30/2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% data matrix manipulations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dimensions
[TT,n]=size(y);
k=n*lags+1;         % # coefficients for each equation


% constructing the matrix of regressors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x=zeros(TT,k);
x(:,1)=1;
for i=1:lags
    x(:,1+(i-1)*n+1:1+i*n)=lag(y,i);
end
x=x(lags+1:end,:);
y=y(lags+1:end,:);
[T,n]=size(y);
Tcovid=Tcovid-lags;


%% starting values and bounds for the minimization of -logLH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
aux=mean(abs(y(Tcovid:max([Tcovid+1 T]),:)-y(Tcovid-1:max([Tcovid+1 T])-1,:))',1)./...
    mean(mean(abs(y(2:Tcovid-1,:)-y(1:Tcovid-2,:))));
if isempty(aux)
    eta0=[];
elseif length(aux)==2;
    eta0=[aux';aux(1);.8];      % volatility hyperparameters 
elseif length(aux)>=3;
    eta0=[aux(1:3)';.8];        % volatility hyperparameters 
end

% bounds
MIN.eta(1:3)=[1;1;1];
MAX.eta(1:3)=[500;500;500];
MIN.eta(4)=.005;
MAX.eta(4)=.995;

ncp=length(eta0);           % # "covid" hyperparameters
ineta=-log((MAX.eta'-eta0)./(eta0-MIN.eta'));
inHeta=(1./(MAX.eta'-eta0)+1./(eta0-MIN.eta')).^2.*(abs(eta0)/1).^2;

x0=[ineta];                 % initial guess for volatility hyperparameters
H0=diag([inHeta]);          % initial guess for the inverse Hessian

%% maximization of the concentrated LH with respect to the covid hyperparameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fh,xh,gh,H,itct,fcount,retcodeh] = csminwel('loglhVAR_covid',x0,H0,[],1e-16,1000,y,x,lags,T,n,MIN,MAX,Tcovid);


%% output of the maximization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MLE of volatility parameters, VAR coefficients and residual covariance
[fh,r.betahat,r.sigmahat]=loglhVAR_covid(xh,y,x,lags,T,n,MIN,MAX,Tcovid);
r.logLH=-fh;
r.vol=MIN.eta'+(MAX.eta'-MIN.eta')./(1+exp(-xh));

