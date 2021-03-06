% Multiview Spectral Embedding
function mappedX = sidong_mse(X, params)

%% ****************** Initialization *****************
% m, the number of views/modalities
fields = fieldnames(X);
m = length(fields);
% The marker types
markers = {'+k','ob','*r','sg','dc','pm'};
% d, the number of dimensions
% if d is not provided in parameters, then give it default value: 2.
if ~isfield(params, 'd')
    d = 2;
else
    d = params.d;
end
% k, the number of neighbors in the neighbors
if ~isfield(params,'k')
    k = 12;
else
    k = params.k;
end
% L, the labels
if ~isfield(params, 'L')
    L = '+';
else
    L = params.L;
end
% gamma, the control parameter of power of alpha
if ~isfield(params, 'sigmaMSE')
    sigma = zeros(1,m) + 0.2;
else
    sigma = params.sigmaMSE;
end
% gamma, the control parameter of power of alpha
if ~isfield(params, 'gamma')
    gamma = 2;
else
    gamma = params.gamma;
end
% threshold
if ~isfield(params, 'threshold')
    threshold = 0.72;
else
    threshold = params.threshold;
end
% The tolerable error
esp = 0.000001;
% Trace the changes of alpha
pre_alpha =  zeros(1, m);
% Initialize the alpha[m] as 1/m
alpha = pre_alpha + 1/m;
% n1, n2 to check the whether X{:} have the same number of subjects
n1 = 0; n2 = 0;

%% ****** Compute normalized Laplacian Matrices for individual views *******
% Normalized Laplacian eigen matrix, not update with EM expectation
Ln = cell(m, 1);
for i = 1 : m
    x = X.(fields{i});
    n1 = size(x, 1);
    % TUNABLE: whether to normalize x
    %x = svmscale(x);
    disp(sprintf(' Now computing the normalized Laplacian matrix for view %d/%d.', i, m));
    %  The laplacian matrix for current view
    Ln{i} = laplacian_matrix(x)
    if i>1 && abs(n1 - n2) > 0
        disp(sprintf('Warning: the dimensions of view %d and %d do not match!', i, i-1));
    end
    n2 = n1;
end

%% ********** Expectation Maximization on alpha and the embedding **********
% First round of embedding
iteration = 0;
% Iterate until converge
while sum(bsxfun(@minus, alpha, pre_alpha).^2) > esp
    iteration = iteration + 1;
    disp(sprintf('Iteration %d...', iteration));
    % Record previous alpha
    pre_alpha = alpha;
    % Combined laplacian matrix
    con_Ln = zeros(n1);
    % ************* E step, fix alpha, update Y ***************
    for i = 1:m
        % Compute the combined normalized laplacian matrix
        con_Ln = con_Ln + alpha(i)^gamma * Ln{i};
    end
    % Compute Y as the first d eigen vectors of con_Ln
    [V,E] = eig(con_Ln);
    % Sort the eigenvalues
    % @TUNABLE: acscend or descend??? Should be ascend!
    [sortedE, eigenRanks] = sort(abs(sum(E)), 'ascend');
    % Y, the global embedding, the top d eigen vectors of con_Ln
    Y = V(:, eigenRanks(1: d));
    % disp(sortedE(1:10));
    
    % ************ M step, fix Y, update alpha *****************
    for i = 1 : m
        alpha(i) = trace(Y'*Ln{i}*Y)^(-1/(gamma - 1));
    end
    % Further normalize alpha(:)
    alpha = alpha/sum(alpha);
    disp(alpha);
    
end

mappedX = Y
disp('size of mapped X is:')
disp(mappedX);
%figure, display_scatter(mappedX);
title([sprintf('d:%d k:%d gamma:%d threshold:%d sigma:', d, k, gamma, threshold), num2str(sigma)]);

mapping.m = m;
mapping.d = d;
mapping.k = k;
mapping.gamma = gamma;
mapping.alpha = alpha;
mapping.L = L;


%% ****************** Visulization function ************************
    function display_scatter(embedding)
        hold on;
        switch d
            case 2
                for l = unique(L)'
                    ll = L == l;
                    scatter(embedding(ll,1), embedding(ll,2), 40, markers{l});
                end
                
            case 3
                for l = unique(L)'
                    ll = L == l;
                    scatter3(embedding(ll,1), embedding(ll,2), embedding(ll,3), 40, markers{l}),  view(40, 25);
                end
            otherwise
                disp(sprintf('Warning: not able to plot %d dimensional data (3 maximum)!', d));
                for l = unique(L)'
                    ll = L == l;
                    scatter3(embedding(ll,1), embedding(ll,2), embedding(ll,3), 40, markers{l}), view(40, 25);
                end
        end
        hold off;
        
    end

%% ***** Derive the normlized laplacian matrix using a Gaussian kernel filter

    function Ln = laplacian_matrix(Points)
        
        % Number of subjects in Points
        n = size(Points, 1);
        % knn Weight matrix
        W = zeros(n);
        % Laplacian matrix
        Ln = zeros(n);
        % Diagonal matrix
        D = eye(n);
        
        fun = @(x, sigma) exp(-x.^2 * sigma);
        distEuclidean = squareform(pdist(Points));
        % Gaussian transform euclidean distances to Gaussian weights
        distGaussian = fun(distEuclidean, sigma(i));
        
        %%%%%%%% @TRICK begins %%%%%%%%%%%%%%%%
        %         % Here we used the nearest neighbors from same diagnosis
        %         % group instead of neighbors from whole dataset in the original MSE
        %         % j represents the training set, we used half
        %         ave = mean(distGaussian(:));
        %         %         disp(ave);
        %         for j = 2:2:n
        %             l = L(j);
        %             ll = L ~= l;
        %             % If the data is the testing data
        %             distGaussian(j, 2:2:n) = threshold;
        %             % If the data is not from the same group as the training
        %             distGaussian(j, ll) = ave + 0.05;
        %         end
        % 
        %%%%%%%%%%%% @TRICK ends %%%%%%%%%
        
        % Sort the matrix by rows in descend order
        [~, distRanks] = sort(distGaussian, 2, 'descend');
        for j = 1:n
            % W(p,q) is not zero if xp is among the k-nearest neighbors of
            % xq, or vice versa. This ensures W, Ln to be symmetric.
            W(j, distRanks(j, 1:k+1)) = distGaussian(j, distRanks(j, 1:k+1));
            W(distRanks(j, 1:k+1), j) = distGaussian(distRanks(j, 1:k+1), j);
            % @NOTE: the subject it self is not included
            W(j,j) = 0;
        end
        for j = 1:n
            % D(j,j) should equal to sum(W(j,:)), but W is sysmetric so it
            % doesn't matter we use W(:,j) or W(j,:);
            D(j,j) = sum(W(j,:),2);
        end
        % @NOTE: whether to use the cross product
        Ln = eye(n) - D^(-.5)*W*D^(-.5);
    end

end


