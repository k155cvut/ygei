%****************************
%JPG komprese pro matici 8x8
%****************************

clc
clear

%Load figure and show
fig1 = imread('image1.bmp');
imshow(fig1,[0 80]);

%RGB components
R=double(fig1(:,:,1));
G=double(fig1(:,:,2));
B=double(fig1(:,:,3));

%Quantization matrix, component Y
 QC=[17 18 24 47 66 99 99 99;
    18 21 26 66 99 99 99 99;
    24 26 56 99 99 99 99 99;
    47 69 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99];

%Quantization matrix, components Cb, Cr
QY=[16 11 10 16 24 40 51 61;
   12 12 14 19 26 58 60 55;
   14 13 16 24 40 57 69 56;
   14 17 22 29 51 87 80 61;
   18 22 37 56 68 109 103 77;
   24 35 55 64 81 104 113 92;
   49 64 78 87 103 121 120 101;
   72 92 95 98 112 100 103 99];


%********************************
% JPEG COMPRESSION
%********************************

%Conversion RGB to YCbCr
Y=  0.2990 * R + 0.5870 * G + 0.1140 * B;
CB=-0.1687 * R - 0.3313 * G + 0.5000 * B + 128;
CR= 0.5000 * R - 0.4187 * G - 0.0813 * B + 128;

%Create transformed components
[m, n] = size(R);
YT = Y;
CBT = CB;
CRT = CR;

%Process by submatrices one by one
for i = 1 : 8 : m-7
    for j = 1 : 8 : n-7

        %Get submatrix
        YS = YT(i:i+7, j:j+7);
        CBS = CBT(i:i+7, j:j+7);
        CRS = CRT(i:i+7, j:j+7);

        %DCT by components
        YSD = mydct2(YS );
        CBSD = mydct2(CBS);
        CRSD = mydct2(CRS);

        %Round values
        YSD=round(YSD);
        CBSD=round(CBSD);
        CRSD=round(CRSD);
        
        %Compression factor
        q=100;
        QY_Y=50*QY/q;
        QC_C=50*QC/q;
        
        %Quantization
        FYS=round(YSD./QY_Y);
        FCBS=round(CBSD./QC_C);
        FCRS=round(CRSD./QC_C);

        %Set compresed submatrix
        YT(i:i+7, j:j+7) = FYS;
        CBT(i:i+7, j:j+7) = FCBS;
        CRT(i:i+7, j:j+7) = FCRS;
    end       
end
