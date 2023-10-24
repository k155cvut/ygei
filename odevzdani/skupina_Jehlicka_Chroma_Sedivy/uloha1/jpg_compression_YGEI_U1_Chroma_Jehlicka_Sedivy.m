% Image JPEG Compression and Decompression 
% YGEI 2023, uloha 1, Jehlicka, Chroma, Sedivy
clc
clear

%%%%%%%%%%%%%%%
compression_factor = 10;
%%%%%%%%%%%%%%%


% Load and display the input image
input_image = imread('image2.bmp');
imshow(input_image,[0 80]);

% Separate RGB 
R = double(input_image(:,:,1));
G = double(input_image(:,:,2));
B = double(input_image(:,:,3));

% Define quantization matrices for Y, CB, Cr 
quantization_matrix_Y = [17 18 24 47 66 99 99 99;
                         18 21 26 66 99 99 99 99;
                         24 26 56 99 99 99 99 99;
                         47 69 99 99 99 99 99 99;
                         99 99 99 99 99 99 99 99;
                         99 99 99 99 99 99 99 99;
                         99 99 99 99 99 99 99 99;
                         99 99 99 99 99 99 99 99];

quantization_matrix_CbCr = [16 11 10 16 24 40 51 61;
                            12 12 14 19 26 58 60 55;
                            14 13 16 24 40 57 69 56;
                            14 17 22 29 51 87 80 61;
                          18 22 37 56 68 109 103 77;
                          24 35 55 64 81 104 113 92;
                        49 64 78 87 103 121 120 101;
                        72 92 95 98 112 100 103 99];

%% JPEG Compression
% Convert RGB to YCbCr
Y=0.2990*R+0.5870*G+0.1140*B;
Cb=-0.1687*R-0.3313*G+0.5000*B+128;
Cr=0.5000*R-0.4187*G-0.0813*B+128;

% Initialize transformed components
[m, n] = size(R);
Y_transformed = Y;
Cb_transformed = Cb;
Cr_transformed = Cr;


for i = 1:8:m-7
    for j = 1:8:n-7
        
        Y_submatrix = Y_transformed(i:i+7, j:j+7);
        Cb_submatrix = Cb_transformed(i:i+7, j:j+7);
        Cr_submatrix = Cr_transformed(i:i+7, j:j+7);

        %  DCT 
        Y_submatrix_dct = mydct(Y_submatrix);
        Cb_submatrix_dct = mydct(Cb_submatrix);
        Cr_submatrix_dct = mydct(Cr_submatrix);

        
        Y_submatrix_dct = round(Y_submatrix_dct);
        Cb_submatrix_dct = round(Cb_submatrix_dct);
        Cr_submatrix_dct = round(Cr_submatrix_dct);

        
        
        Y_quantization_matrix_Y = 50 * quantization_matrix_Y / compression_factor;
        CbCr_quantization_matrix_C = 50 * quantization_matrix_CbCr / compression_factor;

        % Quantization
        Y_quantized = round(Y_submatrix_dct ./ Y_quantization_matrix_Y);
        Cb_quantized = round(Cb_submatrix_dct ./ CbCr_quantization_matrix_C);
        Cr_quantized = round(Cr_submatrix_dct ./ CbCr_quantization_matrix_C);

        % Update the compressed submatrices
        Y_transformed(i:i+7, j:j+7) = Y_quantized;
        Cb_transformed(i:i+7, j:j+7) = Cb_quantized;
        Cr_transformed(i:i+7, j:j+7) = Cr_quantized;
    end
end


%% ZIG-ZAG

Zig_Y = zigzagToOneLine(Y_transformed);
Zig_Cb = zigzagToOneLine(Cb_transformed);
Zig_Cr = zigzagToOneLine(Cr_transformed);

Y_transformed =  createZigzagMatrix(Zig_Y,m,n);
Cb_transformed =  createZigzagMatrix(Zig_Cb,m,n);
Cr_transformed =  createZigzagMatrix(Zig_Cr,m,n);






%% JPEG Decompression

for i = 1:8:m-7
    for j = 1:8:n-7
        
        Y_submatrix = Y_transformed(i:i+7, j:j+7);
        Cb_submatrix = Cb_transformed(i:i+7, j:j+7);
        Cr_submatrix = Cr_transformed(i:i+7, j:j+7);

        % Dequantization
        Y_dequantized = round(Y_submatrix .* Y_quantization_matrix_Y);
        Cb_dequantized = round(Cb_submatrix .* CbCr_quantization_matrix_C);
        Cr_dequantized = round(Cr_submatrix .* CbCr_quantization_matrix_C);

        % Inverse DCT
        Y_inverse_dct = myidct(Y_dequantized);
        Cb_inverse_dct = myidct(Cb_dequantized);
        Cr_inverse_dct = myidct(Cr_dequantized);

        % Update the decompressed submatrices
        Y_transformed(i:i+7, j:j+7) = Y_inverse_dct;
        Cb_transformed(i:i+7, j:j+7) = Cb_inverse_dct;
        Cr_transformed(i:i+7, j:j+7) = Cr_inverse_dct;
    end
