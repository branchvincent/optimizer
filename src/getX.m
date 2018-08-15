function x = getX(P,x,k)
a = P.a(1,k);
b = P.a(2,k);
c = P.b(k);
if isempty(x)
    x = [P.x(k) P.y(k)];
else
    y = (c - a*x)/b;
    x = [x y];
end
end

