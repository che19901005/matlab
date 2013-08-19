classdef mse_co_neighbours_improved < mse_co_neighbours
    % different from the mse_co_neighbours one, we count the neighbour
    % appear times, if the certain neighbour appear more than m/2 times among all
    % the views, then we count it as real neighbour, else discard it.
    
    properties
    end
    
    methods(Access = public)
        function obj = mse_co_neighbours_improved(dimentional,data,r,k)
            obj = obj@mse_co_neighbours(dimentional,data,r,k);
        end
        
        % this function is the one which different from the base class.
        % this function will return a list contains elements which are
        % [index,distance] so that we can give the weights to the distance
        % in this step.
        % the distance will change according to its appearance
        % times.distance = distance/appear times(try).
        function index_and_distance_list = find_real_neighbours_for_input_column(obj,column_number)
            index_matrix = zeros(length(obj.X_feature_matrices),obj.number_neighbours);
            for i = 1:length(obj.X_feature_matrices)
                disp('current view is:');
                disp(i);
                disp('current instance is:');
                disp(column_number);
                [index,distance] = obj.find_k_nearest_neighbours(obj.X_feature_matrices{i},column_number);
                index_matrix(i,:) = index;
                index_and_distance_list{i} = {index,distance};
            end
            unique_values = unique(index_matrix)';
            for i = 1:length(unique_values)
                 % if the appearance times is less than half of views, then
                 % delete it from the list.
                if sum(sum(index_matrix == unique_values(i))) < length(obj.X_feature_matrices)/2
                   for j = 1:length(index_and_distance_list)
                       position = find(index_and_distance_list{j}{1} == unique_values(i));
                       % we need to find out the position current value
                       % is(exist or not)
                       if isempty(position) == 0
                           index_and_distance_list{j}{1}(position) = [];
                           index_and_distance_list{j}{2}(position) = [];
                       end
                   end
                else
                    % if the neighbours appear more than number of half
                    % views, then divide the distance by the appearance
                    % times.
                    for j = 1:length(index_and_distance_list)
                       position = find(index_and_distance_list{j}{1} == unique_values(i));
                       % we need to find out the position current value
                       % is(exist or not)
                       if isempty(position) == 0
                           % we change the distance as
                           % distance=distance*appearance times.
                           index_and_distance_list{j}{2}(position) = index_and_distance_list{j}{2}(position) / (sum(sum(index_matrix == unique_values(i)))^3);
                       end
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
               % this time the result from the function
               % find_real_neighbours_for_input_column contains both
               % information of index and distance.
               index_and_distance_list = obj.find_real_neighbours_for_input_column(j);
               for i = 1:length(index_and_distance_list)
                   disp('current view:');
                   disp(i);
                   disp('index list');
                   disp(index_and_distance_list{i});
                   for v = 1: length(index_and_distance_list{i}{1})
                       if index_and_distance_list{i}{1}(v) >= j
                           index_and_distance_list{i}{1}(v) = index_and_distance_list{i}{1}(v)+1;
                       end
                       Wi{i}(j,index_and_distance_list{i}{1}(v)) = exp(-index_and_distance_list{i}{2}(v));
                       Wi{i}(index_and_distance_list{i}{1}(v),j) = exp(-index_and_distance_list{i}{2}(v));
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

