% Pipeline to process the raw experimental data
clc; clear; close all;
format compact
%% Convert .csv files to .mat format

start = 3; % Starting folder from 3, ignoring '.' and '..' in the directory
stop = start + 3; % final folder depends on the number of participants

% This is where each participants' data are stored for this project
cd ('C:\Users\s2ajami\OneDrive - University of Waterloo\MT project\DataAnalysis\mt_pipeline\Data\Pilot1')


% This function loops in every participant's folder and makes a .mat copy
% of their .csv data 
% Input: start and stop numbers for looping the participants' folders
csv2mat(start, stop)

%% Put all .mat files into a structure

% Input: start and stop numbers for looping the participants' folders
% Output: SubjectData: Structure which includes Each participant's
% Kinematic, Score and DropPos data
SubjectData = mat2struct(start, stop);

%% Make substructures of SubjectData
GroupNames = fieldnames(SubjectData);
% Where GroupNames is either "withHaptics" or "withoutHaptics"

for i = 1:length(GroupNames)
    Participants = SubjectData.(GroupNames{i});
end

%% Add EMG to structured file

%% Synchronize EMG and Unity

%% Analysis: Kinematic data
KinematicData = struct();

GroupNames = fieldnames(SubjectData);
% Where GroupNames is either "withHaptics" or "withoutHaptics"

% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    Participants = SubjectData.(GroupNames{i});
    % where the "Participants" is all the subjects in the i-th
    % group.

    % This loops in each participant of each group
    for j = 1:length(fieldnames(Participants))

        ParticipantNames = fieldnames(Participants);
        Data = Participants.(ParticipantNames{j}).Kinematics;
        LeftBaseline = Data.BaselineLeftPalm.data;
        RightBaseline = Data.BaselineRightPalm.data;
        LeftTest = Data.TestLeftPalm.data;
        RightTest = Data.TestRightPalm.data;

        % Smooth the trajectory and find the local minima and maxima
        window_size = 100;
        smoothedLeftBaseline = movmean(LeftBaseline.X, window_size);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% DOUBLE CHECK THIS PART %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Hyperparameters tuned by trial and error 
        maxima_prominence = 0.002;
        minima_prominence = 0.003;

        [maxima, maximaIndices] = findpeaks(smoothedLeftBaseline, "MinPeakProminence", maxima_prominence);
        [minima, minimaIndices] = findpeaks(-smoothedLeftBaseline, "MinPeakProminence", minima_prominence);

        for kk = 1:min(length(minimaIndices), length(maximaIndices))
            prospective_minima_indices = minimaIndices(minimaIndices > maximaIndices(kk));
            if ~isempty (prospective_minima_indices)
                exact_minima_index = prospective_minima_indices(1);
            end
            if i == 2 && j == 1
                figure
                plot(LeftBaseline(maximaIndices(kk): exact_minima_index, :).Time, LeftBaseline(maximaIndices(kk): exact_minima_index, :).X)
            end
            
            KinematicData.(GroupNames{i}).(strcat('S', num2str(j))).LeftBaseline.(strcat('Trial', num2str(kk))) = LeftBaseline(maximaIndices(kk): exact_minima_index, :);
        end

        % Smooth the trajectory and find the local minima and maxima
        window_size = 100;
        smoothedLeftTest = movmean(LeftTest.X, window_size);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% DOUBLE CHECK THIS PART %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Hyperparameters tuned by trial and error 
        maxima_prominence = 0.03;
        minima_prominence = 0.09;

        [maxima, maximaIndices] = findpeaks(smoothedLeftTest, "MinPeakProminence", maxima_prominence);
        [minima, minimaIndices] = findpeaks(-smoothedLeftTest, "MinPeakProminence", maxima_prominence);

        for kk = 1:min(length(minimaIndices), length(maximaIndices))
            prospective_minima_indices = minimaIndices(minimaIndices > maximaIndices(kk));
            if ~isempty (prospective_minima_indices)
                exact_minima_index = prospective_minima_indices(1);
            end
           
            KinematicData.(GroupNames{i}).(strcat('S', num2str(j))).LeftTest.(strcat('Trial', num2str(kk))) = LeftTest(maximaIndices(kk): exact_minima_index, :);
        end
    end