end

%%  YCbCr to RGB
R_output=1.0000*Y_transformed-0.0000*(Cb_transformed-128)+1.4020*(Cr_transformed-128);
G_output=1.0000*Y_transformed-0.3441*(Cb_transformed-128)-0.7141*(Cr_transformed-128);
B_output=1.0000*Y_transformed+1.7720*(Cb_transformed-128)-0.0001*(Cr_transformed-128);

% Output image
output_image = uint8(zeros(size(input_image)));
output_image(:, :, 1) = uint8(R_output);
output_image(:, :, 2) = uint8(G_output);
output_image(:, :, 3) = uint8(B_output);

% Display the output image
imshow(output_image);

%% Calculate differences and errors in RGB components
delta_R = R_output - R;
delta_G = G_output - G;
delta_B = B_output - B;

delta_R_squared = delta_R .* delta_R;
delta_G_squared = delta_G .* delta_G;
delta_B_squared = delta_B .* delta_B;

mean_R_error = sqrt(sum(sum(delta_R_squared)) / (m * n))
mean_G_error = sqrt(sum(sum(delta_G_squared)) / (m * n))
mean_B_error = sqrt(sum(sum(delta_B_squared)) / (m * n))











%% FUNCTIONS

function [resultingTransform] = mydct(inputMatrix)

% Custom DCT
resultingTransform = inputMatrix;

for u = 0:7
    for v = 0:7

        % Define  Cu, Cv
        if (u == 0)
            Cu = sqrt(2) / 2;
        else
            Cu = 1;
        end

        if (v == 0)
            Cv = sqrt(2) / 2;
        else
            Cv = 1;
        end

        % for each pixel
        sumResult = 0;
        for x = 0:7
            for y = 0:7
                sumResult = sumResult + (1 / 4) * Cu * Cv * inputMatrix(x + 1, y + 1) * ...
                    cos((2 * x + 1) * u * pi / 16) * cos((2 * y + 1) * v * pi / 16);
            end
        end

        %  DCT coefficients
        resultingTransform(u + 1, v + 1) = sumResult;
    end
end
end


function [resultingInverseTransform] = myidct(inputTransform)

% IDCT
resultingInverseTransform = inputTransform;

for x = 0:7
    for y = 0:7

        % for each pixel
        sumResult = 0;
        for u = 0:7
            for v = 0:7

                % Define  Cu, Cv
                if (u == 0)
                    Cu = sqrt(2) / 2;
                else
                    Cu = 1;
                end

                if (v == 0)
                    Cv = sqrt(2) / 2;
                else
                    Cv = 1;
                end

                sumResult = sumResult + (1 / 4) * Cu * Cv * inputTransform(u + 1, v + 1) * ...
                    cos((2 * x + 1) * u * pi / 16) * cos((2 * y + 1) * v * pi / 16);
            end
        end

        % IDCT coefficients
        resultingInverseTransform(x + 1, y + 1) = sumResult;
    end
end
end



function oneLineArray = zigzagToOneLine(inputArray)
   
    [rows, cols] = size(inputArray);
    oneLineArray = zeros(1, rows * cols);

    
    row = 1;
    col = 1;
    direction = -1; % Start with up

    for index = 1:(rows * cols)
        % Assign element to the output array
        oneLineArray(index) = inputArray(row, col);

        % Update  position with direction
        if direction == -1
            % Check for boundary 
            if row > 1 && col < cols
                row = row - 1;
                col = col + 1;
            elseif col == cols
                row = row + 1;
                direction = 1; % Change to down
            else
                col = col + 1;
                direction = 1; % Change to down
            end
        else
            % Check for boundary 
            if col > 1 && row < rows
                row = row + 1;
                col = col - 1;
            elseif row == rows
                col = col + 1;
                direction = -1; % Change to upw
            else
                row = row + 1;
                direction = -1; % Change to up
            end
        end
    end
end



function zigzagMatrix = createZigzagMatrix(inputVector, numRows, numCols)
    if numRows * numCols ~= length(inputVector)
        error('Number of elements in inputVector does not match numRows * numCols.');
    end

    zigzagMatrix = zeros(numRows, numCols);

    
    i = 1;
    j = 1;
    direction = 1;  % 1 for upwards, -1 for downwards

    % Loop through  inputVector and fill zigzagMatrix
    for k = 1:length(inputVector)
        zigzagMatrix(i, j) = inputVector(k);

        % Update indices
        if direction == 1
            if i > 1 && j < numCols
                i = i - 1;
                j = j + 1;
            elseif j < numCols
                j = j + 1;
                direction = -1;
            else
                i = i + 1;
                direction = -1;
            end
        else
            if j > 1 && i < numRows
                i = i + 1;
                j = j - 1;
            elseif i < numRows
                i = i + 1;
                direction = 1;
            else
                j = j + 1;
                direction = 1;
            end
        end
    end
end

