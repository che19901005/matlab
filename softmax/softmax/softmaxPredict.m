function [condP , pred] = softmaxPredict(softmaxModel, data)

    % softmaxModel - model trained using softmaxTrain
    % data - the N x M input matrix, where each column data(:, i) corresponds to
    %        a single test set

    % pred, where pred(i) is argmax_c P(y(c) | x(i)).

    % Unroll the parameters from theta
    theta = softmaxModel.optTheta;  % this provides a numClasses x inputSize matrix

    M = exp(theta * data);
    condP = bsxfun(@rdivide, M, sum(M));
    [~, pred] = max(condP);

end

