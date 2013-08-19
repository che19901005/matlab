% this algotiehm is:
% calculate Lni for each view.
% initialize ai as 1/m.
% for each Lni, calculate Yi for each view(eigenvectors with smallest eigenvalues)
% repeat:
% Y = sum(ai^r*Yi)
% update ai
% until convergence.
function Y = changed_mse(d,data, r, k )
    import MSE;
    mse = MSE(d,data,r,k);
    Lni = mse.Ln;
    Yi = {};
    for i = 1:length(Lni)
        Yi{i} = mse.get_Y_through_L(Lni{i});
    end
    disp(Yi);
    Y = zeros(d,mse.number_instances)
    for i = 1: length(Yi)
        Y = Y + mse.ai(i)^r * Yi{i}
    end
    while(mse.update_and_check_convergence(Y) == 0)
         Y = zeros(d,mse.number_instances);
         for i = 1: length(Yi)
            Y = Y + (mse.ai(i)^r * Yi{i}); 
         end
    end
     Y = zeros(d,mse.number_instances);
     for i = 1: length(Yi)
            Y = Y + mse.ai(i)^r * Yi{i}; 
     end
     disp('final ai is:');
     disp(mse.ai);
end
% result is almost the same as the standard one.
% we can say that Y = sum(ai^r*Yi)