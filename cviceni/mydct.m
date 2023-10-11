function [RT] = mydct(R)

%DCT
RT = R;

for u=0:7
    for v=0:7

        %Coefficients Cu, Cv
        if (u==0)
             Cu=2^0.5/2;
        else
            Cu = 1;
        end

        if (v==0)
             Cv=2^0.5/2;
        else
            Cv = 1;
        end
    
        %Process pixel by pixel
        sumR = 0;
        for x = 0 : 7
            for y = 0 : 7
                sumR = sumR + 1/4 * Cu * Cv * R(x + 1, y + 1 ) *...
                        cos((2 * x + 1) * u * pi/16) * cos((2 * y + 1) * v * pi / 16);
            end
        end
        
        %Compute coefficients
        RT(u + 1, v + 1) = sumR;
    end
end



