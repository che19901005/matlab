function scatter_for_input_matrix(input_matrix)
    shape_factory = {'d','c','x','s','p'};
    shapes = shape_factory(input_matrix(3,:));
    color_factory = {'red','blue','green','black','purple','orange','yello'};
    %color_factory = [1,2,3,4];
    colors = color_factory(input_matrix(3,:));
    %scatter(input_matrix(1,:),input_matrix(2,:),15,'red');
    labels = input_matrix(3,:);
    two_index = find(labels == 2,1);
    three_index = find(labels == 3,1);
    four_index = find(labels == 4,1);
    s = 20;
    scatter(input_matrix(1,1:two_index-1),input_matrix(2,1:two_index-1),s,'red','+'); hold on
    scatter(input_matrix(1, two_index: three_index-1),input_matrix(2,two_index: three_index-1),s,'blue','c'); hold on
    scatter(input_matrix(1,three_index: four_index-1),input_matrix(2,three_index: four_index-1),s, 'green', 'x'); hold on
    scatter(input_matrix(1,four_index:length(labels)),input_matrix(2,four_index:length(labels)),s,'black','s');
end