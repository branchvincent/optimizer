function makeTable(R)

fprintf('\n\\begin{table}[H]\n');
fprintf('\t\\centering\n');
fprintf('\t\\caption{My caption.}\n');
fprintf('\t\\begin{tabular}{| c | c | c | c | c |} \\hline\n');
fprintf('\t\\bf Iteration, k  & $\\bf x_k$ & $\\bf W_k$ & $\\bf p_k$ & $\\bf \\alpha_k$\\\\ \\hline \n');

for k = 1:R.k
    % X
    x = round(R.x(k,:), 3);
    x = makeString(x);
    % Working set
    W = R.W(k,:);
    W = makeString(W(W~=0));
    % Direction
    p = round(R.p(k,:), 3);
    p = makeString(p);
    % Print
    fprintf('\t%2.0f & (%s) & \\{%s\\} & (%s) & %.2f \\\\ \\hline \n',k, x, W, p, R.a(k));
end

fprintf('\t\\end{tabular}\n');
fprintf('\\end{table}\n');

end

function s = makeString(v)
    s = strjoin(arrayfun(@(x) num2str(x), v, 'UniformOutput', false),', ');
end
