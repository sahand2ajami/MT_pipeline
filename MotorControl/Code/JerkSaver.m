function [TrajectoryInfo] = JerkSaver(KinematicData, ConditionString)
    
    downsample_ratio = 2;
    % Apply Savitzky-Golay filter to remove drift
    window_size = 19;   % Must be an odd integer (larger values for more smoothing, but avoid excessive smoothing)
    polynomial_order = 5;  % The order of the polynomial to fit

    global TrajectoryInfo
    subStructure = struct();
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
    
            
            if ConditionString == "Baseline"
                Trials = fieldnames(Data.LeftBaseline);
            elseif ConditionString == "Train"
                Trials = fieldnames(Data.RightTrain);
            elseif ConditionString == "Test"
                Trials = fieldnames(Data.LeftTest);
    %         else
    %             error("String Condition should be either Baseline or Test")
            end

            % Measuring the duration of each trial in baseline
            for k = 1:length(Trials)
                
    
                if ConditionString == "Baseline"
                    Trial = Data.LeftBaseline.(Trials{k});
                elseif ConditionString == "Train"
                    Trial = Data.RightTrain.(Trials{k});
                elseif ConditionString == "Test"
                    Trial = Data.LeftTest.(Trials{k});
                end
                
                if ~isempty(Trial.Time)
                    
                    t_seconds = seconds(Trial.Time);
                    
                    traj_x{k} = Trial.X;
                    traj_y{k} = Trial.Y;
                    traj_z{k} = Trial.Z;
                    
                    traj_x{k} = downsample(traj_x{k}, downsample_ratio);
                    traj_y{k} = downsample(traj_y{k}, downsample_ratio);
                    traj_z{k} = downsample(traj_z{k}, downsample_ratio);
                    t_seconds = downsample(t_seconds, downsample_ratio);

                    % Filter trajectories
                    
                    filtered_traj_x{k} = sgolayfilt(traj_x{k}, polynomial_order, window_size);
                    filtered_traj_y{k} = sgolayfilt(traj_y{k}, polynomial_order, window_size);
                    filtered_traj_z{k} = sgolayfilt(traj_z{k}, polynomial_order, window_size);
                   

                    %% CLEAN THIS PART
%                     vel_notFiltered = diff(traj_x{k}) ./ diff(t_seconds);
%                     vel_Filtered = diff(filtered_traj_x{k}) ./ diff(t_seconds);
% 
%                     if i == 1 && j == 1
%                         figure
%                         plot(t_seconds(1: end-1), vel_notFiltered)
%                         hold on
%                         plot(t_seconds(1: end-1), vel_Filtered)
%                         legend("No Filter", "Yes Filter")
%                     end
%%
                    % Calculate velocity
                    vel_x{k} = diff(traj_x{k}) ./ diff(t_seconds); % Velocity in the x dimension
                    vel_y{k} = diff(traj_y{k}) ./ diff(t_seconds); % Velocity in the y dimension
                    vel_z{k} = diff(traj_z{k}) ./ diff(t_seconds); % Velocity in the z dimension
                    
                    vel_overall{k} = sqrt(vel_x{k}.^2 + vel_y{k}.^2 + vel_z{k}.^2);
                    vel_time{k} = t_seconds(2:end);

                    % Filter Velocity
                    filtered_vel_x{k} = sgolayfilt(vel_x{k}, polynomial_order, window_size);
                    filtered_vel_y{k} = sgolayfilt(vel_y{k}, polynomial_order, window_size);
                    filtered_vel_z{k} = sgolayfilt(vel_z{k}, polynomial_order, window_size);

