% dp_asym(X,Y)
% compute distance between two vector sequences X and Y
% use predecessors (i,j-1) (i-1,j-1) (i-2,j-1)
% returns matrix with accumulated distances in DP.D(yFrameIdx,xFrameIdx)
% returns accumulated distance in DP.dist
% returns backtracking matrix in DP.B(yFrameIdx,xFrameIdx)
% returns matching function matrix in DP.M(yFrameIdx,xFrameIdx)
% path code in Backtracking matrix:
% 0 = horizontal
% 1 = diagonal
% 2 = skip vertical
function DP = compareXY(X,Y)
% get number of frames for X and Y
xFrames = size(X,2);
yFrames = size(Y,2);

% create dp arrays
DP.D = zeros(yFrames,xFrames);

%create backtracking matrix
DP.B = zeros(yFrames,xFrames);

%init distance matrix for j = 1
DP.D(:,1) = Inf;
%init distance for point (1,1)
DP.D(1,1) = norm( X(:,1) - Y(:,1) );
%init backtracking matrix
DP.B(:,1) = -1;
 

% for all j with i = 1 only  the horizontal path
% from predecessor (i,j-1) to point (i,j) is allowed
i = 1;
for j = 2:xFrames
    DP.D(i,j) = DP.D(i,j-i) + norm(X(:,j)-Y(:,i));
    DP.B(i,j) = 0;
end

% for all j with i = 2 only  horizontal and diagonal paths
% from predecessors (i,j-1) and (i-1,j-i) to point (i,j) are allowed
i = 2;
for j = 2:xFrames    
    %find best predecessor
    
    %horizontal path
    t = DP.D(i,j-1);
    min = t ;
    DP.B(i,j) = 0;
    %test diagonal path
    t = DP.D(i-1,j-1);
    if (t < min)
        min = t;
        DP.B(i,j) = 1 ;
    end
    
    DP.D(i,j) = min + norm(X(:,j)-Y(:,i));
    
end


%for all i > 2 all predecessor paths are allowed
for j = 2:xFrames
    for i = 3:yFrames
        %find best predecessor
        
        %horizontal path
        t = DP.D(i,j-1);
        min = t ;
        DP.B(i,j) = 0;
        %all others
        for p = 1:2
            t = DP.D(i-p,j-1);
            if (t < min)
                min = t;
                DP.B(i,j) = p;
            end
        end
           
        DP.D(i,j) = min + norm(X(:,j)-Y(:,i));
        
    end
end


%optimum path is restricted to upper-right corner of the matrix
DP.dist = DP.D(yFrames,xFrames);

%generate matching function matrix
DP.M = zeros(yFrames,xFrames);

% backtracking procedure
%init
i = yFrames;
j = xFrames;
%enter endpoint
DP.M(i,j) = 1;

back = DP.B(i,j);

%backtracking
while (back >= 0)

    %get predecessor index i
    i = i - back;
    %predecessor index j
    j = j - 1;
    
    %enter predecessor point into matching matrix
    DP.M(i,j) = 1;
    
    %get new predecessor
    back = DP.B(i,j);
end

end