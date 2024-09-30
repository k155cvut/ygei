X = [3, 5, 4, -1, 19, 24];
[xmin,xmax,imin,imax] = minmaxwithindices(X)

function [xmin,xmax,imin,imax] = minmaxwithindices(X)
    xmin = X(1);
    xmax = X(1);
    imin = 1;
    imax = 1;
    
    for  i = 1:length(X)
        if X(i) < xmin
            xmin = X(i);
            imin = i;
        end
        if X(i)> xmax
            xmax = X(i);
            imax = i;
        end
    end

end
