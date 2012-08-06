function isThere = findStringInStruct(struct,text)
isThere = 0;
for i=1:length(struct)
    if(strcmp(struct(i),text))
        isThere = 1;
        break;
    end
end
end