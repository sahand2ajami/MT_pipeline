function delsys = emg_csv_2_mat(path)

ax = readmatrix(path);
    start_time_index = 117;

    %% acc time table generation
    acc_time_x = ax(start_time_index:end,3:14:end);
    acc_time_y = ax(start_time_index:end,5:14:end);
    acc_time_z = ax(start_time_index:end,7:14:end);

    gyro_time_x = ax(start_time_index:end,9:14:end);
    gyro_time_y = ax(start_time_index:end,11:14:end);
    gyro_time_z = ax(start_time_index:end,13:14:end);

    imu_time = [acc_time_x acc_time_y acc_time_z gyro_time_x gyro_time_y gyro_time_z];
    % check if time vector is consistent across all acc and gyro data columns
    if rank(nancov(imu_time)) ~= 1
        error('non consistent time across Delsys IMU');
    else
        end_time_index = find(isnan(imu_time(:,1)),1)-1;
        imu_time = imu_time(1:end_time_index,1);
    end

    acc_x = ax(1:end_time_index,4:14:end);
    acc_y = ax(1:end_time_index,6:14:end);
    acc_z = ax(1:end_time_index,8:14:end);

    gyro_x = ax(1:end_time_index,10:14:end);
    gyro_y = ax(1:end_time_index,12:14:end);
    gyro_z = ax(1:end_time_index,14:14:end);
    % generate the imu time table
    delsys.imu = timetable(acc_x,acc_y,acc_z,gyro_x,gyro_y,gyro_z,'RowTimes',seconds(imu_time));
    %% emg time table generation
    emg_time = ax(start_time_index:end,1:14:end);
    emg_time_nm = mean(emg_time, 2, 'omitnan');
    % check if time vector is consistent across all emg data columns
    if rank(nancov(emg_time)) ~= 1
        error('non consistent time across Delsys IMU');
    else
        emg_time = emg_time(:,1);
    end
    emg_time_c = fillgaps(emg_time,100,1);
    
%     scatter(1:length(emg_time),emg_time, 'filled');
%     hold on; 
%     scatter(1:length(emg_time),emg_time_c, 'filled',SizeData=2);
    emg = ax(start_time_index:end,2:14:end);
    % generate the imu time table
    delsys.emg = timetable(emg,'RowTimes',seconds(emg_time_nm));
end

