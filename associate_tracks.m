%**************************************************************************
%
%   Author      W. Bryan Bell, Ph.D.
%   Project     Image Tracking Project, 2024
%   Purpose     Associate and re-order the point track data so that each 
%               point/object corresponds with the given true track data 
%               enabling error analysis to be performed.
%
%   Input       true_tracks     3D array containg the true track coordinates 
%                               for the center of the target/dots.
%                               (TRUTH data delivered as 'perfect_truth.bin')
%               input_tracks	3D array containg the calculated track 
%                               coordinates for the center of the target/dots.
%
%   Output      assoc_tracks	Re-ordered input tracks.
%
%   Index Order 1: Number of image frames in movie. (e.g. 275)
%               2: Number of targets. (e.g. 16)
%               3: Target coordinates.  (e.g. 2), (row,col)
%
%**************************************************************************

function assoc_tracks = associate_tracks(true_tracks, input_tracks)

if (size(true_tracks,1) ~= size(input_tracks,1))
    disp('*** ERROR: associate_tracks: #Frames incosistent ***')
    return
end
if (size(true_tracks,3) ~= size(input_tracks,3))
    disp('*** ERROR: associate_tracks: #Coordinates incosistent ***')
    return
end

n_frames    = size(true_tracks,1);
n_true_trks = size(true_tracks,2);
n_inpt_trks = size(input_tracks,2);

assoc_tracks = zeros(size(true_tracks));

% Loop over each frame
for k_frame = 1:n_frames
    
    % Loop over each truth target point
    for i_trupt = 1:n_true_trks
        r_tru = true_tracks(k_frame,i_trupt,1);
        c_tru = true_tracks(k_frame,i_trupt,2);
        
        % Initial minimum distance in pixels^2
        min_dist_sq = 1e12;

        % Loop over each input_track target and find minimum distance from 
        % the given true_track and then place it in that target location
        % in the assoc_track.
        for i_trkpt = 1:n_inpt_trks
            r_trk = input_tracks(k_frame,i_trkpt,1);
            c_trk = input_tracks(k_frame,i_trkpt,2);

            dist_sq = (r_tru-r_trk)^2 + (c_tru-c_trk)^2;
            if (dist_sq < min_dist_sq)
                min_dist_sq = dist_sq;
                assoc_tracks(k_frame,i_trupt,:) = input_tracks(k_frame,i_trkpt,:);
            end
        end
    end
end

end

%**************************************************************************
