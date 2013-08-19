% in this function, we will achieve a very simple image retreival and
% evaluation functionality, we use knn search method to search the closest
% k instances, and output the matrix to show the result.

function [confusion_matrix,acc] = content_based_image_retreival(data,labels,rank,number_classes)
    confusion_matrix = zeros(number_classes);
    for idx = 1:length(data)
        compared_instances = data;
        % remove the instance from original data.
        compared_instances(:,idx)=[];
        indeces = knnsearch(compared_instances',data(:,idx)','k',rank);
        for result = 1:length(indeces)
            if indeces(result) >= idx
                indeces(result) = indeces(result)+1;
            end
           % confusion_matrix(labels(idx),labels(indeces(result))) = confusion_matrix(labels(idx),labels(indeces(result)))+1;
           %[voted_element,appear_time] = mode(labels(indeces));
        end
        [voted_element,appear_time] = mode(labels(indeces));
        disp(labels(indeces));
        if sum(find(labels(indeces) == labels(idx))) == appear_time
               confusion_matrix(labels(idx),labels(idx)) = confusion_matrix(labels(idx),labels(idx))+1;
        else
            confusion_matrix(labels(idx),voted_element) = confusion_matrix(labels(idx),voted_element) +1;
        end
        disp({'current instance label is:',labels(idx),'voted label is:',voted_element});
    end
    acc = sum(diag(confusion_matrix)) /length(data);
end