%                     %% CLEAN THIS PART
%                     acc_notFiltered = diff(vel_x{k}) ./ diff(t_seconds(1:end-1));
%                     acc_Filtered = diff(filtered_vel_x{k}) ./ diff(t_seconds(1:end-1));
% 
%                     if i == 1 && j == 1
%                         figure
%                         plot(t_seconds(1: end-2), acc_notFiltered)
%                         hold on
%                         plot(t_seconds(1: end-2), acc_Filtered)
%                         legend("No Filter", "Yes Filter")
%                     end
%%
%                     if k == 1
%                         figure
%                         
%                         plot(Trial.Time, Trial.X)
%                         hold on
%                         plot(t_seconds(1: end-1), vel_x{k})
%                         length(Trial.Time)
%                     end
                    % Calculate acceleration
                    acc_x{k} = diff(filtered_vel_x{k}) ./ diff(t_seconds(1:end-1)); % Acceleration in the x dimension
                    acc_y{k} = diff(filtered_vel_y{k}) ./ diff(t_seconds(1:end-1)); % Acceleration in the y dimension
                    acc_z{k} = diff(filtered_vel_z{k}) ./ diff(t_seconds(1:end-1)); % Acceleration in the z dimension
                    acc_overall{k} = sqrt(acc_x{k}.^2 + acc_y{k}.^2 + acc_z{k}.^2);
                    acc_time{k} = t_seconds(3:end);

                    % Filter Acceleration
                    filtered_acc_x{k} = sgolayfilt(acc_x{k}, polynomial_order, window_size);
                    filtered_acc_y{k} = sgolayfilt(acc_y{k}, polynomial_order, window_size);
                    filtered_acc_z{k} = sgolayfilt(acc_z{k}, polynomial_order, window_size);
                    
                    % Calculate jerk
                    jerk_x{k} = diff(acc_x{k}) ./ diff(t_seconds(1:end-2)); % Jerk in the x dimension
                    jerk_y{k} = diff(acc_y{k}) ./ diff(t_seconds(1:end-2)); % Jerk in the y dimension
                    jerk_z{k} = diff(acc_z{k}) ./ diff(t_seconds(1:end-2)); % Jerk in the z dimension
                    jerk_overall{k} = sqrt(jerk_x{k}.^2 + jerk_y{k}.^2 + jerk_z{k}.^2);
                    jerk_time{k} = t_seconds(4:end);

%                     vel_x{k}
                    % find the mean and std of each trial
                    velocity_x_mean = mean(vel_x{k});
                    if velocity_x_mean == inf
                        vel_x{k};
                    end
                    velocity_x_std{k} = std(vel_x{k});
        
                    velocity_y_mean{k} = mean(vel_y{k});
                    velocity_y_std{k} = std(vel_y{k});
            
                    velocity_z_mean{k} = mean(vel_z{k});
                    velocity_z_std{k} = std(vel_z{k});
            
                    velocity_overall_mean{k} = mean(vel_overall{k});
                    velocity_overall_std{k} = std(vel_overall{k});
                    
                    acceleration_x_mean{k} = mean(acc_x{k});
                    acceleration_x_std{k} = std(acc_x{k});
            
                    acceleration_y_mean{k} = mean(acc_y{k});
                    acceleration_y_std{k} = std(acc_y{k});
            
                    acceleration_z_mean{k} = mean(acc_z{k});
                    acceleration_z_std{k} = std(acc_z{k});
            
                    acceleration_overall_mean{k} = mean(acc_overall{k});
                    acceleration_overall_std{k} = std(acc_overall{k});
            
                    jerk_x_mean{k} = mean(jerk_x{k});
                    jerk_x_std{k} = std(jerk_x{k});
            
                    jerk_y_mean{k} = mean(jerk_y{k});
                    jerk_y_std{k} = std(jerk_y{k});
            
                    jerk_z_mean{k} = mean(jerk_z{k});
                    jerk_z_std{k} = std(jerk_z{k});
            
                    jerk_overall_mean{k} = mean(jerk_overall{k});
                    jerk_overall_std{k} = std(jerk_overall{k});

                    
                    TrajectoryInfo.(GroupNames{i}).(strcat('S', num2str(j))).(ConditionString).(Trials{k}).Velocity = timetable(vel_x{k}, vel_y{k}, vel_z{k}, vel_overall{k}, 'RowTimes', seconds(vel_time{k}), 'VariableNames',{'Vel_X','Vel_Y','Vel_Z', 'Velocity_Overall'});
                    TrajectoryInfo.(GroupNames{i}).(strcat('S', num2str(j))).(ConditionString).(Trials{k}).Acceleration = timetable(acc_x{k}, acc_y{k}, acc_z{k}, acc_overall{k}, 'RowTimes', seconds(acc_time{k}), 'VariableNames',{'Acc_X','Acc_Y','Acc_Z', 'Acceleration_Overall'});
                    TrajectoryInfo.(GroupNames{i}).(strcat('S', num2str(j))).(ConditionString).(Trials{k}).Jerk = timetable(jerk_x{k}, jerk_y{k}, jerk_z{k}, jerk_overall{k}, 'RowTimes', seconds(jerk_time{k}), 'VariableNames',{'Jerk_X','Jerk_Y','Jerk_Z', 'Jerk_Overall'});
                    vel_x = {};
                    vel_y = {};
                    vel_z = {};
                    vel_overall = {};
                    
                    acc_x = {};
                    acc_y = {};
                    acc_z = {};
                    acc_overall = {};
                    
                    jerk_x = {};
                    jerk_y = {};
                    jerk_z = {};
                    jerk_overall = {};
                end
            end
        end
    end
end

