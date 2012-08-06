%compute mel value from frequency f
function m = freq2mel (f)
m = 2595 * log10(1 + f./700);
end