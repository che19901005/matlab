% this class is defined to generate different feature matrices using
% different algorithms. It is like a factory used to create different kinds
% of matrices.
classdef feature_matrices_factory    
    properties(Access = public)
        directory_names
    end
    
    methods(Access = public)
        %function obj = feature_matrices_factory(dirnames)
         %   obj.directory_names = cellstr(dirnames)
        %end
        
        function obj = feature_matrices_factory()
            obj.directory_names = cellstr(['./data/ToyDataset/obj_bus/  '; './data/ToyDataset/obj_ship/ '; './data/ToyDataset/obj_train/']);
        end
        % this method is used to generate the feature_matrix, this method
        % takes directory names as argument. return a hsv feature matrix
        % which is 50*150
        function multi_feature_matrices = get_hsv_pwt_correlogram_feature_matrix(obj, number_bins)
            hsv_feature_matrix = [];
            pwt_feature_matrix = [];
            color_correlogram_matrix = [];
            for i = 1:length(obj.directory_names)
                files = dir(char(obj.directory_names(i)));
                fileindex = find(~[files.isdir]);
                % here we take 50 instances from each folder(category)
                for file_i = 1:100
                    image = imread([char(obj.directory_names(i)) char(files(fileindex(file_i)).name)]);
                    hsv_vector = hsv_hist(image,number_bins);
                    pwt_vector = pwt_hist(image);
                    color_correlogram_vector = colorAutoCorrelogram(image)';
                    hsv_feature_matrix = [hsv_feature_matrix hsv_vector];
                    pwt_feature_matrix = [pwt_feature_matrix, pwt_vector];
                    color_correlogram_matrix = [color_correlogram_matrix,color_correlogram_vector];
                end
            end
            zero_idx = find(color_correlogram_matrix == 0);
            %for zidx = 1:length(zero_idx)
             %   color_correlogram_matrix(zero_idx(zidx)) = 10^-4;
            %end
            hsv_max = max(max(hsv_feature_matrix));
            pwt_max = max(max(pwt_feature_matrix));
            color_correlogram_max = max(max(color_correlogram_matrix));
            % then we will use the maximum values of the two matrix to make
            % two matrices values are in range (0,1)
            hsv_feature_matrix = hsv_feature_matrix / hsv_max;
            pwt_feature_matrix = pwt_feature_matrix / pwt_max;
            color_correlogram_matrix = color_correlogram_matrix / color_correlogram_max;
            multi_feature_matrices = {hsv_feature_matrix, pwt_feature_matrix,color_correlogram_matrix};
        end
    end
end

