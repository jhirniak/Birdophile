function answer = isLibraryFile(file)
answer = 0;
if ((length(regexpi(file,'.wav')) + length(regexpi(file,'.mat'))) > 0)
    answer = 1;
end
end