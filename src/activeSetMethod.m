function R = activeSetMethod(P,x0,kmax)

% Set constants
N = length(x0);
M = length(P.b);
P.I = colVec(setxor(1:M, P.E));

% Initialize variables
x = x0;
W = getActiveSet(P,x0);
done = false;

% Initialize results to be returned
R.x = zeros(kmax,N);
R.q = zeros(kmax,1);
R.W = zeros(kmax,M);
R.p = zeros(kmax,N);
R.a = nan(kmax,1);

% Solve
for k = 1:kmax    
    % Find search direction
    p = findDirection(P,W,x);
    
    % Update values
    R.x(k,:) = x;
    R.q(k) = P.f(x);
    R.W(k,:) = [W; zeros(M-length(W),1)].';
    R.p(k,:) = p;
    
    if all(abs(p) <= 1e-8)
        % Find langrage multipliers
        lambdas = findLagrange(P,W,x);
        if all(lambdas >= 0)
            % Found solution
            done = true;
        else
            % Remove contraint
            [~,n] = min(lambdas);   % min index
            W = W(W~=n);            % remove min index
        end
    else
        % Find new x
        [alpha,bc] = findAlpha(P,W,p,x);
        x = x + alpha*p;            % new x
        W = colVec(union(W,bc));    % add blocking constraint, if exists
        R.a(k,:) = alpha;
    end
    
    % Exit, if done
    if done 
        break
    end
end

% Store results
R.k = k;
R.x(k+1:end,:) = [];
R.q(k+1:end) = [];
R.p(k+1:end,:) = [];
R.W(k+1:end,:) = [];
R.a(k+1:end) = [];

% Print solution
if ~done
    fprintf('WARNING: Max iterations reached!\n');
end
fprintf('x%d = %s\n', k, mat2str(x.'));

% Print matlab's solution
try
    options = optimset('Display', 'off');
    xs = quadprog(P.G, P.c, -1*P.a(:,P.I).', -1*P.b(P.I), P.a(:,P.E).', P.b(P.E), [],[],[], options);
    fprintf('xreal = %s\n', mat2str(xs.'));
catch
    fprintf('Quadprog had an error.\n');
end

end

%% Get active set
function A = getActiveSet(P,x)
    A = union(P.E,P.I);  
    A = A(P.a.'*x == P.b);
end

%% Find search direction (Eqn 16.39)
function p = findDirection(P,W,x)
    M = length(x);      % num dof
    N = length(W);      % num working constraints 
    a = P.a(:,W);       % working constraints
    % Calculate direction
    g = P.G*x + P.c;
    K = [P.G -a; a.' zeros(N,N)];
    v = inv(K)*[-g; zeros(N,1)];
    p = v(1:M);
end

%% Find Lagrange multipliers (Eqn 16.42)
function lambdas = findLagrange(P,W,x)
    N = length(P.b);        % num constraints
    a = P.a(:,W);           % working constraints
    NWI = setxor(W,P.I);    % non-intersection of W,I
    % Solve for lambdas
    g = P.G*x + P.c;
    lambdas = zeros(N,1);
    lambdas(W) = linsolve(a,g);
    lambdas(NWI) = 0;
end

%% Find alpha (Eqn 16.41)
function [alpha, bc] = findAlpha(P,W,p,x)
    % Get non-working set
    NW = setxor(W, union(P.E,P.I));
    a = P.a(:,NW);
    b = P.b(NW);
    % Ignore positive values
    con = a.'*p < 0;
    NW = NW(con);
    a = a(:,con);
    b = b(con);
    % Find minimum
    [m,bc] = min((b - a.'*x)./(a'*p)); 
    alpha = min(1, m);
    % Determine blocking constraint
    if isempty(alpha)
        alpha = 1;
        bc = [];
    elseif alpha == 1
        bc = [];
    else
        bc = NW(bc);
    end
end

%% Make column vector
function v = colVec(v)
    if ~iscolumn(v)
        v = v';
    end
end
