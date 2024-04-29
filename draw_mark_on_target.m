%**************************************************************************
%
%   Author      W. Bryan Bell, Ph.D.
%   Project     Image Tracking Project, 2024
%   Purpose     This function draws a cross on a target in an image at a
%               given centroid location as long as the target is at least
%               N pixels large.
%
%   Input       Iin     Input image array
%               stats   Region properties calculated by regionprops()
%                       - stats must contain (Area & Centroid)
%               obj_sz  Target must be at least obj_sz pixels in total size
%                       - Good value is 5 to 10
%               crs_sz  Size of the cross (-M:M)
%                       - Good value is 5, 6 or 7
%               bw_str  Text property string for the color of the cross
%                       - ('black' or 'white')
%
%   Output      Iout:   Output image array
%
%**************************************************************************

function Iout = draw_mark_on_target(Iin, stats, obj_sz, crs_sz, bw_str)

% Initialize the output image
Iout = Iin;
[nrow,ncol] = size(Iout);

% Set the color of the mark
bw  = 0;
cen = 255;
if     strcmpi(bw_str,'black')
    bw = 0;   cen = 255;
elseif strcmpi(bw_str,'white')
    bw = 255; cen = 0;
end

% Draw a mark on the target
for k=1:length(stats)

    % The are of the target must be (obj_sz) pixels large
    if (stats(k).Area > obj_sz)
        row_cen = round(stats(k).Centroid(2));
        col_cen = round(stats(k).Centroid(1));

        % Draw the two horiz. and vert. lines on the target
        for kk=-crs_sz:crs_sz
            row_pix = row_cen + kk;
            row_pix = max(row_pix,1);
            row_pix = min(row_pix,nrow);
            col_pix = col_cen + kk;
            col_pix = max(col_pix,1);
            col_pix = min(col_pix,ncol);
            Iout(row_pix,col_cen) = bw;
            Iout(row_cen,col_pix) = bw;
        end

        % Set the color of the center of the mark
        Iout(row_cen,col_cen) = cen;
    end
end

end

%**************************************************************************
