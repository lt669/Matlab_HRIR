%{
    Script for normalising all of the deconvolved sweeps with each other
%}

function [normalised] = normHRIR(input)

    [n,m,p] = size(input);
    disp('--- normHRIR ---');
    disp(sprintf('Size: n=%d m=%d p=%d',n,m,p));

    % Find maximum value
    maximum = max(max(max(abs(input))));
    
    disp(sprintf('maximum: %d',maximum));
    
    normalised = input./maximum;
    
    maximumNorm = max(max(max(normalised)));
    
    disp(sprintf('maximumNorm: %d',maximumNorm));
    disp('--- normHRIR Exit---');
end