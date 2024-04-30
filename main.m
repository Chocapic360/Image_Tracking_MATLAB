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
[~,r_data] = read_track_data('input_truth_2024.bin');

% Loop through every frame of the movie and process the image
for ith_frame=1:num_imgs

    real_rows = r_data(ith_frame,:,1);
    real_cols = r_data(ith_frame,:,2);

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
        r = S(i).Centroid(2);
        c = S(i).Centroid(1);

        % Assorted List of centroid values
        c_row = [r, c_row];
        c_col = [c, c_col];

        % Sorted Matrix of centroid values
        dot_num = 0;
        lownorm = 1000;
        for j = 1:16
            real_r = r_data(ith_frame,j,1);
            real_c = r_data(ith_frame,j,2);
            if norm([r,c] - [real_r, real_c]) < lownorm
                dot_num = j;
                lownorm = norm([r,c] - [real_r, real_c]);
            end
        end
        t_data(ith_frame,dot_num,1) = r;
        t_data(ith_frame,dot_num,2) = c;
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

% Assorted List of real data
r_row = [];
r_col = [];

for i = 1:300
    for j = 1:16
        r_row = [r_data(i,j,1), r_row];
        r_col = [r_data(i,j,2), r_col];
    end
end

% Sorted by magnitude
r_mat = [sort(r_row)', sort(r_col)'];
c_mat = [sort(c_row)', sort(c_col)'];

% Assorted Error list
errors = zeros(1,4800);
for i = 1:4800
    errors(i) = norm(r_mat(i,:)-c_mat(i,:));
end

% Sorted Error Matrix
error_mat = zeros(300,16);
for i = 1:300
    for j = 1:16
        error_mat(i,j) = norm([t_data(i,j,1),t_data(i,j,2)]-[r_data(i,j,1),r_data(i,j,2)]);
    end
end

% Error graph for assorted list of center values
figure;
hold on;
plot(1:4800, errors, 'r.');
yline(mean(errors),'blue','LineWidth',1.25);
xlim([0 4800]);
legend("Error", "Average");
xlabel("Data points");
ylabel("Norm distance to real data (pixels)");
title("Error of tracked points");
hold off;

% Error graph for each dot
figure;
sgtitle("Norm distance for each dot (pixels)");
for i = 1:16
    subplot(2,8,i);
    hold on;
    plot(1:300,error_mat(:,i), 'b.')
    yline(mean(error_mat(:,i)),'red','LineWidth',1.25)
    hold off;
    subplot_title = 'Dot #'+string(i);
    title(subplot_title);
    xlabel("Frames");
    ylabel("Norm Distance (pixels)");
end