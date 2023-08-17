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
        RightTrain = Data.TrainRightPalm.data;
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
        [minima, minimaIndices] = findpeaks(-smoothedLeftBaseline, "MinPeakProminence", maxima_prominence, "MinPeakDistance", minima_min_peak_distance);

%         figure
%         yyaxis left
%         findpeaks(smoothedLeftBaseline, "MinPeakProminence", maxima_prominence, "MinPeakDistance", maxima_min_peak_distance);
%         yyaxis right
%         findpeaks(-smoothedLeftBaseline, "MinPeakProminence", minima_prominence, "MinPeakDistance", minima_min_peak_distance);
%         legend("max", "min")

%       end
% end      


        for kk = 1:min(length(minimaIndices), length(maximaIndices))
            prospective_minima_indices = minimaIndices(minimaIndices > maximaIndices(kk));
            if ~isempty (prospective_minima_indices)
                exact_minima_index = prospective_minima_indices(1);
            end
            
            KinematicData.(GroupNames{i}).(strcat('S', num2str(j))).LeftBaseline.(strcat('Trial', num2str(kk))) = LeftBaseline(maximaIndices(kk): exact_minima_index, :);
        end

        
        %%% THIS IS FOR RIGHT TRAIN
        % Smooth the trajectory and find the local minima and maxima
        window_size = 100;
        smoothedRightTrain = movmean(RightTrain.X, window_size);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% DOUBLE CHECK THIS PART %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Hyperparameters tuned by trial and error 
        maxima_prominence = 0.05;
        minima_prominence = 0.05;

        maxima_min_peak_distance = 0.5;
        minima_min_peak_distance = 0.5;

        [maxima, maximaIndices] = findpeaks(smoothedRightTrain, "MinPeakProminence", maxima_prominence, "MinPeakDistance", maxima_min_peak_distance);
        [minima, minimaIndices] = findpeaks(-smoothedRightTrain, "MinPeakProminence", maxima_prominence, "MinPeakDistance", minima_min_peak_distance);

%         figure
%         yyaxis left
%         findpeaks(smoothedRightTrain, "MinPeakProminence", maxima_prominence, "MinPeakDistance", maxima_min_peak_distance);
%         yyaxis right
%         findpeaks(-smoothedRightTrain, "MinPeakProminence", minima_prominence, "MinPeakDistance", minima_min_peak_distance);
%         legend("max", "min")

%       end
% end      


        for kk = 1:min(length(minimaIndices), length(maximaIndices))
            prospective_maxima_indices = maximaIndices(maximaIndices > minimaIndices(kk));
            if ~isempty (prospective_maxima_indices)
                exact_maxima_index = prospective_maxima_indices(1);
            end
            
            KinematicData.(GroupNames{i}).(strcat('S', num2str(j))).RightTrain.(strcat('Trial', num2str(kk))) = RightTrain(minimaIndices(kk): exact_maxima_index, :);
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
        TrainTrials = fieldnames(Data.RightTrain);
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

        TimeData.(GroupNames{i}).(strcat('S', num2str(j))).Baseline.time_vector = time_baseline';
        TimeData.(GroupNames{i}).(strcat('S', num2str(j))).Baseline.time_mean = time_baseline_mean;
        TimeData.(GroupNames{i}).(strcat('S', num2str(j))).Baseline.time_std = time_baseline_std;

        % Measuring the duration of each trial in train
        for k = 1:length(TrainTrials)

            Trial = Data.RightTrain.(TrainTrials{k});
            if ~isempty(Trial.Time)
                time_train(k) = Trial.Time(end) - Trial.Time(1);
            end
        end
        time_train_mean = mean(time_train);
        time_train_std = std(time_train);

        TimeData.(GroupNames{i}).(strcat('S', num2str(j))).Train.time_vector = time_train';
        TimeData.(GroupNames{i}).(strcat('S', num2str(j))).Train.time_mean = time_train_mean;
        TimeData.(GroupNames{i}).(strcat('S', num2str(j))).Train.time_std = time_train_std;
        
        % Measuring the duration of each trial in test