end
%% Analysis: Time performance

TimeData = struct();

GroupNames = fieldnames(KinematicData);
% Where GroupNames is either "withHaptics" or "withoutHaptics"

% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    Participants = KinematicData.(GroupNames{i});
    % where the "Participants" is all the subjects in the i-th
    % group.

    % This loops in each participant of each group
    for j = 1:length(fieldnames(Participants))

        ParticipantNames = fieldnames(Participants);
        Data = Participants.(ParticipantNames{j});

        BaselineTrials = fieldnames(Data.LeftBaseline);
        TestTrials = fieldnames(Data.LeftTest);

        % Measuring the duration of each trial in baseline
%         time_baseline = [];
        for k = 1:length(BaselineTrials)

            Trial = Data.LeftBaseline.(BaselineTrials{k});
            if ~isempty(Trial.Time)
                time_baseline(k) = Trial.Time(end) - Trial.Time(1);
            end
        end
        time_baseline_mean = mean(time_baseline);
        time_baseline_std = std(time_baseline);

        TimeData.(GroupNames{i}).(strcat('S', num2str(j))).Baseline.time_vector = time_baseline;
        TimeData.(GroupNames{i}).(strcat('S', num2str(j))).Baseline.time_mean = time_baseline_mean;
        TimeData.(GroupNames{i}).(strcat('S', num2str(j))).Baseline.time_std = time_baseline_std;

        % Measuring the duration of each trial in baseline
%         time_test = [];
        for k = 1:length(TestTrials)
            
            Trial = Data.LeftTest.(TestTrials{k});
            
            if ~isempty(Trial)
                time_test(k) = Trial.Time(end) - Trial.Time(1);
            end
%             time_test(k) = Trial.Time(end) - Trial.Time(1);
        end

        time_test_mean = mean(time_test);
        time_test_std = std(time_test);

        TimeData.(GroupNames{i}).(strcat('S', num2str(j))).Test.time_vector = time_test;
        TimeData.(GroupNames{i}).(strcat('S', num2str(j))).Test.time_mean = time_test_mean;
        TimeData.(GroupNames{i}).(strcat('S', num2str(j))).Test.time_std = time_test_std;
    end
end

% Plot the time

GroupNames = fieldnames(TimeData);
% DropPosErrorData = struct();

k = 1;
figure

% Change the dimensions of the figure
newWidth = 1000;  % New width in pixels
newHeight = 800; % New height in pixels
% set(gcf, 'Position', [100, 100, newWidth, newHeight]);
set(gca, 'XTickLabel', {});
set(gca, 'XTick', []);

% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    Participants = TimeData.(GroupNames{i});
    
    % This loops in each participant of each group
    for j = 1:length(fieldnames(Participants))
        ParticipantNames = fieldnames(Participants);
 
        Data = Participants.(ParticipantNames{j});

        % Example data
        data1 = Data.Baseline.time_vector;
        data2 = Data.Test.time_vector(end-(length(data1) - 1):end);
        
        % Calculate mean and standard deviation
        mean1 = mean(data1);
        std1 = std(data1);
        mean2 = mean(data2);
        std2 = std(data2);
        
        % Create a figure
        subplot(length(GroupNames), length(fieldnames(Participants)), k)

        % Set the position of each bar chart
        barPositions = 0;
        barWidth = 0.3;
        set(gca, 'XTick', []);
        % Plot the first bar chart
        bar(barPositions, mean1, barWidth);
        hold on;
        bar(barPositions + barWidth, mean2, barWidth);
        
        errorbar(barPositions, mean1, std1, 'k.', 'LineWidth', 1);
        
        % Plot the second bar chart
        
        errorbar(barPositions + barWidth, mean2, std2, 'k.', 'LineWidth', 1);
        
        % Customize the chart
