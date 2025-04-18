% Pipeline to process the raw experimental data
clc; clear; close all;
format compact
%% Convert .csv files to .mat format


start = 3; % Starting folder from 3, ignoring '.' and '..' in the directory
num_participants = 22;
stop = start + (num_participants - 1); % final folder depends on the number of participants

% This is where each participants' data are stored for this project
data_path = "D:\OneDrive - University of Waterloo\project_MT\DataAnalysis\mt_pipeline\MotorControl\Data";
cd(data_path)

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

% Create categorical array for x-axis labels with desired order
TimeTable.Condition = categorical(TimeTable.Condition);
TimeTable.Group = categorical(TimeTable.Group);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
TimeTable.Condition = reordercats(TimeTable.Condition, desiredOrder);

%% Extract Time data

with_haptics_baseline_time = TimeTable(TimeTable.Group == "WithHaptics" & TimeTable.Condition == 'Baseline', :).Time;
with_haptics_train_time = TimeTable(TimeTable.Group == "WithHaptics" & TimeTable.Condition == 'Train', :).Time;
with_haptics_test_time = TimeTable(TimeTable.Group == "WithHaptics" & TimeTable.Condition == 'Test', :).Time;

without_haptics_baseline_time = TimeTable(TimeTable.Group == "WithoutHaptics" & TimeTable.Condition == 'Baseline', :).Time;
without_haptics_train_time = TimeTable(TimeTable.Group == "WithoutHaptics" & TimeTable.Condition == 'Train', :).Time;
without_haptics_test_time = TimeTable(TimeTable.Group == "WithoutHaptics" & TimeTable.Condition == 'Test', :).Time;

with_haptics_baseline_time = seconds(with_haptics_baseline_time);
with_haptics_train_time = seconds(with_haptics_train_time);
with_haptics_test_time = seconds(with_haptics_test_time);

without_haptics_baseline_time = seconds(without_haptics_baseline_time);
without_haptics_train_time = seconds(without_haptics_train_time);
without_haptics_test_time = seconds(without_haptics_test_time);
%% Plot Time
y1 = with_haptics_baseline_time;
y2 = without_haptics_baseline_time;
y3 = with_haptics_train_time;
y4 = without_haptics_train_time;
y5 = with_haptics_test_time;
y6 = without_haptics_test_time;

y_label = "Time [s]";
y_lim = [0, 3];

