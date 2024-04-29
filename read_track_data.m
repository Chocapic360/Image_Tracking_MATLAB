%**************************************************************************
%
%   Author      W. Bryan Bell, Ph.D.
%   Project     Image Tracking Project, 2024
%   Purpose     Read the truth data for the Image Tracking Project
%
%   Input       filename: Filename of the binary truth file.
%                           (TRUTH data delivered as 'truth.bin')
%
%   Output      success:  Flag stating if the file read was successful.
%               tracks:   3D array containg the track coordinate values for
%                         the center of the target/dots for the Project.
%                           1: Number of image frames in movie.
%                           2: Number of targets.
%                           3: Target coordinate (row,col)
%
%**************************************************************************

function [success, tracks] = read_track_data(filename)

in_fid = fopen(filename,'r','l');
if (in_fid == 0)
    success = false;
    return;
end

num_imgs = fread(in_fid, 1, 'int32');
num_pts  = fread(in_fid, 1, 'int32');
tracks = zeros(num_imgs,num_pts,2);
for img_num=1:num_imgs
    for i_pt=1:num_pts
        tracks(img_num,i_pt,1) = fread(in_fid, 1, 'float64');
        tracks(img_num,i_pt,2) = fread(in_fid, 1, 'float64');
    end
end
fclose(in_fid);
success = true;

end

%**************************************************************************