%         xlabel(["Baseline", "Test"]);
        ylabel('Duration [sec]');
        legend('Baseline', 'Test', 'Location','bestoutside');
        title(strcat(GroupNames{i}, ' - P', num2str(j)));
        
        % Adjust the x-axis limits
        xlim([min(barPositions)-barWidth, max(barPositions)+2*barWidth]);
        
        % Adjust the x-axis tick labels
        xticks([]);
        k = k + 1;
    end
end

%% Analysis: Trajectory smoothness

%%% Find Velocity, Acceleration and Jerk, and save them into TrajectoryInfo()
global TrajectoryInfo;

TrajectoryInfo = struct();
TrajectoryInfo = JerkSaver(KinematicData, "Baseline");
TrajectoryInfo = JerkSaver(KinematicData, "Test");

%%% Plot the Velocity (mean and std)

%% Analysis: Score data

ScoreData = struct();

GroupNames = fieldnames(SubjectData);
% Where GroupNames is either "withHaptics" or "withoutHaptics"

% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    Participants = SubjectData.(GroupNames{i});
    % where the "Participants" is all the subjects in the i-th
    % group.

    % This loops in each participant of each group
    for j = 1:length(fieldnames(Participants))

        ParticipantNames = fieldnames(Participants);
        Data = Participants.(ParticipantNames{j}).Score;

        BaselineScore = (Data.Baseline.data(1)) / (Data.Baseline.data(end)) * 100;
        TrainScore = (Data.Train.data(1)) / (Data.Train.data(end)) * 100;
        TestScore = (Data.Test.data(1)) / (Data.Test.data(end)) * 100;
        

        ScoreData.(GroupNames{i}).(strcat('S', num2str(j))).Baseline = BaselineScore;
        ScoreData.(GroupNames{i}).(strcat('S', num2str(j))).Train = TrainScore;
        ScoreData.(GroupNames{i}).(strcat('S', num2str(j))).Test = TestScore;
    end
end

%%% Plot Score data
GroupNames = fieldnames(ScoreData);
% DropPosErrorData = struct();

k = 1;
figure

% Change the dimensions of the figure
newWidth = 1000;  % New width in pixels
newHeight = 800; % New height in pixels
% set(gcf, 'Position', [100, 100, newWidth, newHeight]);
set(gca, 'XTickLabel', {});
set(gca, 'XTick', []);

% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    Participants = ScoreData.(GroupNames{i});
    
    % This loops in each participant of each group
    for j = 1:length(fieldnames(Participants))
        ParticipantNames = fieldnames(Participants);
 
        Data = Participants.(ParticipantNames{j});

        % Example data
        data1 = Data.Baseline;
        data2 = Data.Test;
        
        % Calculate mean and standard deviation
        mean1 = mean(data1);
        std1 = std(data1);
        mean2 = mean(data2);
        std2 = std(data2);
        
        % Create a figure
        subplot(length(GroupNames), length(fieldnames(Participants)), k)

        % Set the position of each bar chart
        barPositions = 0;
        barWidth = 0.3;
        set(gca, 'XTick', []);
        % Plot the first bar chart
        bar(barPositions, mean1, barWidth);
        hold on;
        bar(barPositions + barWidth, mean2, barWidth);
        
        errorbar(barPositions, mean1, std1, 'k.', 'LineWidth', 1);
        
        % Plot the second bar chart
        
        errorbar(barPositions + barWidth, mean2, std2, 'k.', 'LineWidth', 1);
        
        % Customize the chart
%         xlabel(["Baseline", "Test"]);
        ylabel('Duration [sec]');
        legend('Baseline', 'Test', 'Location','bestoutside');
        title(strcat(GroupNames{i}, ' - P', num2str(j)));
        
        % Adjust the x-axis limits
        xlim([min(barPositions)-barWidth, max(barPositions)+2*barWidth]);
        
        % Adjust the x-axis tick labels
        xticks([]);
        k = k + 1;
    end
end
%% Analysis: DropPos data

%%% Step1: Clean the data and store them in DropPosData
DropPosData = struct();

GroupNames = fieldnames(SubjectData);
% Where GroupNames is either "withHaptics" or "withoutHaptics"

