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

% Create the output movie object
out_fname = 'output.avi';
video_out_obj = VideoWriter(out_fname);
video_out_obj.FrameRate = frame_rate;
open(video_out_obj);

c_row = [];
c_col = [];

t_data = zeros(300,16,2);

% Loop through every frame of the movie and process the image
for ith_frame=1:num_imgs
    %ith_frame = 1; %%% DEBUG ONLY
    % Read the ith frame into an image
    I1 = read(video_in_obj, ith_frame);

    % Denoise using 5x5 avg filter
    filter = ones(5,5)/25;
    I2 = imfilter(I1,filter);

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
        I2 = draw_mark_on_target(I2,S(i),10,7,'white');
        % Note down the centers
        c_row = [S(i).Centroid(2), c_row];
        c_col = [S(i).Centroid(1), c_col];
        t_data(ith_frame,i,1) = S(i).Centroid(2);
        t_data(ith_frame,i,2) = S(i).Centroid(1);
    end

    % Plot trails
    for i = 2:length(c_row)
        a = round(c_row(i));
        b = round(c_col(i));
        I2(a,b) = 0;
    end

    % Add the image to the ith frame of the output movie
    f = im2frame(im2double(I2),gray(256));
    writeVideo(video_out_obj,f.cdata);
end

% Writes the movie data to file when it is closed
close(video_out_obj);

[~,r_data] = read_track_data('input_truth_2024.bin');
out_fname = 'output_test.avi';
video_out_obj = VideoWriter(out_fname);
video_out_obj.FrameRate = frame_rate;
open(video_out_obj);

r_row = [];
r_col = [];

for i = 1:300
    for j = 1:16
        r_row = [r_data(i,j,1), r_row];
        r_col = [r_data(i,j,2), r_col];
    end
end

r_mat = [sort(r_row)', sort(r_col)'];
c_mat = [sort(c_row)', sort(c_col)'];

errors = zeros(1,4800);
for i = 1:4800
    errors(i) = norm(r_mat(i,:)-c_mat(i,:));
end

figure;
hold on;
plot(1:4800, errors, 'r.');
yline(mean(errors),'blue','LineWidth',1.25);
xlim([0 4800]);
legend("Error", "Average");
xlabel("Data points");
ylabel("Norm distance to real data (pixels)");
title("Error of tracked points");