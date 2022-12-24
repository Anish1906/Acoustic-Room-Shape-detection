clear all; close all;

%% input parameters

microphoneLocs =  [ 3.9, 3.9, 1.0; ...
                   3.9, 4.1, 1.2; ...
                   4.1, 3.9, 1.0; ...
                   4.1, 4.1, 1.2; ...
                   4.2, 4.1, 1.4];
imSrcTrue = [4,4,-1.2];

%% calculate and plot distance constraints at each microphone

echoDists = vecnorm(microphoneLocs-imSrcTrue,2,2);
plotImageSourceEstimationConstraints(microphoneLocs,imSrcTrue,echoDists)

%%

function plotImageSourceEstimationConstraints(microphoneLocs,estImSrc,echodists)
    
    figure;
    
    scatter3(microphoneLocs(:,1),microphoneLocs(:,2),microphoneLocs(:,3),200,'g.');
    hold on; scatter3(estImSrc(1),estImSrc(2),estImSrc(3),200,'r.');
%     legend('microphone positions','estimated image source');

    for n = 1:size(microphoneLocs,1)
        radius = echodists(n);
        [X,Y,Z] = sphere;
        X = radius*X;
        Y = radius*Y;
        Z = radius*Z;

        hold on; surf(X+microphoneLocs(n,1),Y+microphoneLocs(n,2),Z+microphoneLocs(n,3),'FaceAlpha',0.5);
    end

    axis equal;
    title('Distance Constraints from Image Source');
    xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
    legend('Microphones','Image Source');


end