x_init = 0; y_init = 0.9; z_init = 0;
x_tol = 0.009; y_tol = 0.009; z_tol = 0.009;

% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    Participants = SubjectData.(GroupNames{i});
    % where the "Participants" is all the subjects in the i-th
    % group.

    % This loops in each participant of each group
    for j = 1:length(fieldnames(Participants))
        
        CubeVectorBaseline = timetable();
        TargetVectorBaselinetemp = timetable();
        TargetVectorBaseline = timetable();

        CubeVectorTest = timetable();
        TargetVectorTesttemp = timetable();
        TargetVectorTest = timetable();

        ParticipantNames = fieldnames(Participants);
 
        Data = Participants.(ParticipantNames{j});

        % Actual data
        DropPosBaselineCube = Data.DropPos.BaselineLeftDropPosCube.data;
        DropPosBaselineTarget = Data.DropPos.BaselineLeftDropPosTarget.data;

        % Cleans the data for DropPosBaselineCube (removes init positions)
        for k = 1:size(DropPosBaselineCube, 1)
            if (abs(DropPosBaselineCube.X(k) - x_init) > x_tol) || ...
                    (abs(DropPosBaselineCube.Y(k) - y_init) > y_tol) || ...
                    (abs(DropPosBaselineCube.Z(k) - z_init) > z_tol)

                newRow = timetable(DropPosBaselineCube.X(k), DropPosBaselineCube.Z(k), 'RowTimes', DropPosBaselineCube.Time(k), 'VariableNames', {'X', 'Z'});
                CubeVectorBaseline = [CubeVectorBaseline; newRow];
                clear newRow
            end
        end

        % Cleans the data for Target (removes init positions)
        for k = 1:size(DropPosBaselineTarget, 1)
            if (abs(DropPosBaselineTarget.X(k) - x_init) > x_tol) || ...
                    (abs(DropPosBaselineTarget.Y(k) - y_init) > y_tol) || ...
                    (abs(DropPosBaselineTarget.Z(k) - z_init) > z_tol)

                newRow = timetable(DropPosBaselineTarget.X(k), DropPosBaselineTarget.Z(k), 'RowTimes', DropPosBaselineTarget.Time(k), 'VariableNames', {'X', 'Z'});
                TargetVectorBaselinetemp = [TargetVectorBaselinetemp; newRow];
                clear newRow
            end
        end

        % Cleans the data for Target (removes redundancies)
        for k = 1:size(CubeVectorBaseline, 1)
            temptable = TargetVectorBaselinetemp(TargetVectorBaselinetemp.Properties.RowTimes == CubeVectorBaseline.Time(k), :);
            newRow = temptable(1, :);
            TargetVectorBaseline = [TargetVectorBaseline; newRow];
            clear newRow
        end

        %%%%%%%%%%

        % Actual data
        DropPosTestCube = Data.DropPos.TestLeftDropPosCube.data;
        DropPosTestTarget = Data.DropPos.TestLeftDropPosTarget.data;

        % Cleans the data for DropPosTestCube (removes init positions)
        for k = 1:size(DropPosTestCube, 1)
            if (abs(DropPosTestCube.X(k) - x_init) > x_tol) || ...
                    (abs(DropPosTestCube.Y(k) - y_init) > y_tol) || ...
                    (abs(DropPosTestCube.Z(k) - z_init) > z_tol)

                newRow = timetable(DropPosTestCube.X(k), DropPosTestCube.Z(k), 'RowTimes', DropPosTestCube.Time(k), 'VariableNames', {'X', 'Z'});
                CubeVectorTest = [CubeVectorTest; newRow];
                clear newRow
            end
        end

        % Cleans the data for Target (removes init positions)
        for k = 1:size(DropPosTestTarget, 1)
            if (abs(DropPosTestTarget.X(k) - x_init) > x_tol) || ...
                    (abs(DropPosTestTarget.Y(k) - y_init) > y_tol) || ...
                    (abs(DropPosTestTarget.Z(k) - z_init) > z_tol)

                newRow = timetable(DropPosTestTarget.X(k), DropPosTestTarget.Z(k), 'RowTimes', DropPosTestTarget.Time(k), 'VariableNames', {'X', 'Z'});
                TargetVectorTesttemp = [TargetVectorTesttemp; newRow];
                clear newRow
            end
        end
        
        % Cleans the data for Target (removes redundancies)
        for k = 1:size(CubeVectorTest, 1)
            temptable = TargetVectorTesttemp(TargetVectorTesttemp.Properties.RowTimes == CubeVectorTest.Time(k), :);
            newRow = temptable(1, :);
            TargetVectorTest = [TargetVectorTest; newRow];
            clear newRow
        end

        DropPosData.(GroupNames{i}).(strcat('S', num2str(j))).CubeVectorBaseline = CubeVectorBaseline;
        DropPosData.(GroupNames{i}).(strcat('S', num2str(j))).TargetVectorBaseline = TargetVectorBaseline;
        DropPosData.(GroupNames{i}).(strcat('S', num2str(j))).CubeVectorTest = CubeVectorTest;
        DropPosData.(GroupNames{i}).(strcat('S', num2str(j))).TargetVectorTest = TargetVectorTest;

        clear CubeVectorTest CubVectorBaseline TargetVectorTest ...
            TargetVectorBaselinetemp TargetVectorTesttemp
    end
