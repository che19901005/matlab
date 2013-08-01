% in this file, we will try to test the results got from only hsv, only pwt
% and the final feature fusion matrix got from mse algorithm.


% we define a class used to get different kind of feature matrix using
% data.

classdef feature_matrices_factory
% first we got the feature matrix of hsv for 150 photoes(50 for each
% category) 50*150

function hsv_feature_matrix = get_hsv_feature_matrix