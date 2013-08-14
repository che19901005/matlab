function b = counter()
N=1e8;
M=1e7;
a=[randi(M,N,1) randi(1e3,N,1)]*[1 1; 0 1];
idx = 1:max(a(:));
d = diff(a, 1, 2) + 1 ; % interval length
s = a(:,1); % interval start point
L = ceil(max(d)/2);
b = 0*idx;
tic
while L>0
    iL = (d>=L);
    u = hist(s(iL),idx);
    %b = b + conv(u, ones(1,L),'same');
    b = b + filter(ones(1,L),1,u);
    s(iL) = s(iL)+L;
    d(iL) = d(iL)-L;    
    L = ceil(max(d)/2);
    toc
end
end