% [Final] This script converts all the csv files in the current directory and
% subforlders into .mat files with much smaller size since the time vector
% for the IMU and the emg sensors are all the same. Moreover, the saved
% data is in the format of time table which easier to be synced with the
% rest of the data later. The .mat files has the same name as the .csv
% files. * 

clc; clear all; close all;
start = 3;
stop = 6;
% this is where emg files are stored for this project
cd ('D:\School\MT_project\Data\Pilot011')

% with'*.' dir will read folder names only
folderName = dir('*');
% folderName = dir('*.');

% Define the variable names and their corresponding file names
KinematicsVariables = struct(...
    'BaselineLeftPalm', "BaselineLeftPalm", ...
    'BaselineRightPalm', "BaselineRightPalm", ...
    'TestLeftPalm', "TestLeftPalm", ...
    'TestRightPalm', "TestRightPalm", ...
    'TrainLeftPalm', "TrainLeftPalm", ...
    'TrainRightPalm', "TrainRightPalm" ...
);

ScoreVariables = struct(...
    'Baseline', "Baseline", ...
    'Train', "Train", ...
    'Test', "Test" ...
);

DropPosVariables = struct(...
    'BaselineLeftDropPosTarget', "BaselineLeftDropPosTarget", ...
    'BaselineLeftDropPosCube', "BaselineLeftDropPosCube", ...
    'TrainLeftDropPosTarget', "TrainLeftDropPosTarget", ...
    'TrainLeftDropPosCube', "TrainLeftDropPosCube", ...
    'TestLeftDropPosTarget', "TestLeftDropPosTarget", ...  
    'TestLeftDropPosCube', "TestLeftDropPosCube" ...  
);



% Initialize the variables structure
data = struct();
SubjectData = struct();

% i starts fom 3 becasue folderName first two elements are '.' and '..'
for i = start:stop

    % go to the folder
    cd(folderName(i).name)

    % with'*.csv' dir will read csv files only
    fileName = dir('*.mat');

    for j = 1:length(fileName)
        name = string(fileName(j).name(1:end-4));

        if isfield(KinematicsVariables, name)
            data.Kinematics.(KinematicsVariables.(name)) = load(fileName(j).name);
      
        elseif isfield(ScoreVariables, name)
            data.Score.(ScoreVariables.(name)) = load(fileName(j).name);

        elseif isfield(DropPosVariables, name)
            data.DropPos.(DropPosVariables.(name)) = load(fileName(j).name);

        end
    end

    SubjectData.(strcat('S', num2str(i-2))).Kinematics = data.Kinematics;
    SubjectData.(strcat('S', num2str(i-2))).Score = data.Score;
    SubjectData.(strcat('S', num2str(i-2))).DropPos = data.DropPos;

    % go back to the main folder
    cd ..
end
