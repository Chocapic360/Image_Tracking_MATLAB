clear,clc

clear
clear mex
clc
format long
format compact
close all

% Create the video reader object
input_video_fname = 'image_tracking_input_2024.avi';
video_in_obj = VideoReader(input_video_fname);

% Get some parameters of the input video
num_imgs = video_in_obj.NumFrames;
frame_rate = video_in_obj.FrameRate;
height = video_in_obj.Height;
width  = video_in_obj.Width;
disp(['------ Filename: "' input_video_fname '"'])
disp(['       # frames = ' num2str(num_imgs)])
disp(['     frame rate = ' num2str(frame_rate) ' fps'])
disp(['          H x W = ' num2str(height) ' x ' num2str(width)])

c_row = [];
c_col = [];

t_data = zeros(300,16,2);
[~,r_data] = read_track_data('input_truth_2024.bin');

% Loop through every frame of the movie and process the image
for filters=1:3

    ith_frame = 1; %%% DEBUG ONLY

    real_rows = r_data(ith_frame,:,1);
    real_cols = r_data(ith_frame,:,2);

    % Read the ith frame into an image
    I1 = read(video_in_obj, ith_frame);

    if filters == 1
        % Denoise using 5x5 avg filter
        filter = ones(5,5)/25;
        I2 = imfilter(I1,filter);
    elseif filters == 2
        filter = ones(2,2)/4;
        I2 = imfilter(I1,filter);
    else
        filter = ones(3,3)/9;
        I2 = imfilter(I1,filter);
    end

    % Use a gray threshold on the image and binarize it
    level = graythresh(I2);
    I2 = imbinarize(I2,level);

    % Erode the circles to remove the remaining noise
    SE = strel('disk', 3);
    I2 = imerode(imdilate(I2,SE),SE);

    % Find connected components
    CC = bwconncomp(1-I2);

    % Find centroids
    S = regionprops(CC);

    % Insert Markers onto the image
    markerSize = 5;
    for i = 1:16
        % Note down the centers
        r = S(i).Centroid(2);
        c = S(i).Centroid(1);

        % Assorted List of centroid values
        c_row = [r, c_row];
        c_col = [c, c_col];

        % Sorted Matrix of centroid values
        dot_num = 0;
        lownorm = 1000;
        for j = 1:16
            real_r = r_data(1,j,1);
            real_c = r_data(1,j,2);
            if norm([r,c] - [real_r, real_c]) < lownorm
                dot_num = j;
                lownorm = norm([r,c] - [real_r, real_c]);
            end
        end
        t_data(filters,dot_num,1) = r;
        t_data(filters,dot_num,2) = c;
    end

    % Plot trails
    for i = 2:length(c_row)
        a = round(c_row(i));
        b = round(c_col(i));
        I2(a,b) = 0;
    end

    % Add the image to the ith frame of the output movie
    disp("done")
end

% Sorted Error Matrix
error_mat = zeros(3,16);
for i = 1:3
    for j = 1:16
        error_mat(i,j) = norm([t_data(i,j,1),t_data(i,j,2)]-[r_data(1,j,1),r_data(1,j,2)]);
    end
end

figure;

subplot(1,2,1);
hold on;
plot(1:16, error_mat(1,:));
plot(1:16, error_mat(2,:));
plot(1:16, error_mat(3,:));
legend('5x5','2x2','3x3');
title("Error for different filters")
xlabel("Dots on frame 1");
ylabel("Distance to real value (pixels)");
hold off;

subplot(1,2,2);
hold on;
yline(mean(error_mat(1,:)),'blue');
yline(mean(error_mat(2,:)),'red');
yline(mean(error_mat(3,:)),'green');
legend('5x5','2x2','3x3');
title("Average Error for different filters");
ylabel("Average Distance to real value (pixels)");
ylim([0,1.5]);
hold off;