% Pipeline to process the raw experimental data
clc; clear; close all;
format compact
%% Convert .csv files to .mat format


start = 3; % Starting folder from 3, ignoring '.' and '..' in the directory
num_participants = 22;
stop = start + (num_participants - 1); % final folder depends on the number of participants

% This is where each participants' data are stored for this project
% cd ('C:\Users\Sahand\OneDrive - University of Waterloo\MT project\DataAnalysis\mt_pipeline\Data\Pilot2')
cd ('C:\Users\s2ajami\OneDrive - University of Waterloo\MT project\DataAnalysis\mt_pipeline\MotorControl\Data\CHIData')

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
        maxima_prominence = 0.05;
        minima_prominence = 0.05;

        maxima_min_peak_distance = 0.5;
        minima_min_peak_distance = 0.5;

        [maxima, maximaIndices] = findpeaks(smoothedLeftBaseline, "MinPeakProminence", maxima_prominence, "MinPeakDistance", maxima_min_peak_distance);
        [minima, minimaIndices] = findpeaks(-smoothedLeftBaseline, "MinPeakProminence", minima_prominence, "MinPeakDistance", minima_min_peak_distance);

        


        for kk = 1:min(length(minimaIndices), length(maximaIndices))
            prospective_minima_indices = minimaIndices(minimaIndices > maximaIndices(kk));
            if ~isempty (prospective_minima_indices)
                exact_minima_index = prospective_minima_indices(1);
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
        maxima_prominence = 0.05;
        minima_prominence = 0.05;

        maxima_min_peak_distance = 0.5;
        minima_min_peak_distance = 0.0; 

        [maxima, maximaIndices] = findpeaks(smoothedLeftTest, "MinPeakProminence", maxima_prominence, "MinPeakDistance", maxima_min_peak_distance);
        [minima, minimaIndices] = findpeaks(-smoothedLeftTest, "MinPeakProminence", maxima_prominence, "MinPeakDistance", minima_min_peak_distance);

        % This block finds the exact local exterma after the current
        % exterma to extract the trial's trajectory
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

% GroupNames = fieldnames(TimeData);
% % DropPosErrorData = struct();
% 
% k = 1;
% figure
% 
% % Change the dimensions of the figure
% newWidth = 1000;  % New width in pixels
% newHeight = 800; % New height in pixels
% % set(gcf, 'Position', [100, 100, newWidth, newHeight]);
% set(gca, 'XTickLabel', {});
% set(gca, 'XTick', []);
% 
% % This loops in the "withHaptics" and "withoutHaptics" groups
% for i = 1:length(GroupNames)
%     % i = 1 WithoutHaptics
%     % i = 2 WithHaptics
% 
%     Participants = TimeData.(GroupNames{i});
%     
%     % This loops in each participant of each group
%     for j = 1:length(fieldnames(Participants))
%         ParticipantNames = fieldnames(Participants);
%  
%         Data = Participants.(ParticipantNames{j});
% 
%         % Example data
%         data1 = Data.Baseline.time_vector;
%         data2 = Data.Test.time_vector;
%         
%         % Calculate mean and standard deviation
%         mean1 = mean(data1);
%         std1 = std(data1);
%         mean2 = mean(data2);
%         std2 = std(data2);
%         
%         % Create a figure
%         subplot(length(GroupNames), length(fieldnames(Participants)), k)
% 
%         % Set the position of each bar chart
%         barPositions = 0;
%         barWidth = 0.3;
%         set(gca, 'XTick', []);
%         % Plot the first bar chart
%         bar(barPositions, mean1, barWidth);
%         hold on;
%         bar(barPositions + barWidth, mean2, barWidth);
%         
%         errorbar(barPositions, mean1, std1, 'k.', 'LineWidth', 1);
%         
%         % Plot the second bar chart
%         
%         errorbar(barPositions + barWidth, mean2, std2, 'k.', 'LineWidth', 1);
%         
%         % Customize the chart
% %         xlabel(["Baseline", "Test"]);
%         ylabel('Duration [sec]');
%         legend('Baseline', 'Test', 'Location','bestoutside');
%         title(strcat(GroupNames{i}, ' - P', num2str(j)));
%         
%         % Adjust the x-axis limits
%         xlim([min(barPositions)-barWidth, max(barPositions)+2*barWidth]);
%         
%         % Adjust the x-axis tick labels
%         xticks([]);
%         k = k + 1;
%     end
% end