%         time_test = [];
        for k = 1:length(TestTrials)
            
            Trial = Data.LeftTest.(TestTrials{k});
            
            if ~isempty(Trial)
                time_test(k) = Trial.Time(end) - Trial.Time(1);
            end
        end

        time_test_mean = mean(time_test);
        time_test_std = std(time_test);

        TimeData.(GroupNames{i}).(strcat('S', num2str(j))).Test.time_vector = time_test';
        TimeData.(GroupNames{i}).(strcat('S', num2str(j))).Test.time_mean = time_test_mean;
        TimeData.(GroupNames{i}).(strcat('S', num2str(j))).Test.time_std = time_test_std;
    end
end
%%

%%% Step 4: Plot the Time Data - Group specific
% make a timetable for boxplot
GroupNames = fieldnames(TimeData);

timeData = [];
variable_names = {'Group', 'Condition', 'Time'};
condition_temp = {};
TimeTable = table({}, {}, timeData, 'VariableNames', variable_names);
% DropPosBoxPlotTable = ;
% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    Participants = TimeData.(GroupNames{i});

    % This loops in each participant of each group
    for j = 1:length(fieldnames(Participants))
        ParticipantNames = fieldnames(Participants);

        myData = Participants.(ParticipantNames{j});

%         Baseline_timeData = myData.Baseline.time_vector;
%         Train_timeData = myData.Baseline.time_vector;
%         Test_timeData = myData.Test.time_vector;
        Baseline_timeData = myData.Baseline.time_mean;
        Train_timeData = myData.Train.time_mean;
        Test_timeData = myData.Test.time_mean;
        
        min_size = min([length(Baseline_timeData), length(Train_timeData), length(Test_timeData)]);
        
        % Make the error size consistent among the conditions
        Baseline_timeData = Baseline_timeData(end - (min_size - 1):end);
        Train_timeData = Train_timeData(end - (min_size - 1):end);
        Test_timeData = Test_timeData(end - (min_size - 1):end);
        
        groupname_temp = cell('');
        condition_temp = cell('');
        for k=1:min_size
            condition_temp = [condition_temp; 'Baseline'];
            groupname_temp = [groupname_temp; GroupNames{i}];
        end
        
        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, Baseline_timeData, ...
            'VariableNames', variable_names);
        
        TimeTable = [TimeTable; newTable];
        
        groupname_temp = cell('');
        condition_temp = cell('');
        for k=1:min_size
            condition_temp = [condition_temp; 'Train'];
            groupname_temp = [groupname_temp; GroupNames{i}];
        end

        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, Train_timeData, ...
            'VariableNames', variable_names);
        
        TimeTable = [TimeTable; newTable];
        
        groupname_temp = cell('');
        condition_temp = cell('');
        for k=1:min_size
            condition_temp = [condition_temp; 'Test'];
            groupname_temp = [groupname_temp; GroupNames{i}];
        end
        
        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, Test_timeData, ...
            'VariableNames', variable_names);
        
        TimeTable = [TimeTable; newTable];
    end
end

% Statistical test for DropPosError


% Create categorical array for x-axis labels with desired order
TimeTable.Condition = categorical(TimeTable.Condition);
TimeTable.Group = categorical(TimeTable.Group);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
TimeTable.Condition = reordercats(TimeTable.Condition, desiredOrder);

figure
time_boxchart = boxchart(TimeTable.Condition, seconds(TimeTable.Time),'GroupByColor',TimeTable.Group);

legend("Location", "Best")
title('Time plot - MEAN');
ylabel('Time [sec]');
xlabel('Conditions');
ylim([0.7, 2.5])

%%
%%% Step 4: Plot the Time Data - Group specific
% make a timetable for boxplot
GroupNames = fieldnames(TimeData);

timeData = [];
variable_names = {'Group', 'Condition', 'Time'};
condition_temp = {};
TimeTable = table({}, {}, timeData, 'VariableNames', variable_names);
% DropPosBoxPlotTable = ;
% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    Participants = TimeData.(GroupNames{i});

    % This loops in each participant of each group
    for j = 1:length(fieldnames(Participants))
        ParticipantNames = fieldnames(Participants);

        myData = Participants.(ParticipantNames{j});

