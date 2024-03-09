
function data = csv22mat(path)

ax = readmatrix(path);


    %% Palm data
    if path == "TrainRightPalm.csv" || path == "TrainLeftPalm.csv" || path == "TestRightPalm.csv"|| path == "TestLeftPalm.csv" || path == "BaselineRightPalm.csv" || path == "BaselineLeftPalm.csv"
        kinematics = timetable(ax(:, 2), ax(:, 3), ax(:, 4), 'RowTimes', seconds(ax(:, 1)), 'VariableNames',{'X','Y','Z'});

    %% Drop pos
    elseif path == "TrainRighttDropPosTarget.csv" || path == "TrainLeftDropPosTarget.csv" || path == "TrainLeftDropPosTarget.csv" || path == "TrainDropPosCube.csv" || path == "TestLeftDropPosTarget.csv" || path == "TestLeftDropPosCube.csv" || path == "BaselineLeftDropPosTarget.csv" || path == "BaselineLeftDropPosCube.csv"
        kinematics = timetable(ax(:, 2), ax(:, 3), ax(:, 4), 'RowTimes', seconds(ax(:, 1)), 'VariableNames',{'X','Y','Z'});

    
    elseif path == "Baseline.csv" || path == "Train.csv" || path == "Test.csv"

        kinematics = ax;

    end

    data = kinematics;
end