%% Analysis: Trajectory smoothness
% VEL = {};
% %%% Find Velocity, Acceleration and Jerk, and save them into TrajectoryInfo()
% global TrajectoryInfo;
% 
% TrajectoryInfo = struct();
% 
% 
%     % Note that in the JerkSaver function, the for calculating the derivatives 
%     % of trajectory, the data is downsampled by 1/3 times.
% TrajectoryInfo = JerkSaver(KinematicData, "Baseline");
% TrajectoryInfo = JerkSaver(KinematicData, "Test");
% 
% %%% Find mean and std of each trial for velocity
% GroupNames = fieldnames(TrajectoryInfo);
% % Where GroupNames is either "withHaptics" or "withoutHaptics"
% 
% % This loops in the "withHaptics" and "withoutHaptics" groups
% for i = 1:length(GroupNames)
%     % i = 1 WithoutHaptics
%     % i = 2 WithHaptics
% 
%     Participants = TrajectoryInfo.(GroupNames{i});
%     % where the "Participants" is all the subjects in the i-th
%     % group.
% 
%     % This loops in each participant of each group
%     for j = 1:length(fieldnames(Participants))
% 
%         ParticipantNames = fieldnames(Participants);
%         Data = Participants.(ParticipantNames{j});
% 
%         BaselineTrials = Data.Baseline;
%         field_names = fieldnames(BaselineTrials);
% 
%         for k = 1:length(fieldnames(BaselineTrials))
%             VEL_baseline{i, j, k} = BaselineTrials.(field_names{k}).Velocity;
%             ACC_baseline{i, j, k} = BaselineTrials.(field_names{k}).Acceleration;
%             JRK_baseline{i, j, k} = BaselineTrials.(field_names{k}).Jerk;
%         end
% 
%         for kk = 1:size(VEL_baseline, 3)
%             VEL_baseline_trialmean{i, j, kk} = mean(VEL_baseline{i, j, kk}.Velocity_Overall);
%             ACC_baseline_trialmean{i, j, kk} = mean(ACC_baseline{i, j, kk}.Acceleration_Overall);
%             JRK_baseline_trialmean{i, j, kk} = mean(JRK_baseline{i, j, kk}.Jerk_Overall);
%         end
% 
%         VEL_baseline_subjectmean{i, j} = mean([VEL_baseline_trialmean{i, j, :}]);
%         ACC_baseline_subjectmean{i, j} = mean([ACC_baseline_trialmean{i, j, :}]);
%         JRK_baseline_subjectmean{i, j} = mean([JRK_baseline_trialmean{i, j, :}]);
% 
%         TestTrials = Data.Test;
%         field_names = fieldnames(TestTrials);
% 
%         for k = 1:length(fieldnames(TestTrials))
%             VEL_test{i, j, k} = TestTrials.(field_names{k}).Velocity;
%             ACC_test{i, j, k} = TestTrials.(field_names{k}).Acceleration;
%             JRK_test{i, j, k} = TestTrials.(field_names{k}).Jerk;
%         end
% 
%         for kk = 1:size(VEL_baseline, 3)
%             VEL_test_trialmean{i, j, kk} = mean(VEL_test{i, j, kk}.Velocity_Overall);
%             ACC_test_trialmean{i, j, kk} = mean(ACC_test{i, j, kk}.Acceleration_Overall);
%             JRK_test_trialmean{i, j, kk} = mean(JRK_test{i, j, kk}.Jerk_Overall);
%         end
% 
%         VEL_test_subjectmean{i, j} = mean([VEL_test_trialmean{i, j, :}]);
%         ACC_test_subjectmean{i, j} = mean([ACC_test_trialmean{i, j, :}]);
%         JRK_test_subjectmean{i, j} = mean([JRK_test_trialmean{i, j, :}]);
% 
%     end
% end
% 
% figure
% for i = 1:length(GroupNames)
%     % Plot velocity - group specific
%     data1 = [VEL_baseline_subjectmean{i, :}];
%     data2 = [VEL_test_subjectmean{i, :}];
%     % Create a figure
%     
%     subplot(length(GroupNames), 1, i)
%     PlotTrajInfo(data1, data2, 'Velocity [m/s]', strcat(GroupNames{i}))
% end
% 
% figure
% for i=1:length(GroupNames)
% 
%     % Plot acceleration - group specific
%     data1 = [ACC_baseline_subjectmean{i, :}];
%     data2 = [ACC_test_subjectmean{i, :}];
%     % Create a figure
%     
%     subplot(length(GroupNames), 1, i)
%     PlotTrajInfo(data1, data2, 'Acceleration [m/s^2]', strcat(GroupNames{i}))
% end
% 
% figure
% for i=1:length(GroupNames)
% 
%     % Plot acceleration - group specific
%     data1 = [JRK_baseline_subjectmean{i, :}];
%     data2 = [JRK_test_subjectmean{i, :}];
%     % Create a figure
%     
%     subplot(length(GroupNames), 1, i)
%     PlotTrajInfo(data1, data2, 'Jerk [m/s^3]', strcat(GroupNames{i}))
% end




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

