clc
clear

%Load image
ras1 = imread('h:/YGEI/cv2/image1.bmp');
imshow(ras1);

%Compression factor
q = 25;

%get RGB componets
R=ras1(:,:,1);
G=ras1(:,:,2);
B=ras1(:,:,3);

%transformation RGB to YCC
Y = 0.2990 * R + 0.5870 * G + 0.1140 * B;
CB = -0.1687 * R -0.3313 * G + 0.5000 * B + 128;
CR = 0.5 * R - 0.4187 * G - 0.0813 * B + 128;

%Quantisation matrix
Qy = [16 11 10 16 24 40 51 61;
12 12 14 19 26 58 60 55;
14 13 16 24 40 87 69 56;
14 17 22 29 51 87 80 62;
18 22 37 26 68 109 103 77;
24 35 55 64 81 104 113 92;
49 64 78 87 103 121 120 101;
72 92 95 98 112 100 103 99];

% Chrominance matrix
Qc = [17 18 24 47 66 99 99 99
18 21 26 66 99 99 99 99
24 26 56 99 99 99 99 99
47 69 99 99 99 99 99 99
99 99 99 99 99 99 99 99
99 99 99 99 99 99 99 99
99 99 99 99 99 99 99 99
99 99 99 99 99 99 99 99];

%Update quantisation matrices according to q
Qc = (50*Qc)/q;
Qy = (50*Qy)/q;


%Process input easter by sub-matrices
[m, n] = size(Y);

for i = 1:8:m-7
    for j=1:8:n-7

        %Create submatrices
        Ys = Y(i:i+7,j:j+7);
        CBs = CB(i:i+7,j:j+7);
        CRs = CR(i:i+7,j:j+7);

        %Apply DCT
        Ydct = mydct(Ys);
        CBdct = mydct(CBs);
        CRdct = mydct(CRs);

        %Quantisation
        Yq = Ydct./Qc;
        CBq = CBdct./Qy;
        CRq = CRdct./Qy;
        
        %Round
        
    end
end





function Rt=mydct(R)
Rt = R

%Output raster: rows
for u = 0:7
    %Cu
    if u == 0
        Cu = sqrt(2)/2;
    else
        Cu = 1
    end

    %Output raster: columns
    for v = 0:7
        if v == 0
            Cv = sqrt(2)/2;
        else
            Cv = 1
        end

        %Input raster: rows
        F = 0;
        for x = 0:7
            %Input raster: columns
            for y = 0:7
                F=F+1/4*Cu*Cv*(R(x+1,y+1)*cos((2*x+1)*u*pi/16)*cos((2*y+1)*v*pi/16));
            end
        end

        %Output raster
        Rt(u+1,v+1) = F;
    end
end

end

function Rt=myidct(R)
Rt = R

%Output raster: rows
for x = 0:7
   
    %Output raster: columns
    for y = 0:7
       
        %Input raster: rows
        F = 0;
        for u = 0:7
            %Cu
            if u == 0
                Cu = sqrt(2)/2;
            else
                 Cu = 1
            end

            %Input raster: columns
            for v = 0:7
                %Cv
                if v == 0
                    Cv = sqrt(2)/2;
                else
                    Cv = 1
                end
                F=F+1/4*Cu*Cv*(R(x+1,y+1)*cos((2*x+1)*u*pi/16)*cos((2*y+1)*v*pi/16));
            end
        end

        %Output raster
        Rt(u+1,v+1) = F;
    end
end

end