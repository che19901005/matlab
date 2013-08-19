function MAP(Y)
end

function indeces = retrieval(query,dataset,rank)
[indeces,distances] = knnsearch(dataset,query,'k',rank);
end