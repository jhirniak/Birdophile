%compute frequency from mel value
function f = mel2freq (m)
f = 700*((10.^(m ./2595)) -1);
end