%         Baseline_timeData = myData.Baseline.time_vector;
%         Train_timeData = myData.Baseline.time_vector;
%         Test_timeData = myData.Test.time_vector;
        Baseline_timeData = myData.Baseline.time_std;
        Train_timeData = myData.Train.time_std;
        Test_timeData = myData.Test.time_std;
        
        min_size = min([length(Baseline_timeData), length(Train_timeData), length(Test_timeData)]);
        
        % Make the error size consistent among the conditions
        Baseline_timeData = Baseline_timeData(end - (min_size - 1):end);
        Train_timeData = Train_timeData(end - (min_size - 1):end);
        Test_timeData = Test_timeData(end - (min_size - 1):end);
        
        groupname_temp = cell('');
        condition_temp = cell('');
        for k=1:min_size
            condition_temp = [condition_temp; 'Baseline'];
            groupname_temp = [groupname_temp; GroupNames{i}];
        end
        
        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, Baseline_timeData, ...
            'VariableNames', variable_names);
        
        TimeTable = [TimeTable; newTable];
        
        groupname_temp = cell('');
        condition_temp = cell('');
        for k=1:min_size
            condition_temp = [condition_temp; 'Train'];
            groupname_temp = [groupname_temp; GroupNames{i}];
        end

        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, Train_timeData, ...
            'VariableNames', variable_names);
        
        TimeTable = [TimeTable; newTable];
        
        groupname_temp = cell('');
        condition_temp = cell('');
        for k=1:min_size
            condition_temp = [condition_temp; 'Test'];
            groupname_temp = [groupname_temp; GroupNames{i}];
        end
        
        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, Test_timeData, ...
            'VariableNames', variable_names);
        
        TimeTable = [TimeTable; newTable];
    end
end

% Statistical test for DropPosError


% Create categorical array for x-axis labels with desired order
TimeTable.Condition = categorical(TimeTable.Condition);
TimeTable.Group = categorical(TimeTable.Group);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
TimeTable.Condition = reordercats(TimeTable.Condition, desiredOrder);

figure
time_boxchart = boxchart(TimeTable.Condition, seconds(TimeTable.Time),'GroupByColor',TimeTable.Group);

legend("Location", "Best")
title('Time plot - STD');
ylabel('Time [sec]');
xlabel('Conditions');
% ylim([0.7, 2.5])

%% Analysis: Trajectory smoothness
VEL = {};
%%% Find Velocity, Acceleration and Jerk, and save them into TrajectoryInfo()
global TrajectoryInfo;

TrajectoryInfo = struct();

    % Note that in the JerkSaver function, the for calculating the derivatives 
    % of trajectory, the data is downsampled by 1/3 times.
TrajectoryInfo = JerkSaver(KinematicData, "Baseline");
TrajectoryInfo = JerkSaver(KinematicData, "Train");
TrajectoryInfo = JerkSaver(KinematicData, "Test");

%%% Find mean and std of each trial for velocity
GroupNames = fieldnames(TrajectoryInfo);
% Where GroupNames is either "withHaptics" or "withoutHaptics"
% 

velData = [];
accData = [];
jrkData = [];

vel_variable_names = {'Group', 'Condition', 'Velocity'};
condition_temp = {};
VelTable = table({}, {}, velData, 'VariableNames', vel_variable_names);

acc_variable_names = {'Group', 'Condition', 'Acceleration'};
condition_temp = {};
AccTable = table({}, {}, accData, 'VariableNames', acc_variable_names);

jrk_variable_names = {'Group', 'Condition', 'Jerk'};
condition_temp = {};
JrkTable = table({}, {}, jrkData, 'VariableNames', jrk_variable_names);

% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    Participants = TrajectoryInfo.(GroupNames{i});
    % where the "Participants" is all the subjects in the i-th
    % group.

    % This loops in each participant of each group
    for j = 1:length(fieldnames(Participants))

        ParticipantNames = fieldnames(Participants);
        Data = Participants.(ParticipantNames{j});

        BaselineTrials = Data.Baseline;
        field_names = fieldnames(BaselineTrials);

        for k = 1:length(fieldnames(BaselineTrials))
            VEL_baseline{i, j, k} = BaselineTrials.(field_names{k}).Velocity;
            ACC_baseline{i, j, k} = BaselineTrials.(field_names{k}).Acceleration;
            JRK_baseline{i, j, k} = BaselineTrials.(field_names{k}).Jerk;
        end

        for kk = 1:size(VEL_baseline, 3)
            if ~isempty(VEL_baseline{i, j, kk})
                VEL_baseline_trialmean{i, j, kk} = mean(VEL_baseline{i, j, kk}.Velocity_Overall);
            end
            
            if ~isempty(ACC_baseline{i, j, kk})
                ACC_baseline_trialmean{i, j, kk} = mean(ACC_baseline{i, j, kk}.Acceleration_Overall);
            end
            
            if ~isempty(JRK_baseline{i, j, kk})
                JRK_baseline_trialmean{i, j, kk} = mean(JRK_baseline{i, j, kk}.Jerk_Overall);
            end
        end
        VEL_baseline_participantmean = mean([VEL_baseline_trialmean{i, j, :}]);
        ACC_baseline_participantmean = mean([ACC_baseline_trialmean{i, j, :}]);
        JRK_baseline_participantmean = mean([JRK_baseline_trialmean{i, j, :}]);

        groupname_temp = cell('');
        condition_temp = cell('');
        
        condition_temp = [condition_temp; 'Baseline'];
        groupname_temp = [groupname_temp; GroupNames{i}];
        
        % Make the table to have data of all conditions together
        newRow = table(groupname_temp, condition_temp, VEL_baseline_participantmean, ...
            'VariableNames', vel_variable_names);
        VelTable = [VelTable; newRow];
        
        newRow = table(groupname_temp, condition_temp, ACC_baseline_participantmean, ...
            'VariableNames', acc_variable_names);
        AccTable = [AccTable; newRow];
        
        newRow = table(groupname_temp, condition_temp, JRK_baseline_participantmean, ...
            'VariableNames', jrk_variable_names);
        JrkTable = [JrkTable; newRow];
        
        
% %         VEL_baseline_subjectmean{i, j} = mean([VEL_baseline_trialmean{i, j, :}]);
% %         ACC_baseline_subjectmean{i, j} = mean([ACC_baseline_trialmean{i, j, :}]);
% %         JRK_baseline_subjectmean{i, j} = mean([JRK_baseline_trialmean{i, j, :}]);

        TrainTrials = Data.Train;
        field_names = fieldnames(TrainTrials);

        for k = 1:length(fieldnames(TrainTrials))
            VEL_train{i, j, k} = TrainTrials.(field_names{k}).Velocity;
            ACC_train{i, j, k} = TrainTrials.(field_names{k}).Acceleration;
            JRK_train{i, j, k} = TrainTrials.(field_names{k}).Jerk;
        end

        for kk = 1:size(VEL_train, 3)
            if ~isempty(VEL_train{i, j, kk})
                VEL_train_trialmean{i, j, kk} = mean(VEL_train{i, j, kk}.Velocity_Overall);
            end
            
            if ~isempty(ACC_train{i, j, kk})
                ACC_train_trialmean{i, j, kk} = mean(ACC_train{i, j, kk}.Acceleration_Overall);
            end
            
            if ~isempty(JRK_train{i, j, kk})
                JRK_train_trialmean{i, j, kk} = mean(JRK_train{i, j, kk}.Jerk_Overall);
            end
        end
        VEL_train_participantmean = mean([VEL_train_trialmean{i, j, :}]);
        ACC_train_participantmean = mean([ACC_train_trialmean{i, j, :}]);
        JRK_train_participantmean = mean([JRK_train_trialmean{i, j, :}]);
        
        groupname_temp = cell('');
        condition_temp = cell('');
        
        condition_temp = [condition_temp; 'Train'];
        groupname_temp = [groupname_temp; GroupNames{i}];
        
        % Make the table to have data of all conditions together
        newRow = table(groupname_temp, condition_temp, VEL_train_participantmean, ...
            'VariableNames', vel_variable_names);
        VelTable = [VelTable; newRow];
        
        newRow = table(groupname_temp, condition_temp, ACC_train_participantmean, ...
            'VariableNames', acc_variable_names);
        AccTable = [AccTable; newRow];
        
        newRow = table(groupname_temp, condition_temp, JRK_train_participantmean, ...
            'VariableNames', jrk_variable_names);
        JrkTable = [JrkTable; newRow];
        
        
        %%% TestTrials

        TestTrials = Data.Test;
        field_names = fieldnames(TestTrials);

        for k = 1:length(fieldnames(TestTrials))
            VEL_test{i, j, k} = TestTrials.(field_names{k}).Velocity;
            ACC_test{i, j, k} = TestTrials.(field_names{k}).Acceleration;
            JRK_test{i, j, k} = TestTrials.(field_names{k}).Jerk;
        end

        for kk = 1:size(VEL_test, 3)
            if ~isempty(VEL_test{i, j, kk})

                VEL_test_trialmean{i, j, kk} = mean(VEL_test{i, j, kk}.Velocity_Overall);
                % This calculates mean of trial kk of group i_th,
                % participant j_th
            end

            if ~isempty(ACC_test{i, j, kk})
                ACC_test_trialmean{i, j, kk} = mean(ACC_test{i, j, kk}.Acceleration_Overall);
            end
            
            if ~isempty(JRK_test{i, j, kk})
                JRK_test_trialmean{i, j, kk} = mean(JRK_test{i, j, kk}.Jerk_Overall);
            end
        end
        
        VEL_test_participantmean = mean([VEL_test_trialmean{i, j, :}]);
        ACC_test_participantmean = mean([ACC_test_trialmean{i, j, :}]);
        JRK_test_participantmean = mean([JRK_test_trialmean{i, j, :}]);
        
        groupname_temp = cell('');
        condition_temp = cell('');
        
        condition_temp = [condition_temp; 'Test'];
        groupname_temp = [groupname_temp; GroupNames{i}];
        
        % Make the table to have data of all conditions together
        newRow = table(groupname_temp, condition_temp, VEL_test_participantmean, ...
            'VariableNames', vel_variable_names);
        VelTable = [VelTable; newRow];
        
        newRow = table(groupname_temp, condition_temp, ACC_test_participantmean, ...
            'VariableNames', acc_variable_names);
        AccTable = [AccTable; newRow];
        
        newRow = table(groupname_temp, condition_temp, JRK_test_participantmean, ...
            'VariableNames', jrk_variable_names);
        JrkTable = [JrkTable; newRow];
    end
