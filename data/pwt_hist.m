function pwt = pwt_hist(I)

N_ROWS = 256;
N_SCALES = log2(N_ROWS) - 2;
% display([N_ROWS, N_SCALES]);
pwt = zeros(500, 1);
options.nb_orientations = 6;
Jmin = 4;

% Filtering kernal
h = fspecial('gaussian');
% Filtered image
F = imfilter(I, h);
% Resized image to N_ROWS by N_ROWS
I = zeros(N_ROWS);

[m1, m2, m3] = size(F);


if m3 == 1
    [X, YCBCR] = gray2ind(F, N_ROWS);
else
    YCBCR = rgb2ycbcr(F);
    X = YCBCR(:,:,1);
end


if m1 > m2
    X = imresize(X, [N_ROWS, NaN]);
    [n1,n2,n3] = size(X);
    I(:,1:n2) = X(:,:);
else
    X = imresize(X, [NaN, N_ROWS]);
    [n1,n2,n3] = size(X);
    I(1:n1, :) = X(:,:);
end



MS = perform_steerable_transform(I, Jmin, options);

loc = 1;

for l = 2: length(MS)-1    
    pwt(loc) = mean2(MS{l});
    pwt(loc + 1) = std2(MS{l});
    loc = loc + 2; 
    % Debug
    % imshow(MS{l});
    % pause;
end

pwt = abs(pwt(pwt ~= 0));

end