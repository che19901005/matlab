classdef mse_co_neighbours_improved_original < mse_co_neighbours
    % different from the mse_co_neighbours one, we count the neighbour
    % appear times, if the certain neighbour appear more than m/2 times among all
    % the views, then we count it as real neighbour, else discard it.
    
    properties
    end
    
    methods(Access = public)
        function obj = mse_co_neighbours_improved_original(dimentional,data,r,k)
            obj = obj@mse_co_neighbours(dimentional,data,r,k);
        end
        
        % this function is the one which different from the base class.
        function index_list = find_real_neighbours_for_input_column(obj,column_number)
            index_matrix = zeros(length(obj.X_feature_matrices),obj.number_neighbours);
            for i = 1:length(obj.X_feature_matrices)
                disp('current view is:');
                disp(i);
                disp('current instance is:');
                disp(column_number);
                [index,distance] = obj.find_k_nearest_neighbours(obj.X_feature_matrices{i},column_number);
                index_matrix(i,:) = index;
                index_list{i} = index;
            end
            unique_values = unique(index_matrix)';
            for i = 1:length(unique_values)
                if sum(sum(index_matrix == unique_values(i))) <= length(obj.X_feature_matrices)/2
                   for j = 1:length(index_list)
                       index_list{j} = index_list{j}(index_list{j} ~= unique_values(i));
                   end
                end
            end
            
        end
        
        % this function is also different from the co_neighbours one, this
        % time we treat neighbours from each view respectively, not the
        % same thing.
         function generate_Lni(obj)
           Wi = {};
           for i = 1:length(obj.X_feature_matrices)
               Wi{i} = ones(obj.number_instances)*(0.0000000001);
           end
           for j = 1:obj.number_instances
               index_list = obj.find_real_neighbours_for_input_column(j);
               for i = 1:length(index_list)
                   disp('current view:');
                   disp(i);
                   disp('index list');
                   disp(index_list);
                   for v = 1: length(index_list{i})
                       if index_list{i}(v) >= j
                           index_list{i}(v) = index_list{i}(v)+1;
                       end
                       Wi{i}(j,index_list{i}(v)) = exp(-norm(obj.X_feature_matrices{i}(:,j) - obj.X_feature_matrices{i}(:,index_list{i}(v))));
                       Wi{i}(index_list{i}(v),j) = exp(-norm(obj.X_feature_matrices{i}(:,j) - obj.X_feature_matrices{i}(:,index_list{i}(v))));
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
    end
    
end
