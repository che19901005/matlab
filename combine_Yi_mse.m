% in this function, we will try a crazy new way as below:
% 1. calculate Lni for each view.
% 2. calculate Yni for each view which is the eigenvectors of Lni with
% minimum d eigenvalues.
% 3. initial ai as uniform distribution
% repeat:
%  4. combine all Yi as [a1Y1; ... ; amYm] as Y.
% 5. get L through Y get last step.
% 6. get Y through L above
% 7. update ai through Y got above.
% 8. until convergence.
function Y = combine_Yi_mse(d,data,r,k)
    import MSE;
    mse = MSE(d,data,r,k);
    Ln = mse.Ln;
    Yi = {};
    for i = 1:length(Ln)
        Yi{i} = mse.get_Y_through_L(Ln{i});
    end
    Y = []
    for i = 1:length(Yi)
        Y = [Y;mse.ai(i)^r*Yi{i}];
    end
    L = mse.find_Lni_for_input_matrix(Y);
    Y = mse.get_Y_through_L(L);
    while(mse.update_and_check_convergence(Y) == 0)
        Y = []
        for i = 1:length(Yi)
            Y = [Y;mse.ai(i)^r*Yi{i}];
        end
        L = mse.find_Lni_for_input_matrix(Y);
        Y = mse.get_Y_through_L(L);
    end
end

% this algorithm is not working well, because the update ai function is not
% correct according this case, we still use the function from the mse.