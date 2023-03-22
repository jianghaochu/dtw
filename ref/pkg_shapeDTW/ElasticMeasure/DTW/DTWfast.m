function [dist, match] = DTWfast(p,q)
    % https://www.mathworks.com/help/matlab/ref/narginchk.html
    % narginchk(minArgs,maxArgs) validates the number of input arguments
    narginchk(2,2);
    [lenp, dimsp] = size(p);
    [lenq, dimsq] = size(q);
    
    if lenp < dimsp || lenq < dimsq
        warning('Each dimension of signal should be organized columnwisely\n');
    end
    
    if dimsp ~= dimsq
        error('two sequences should be of the same dimensions\n');
    end
    
    % dist2 is available at discriptor\shape-context
    % dist2 Calculates squared distance between two sets of points
    d = dist2(p, q);
	d = sqrt(d);

    % dpfast is available at ElasticMeasure\DanEills
    % dpfast Return state sequence in idxp, idxq; full min cost matrix as cD and 
    % local costs along best path in pc.
    % dpfast calls a mex file (complied subroutine) to speed up calculation
    [idxp, idxq, cD, pc] = dpfast(d);

    % Here is the place apply weights on the time-dimension
	match =[idxp' idxq'];    
    dist = sum(pc);
 
end