end
%%
VelTable.Condition = categorical(VelTable.Condition);
VelTable.Group = categorical(VelTable.Group);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
VelTable.Condition = reordercats(VelTable.Condition, desiredOrder);


figure
vel_boxchart = boxchart(VelTable.Condition, VelTable.Velocity,'GroupByColor',VelTable.Group);

legend("Location", "Best")
title('Velocity plot - MEAN');
ylabel('Velocity [m/s]');
xlabel('Conditions');

%%% Acceleration
AccTable.Condition = categorical(AccTable.Condition);
AccTable.Group = categorical(AccTable.Group);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
AccTable.Condition = reordercats(AccTable.Condition, desiredOrder);


figure
acc_boxchart = boxchart(AccTable.Condition, AccTable.Acceleration,'GroupByColor',AccTable.Group);

legend("Location", "Best")
title('Acceleration plot - MEAN');
ylabel('Acceleration [m/s^2]');
xlabel('Conditions');

%%% Jerk
JrkTable.Condition = categorical(JrkTable.Condition);
JrkTable.Group = categorical(JrkTable.Group);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
JrkTable.Condition = reordercats(JrkTable.Condition, desiredOrder);


figure
jrk_boxchart = boxchart(JrkTable.Condition, JrkTable.Jerk,'GroupByColor',JrkTable.Group);

legend("Location", "Best")
title('Jerk plot - MEAN');
ylabel('Jerk [m/s^3]');
xlabel('Conditions');

%% Analysis: Score data
close all


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

% % % Change the dimensions of the figure
% % newWidth = 600;  % New width in pixels
% % newHeight = 800; % New height in pixels
% % set(gcf, 'Position', [100, 100, newWidth, newHeight]);
% % set(gca, 'XTickLabel', {});
% % set(gca, 'XTick', []);

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

