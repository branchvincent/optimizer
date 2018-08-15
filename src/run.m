% Load problem
types = {'int','bound','vert','ext','rand'};
type = types{5};
[P,x0] = prob(type);
kmax = 100;

% Run
R = activeSetMethod(P,x0,kmax);

% Plot q
plot(1:R.k,R.q,'b');
title('Objective Function');
xlabel('Iteration, k'); 
ylabel('$q(x_k)$','Interpreter','latex');
set(gca,'xtick',1:R.k);
saveas(gcf,strcat('q',type),'epsc'); clf;

% Plot constraints
plotregion(P.a(:,P.I).', P.b(P.I), [], [], 'g', 0); %0.025
hold on;

% Plot objective function
syms x1 x2
fc = fcontour(P.f([x1; x2]), [xlim ylim]);
fc.LevelStep = (max(R.q) - min(R.q))/15;
colorbar; caxis([-20 40]);

% Plot iterates
x = R.x(:,1); y = R.x(:,2);
scatter(x, y, 'k', 'filled');
labels = cellstr(num2str((1:R.k).', '$x^%d$'));
for k = 2:length(labels)
    if x(k) == x(k-1) && y(k) == y(k-1)
        labels{k-1} = strcat(labels{k-1}, ',', labels{k});
        labels{k} = '';
    end
end
text(x, y+0.1, labels, 'Interpreter', 'latex');

% Add labels
title('Iterates with Contour','fontweight','bold');
xlabel('$x_1$','Interpreter','latex'); 
ylabel('$x_2$','Interpreter','latex'); 
saveas(gcf,strcat('x',type),'epsc');

% Get table
makeTable(R);