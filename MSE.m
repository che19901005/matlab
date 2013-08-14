classdef MSE < handle
    %MSE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = public)
        final_dimentional = 0;
        X_feature_matrices = []
        r = 1;
        number_instances = 0;
        number_neighbours = 0;
        Ln = [];
        ai = [];
        %Li = []
    end
    
    methods(Access = public)
        % the constructor will give values to the properties belong to this
        % class.
        function obj = MSE(d_value,feature_matrices,r_value, k_value)
            % this is the final dimentional user wanna to reduce to.
            obj.final_dimentional = d_value;
            % this is the real data will be used.
            obj.X_feature_matrices = feature_matrices;
            % the power value will be used to ai, rich complementary
            % perfers large r.
            obj.r = r_value;
            % this is value of how many instances are considered.
            obj.number_instances = size(obj.X_feature_matrices{1},2);
            % this value is how many nearest neighbors will be considered.
            obj.number_neighbours = k_value;
            % weights for each model.The training part is about this.
            obj.ai = ones(1, size(obj.X_feature_matrices,2 ))/size(obj.X_feature_matrices,2);
            % for each model, calculate Ln for each model when we generate
            % the model.
            %for i = 1:size(obj.X_feature_matrices,2);
                %Lni_and_Li = obj.find_Lni_for_input_matrix(obj.X_feature_matrices{i})
             %   obj.Ln{i} = obj.find_Lni_for_input_matrix(obj.X_feature_matrices{i});
                %obj.Li{i} = Lni_and_Li{2}
            %end
        end
        
       % this method is used to find out he k-nearest neighbours matrix
       % according to an input matrix: mi*(k+1) and an value i which means the ith
       % column is used as standard. return both index of the neighbours
       % and the distances.
       function [indeces,distances] = find_k_nearest_neighbours(obj, input_matrix, column_index)
           %number_rows = size(input_matrix,1);
           %number_columns = size(input_matrix,2)
           target_vector = input_matrix(:,column_index);
           input_matrix(:,column_index) = [];
           % knnsearch can only used to search row vectors not column, so
           % in this case we need to transfer them so that we take columes
           % as target vectors.
           [indeces , distances] = knnsearch(input_matrix', target_vector', 'k',obj.number_neighbours);
           disp('k nearest neighbours are:');
           disp([indeces, distances]);
           %neighbour_matrix = [target_vector input_matrix(:,indeces)];
       end
       
      % this function is used to generate Ln(i) for ith view. input is a
      % feature matrix mi*n for a view and output a matrix which is Ln(i) n*n for
      % this matrix
      
      
      
      % this method will be used to calculate L with current ai vector and
      % Ln for all views. input: ai vector: 1 * m / Ln: contain m matrices
      % for each view. output: L n*n
      function L = get_L_through_current_a_Ln(obj, ai, Ln)
          L = zeros(obj.number_instances);
          for i = 1: length(obj.ai)
             L = L + (ai(i)^obj.r) * Ln{i};
          end
      end
      
      % this method is used to get Y through an input L matrix. input: L
      % n*n. output: Y  d*n matrix.
      
      function Y = get_Y_through_L(obj, L)
          Y = zeros(obj.final_dimentional,obj.number_instances);
          [eigenvectors, eigenvalues] = eig(L);
          % this method will sort sorted_value from big to small, and
          % change sorted_vectors according to the change of eigenvalues
          [sorted_vectors,sorted_values] = sortem(eigenvectors,eigenvalues);
          for i = 1: obj.final_dimentional
              Y(i,:)= sorted_vectors(:,size(sorted_vectors,2)-i+1)';
          end
      end
      
      % this function will be used to update local ai vector first, and
      % then check whether it changes or not. return the boolean value to
      % show whether meet the convergence(ai does not change). 
      
      function convergence = update_and_check_convergence(obj, Y)
          last_ai = obj.ai;
          sum = 0;
          for i = 1:length(obj.ai)
              sum = sum + (1/trace(Y*obj.Ln{i}*Y'))^(1/(obj.r-1));
          end
          for i = 1: size(obj.ai,2)
              obj.ai(i) = (1/trace(Y*obj.Ln{i}*Y'))^(1/(obj.r-1))/sum;
          end
          disp(last_ai);
          disp(obj.ai);
          convergence = (norm(last_ai - obj.ai) < 0.000001);
      end
      
      % this method is used to do the whole training process until
      % convergence. After generating the object, you can just call train()
      % to do the entire training progress.
      
      function final_Y = train(obj)
          for i = 1:size(obj.X_feature_matrices,2);
                %Lni_and_Li = obj.find_Lni_for_input_matrix(obj.X_feature_matrices{i})
                obj.Ln{i} = obj.find_Lni_for_input_matrix(obj.X_feature_matrices{i});
                %obj.Li{i} = Lni_and_Li{2}
          end
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
      
      % this method is also used for training, but take an argument which
      % is the times training will be done.
      
      function final_Y = train_with_certain_times(obj, times)
          L = obj.get_L_through_current_a_Ln(obj.ai, obj.Ln);
          Y = obj. get_Y_through_L(L);
          for i = 1: times
              obj.update_and_check_convergence(Y);
              disp(obj.ai);
              L = obj.get_L_through_current_a_Ln(obj.ai, obj.Ln);
               Y =  obj.get_Y_through_L(L);
          end
          final_L = obj.get_L_through_current_a_Ln(obj.ai, obj.Ln);s
          final_Y = obj.get_Y_through_L(final_L);
      end
        
    end
    methods(Access = private)
    function Lni = find_Lni_for_input_matrix(obj, input_matrix)
          number_examples = size(input_matrix,2);
          Wi = zeros(number_examples);
          for i =1: number_examples
              new_input_matrix = input_matrix;
              [indeces, distances] = obj.find_k_nearest_neighbours(new_input_matrix, i);
              % here we define the value of t as 3.
              distances = exp(-distances);
              %weight_sum_vector(i) = sum(distances);
              for j = 1:length(indeces)
                  % since we removed ith colume from the original one, so
                  % if the index is larger then i, then that means after
                  % removing i, index go one step ahead.
                  if indeces(j) >= i
                      indeces(j) = indeces(j)+1;
                  end
                  Wi(i, indeces(j)) =  distances(j);
                  Wi(indeces(j), i) = distances(j);
              end
          end
          % weight_sum_vector is a colume vector contains sum of each row
          % in Wi. n*1
          weight_sum_vector = sum(Wi,2);
           Di_matrix = diag(weight_sum_vector);
           %Lni = eye(number_examples)-(Di_matrix^(-0.5)) * Wi *(Di_matrix^(-0.5));
           Lni = Di_matrix^(-0.5) * (Di_matrix - Wi) * Di_matrix^(-0.5);
           %Li = Di_matrix - Wi
           %Lni_and_Li = {Lni,Li}
    end
    end
    
end

