function similarity = compareMFCCs(x,y)
%compare
DP = compareXY(x,y);

%normalize results
n = size(x,2);
d(n)=norm(x(:,n));
for i=2:n
    d(i)=norm(x(:,i));
end

similarity = DP.dist/sum(d);

end