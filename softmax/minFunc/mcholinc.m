function [R,tau] = mcholinc(H,verbose)
% Computes Cholesky of H+tau*I, for suitably large tau that matrix is pd

p = size(H,1);

BETA = norm(H,'fro');
if min(diag(H)) > 1e-12
    tau = 0;
else
    if verbose
        fprintf('Small Value on Diagonal, Adjusting Hessian\n');
    end
    tau = max(BETA/2,1e-12);
end
while 1
    [R,posDef] = chol(H+tau*eye(p));
    if posDef == 0
        break;
    else
        if verbose
            fprintf('Cholesky Failed, Adjusting Hessian\n');
        end
        tau = max(2*tau,BETA/2);
    end
end
