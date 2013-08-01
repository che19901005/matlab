function hsv = hsv_hist(I, N_BINS)

h = fspecial('gaussian');
I = imfilter(I, h);
[m1, m2, m3] = size(I);

if m3 == 1  
    % Might be a problem if HSV has less bins than N_BINS
    [X, HSV] = gray2ind(I, N_BINS);
else    
    HSVmap = rgb2hsv(I);     
    % Same problem as above
    [X, HSV] = rgb2ind(HSVmap, N_BINS);
end

hsv = imhist(X, HSV);

% To fix the histogram if the number of bins in HSV 
[n1, n2, n3] = size(hsv);
if n1 < N_BINS
    scale = N_BINS/n1;
    new_hsv = imresize(hsv, scale, 'nearest');
    hsv = new_hsv(:, 1);
end


end