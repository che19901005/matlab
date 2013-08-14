classdef mse_co_neighbours < MSE
    % in this class, an improved MSE algorithm will be implemented.
    % when we find the k nearest neighbours, we only treat the neighbours
    % in every view as real neighbours, if p is q's neighbour in only one
    % view, then it can not be treated as the neighbours.
    properties(Access = public)
    end
    
    methods(Access = public)
        function obj = mse_co_neighbours(dimentional,data,r,k)
            obj = obj@MSE(dimentional,data,r,k);
            obj.ai = ones(1,length(data))/length(data);
            obj.number_instances = length(data{1});
            obj.generate_Lni();
        end
        
        % in this function, we will try to find out the real neighbours of
        % an input instance using the data of all views.
        function indeces = find_real_neighbours_for_input_column(obj,column_number)
            index_list = {};
            for i = 1:length(obj.X_feature_matrices)
                disp('current view is:');
                disp(i);
                disp('current instance is:');
                disp(column_number);
                [index,distance] = obj.find_k_nearest_neighbours(obj.X_feature_matrices{i},column_number);
                index_list{i} = index;
            end
            indeces = index_list{1};
            for i = 1:length(index_list)
                indeces = mintersect(indeces,index_list{i});
            end
                  
        end
        
       % in this function we will generate Lni for each view.
       function generate_Lni(obj)
           Wi = {};
           for i = 1:length(obj.X_feature_matrices)
               Wi{i} = ones(obj.number_instances)*(0.0000000001);
           end
           for j = 1:obj.number_instances
               index = obj.find_real_neighbours_for_input_column(j);
               disp('intersection index is:');
               disp(index);
               for i = 1:length(index)
                   if index(i)>=j
                       index(i) = index(i)+1;
                   end
                   for v = 1:length(obj.X_feature_matrices)
                       Wi{v}(j,index(i)) = exp(-norm(obj.X_feature_matrices{v}(:,j) - obj.X_feature_matrices{v}(:,index(i))));
                       Wi{v}(index(i),j) = exp(-norm(obj.X_feature_matrices{v}(:,j) - obj.X_feature_matrices{v}(:,index(i))));
                   end
               end
           end
           for i = 1:length(obj.X_feature_matrices)
               D = diag(sum(Wi{i},2));
               %disp('wi is:');
               %disp(Wi{i});
               %disp('di is:');
               %disp(D);
               obj.Ln{i} = eye(obj.number_instances)-D^(-0.5)*Wi{i}*D^(-0.5);
           end
       end
       
       function final_Y = train(obj)
            times = 1;
          L = obj.get_L_through_current_a_Ln(obj.ai, obj.Ln);
          Y =  obj.get_Y_through_L(L);
          while(obj.update_and_check_convergence(Y) == 0)
               L = obj.get_L_through_current_a_Ln(obj.ai, obj.Ln);
               Y =  obj.get_Y_through_L(L);
               times = times + 1;
          end
          
          final_L = obj.get_L_through_current_a_Ln(obj.ai, obj.Ln);
          final_Y = obj.get_Y_through_L(final_L);
          disp('total training times is:');
          disp(times);
          disp(obj.ai);
       end
    end
    
end