% %         Example data
% %         data1 = [BaselineData{i, :}];
% %         data2 = [TrainData{i, :}];
% %         data3 = [TestData{i, :}];
% %         
% %         Calculate mean and standard deviation
% %         mean1 = mean(data1);
% %         std1 = std(data1);
% %         mean2 = mean(data2);
% %         std2 = std(data2);
% %         mean3 = mean(data3);
% %         std3 = std(data3);
% %         
% %         Create a figure
% %         subplot(length(GroupNames), 1, i)
% % 
% %         Set the position of each bar chart
% %         barPositions = 0;
% %         barWidth = 0.3;
% %         set(gca, 'XTick', []);
% %         Plot the first bar chart
% %         bar(barPositions, mean1, barWidth);
% %         hold on;
% %         bar(barPositions + barWidth, mean2, barWidth);
% %         hold on;
% %         bar(barPositions + 2*barWidth, mean3, barWidth);
% %         
% %         errorbar(barPositions, mean1, std1, 'k.', 'LineWidth', 1);
% %         
% %         Plot the second bar chart
% %         
% %         errorbar(barPositions + barWidth, mean2, std2, 'k.', 'LineWidth', 1);
% % 
% %         errorbar(barPositions + 2*barWidth, mean3, std3, 'k.', 'LineWidth', 1);
% %         
% %         Customize the chart
% %         xlabel(["Baseline", "Test"]);
% %         ylabel('Score Percentage [%]');
% %         legend('Baseline', 'Train', 'Test', 'Location', 'bestoutside');
% %         title(strcat(GroupNames{i}));
% %         
% %         Adjust the x-axis limits
% %         xlim([min(barPositions)-barWidth, max(barPositions)+3*barWidth]);
% %         
% %         Adjust the x-axis tick labels
% %         xticks([]);

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
centre = [1, 2.75, 4.5];
bias = 0.3;
    x_data1 = centre - bias;
    x_data1 = repmat(x_data1, 1, 11);
    x_data2 = centre + bias;
    x_data2 = repmat(x_data2, 1, 11);
    % x_data2 = repmat(x_data1, 1, 11);
    y_data1 = ScoreTable.Score(1:33);
    y_data2 = ScoreTable.Score(34:end);
    score_boxchart = boxchart(x_data1, y_data1);
    hold on
    boxchart(x_data2, y_data2)
    score_boxchart.Parent.XTick = centre;
    score_boxchart.Parent.XTickLabel = {'Baseline','Train','Test'};

score_legend = legend("WithHaptics","WithoutHaptics","Location", "Best");
excludeIndex = 2;
legendEntries = score_legend.EntryContainer.Children;
legendEntries(3:end) = [];
score_legend.String = {'WithHaptics', 'WithoutHaptics'}

title('Score plot');
ylabel('Score [%]');
ylim([0, 130])
xlabel('Conditions');

%%% Statistical Analysis: Score

% Create categorical array for x-axis labels with desired order
ScoreTable.Condition = categorical(ScoreTable.Condition);
ScoreTable.Group = categorical(ScoreTable.Group);

with_haptics_baseline_score = ScoreTable((ScoreTable.Group == 'WithHaptics' & ScoreTable.Condition == 'Baseline'), :).Score;
with_haptics_train_score = ScoreTable((ScoreTable.Group == 'WithHaptics' & ScoreTable.Condition == 'Train'), :).Score;
with_haptics_test_score = ScoreTable((ScoreTable.Group == 'WithHaptics' & ScoreTable.Condition == 'Test'), :).Score;

without_haptics_baseline_score = ScoreTable((ScoreTable.Group == 'WithoutHaptics' & ScoreTable.Condition == 'Baseline'), :).Score;
without_haptics_train_score = ScoreTable((ScoreTable.Group == 'WithoutHaptics' & ScoreTable.Condition == 'Train'), :).Score;
without_haptics_test_score = ScoreTable((ScoreTable.Group == 'WithoutHaptics' & ScoreTable.Condition == 'Test'), :).Score;

[p, hStat, stats] = ranksum(with_haptics_baseline_score, without_haptics_baseline_score);
[p, hStat, stats] = ranksum(with_haptics_baseline_score, with_haptics_train_score);
[p, hStat, stats] = ranksum(with_haptics_test_score, without_haptics_test_score)

