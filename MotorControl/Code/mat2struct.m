function SubjectData = mat2struct(start, stop)

YesHapticsCounter = 1;
NoHapticsCounter = 1;

% with'*.' dir will read folder names only
folderName = dir('*');

%% Define the variable names and their corresponding file names

% Kinematic variables
KinematicsVariables = struct(...
    'BaselineLeftPalm', "BaselineLeftPalm", ...
    'BaselineRightPalm', "BaselineRightPalm", ...
    'TestLeftPalm', "TestLeftPalm", ...
    'TestRightPalm', "TestRightPalm", ...
    'TrainLeftPalm', "TrainLeftPalm", ...
    'TrainRightPalm', "TrainRightPalm" ...
);

% Score variables
ScoreVariables = struct(...
    'Baseline', "Baseline", ...
    'Train', "Train", ...
    'Test', "Test" ...
);

% DropPos variables
DropPosVariables = struct(...
    'BaselineLeftDropPosTarget', "BaselineLeftDropPosTarget", ...
    'BaselineLeftDropPosCube', "BaselineLeftDropPosCube", ...
    'TrainLeftDropPosTarget', "TrainLeftDropPosTarget", ...
    'TrainDropPosCube', "TrainDropPosCube", ...
    'TestLeftDropPosTarget', "TestLeftDropPosTarget", ...  
    'TestLeftDropPosCube', "TestLeftDropPosCube" ...  
);

% Initialize the variables structure
data = struct();
SubjectData = struct();

% i starts fom 3 because folderName first two elements are '.' and '..'
% which are to be ignored
for i = start:stop % Loop in the participants' folder
%     if i == 3 || i == 22 || i == 5
%         continue
%     else

    % go to the folder
    cd(folderName(i).name)

    % with'*.mat' dir will read .mat files only
    fileName = dir('*.mat');

    for j = 1:length(fileName) % Loop in every .mat file

        name = string(fileName(j).name(1:end-4));

        % Clustering each .mat file into Kinematic, Score or DropPos
        % category
        if isfield(KinematicsVariables, name)
            data.Kinematics.(KinematicsVariables.(name)) = load(fileName(j).name);
      
        elseif isfield(ScoreVariables, name)
            data.Score.(ScoreVariables.(name)) = load(fileName(j).name);

        elseif isfield(DropPosVariables, name)
            data.DropPos.(DropPosVariables.(name)) = load(fileName(j).name);

        end
    end

    % Clustering all data into "WithHaptics" and "WithoutHaptics" categories
    indices = strfind(folderName(i).name, 'without haptics');
    if isempty(indices)
        SubjectData.WithHaptics.(strcat('S', num2str(YesHapticsCounter), '_', folderName(i).name(1:2))).Kinematics = data.Kinematics;
        SubjectData.WithHaptics.(strcat('S', num2str(YesHapticsCounter), '_', folderName(i).name(1:2))).Score = data.Score;
        SubjectData.WithHaptics.(strcat('S', num2str(YesHapticsCounter), '_', folderName(i).name(1:2))).DropPos = data.DropPos;

        YesHapticsCounter = YesHapticsCounter+1;

    else
        SubjectData.WithoutHaptics.(strcat('S', num2str(NoHapticsCounter), '_', folderName(i).name(1:2))).Kinematics = data.Kinematics;
        SubjectData.WithoutHaptics.(strcat('S', num2str(NoHapticsCounter), '_', folderName(i).name(1:2))).Score = data.Score;
        SubjectData.WithoutHaptics.(strcat('S', num2str(NoHapticsCounter), '_', folderName(i).name(1:2))).DropPos = data.DropPos;

        NoHapticsCounter = NoHapticsCounter+1;
    end
    
    % go back to the main folder
    cd ..
    end
end