classdef bio_data_process_output < handle
    %we will use this class, we will achieve functions to process input
    %data style, use mse to train and finally output the matrix
    properties(Access = public)
        pet_cmrglc;
        mri_volume;
        mri_solidity;
        mri_convexity;
        labels;
        final_matrix;
        data;
    end
    
    methods(Access = public)
        % when we create the class, we load the data from data_toSQ_HY.mat
        % and meanwhile change the style of all of them. since the original
        % data is #patients * #features, however when we use mse to train,
        % we need data as #features * #patients.
        function obj = bio_data_process_output()
            mat = load('data_toSQ_HY.mat');
            data = mat.data;
            
            % next lines use 1/(1+e^x) to normalise the matrix.
            
            %obj.pet_cmrglc = 1./(1+exp(-data.CMRGLC'));
            %obj.mri_volume = 1./(1+exp(-data.VOLUME'));
            %obj.mri_solidity = 1./(1+exp(-data.SOLIDITY'));
            %obj.mri_convexity = 1./(1+exp(-data.CONVEXITY'));
            
            % now we use maximum value in the matrix to normalise the
            % matrix.
            obj.pet_cmrglc = data.CMRGLC'/max(max(data.CMRGLC));
            obj.mri_volume = data.VOLUME'/(max(max(data.VOLUME)));
            obj.mri_solidity = data.SOLIDITY'/max(max(data.SOLIDITY));
            obj.mri_convexity = data.CONVEXITY'/max(max(data.CONVEXITY));
            
            obj.labels = data.labels';
            obj.data = {obj.pet_cmrglc,obj.mri_volume,obj.mri_solidity,obj.mri_convexity};
        end
        
        function get_mse_low_dimentional_matrix(obj, dimentional,r, k_neighbors)
            mse = MSE(dimentional, {obj.pet_cmrglc,obj.mri_volume,obj.mri_solidity,obj.mri_convexity},r,k_neighbors);
            Y = mse.train();
            obj.final_matrix = [Y; obj.labels];
        end
    end
    
end