%%% Plot The score data (By each group)
GroupNames = fieldnames(ScoreData);

k = 1;
% figure

BaselineData = {};
TrainData = {};
TestData = {};

% Change the dimensions of the figure
newWidth = 600;  % New width in pixels
newHeight = 800; % New height in pixels
set(gcf, 'Position', [100, 100, newWidth, newHeight]);
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

        BaselineData{i, j} = Data.Baseline;
        TrainData{i, j} = Data.Train;
        TestData{i, j} = Data.Test;
    end

%         % Example data
%         data1 = [BaselineData{i, :}];
%         data2 = [TrainData{i, :}];
%         data3 = [TestData{i, :}];
%         
%         % Calculate mean and standard deviation
%         mean1 = mean(data1);
%         std1 = std(data1);
%         mean2 = mean(data2);
%         std2 = std(data2);
%         mean3 = mean(data3);
%         std3 = std(data3);
%         
%         % Create a figure
%         subplot(length(GroupNames), 1, i)
% 
%         % Set the position of each bar chart
%         barPositions = 0;
%         barWidth = 0.3;
%         set(gca, 'XTick', []);
%         % Plot the first bar chart
%         bar(barPositions, mean1, barWidth);
%         hold on;
%         bar(barPositions + barWidth, mean2, barWidth);
%         hold on;
%         bar(barPositions + 2*barWidth, mean3, barWidth);
%         
%         errorbar(barPositions, mean1, std1, 'k.', 'LineWidth', 1);
%         
%         % Plot the second bar chart
%         
%         errorbar(barPositions + barWidth, mean2, std2, 'k.', 'LineWidth', 1);
% 
%         errorbar(barPositions + 2*barWidth, mean3, std3, 'k.', 'LineWidth', 1);
%         
%         % Customize the chart
% %         xlabel(["Baseline", "Test"]);
%         ylabel('Score Percentage [%]');
%         legend('Baseline', 'Train', 'Test', 'Location', 'bestoutside');
%         title(strcat(GroupNames{i}));
%         
%         % Adjust the x-axis limits
%         xlim([min(barPositions)-barWidth, max(barPositions)+3*barWidth]);
%         
%         % Adjust the x-axis tick labels
%         xticks([]);

end

%%% Step 4: Plot the Score Data - Group specific

% make a table for boxplot
GroupNames = fieldnames(ScoreData);

scoreData = [];
variable_names = {'Group', 'Condition', 'Score'};
condition_temp = {};
ScoreTable = table({}, {}, scoreData, 'VariableNames', variable_names);

% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    Participants = ScoreData.(GroupNames{i});

    % This loops in each participant of each group
    for j = 1:length(fieldnames(Participants))
        ParticipantNames = fieldnames(Participants);

        myData = Participants.(ParticipantNames{j});


        Baseline_scoreData = myData.Baseline;
        Train_scoreData = myData.Train;
        Test_scoreData = myData.Test;
        
        groupname_temp = cell('');
        condition_temp = cell('');
        condition_temp = [condition_temp; 'Baseline'];
        groupname_temp = [groupname_temp; GroupNames{i}];
        
        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, Baseline_scoreData, ...
            'VariableNames', variable_names);
        
        ScoreTable = [ScoreTable; newTable];
        
        groupname_temp = cell('');
        condition_temp = cell('');
        condition_temp = [condition_temp; 'Train'];
        groupname_temp = [groupname_temp; GroupNames{i}];
        
        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, Train_scoreData, ...
            'VariableNames', variable_names);
        
        ScoreTable = [ScoreTable; newTable];
        
        groupname_temp = cell('');
        condition_temp = cell('');
        condition_temp = [condition_temp; 'Test'];
        groupname_temp = [groupname_temp; GroupNames{i}];
        
        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, Test_scoreData, ...
            'VariableNames', variable_names);
        
        ScoreTable = [ScoreTable; newTable];
    end
