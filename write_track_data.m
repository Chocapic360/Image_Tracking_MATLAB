%**************************************************************************
%
%   Author      W. Bryan Bell, Ph.D.
%   Project     Image Tracking Project, 2024
%   Purpose     Write tracking coordinate data for Image Tracking Project
%
%   Input       filename: Filename of the binary track file.
%                         (TRUTH data was delivered as 'truth.bin')
%               tracks:   3D array containg the track values for the center
%                         of the target/dots for the Project.
%                           1: Number of image frames in movie.
%                           2: Number of targets.
%                           3: Target coordinate (row,col)
%
%   Output      success:  Flag stating if the file read was successful.
%
%**************************************************************************

function success = write_track_data(filename,tracks)

fid = fopen(filename,'w','l');
if (fid == 0)
    success = false;
    return;
end

[num_imgs, num_pts, coord] = size(tracks);
if (coord ~= 2)
    success = false;
    return;
end

fwrite(fid, num_imgs, 'int32');
fwrite(fid, num_pts, 'int32');
for img_num=1:num_imgs
    for i_pt=1:num_pts
        fwrite(fid, tracks(img_num,i_pt,1), 'float64');
        fwrite(fid, tracks(img_num,i_pt,2), 'float64');
    end
end
fclose(fid);
success = true;

end

%**************************************************************************
