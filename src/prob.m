function [P,x0] = prob(type)

% Function
P.G = [2 -2; -2 4;];
P.c = [-2; -6];
P.f = @(x) 0.5*x.'*P.G*x + x.'*P.c; 

% Constraints
M = 8;
theta = 0:2*pi/M:2*pi; rho = 2*ones(1,M+1);
[x,y] = pol2cart(theta,rho);
y = y+2;
P.x = x; P.y = y;
P.a = zeros(2,M); P.b = zeros(M,1);
sn = ones(1,M); sn(1:M/2) = -1;

for k = 1:M
    coefficients = polyfit(x(k:k+1),y(k:k+1), 1);
    a = coefficients(1); b = coefficients(2);
    P.a(:,k) = sn(k)*[-a 1].';
    P.b(k) = sn(k)*b;
end
P.E = [].';
P.I = [1:M].';

% Initial x
if strcmp(type,'int')
    x0 = [0 2.5].';
elseif strcmp(type,'bound')
    x0 = [-1.75 1.3964].'; %getX(P,-1.75,5).'
elseif strcmp(type,'vert')
    x0 = [-1.4142 3.4142].'; %getX(P,[],4).'
elseif strcmp(type, 'ext')
    x0 = [1 min(y)+0.25].';
else
    x0 = [-2 + 4*rand 4*rand].';
end