end

% Create categorical array for x-axis labels with desired order
ScoreTable.Condition = categorical(ScoreTable.Condition);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
ScoreTable.Condition = reordercats(ScoreTable.Condition, desiredOrder);


figure
score_boxchart = boxchart(ScoreTable.Condition, ScoreTable.Score,'GroupByColor', ScoreTable.Group);

legend("Location", "Best")
title('Score plot');
ylabel('Score [%]');
xlabel('Conditions');

%% Analysis: DropPos data

%%% Step1: Clean the data and store them in DropPosData
DropPosData = struct();

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

        % Cleans the data (removes the ones recorded at zero time)
        DropPosBaselineCube = DropPosBaselineCube(DropPosBaselineCube.Time>0, :);
        DropPosBaselineTarget = DropPosBaselineTarget(DropPosBaselineTarget.Time>0, :);

        % Actual data
        DropPosTrainCube = Data.DropPos.TrainDropPosCube.data;
        DropPosTrainTarget = Data.DropPos.TrainLeftDropPosTarget.data;
        
        % Cleans the data (removes the ones recorded at zero time)
        DropPosTrainCube = DropPosTrainCube(DropPosTrainCube.Time>0, :);
        DropPosTrainTarget = DropPosTrainTarget(DropPosTrainTarget.Time>0, :);
        
        % Actual data
        DropPosTestCube = Data.DropPos.TestLeftDropPosCube.data;
        DropPosTestTarget = Data.DropPos.TestLeftDropPosTarget.data;
        
        % Cleans the data (removes the ones recorded at zero time)
        DropPosTestCube = DropPosTestCube(DropPosTestCube.Time>0, :);
        DropPosTestTarget = DropPosTestTarget(DropPosTestTarget.Time>0, :);

        DropPosData.(GroupNames{i}).(strcat('S', num2str(j))).CubeVectorBaseline = DropPosBaselineCube;
        DropPosData.(GroupNames{i}).(strcat('S', num2str(j))).TargetVectorBaseline = DropPosBaselineTarget;
        DropPosData.(GroupNames{i}).(strcat('S', num2str(j))).CubeVectorTrain = DropPosTrainCube;
        DropPosData.(GroupNames{i}).(strcat('S', num2str(j))).TargetVectorTrain = DropPosTrainTarget;
        DropPosData.(GroupNames{i}).(strcat('S', num2str(j))).CubeVectorTest = DropPosTestCube;
        DropPosData.(GroupNames{i}).(strcat('S', num2str(j))).TargetVectorTest = DropPosTestTarget;
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
        CubeDropTrain = [Data.CubeVectorTrain.X, Data.CubeVectorTrain.Z];
        TargetDropTrain = [Data.TargetVectorTrain.X, Data.TargetVectorTrain.Z];
        
        % Actual Data
        CubeDropTest = [Data.CubeVectorTest.X, Data.CubeVectorTest.Z];
        TargetDropTest = [Data.TargetVectorTest.X, Data.TargetVectorTest.Z];

        %%% Calculate Error
        % Baseline

        DifferenceBaseline = CubeDropBaseline - TargetDropBaseline;
        for k = 1:size(DifferenceBaseline, 1)
            error_baseline(k, 1) = norm(DifferenceBaseline(k, :), 2);
        end

        % Train
        DifferenceTrain = CubeDropTrain - TargetDropTrain;
        for k = 1:size(DifferenceTrain, 1)
            error_train(k, 1) = norm(DifferenceTrain(k, :), 2);
        end
        
        % Test
        DifferenceTest = CubeDropTest - TargetDropTest;
        for k = 1:size(DifferenceTest, 1)
            error_test(k, 1) = norm(DifferenceTest(k, :), 2);
        end

        %%% Calculate mean and std
        mean_error_baseline = mean(error_baseline);
        std_error_baseline = std(error_baseline);
        mean_error_train = mean(error_train);
        std_error_train = std(error_train);
        mean_error_test = mean(error_test);
        std_error_test = std(error_test);

        %%% Save the error, mean and std of baseline and test in structure
        DropPosErrorData.(GroupNames{i}).(strcat('S', num2str(j))).error_baseline = error_baseline;
        DropPosErrorData.(GroupNames{i}).(strcat('S', num2str(j))).error_train = error_train;
        DropPosErrorData.(GroupNames{i}).(strcat('S', num2str(j))).error_test = error_test;
        DropPosErrorData.(GroupNames{i}).(strcat('S', num2str(j))).mean_error_baseline = mean_error_baseline;
        DropPosErrorData.(GroupNames{i}).(strcat('S', num2str(j))).std_error_baseline = std_error_baseline;
        DropPosErrorData.(GroupNames{i}).(strcat('S', num2str(j))).mean_error_train = mean_error_train;
        DropPosErrorData.(GroupNames{i}).(strcat('S', num2str(j))).std_error_train = std_error_train;
        DropPosErrorData.(GroupNames{i}).(strcat('S', num2str(j))).mean_error_test = mean_error_test;
        DropPosErrorData.(GroupNames{i}).(strcat('S', num2str(j))).std_error_test = std_error_test;
    end 
