function [cost, grad] = softmaxCost(theta, ...
		numClasses, inputSize, lambda, data, labels)

	% numClasses - the number of classes 
	% inputSize - the size N of the input vector
	% lambda - weight decay parameter
	% data - the N x M input matrix, where each column data(:, i) corresponds to
	%        a single test set
	% labels - an M x 1 matrix containing the labels corresponding for the input data
	%

	% Unroll the parameters from theta
	theta = reshape(theta, numClasses, inputSize);

	ndatas = size(data, 2);

	groundTruth = full(sparse(labels, 1:ndatas, 1));

	cost = 0;

	thetagrad = zeros(numClasses, inputSize);

	% compute cost(theta)
	% compute hTheta(x), vectorized
	M = exp(theta * data);

	% tried to avoid overflow by adding the following line, while it creates -Inf sometimes
	%M = bsxfun(@minus, M, median(M));

	hTheta = bsxfun(@rdivide, M, sum(M));
	logH = log(hTheta);
	cost = -(1 / ndatas) * sum(sum(groundTruth .* logH));
	penalty = (0.5 * lambda) * sum(sum(theta .^ 2));
	cost = cost + penalty;

	% compute gradients
	prob = groundTruth - hTheta;
	s = 0;

	for i = 1 : ndatas
		s = s + sumtimes(data(:, i), prob(:, i));
	end

	thetagrad =  s' / -ndatas + lambda * theta;

	% ------------------------------------------------------------------
	% Unroll the gradient matrices into a vector for minFunc
	grad = [thetagrad(:)];
end

% this function is designed to buttress the bsxfun for gradients computing
% multiply a with every element in b
function r = sumtimes(a, b)
	r = bsxfun(@times, a, b');
end