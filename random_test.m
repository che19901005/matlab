function random_test(labels)
right = 0;
for i = 1:length(labels)
    l = randi(4)
    if l == labels(i)
        right=right+1;
    end
end
disp({'the accurency is:',right/331});
end