end
%%

%%% Step 4: Plot the DropPos Error Data - Group specific
% make a timetable for boxplot
GroupNames = fieldnames(DropPosErrorData);

errorData = [];
variable_names = {'Group', 'Condition', 'Error'};
condition_temp = {};
DropPosTable = table({}, {}, errorData, 'VariableNames', variable_names);
% DropPosBoxPlotTable = ;
% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    Participants = DropPosErrorData.(GroupNames{i});

    % This loops in each participant of each group
    for j = 1:length(fieldnames(Participants))
        ParticipantNames = fieldnames(Participants);

        myData = Participants.(ParticipantNames{j});

%         Baseline_errorData = myData.error_baseline;
%         Train_errorData = myData.error_train;
%         Test_errorData = myData.error_test;
        Baseline_errorData = myData.mean_error_baseline;
        Train_errorData = myData.mean_error_train;
        Test_errorData = myData.mean_error_test;
        
        min_size = min([length(Baseline_errorData), length(Train_errorData), length(Test_errorData)]);
        
        % Make the error size consistent among the conditions
        Baseline_errorData = Baseline_errorData(end - (min_size - 1):end);
        Train_errorData = Train_errorData(end - (min_size - 1):end);
        Test_errorData = Test_errorData(end - (min_size - 1):end);
        
        groupname_temp = cell('');
        condition_temp = cell('');
        for k=1:min_size
            condition_temp = [condition_temp; 'Baseline'];
            groupname_temp = [groupname_temp; GroupNames{i}];
        end
        
        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, Baseline_errorData, ...
            'VariableNames', variable_names);
        
        DropPosTable = [DropPosTable; newTable];
        
        groupname_temp = cell('');
        condition_temp = cell('');
        for k=1:min_size
            condition_temp = [condition_temp; 'Train'];
            groupname_temp = [groupname_temp; GroupNames{i}];
        end

        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, Train_errorData, ...
            'VariableNames', variable_names);
        
        DropPosTable = [DropPosTable; newTable];
        
        groupname_temp = cell('');
        condition_temp = cell('');
        for k=1:min_size
            condition_temp = [condition_temp; 'Test'];
            groupname_temp = [groupname_temp; GroupNames{i}];
        end
        
        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, Test_errorData, ...
            'VariableNames', variable_names);
        
        DropPosTable = [DropPosTable; newTable];
    end
end
%% Statistical test



%%

% Create categorical array for x-axis labels with desired order
DropPosTable.Condition = categorical(DropPosTable.Condition);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
DropPosTable.Condition = reordercats(DropPosTable.Condition, desiredOrder);


figure
error_boxchart = boxchart(DropPosTable.Condition, DropPosTable.Error,'GroupByColor',DropPosTable.Group);

legend("Location", "Best")
title('Error plot');
ylabel('Error [m]');
xlabel('Conditions');

%% Analysis: EMG data