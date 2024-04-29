%**************************************************************************
%
%   Author      W. Bryan Bell, Ph.D.
%   Project     Image Tracking Project, 2024
%   Purpose     Give a coding example of how to read, parse, process 
%               and write an AVI file.
%
%**************************************************************************

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
out_fname = 'example_output.avi';
video_out_obj = VideoWriter(out_fname);
video_out_obj.FrameRate = frame_rate;
open(video_out_obj);

% Loop through every frame of the movie and process the image
% - The 2D image  data is contained in the image, I1 a can be further
%   processed as needed.
for ith_frame=1:num_imgs
    
    % Read the ith frame into an image
    I1 = read(video_in_obj, ith_frame);
    
    % Process the image (In this case, take the negative of the image)
    I2 = 255 - I1;
    
    % Add the image to the ith frame of the output movie
    f = im2frame(I2,gray(256));
    writeVideo(video_out_obj,f.cdata)
end

% Writes the movie data to file when it is closed
close(video_out_obj);

% Look at the last processed frame of the image
figure
colormap(gray(256));
imshow(I1);

%**************************************************************************