% lineHandles = findobj(score_boxchart(1));
hold on
bias2 = 0.02;
StatisticalLines(centre(1) - bias, centre(3) - bias, '**', 96, 0.7, 2, score_legend)
StatisticalLines(centre(1) + bias, centre(3) + bias, '***', 93, 0.7, 2, score_legend)
StatisticalLines(centre(1) + bias, centre(2) + bias - bias2, '**', 90, 0.7, 2, score_legend)
StatisticalLines(centre(2) + bias + bias2, centre(3) + bias, '***', 90, 0.7, 2, score_legend)
StatisticalLines(centre(1) - bias, centre(2) - bias - bias2, '*', 87, 0.7, 2, score_legend)
StatisticalLines(centre(2) - bias + bias2, centre(3) - bias - bias2, '***', 87, 0.7, 2, score_legend)
StatisticalLines(centre(3) - bias + bias2, centre(3) + bias, '**', 87, 0.7, 2, score_legend)
ylim([0, 100])
xlim([0.25, 5.25])

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
        Baseline_errorData = myData.std_error_baseline;
        Train_errorData = myData.std_error_train;
        Test_errorData = myData.std_error_test;
        
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
%Statistical test for DropPosError
% Create categorical array for x-axis labels with desired order
DropPosTable.Condition = categorical(DropPosTable.Condition);
DropPosTable.Group = categorical(DropPosTable.Group);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
DropPosTable.Condition = reordercats(DropPosTable.Condition, desiredOrder);


figure
error_boxchart = boxchart(DropPosTable.Condition, DropPosTable.Error,'GroupByColor',DropPosTable.Group);

legend("Location", "Best")
title('Error plot - STD');
ylabel('Error [m]');
xlabel('Conditions');
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
%% Statistical test for DropPosError
% Create categorical array for x-axis labels with desired order
DropPosTable.Condition = categorical(DropPosTable.Condition);
DropPosTable.Group = categorical(DropPosTable.Group);

with_haptics_baseline_error = DropPosTable((DropPosTable.Group == 'WithHaptics' & DropPosTable.Condition == 'Baseline'), :);
with_haptics_train_error = DropPosTable((DropPosTable.Group == 'WithHaptics' & DropPosTable.Condition == 'Train'), :);
with_haptics_test_error = DropPosTable((DropPosTable.Group == 'WithHaptics' & DropPosTable.Condition == 'Test'), :);

without_haptics_baseline_error = DropPosTable((DropPosTable.Group == 'WithoutHaptics' & DropPosTable.Condition == 'Baseline'), :);
without_haptics_train_error = DropPosTable((DropPosTable.Group == 'WithoutHaptics' & DropPosTable.Condition == 'Train'), :);
without_haptics_test_error = DropPosTable((DropPosTable.Group == 'WithoutHaptics' & DropPosTable.Condition == 'Test'), :);

with_haptics_baseline_error = with_haptics_baseline_error.Error;
with_haptics_train_error = with_haptics_train_error.Error;
with_haptics_test_error = with_haptics_test_error.Error;

without_haptics_baseline_error = without_haptics_baseline_error.Error;
without_haptics_train_error = without_haptics_train_error.Error;
without_haptics_test_error = without_haptics_test_error.Error;

clc
disp('DropPosError')
disp('------------')
disp('WithHapticsBaseline vs. WithoutHapticsBaseline:')
[p, hStat, stats] = ranksum(with_haptics_baseline_error, without_haptics_baseline_error);
if hStat
    disp('The medians are significantly different.');

else
    disp('The medians are not significantly different.');
end

disp('------------')
disp('WithHapticsBaseline vs. WithHapticsTrain:')
[p, hStat, stats] = ranksum(with_haptics_baseline_error, with_haptics_train_error);
if hStat
    disp('The medians are significantly different.');

else
    disp('The medians are not significantly different.');
end

disp('------------')
disp('WithHapticsBaseline vs. WithHapticsTest:')
[p, hStat, stats] = ranksum(with_haptics_baseline_error, with_haptics_test_error);
if hStat
    disp('The medians are significantly different.');

else
    disp('The medians are not significantly different.');
end

disp('------------')
disp('WithoutHapticsBaseline vs. WithoutHapticsTrain:')
[p, hStat, stats] = ranksum(without_haptics_baseline_error, without_haptics_train_error);
if hStat
    disp('The medians are significantly different.');

else
    disp('The medians are not significantly different.');
end

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
DropPosTable.Condition = reordercats(DropPosTable.Condition, desiredOrder);

figure
error_boxchart = boxchart(DropPosTable.Condition, DropPosTable.Error,'GroupByColor',DropPosTable.Group);

legend("Location", "Best")
title('Error plot - MEAN');
ylabel('Error [m]');
xlabel('Conditions');

%% Analysis: EMG data