[my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', y_label, y_lim, "", 0.5, 0.6);
%%
figure
data = with_haptics_test_time;
qqplot(data)
%%
% [h, p] = ttest2(with_haptics_test_time, without_haptics_test_time)
 [H, pValue, W] = swtest(with_haptics_test_time, 0.05)
%%
%%% Step 4: Plot the Time Data - Group specific
% % make a timetable for boxplot
% GroupNames = fieldnames(TimeData);
% 
% timeData = [];
% variable_names = {'Group', 'Condition', 'Time'};
% condition_temp = {};
% TimeTable = table({}, {}, timeData, 'VariableNames', variable_names);
% % DropPosBoxPlotTable = ;
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
%         myData = Participants.(ParticipantNames{j});
% 
% %         Baseline_timeData = myData.Baseline.time_vector;
% %         Train_timeData = myData.Baseline.time_vector;
% %         Test_timeData = myData.Test.time_vector;
%         Baseline_timeData = myData.Baseline.time_std;
%         Train_timeData = myData.Train.time_std;
%         Test_timeData = myData.Test.time_std;
%         
%         min_size = min([length(Baseline_timeData), length(Train_timeData), length(Test_timeData)]);
%         
%         % Make the error size consistent among the conditions
%         Baseline_timeData = Baseline_timeData(end - (min_size - 1):end);
%         Train_timeData = Train_timeData(end - (min_size - 1):end);
%         Test_timeData = Test_timeData(end - (min_size - 1):end);
%         
%         groupname_temp = cell('');
%         condition_temp = cell('');
%         for k=1:min_size
%             condition_temp = [condition_temp; 'Baseline'];
%             groupname_temp = [groupname_temp; GroupNames{i}];
%         end
%         
%         % Make the table to have data of all conditions together
%         newTable = table(groupname_temp, condition_temp, Baseline_timeData, ...
%             'VariableNames', variable_names);
%         
%         TimeTable = [TimeTable; newTable];
%         
%         groupname_temp = cell('');
%         condition_temp = cell('');
%         for k=1:min_size
%             condition_temp = [condition_temp; 'Train'];
%             groupname_temp = [groupname_temp; GroupNames{i}];
%         end
% 
%         % Make the table to have data of all conditions together
%         newTable = table(groupname_temp, condition_temp, Train_timeData, ...
%             'VariableNames', variable_names);
%         
%         TimeTable = [TimeTable; newTable];
%         
%         groupname_temp = cell('');
%         condition_temp = cell('');
%         for k=1:min_size
%             condition_temp = [condition_temp; 'Test'];
%             groupname_temp = [groupname_temp; GroupNames{i}];
%         end
%         
%         % Make the table to have data of all conditions together
%         newTable = table(groupname_temp, condition_temp, Test_timeData, ...
%             'VariableNames', variable_names);
%         
%         TimeTable = [TimeTable; newTable];
%     end
% end
% 
% % Create categorical array for x-axis labels with desired order
% TimeTable.Condition = categorical(TimeTable.Condition);
% TimeTable.Group = categorical(TimeTable.Group);
% 
% % Define the desired order of x-axis categories
% desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed
% 
% % Reorder the unique values in DropPosTable.Condition
% TimeTable.Condition = reordercats(TimeTable.Condition, desiredOrder);

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

%% Data extraction for velocity
withhaptics_baseline_vel = VelTable(VelTable.Group == "WithHaptics" & VelTable.Condition == "Baseline", :).Velocity;
withouthaptics_baseline_vel = VelTable(VelTable.Group == "WithoutHaptics" & VelTable.Condition == "Baseline", :).Velocity;

withhaptics_train_vel = VelTable(VelTable.Group == "WithHaptics" & VelTable.Condition == "Train", :).Velocity;
withouthaptics_train_vel = VelTable(VelTable.Group == "WithoutHaptics" & VelTable.Condition == "Train", :).Velocity;

withhaptics_test_vel = VelTable(VelTable.Group == "WithHaptics" & VelTable.Condition == "Test", :).Velocity;
withouthaptics_test_vel = VelTable(VelTable.Group == "WithoutHaptics" & VelTable.Condition == "Test", :).Velocity;

%% Plot Velocity

y1 = withhaptics_baseline_vel;
y2 = withouthaptics_baseline_vel;
y3 = withhaptics_train_vel;
y4 = withouthaptics_train_vel;
y5 = withhaptics_test_vel;
y6 = withouthaptics_test_vel;

y_label = "Velocity [m/s]";
y_lim = [min(min([y1, y2, y3, y4, y5, y6])) - 0.05, max(max([y1, y2, y3, y4, y5, y6])) + 0.05];

[my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, y3, y4, y5, y6, 5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', y_label, y_lim, "", 0.5, 0.6);

%%

%%% Acceleration
AccTable.Condition = categorical(AccTable.Condition);
AccTable.Group = categorical(AccTable.Group);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
AccTable.Condition = reordercats(AccTable.Condition, desiredOrder);

%% Data extraction for acceleration
withhaptics_baseline_acc = AccTable(AccTable.Group == "WithHaptics" & AccTable.Condition == "Baseline", :).Acceleration;
withouthaptics_baseline_acc = AccTable(AccTable.Group == "WithoutHaptics" & AccTable.Condition == "Baseline", :).Acceleration;

withhaptics_train_acc = AccTable(AccTable.Group == "WithHaptics" & AccTable.Condition == "Train", :).Acceleration;
withouthaptics_train_acc = AccTable(AccTable.Group == "WithoutHaptics" & AccTable.Condition == "Train", :).Acceleration;

withhaptics_test_acc = AccTable(AccTable.Group == "WithHaptics" & AccTable.Condition == "Test", :).Acceleration;
withouthaptics_test_acc = AccTable(AccTable.Group == "WithoutHaptics" & AccTable.Condition == "Test", :).Acceleration;

%% Plot Acceleration

y1 = withhaptics_baseline_acc;
y2 = withouthaptics_baseline_acc;
y3 = withhaptics_train_acc;
y4 = withouthaptics_train_acc;
y5 = withhaptics_test_acc;
y6 = withouthaptics_test_acc;

y_label = "Acceleration [m/s^2]";
y_lim = [min(min([y1, y2, y3, y4, y5, y6])) - 0.5, max(max([y1, y2, y3, y4, y5, y6])) + 0.5];

[my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, y3, y4, y5, y6, 5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', y_label, y_lim, "", 0.5, 0.6);


%% Jerk
JrkTable.Condition = categorical(JrkTable.Condition);
JrkTable.Group = categorical(JrkTable.Group);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
JrkTable.Condition = reordercats(JrkTable.Condition, desiredOrder);

% Data extraction for jerk
withhaptics_baseline_jerk = JrkTable(JrkTable.Group == "WithHaptics" & JrkTable.Condition == "Baseline", :).Jerk;
withouthaptics_baseline_jerk = JrkTable(JrkTable.Group == "WithoutHaptics" & JrkTable.Condition == "Baseline", :).Jerk;

withhaptics_train_jerk = JrkTable(JrkTable.Group == "WithHaptics" & JrkTable.Condition == "Train", :).Jerk;
withouthaptics_train_jerk = JrkTable(JrkTable.Group == "WithoutHaptics" & JrkTable.Condition == "Train", :).Jerk;

withhaptics_test_jerk = JrkTable(JrkTable.Group == "WithHaptics" & JrkTable.Condition == "Test", :).Jerk;
withouthaptics_test_jerk = JrkTable(JrkTable.Group == "WithoutHaptics" & JrkTable.Condition == "Test", :).Jerk;

% Plot Jerk
y1 = withhaptics_baseline_jerk;
y2 = withouthaptics_baseline_jerk;
y3 = withhaptics_train_jerk;
y4 = withouthaptics_train_jerk;
y5 = withhaptics_test_jerk;
y6 = withouthaptics_test_jerk;

y_label = "Jerk [m/s^3]";
y_lim = [min(min([y1, y2, y3, y4, y5, y6])) - 5, max(max([y1, y2, y3, y4, y5, y6])) + 5];

[my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, y3, y4, y5, y6, 5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', y_label, y_lim, "", 0.5, 0.6);

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

        BaselineScore = (Data.Baseline.data(1));
        TrainScore = (Data.Train.data(1));
        TestScore = (Data.Test.data(1));

        ScoreData.(GroupNames{i}).(strcat('S', num2str(j))).Baseline = BaselineScore;
        ScoreData.(GroupNames{i}).(strcat('S', num2str(j))).Train = TrainScore;
        ScoreData.(GroupNames{i}).(strcat('S', num2str(j))).Test = TestScore;
    end
end

%%% Plot The score data (By each group)
GroupNames = fieldnames(ScoreData);

k = 1;

BaselineData = {};
TrainData = {};
TestData = {};


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
end


% make a table for boxplot
GroupNames = fieldnames(ScoreData);

scoreData = [];
variable_names = {'Group', 'Condition', 'Score'};
condition_temp = {};
ScoreTable = table({}, {}, scoreData, 'VariableNames', variable_names);

% make a table for delta score between Test and Baseline for barplot
DeltaScore = [];
variable_names_delta = {'Group', 'DeltaScore'}
DeltaTable = table({}, DeltaScore, 'VariableNames', variable_names_delta)

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
        
        DeltaScore = Test_scoreData - Baseline_scoreData

        groupname_temp_delta = cell('');
        groupname_temp_delta = [groupname_temp_delta; GroupNames{i}];
        newRow_delta = table(groupname_temp_delta, DeltaScore, 'VariableNames', variable_names_delta);
        DeltaTable = [DeltaTable; newRow_delta];


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

%% data extraction for score
withhaptics_baseline_gamescore = ScoreTable(ScoreTable.Group == "WithHaptics" & ScoreTable.Condition == "Baseline", :).Score;
withouthaptics_baseline_gamescore = ScoreTable(ScoreTable.Group == "WithoutHaptics" & ScoreTable.Condition == "Baseline", :).Score;

withhaptics_train_gamescore = ScoreTable(ScoreTable.Group == "WithHaptics" & ScoreTable.Condition == "Train", :).Score;
withouthaptics_train_gamescore = ScoreTable(ScoreTable.Group == "WithoutHaptics" & ScoreTable.Condition == "Train", :).Score;

withhaptics_test_gamescore = ScoreTable(ScoreTable.Group == "WithHaptics" & ScoreTable.Condition == "Test", :).Score;
withouthaptics_test_gamescore = ScoreTable(ScoreTable.Group == "WithoutHaptics" & ScoreTable.Condition == "Test", :).Score;
%% Plot Success rate
y1 = withhaptics_baseline_gamescore/60*100;
y2 = withouthaptics_baseline_gamescore/60*100;
y3 = withhaptics_train_gamescore/60*100;
y4 = withouthaptics_train_gamescore/60*100;
y5 = withhaptics_test_gamescore/60*100;
y6 = withouthaptics_test_gamescore/60*100;

y_label = "Success rate  [%]";
y_lim = [0, 100];

[my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', y_label, y_lim, "", 0.5, 0.6);
StatisticalLines(x1, 0.995*x5, '***', 90, 2, 7)
StatisticalLines(1.005*x5, x6, '***', 90, 2, 7)
StatisticalLines(x2, x6, '***', 97, 2, 7)
%%
format long
% Combine the data into a single vector
data = [y1', y2', (y5+0.1)', (y6-0.2)'];

% Create a grouping variable
group = [repmat({'y1'}, 1, length(y1)), repmat({'y2'}, 1, length(y2)), repmat({'y5'}, 1, length(y5)), repmat({'y6'}, 1, length(y6))];

% Perform One-Way ANOVA
[p, tbl, stats] = anova1(data, group);

% Display ANOVA table
disp('ANOVA Table:');
disp(tbl);

% Display the p-value from the ANOVA with higher precision
format long;
fprintf('ANOVA p-value: %e\n', p);

% Conduct Tukey's HSD post-hoc test
results = multcompare(stats, 'CType', 'tukey-kramer');

% Display post-hoc test results
disp('Tukeys HSD post-hoc test results:');
disp(results);

% Extract and display p-values with corresponding group comparisons
comparison_labels = {'y1 vs y2', 'y1 vs y5', 'y1 vs y6', 'y2 vs y5', 'y2 vs y6', 'y5 vs y6'};
posthoc_comparisons = results(:, [1, 2, 6]); % Extract group comparisons and p-values

% Display the comparisons with their corresponding p-values
fprintf('Post-hoc comparisons and p-values:\n');
for i = 1:size(posthoc_comparisons, 1)
    group1 = comparison_labels{(posthoc_comparisons(i, 1) - 1) * 3 + posthoc_comparisons(i, 2) - 1};
    fprintf('%s: p-value = %e\n', group1, posthoc_comparisons(i, 3));
    i
    switch posthoc_comparisons(i, 3)
        case posthoc_comparisons(i, 3) < 0.05 && posthoc_comparisons(i, 3) > 0.01
            fprintf("*")
        case posthoc_comparisons(i, 3) < 0.01 && posthoc_comparisons(i, 3) > 0.001
            fprintf("**")
        case posthoc_comparisons(i, 3) < 0.001 
            fprintf("***")
    end
end
%%
effect = meanEffectSize(y5,y6,Paired=false,Effect="robustcohen",Alpha=0.05)
effect = meanEffectSize(y1,y5,Paired=true,Effect="robustcohen",Alpha=0.05)
effect = meanEffectSize(y2,y6,Paired=true,Effect="robustcohen",Alpha=0.05)
%%
%%% Normality check
figure
    data = withouthaptics_test_gamescore
    mean_ = mean(data);
    res_ = data - mean_;
    qqplot(data)
%% Run stats
[h,p] = ttest2(withhaptics_test_gamescore, withouthaptics_test_gamescore,'Alpha',0.05)
%%
[p,tbl,stats] = anova2([withhaptics_test_gamescore, withouthaptics_test_gamescore]);
p
figure
comparison = multcompare(stats)
p = comparison(:, end)
%% Stats for score
% close all
[p,t,stats] = anova1([withouthaptics_baseline_gamescore, withouthaptics_test_gamescore])
p
[p,t,stats] = anova1([withhaptics_baseline_gamescore, withhaptics_test_gamescore])
p
% [c,m,h,gnames] = multcompare(stats, "bonferroni")

%%
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
% bias2 = 0.02;
% StatisticalLines(centre(1) - bias, centre(3) - bias, '**', 96, 0.7, 2, score_legend)
% StatisticalLines(centre(1) + bias, centre(3) + bias, '***', 93, 0.7, 2, score_legend)
% StatisticalLines(centre(1) + bias, centre(2) + bias - bias2, '**', 90, 0.7, 2, score_legend)
% StatisticalLines(centre(2) + bias + bias2, centre(3) + bias, '***', 90, 0.7, 2, score_legend)
% StatisticalLines(centre(1) - bias, centre(2) - bias - bias2, '*', 87, 0.7, 2, score_legend)
% StatisticalLines(centre(2) - bias + bias2, centre(3) - bias - bias2, '***', 87, 0.7, 2, score_legend)
% StatisticalLines(centre(3) - bias + bias2, centre(3) + bias, '**', 87, 0.7, 2, score_legend)
% ylim([0, 60])
% xlim([0.25, 5.25])
%% Score plot
% close all
% plot_width = 8.6;
% 
% PerformanceFigure = figure;
% PerformanceFigure.Units = "centimeters";
%     old_pos = PerformanceFigure.Position;
%     PerformanceFigure.Position(3) = plot_width;
%     PerformanceFigure.Position(4) = 8;
%     PerformanceFigure.Position
% 
% ScorePlot = subplot(1, 2, 1);
%     n_withhaptics = 11;
%     n_withouthaptics = 11;
%     centre = 1;
%     bias_between_groups = 0.3;
%     bias_between_conditions = 1.5;
%     bias_between_questions = 0.7;
%     color_withhaptics = [0 0.4470 0.7410];
%     color_withouthaptics = [0.8500 0.3250 0.0980];
%     bias2 = 0.02;
% 
%     withhaptics_baseline_q6_x = (centre - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
%     withouthaptics_baseline_q6_x = (centre - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
%     withhaptics_train_q6_x = (centre - bias_between_groups) * ones(1, n_withhaptics);
%     withouthaptics_train_q6_x = (centre + bias_between_groups) * ones(1, n_withouthaptics);
%     withhaptics_test_q6_x = (centre + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
%     withouthaptics_test_q6_x = (centre + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
% 
%     score_boxchart = boxchart(withhaptics_baseline_q6_x, withhaptics_baseline_gamescore);
%     score_boxchart.BoxFaceColor = color_withhaptics;
%     score_boxchart.MarkerColor = color_withhaptics;
%     score_boxchart.MarkerSize = 3;
%     hold on
%     score_boxchart = boxchart(withouthaptics_baseline_q6_x, withouthaptics_baseline_gamescore);
%     score_boxchart.BoxFaceColor = color_withouthaptics;
%     score_boxchart.MarkerColor = color_withouthaptics;
%     score_boxchart.MarkerSize = 3;
% 
%     %%%% Train
%     score_boxchart = boxchart(withhaptics_train_q6_x, withhaptics_train_gamescore);
%     score_boxchart.BoxFaceColor = color_withhaptics;
%     score_boxchart.MarkerColor = color_withhaptics;
%     score_boxchart.MarkerSize = 3;
%     hold on
%     score_boxchart = boxchart(withouthaptics_train_q6_x, withouthaptics_train_gamescore);
%     score_boxchart.BoxFaceColor = color_withouthaptics;
%     score_boxchart.MarkerColor = color_withouthaptics;
%     score_boxchart.MarkerSize = 3;
%     
%     %%%% Test
%     score_boxchart = boxchart(withhaptics_test_q6_x, withhaptics_test_gamescore);
%     score_boxchart.BoxFaceColor = color_withhaptics;
%     score_boxchart.MarkerColor = color_withhaptics;
%     score_boxchart.MarkerSize = 3;
%     hold on
%     score_boxchart = boxchart(withouthaptics_test_q6_x, withouthaptics_test_gamescore);
%     score_boxchart.BoxFaceColor = color_withouthaptics;
%     score_boxchart.MarkerColor = color_withouthaptics;
%     score_boxchart.MarkerSize = 3;
% %     score_legend = legend("With haptics", "Without haptics", "Location", "northOutside")
% %     score_boxchart.Parent.Legend.Units = 'points';
% %     score_boxchart.Parent.Legend.FontSize = 9;
% %     score_boxchart.Parent.Legend.FontName = 'Linux Libertine G';
% %     score_boxchart.Parent.Legend.Orientation = 'horizontal';
% 
%     score_boxchart.Parent.XTick = [centre - bias_between_conditions, centre, centre + bias_between_conditions];
%     score_boxchart.Parent.XTickLabel = {'Baseline', 'Train', 'Test'};
%     score_boxchart.Parent.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.Units = 'points';
%     score_boxchart.Parent.FontSize = 9;
% 
%     score_boxchart.Parent.XLim = [centre(1) - bias_between_conditions - bias_between_groups - score_boxchart.BoxWidth, centre(1) + bias_between_conditions + bias_between_groups + score_boxchart.BoxWidth];
%     score_boxchart.Parent.Subtitle.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.Subtitle.Units = 'points';
%     score_boxchart.Parent.Subtitle.FontSize = 9;
% 
%     score_boxchart.Parent.YLabel.String = "Accuracy";
%     score_boxchart.Parent.YLabel.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.YLabel.FontUnits = "points";
%     score_boxchart.Parent.YLabel.FontSize = 9;
%     score_boxchart.MarkerSize = 3;
%     ylim([0, 65])
% %     StatisticalLines2(withhaptics_baseline_q6_x(1), withhaptics_test_q6_x(1) - bias2, '***', 56, 0.5, 9)
% %     StatisticalLines2(withhaptics_test_q6_x(1) + bias2, withouthaptics_test_q6_x(1), '**', 56, 0.5, 9)
% %     StatisticalLines2(withouthaptics_baseline_q6_x(1), withouthaptics_test_q6_x(1), '***', 60, 0.5, 9)
% 
% subplot(1,2,2)
%     n_withhaptics = 11;
%     n_withouthaptics = 11;
%     centre = 1;
%     bias_between_groups = 0.3;
%     bias_between_conditions = 1.5;
%     bias_between_questions = 0.7;
%     color_withhaptics = [0 0.4470 0.7410];
%     color_withouthaptics = [0.8500 0.3250 0.0980];
%     bias2 = 0.02;
% 
%     withhaptics_baseline_q6_x = (centre - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
%     withouthaptics_baseline_q6_x = (centre - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
%     
%     withhaptics_train_q6_x = (centre - bias_between_groups) * ones(1, n_withhaptics);
%     withouthaptics_train_q6_x = (centre + bias_between_groups) * ones(1, n_withouthaptics);
%     
%     withhaptics_test_q6_x = (centre + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
%     withouthaptics_test_q6_x = (centre + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
%  
% %%%Baseline
%     score_boxchart = boxchart(withhaptics_baseline_q6_x, with_haptics_baseline_time);
%     score_boxchart.BoxFaceColor = color_withhaptics;
%     score_boxchart.MarkerColor = color_withhaptics;
%     score_boxchart.MarkerSize = 3;
%     hold on
%     score_boxchart = boxchart(withouthaptics_baseline_q6_x, without_haptics_baseline_time);
%     score_boxchart.BoxFaceColor = color_withouthaptics;
%     score_boxchart.MarkerColor = color_withouthaptics;
%     score_boxchart.MarkerSize = 3;
% 
%     %%%% Train
%     score_boxchart = boxchart(withhaptics_train_q6_x, with_haptics_train_time);
%     score_boxchart.BoxFaceColor = color_withhaptics;
%     score_boxchart.MarkerColor = color_withhaptics;
%     score_boxchart.MarkerSize = 3;
%     hold on
%     score_boxchart = boxchart(withouthaptics_train_q6_x, without_haptics_train_time);
%     score_boxchart.BoxFaceColor = color_withouthaptics;
%     score_boxchart.MarkerColor = color_withouthaptics;
%     score_boxchart.MarkerSize = 3;
%     
%     %%%% Test
%     score_boxchart = boxchart(withhaptics_test_q6_x, with_haptics_test_time);
%     score_boxchart.BoxFaceColor = color_withhaptics;
%     score_boxchart.MarkerColor = color_withhaptics;
%     score_boxchart.MarkerSize = 3;
%     hold on
%     score_boxchart = boxchart(withouthaptics_test_q6_x, without_haptics_test_time);
%     score_boxchart.BoxFaceColor = color_withouthaptics;
%     score_boxchart.MarkerColor = color_withouthaptics;
%     score_boxchart.MarkerSize = 3;
% 
%     score_boxchart.Parent.XTick = [centre - bias_between_conditions, centre, centre + bias_between_conditions];
%     score_boxchart.Parent.XTickLabel = {'Baseline', 'Train', 'Test'};
%     score_boxchart.Parent.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.Units = 'points';
%     score_boxchart.Parent.FontSize = 9;
% 
%     score_boxchart.Parent.XLim = [centre(1) - bias_between_conditions - bias_between_groups - score_boxchart.BoxWidth, centre(1) + bias_between_conditions + bias_between_groups + score_boxchart.BoxWidth];
%     score_boxchart.Parent.Subtitle.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.Subtitle.Units = 'points';
%     score_boxchart.Parent.Subtitle.FontSize = 9;
% %     score_legend = legend("With haptics", "Without haptics", "Location", "northoutside")
% %     score_boxchart.Parent.Legend.Units = 'points';
% %     score_boxchart.Parent.Legend.FontSize = 9;
% %     score_boxchart.Parent.Legend.FontName = 'Linux Libertine G';
% %     score_boxchart.Parent.Legend.Orientation = 'horizontal';
% %     score_boxchart.Parent.Legend.Position = [200 290 183.7500 13.5000];
%     score_boxchart.Parent.YLabel.String = "Time [s]";
%     score_boxchart.Parent.YLabel.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.YLabel.FontUnits = "points";
%     score_boxchart.Parent.YLabel.FontSize = 9;
%     score_boxchart.MarkerSize = 3;
% 
% %     score_boxchart.Parent.Position(2) = 70
%     ylim([0, 2.6])
% 
% % Create a legend in the middle of the figure
% hLegend = legend('With haptics', 'Without haptics', 'Location', 'best', 'Orientation','horizontal');
% 
% % Adjust the position of the legend
% pos = get(hLegend, 'Position');
% pos(1) = 0.5 - pos(3)/2; % Center the legend horizontally
% pos(2) = 1 - pos(4);     % Place the legend at the top of the figure
% set(hLegend, 'Position', pos);
%%
    [p1,h,stats] = signrank(withhaptics_baseline_gamescore, withhaptics_test_gamescore, alpha=0.05/2)

%%
    [p2,h,stats] = signrank(withouthaptics_baseline_gamescore, withouthaptics_test_gamescore, alpha=0.05/2)
%%
    [p3,h,stats] = ranksum(withouthaptics_test_gamescore, withhaptics_test_gamescore)
    %% Statistical tests on game score
    [p,h,stats] = anova1([withhaptics_baseline_gamescore, withhaptics_test_gamescore], {'WithHapticsBaseline', 'WithHapticsTest'});
    p
    %%
    [p,h,stats] = anova1([withouthaptics_baseline_gamescore, withouthaptics_test_gamescore], {'WithoutHapticsBaseline', 'WithoutHapticsTest'});
    p
    %%
        [p,h,stats] = anova1([withhaptics_test_gamescore, withouthaptics_test_gamescore], {'WithHapticsTest', 'WithoutHapticsTest'});
    p
%     p = p*3

%% Data extraction for delta score

withhaptics_delta_score = DeltaTable(DeltaTable.Group == "WithHaptics", :).DeltaScore;
withouthaptics_delta_score = DeltaTable(DeltaTable.Group == "WithoutHaptics", :).DeltaScore;

mean_withhaptics = mean(withhaptics_delta_score);
mean_withouthaptics = mean(withouthaptics_delta_score);

std_withhaptics = std(withhaptics_delta_score);
std_withouthaptics = std(withouthaptics_delta_score);
% barplot for delta score
% figure
% close all
DeltaScoreFigure = figure;
    DeltaScoreFigure.Units = 'centimeters';
    DeltaScoreFigure.Position
    DeltaScoreFigure.Position = [15, 15, 7.5, 7.5/14.8167*11.1125];
    DeltaScoreFigure.PaperUnits = 'centimeters';
%     NASAScoreFigure.PaperPosition = [15, 15, 7.5, 7.5];

    n_withhaptics = 11;
    n_withouthaptics = 11;
    centre = 1;
    bias_between_groups = 0.3;
    bias_between_conditions = 1.5;
    bias_between_questions = 0.7;
    color_withhaptics = [0 0.4470 0.7410];
    color_withouthaptics = [0.8500 0.3250 0.0980];
    withouthaptics_alpha = 0.2000;
    withhaptics_alpha = 0.2000;
    bias2 = 0.02;

    withhaptics_baseline_q6_x = (centre - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_baseline_q6_x = (centre - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
%     withhaptics_train_q6_x = (centre - bias_between_groups) * ones(1, n_withhaptics);
%     withouthaptics_train_q6_x = (centre + bias_between_groups) * ones(1, n_withouthaptics);
%     withhaptics_test_q6_x = (centre + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
%     withouthaptics_test_q6_x = (centre + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);


    delta_barchart = bar(withhaptics_baseline_q6_x(1), mean_withhaptics);
    delta_barchart.FaceColor = color_withhaptics;
    delta_barchart.FaceAlpha = withhaptics_alpha;
    delta_barchart.BarWidth = 0.5;
    delta_barchart.EdgeColor = color_withhaptics;
    delta_barchart.LineWidth = 1;
    delta_barchart.Parent.XTick = [];
    hold on
    delta_barchart = bar(withouthaptics_baseline_q6_x(1), mean_withouthaptics);
    delta_barchart.FaceColor = color_withouthaptics;
    delta_barchart.FaceAlpha = withouthaptics_alpha;
    delta_barchart.BarWidth = 0.5;
    delta_barchart.EdgeColor = color_withouthaptics;
    delta_barchart.LineWidth = 1;
    delta_barchart.Parent.XTick = [];
%     xlim([-.5, 0])

    hold on
    errorbar(withhaptics_baseline_q6_x(1), mean_withhaptics, std_withhaptics, 'k.', 'LineWidth', 1);
    hold on
    errorbar(withouthaptics_baseline_q6_x(1), mean_withouthaptics, std_withouthaptics, 'k.', 'LineWidth', 1);
%%
%     %%
%     figure
%     data = withouthaptics_delta_score;
%     mean_ = mean(data);
%     res_ = data - mean_;
%     qqplot(res_)

[h, p, stat] = swtest(withhaptics_test_gamescore, 0.05)

%% Handedness analysis
% close all
% withhaptics_handedness = [6, 3, 6, 6, arman, 3, 2, 5, 0, 9, 5];
% withouthaptics_handedness = [0, 5, 6, 0, 2, 3, chongren, 10, 6, 7, 6];
withhaptics_handedness = [6, 3, 6, 6, 3, 3, 2, 5, 0, 9, 5]';
withouthaptics_handedness = [0, 5, 6, 0, 2, 3, 2, 10, 6, 7, 6]';
figure
scatter([withhaptics_handedness; withouthaptics_handedness], [withhaptics_delta_score; withouthaptics_delta_score]);
hold on
scatter(withouthaptics_handedness, withouthaptics_delta_score);
legend("With haptics", "Without haptics")
xlim([-0.5, 10.5])

WithHaptics = [withhaptics_handedness, withhaptics_delta_score];
WithoutHaptics = [withouthaptics_handedness, withouthaptics_delta_score];
% Assuming 'data' is your preprocessed data and 'k' is the number of clusters
data = [WithHaptics; WithoutHaptics];
k = 2;
idx = kmeans(data, k);

% 'idx' contains the cluster assignments for each data point
% 'C' contains the final centroids
[idx, C] = kmeans(data, k);
figure
scatter(data(:,1), data(:,2), [], idx, 'filled');
title('Cluster Assignments');

% ARI = adjustedrandindex(groundTruthLabels, idx);


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

%% 
difference_withhaptics = []