end

%%

%%% Step2: Save the error data as data structure

GroupNames = fieldnames(DropPosData);
DropPosErrorData = struct();

% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    Participants = DropPosData.(GroupNames{i});
    
    % This loops in each participant of each group
    for j = 1:length(fieldnames(Participants))
        ParticipantNames = fieldnames(Participants);
 
        Data = Participants.(ParticipantNames{j});
        
        % Actual Data
        CubeDropBaseline = [Data.CubeVectorBaseline.X, Data.CubeVectorBaseline.Z];
        TargetDropBaseline = [Data.TargetVectorBaseline.X, Data.TargetVectorBaseline.Z];

        % Actual Data
        CubeDropTest = [Data.CubeVectorTest.X, Data.CubeVectorTest.Z];
        TargetDropTest = [Data.TargetVectorTest.X, Data.TargetVectorTest.Z];

        %%% Calculate Error
        % Baseline
        DifferenceBaseline = CubeDropBaseline - TargetDropBaseline;
        for k = 1:size(DifferenceBaseline, 1)
            error_baseline(k, 1) = norm(DifferenceBaseline(k, :), 2);
        end
        
        % Test
        DifferenceTest = CubeDropTest - TargetDropTest;
        for k = 1:size(DifferenceTest, 1)
            error_test(k, 1) = norm(DifferenceTest(k, :), 2);
        end

        %%% Calculate mean and std
        mean_error_baseline = mean(error_baseline);
        std_error_baseline = std(error_baseline);
        mean_error_test = mean(error_test);
        std_error_test = std(error_test);

        %%% Save the error, mean and std of baseline and test in structure
        DropPosErrorData.(GroupNames{i}).(strcat('S', num2str(j))).error_baseline = error_baseline;
        DropPosErrorData.(GroupNames{i}).(strcat('S', num2str(j))).error_test = error_test;
        DropPosErrorData.(GroupNames{i}).(strcat('S', num2str(j))).mean_error_baseline = mean_error_baseline;
        DropPosErrorData.(GroupNames{i}).(strcat('S', num2str(j))).std_error_baseline = std_error_baseline;
        DropPosErrorData.(GroupNames{i}).(strcat('S', num2str(j))).mean_error_test = mean_error_test;
        DropPosErrorData.(GroupNames{i}).(strcat('S', num2str(j))).std_error_test = std_error_test;

        clear error_baseline error_test mean_error_baseline ...
            std_error_baseline mean_error_test std_error_test ...
            DifferenceBaseline DifferenceTest CubeDropTest TargetDropTest

    end 
end

%% Step 3: Plot the data
%%% Step2: Save the error data as data structure

PlotData(DropPosErrorData)

%% Analysis: EMG data