clc, clear, close all
%%

n_withhaptics = 11;
n_withouthaptics = 11;

cd('C:\Users\s2ajami\OneDrive - University of Waterloo\MT project\DataAnalysis\mt_pipeline\Questionnaire\Data')

% Define the path to your Excel file
excelFilePath = 'QuestionnaireData.xlsx';

% Get sheet names from the Excel file
[~, sheetNames] = xlsfinfo(excelFilePath);


% global PresenceData
% global NasaData
% global BodyData 

PresenceData = struct();
NasaData = struct();
BodyData = struct();

WithHapticsCounter = 1;
WithoutHapticsCounter = 1;
%%
tic
% Loop through each sheet and read specific cells
for sheetIndex = 1:numel(sheetNames)
    sheetName = sheetNames{sheetIndex};
    
    BodyData = ReadExcel(BodyData, excelFilePath, 'D11:F11', 'BodyOwnership', 'Baseline', sheetName);
    BodyData = ReadExcel(BodyData, excelFilePath, 'D21:F21', 'BodyOwnership', 'Train', sheetName);
    BodyData = ReadExcel(BodyData, excelFilePath, 'D31:F31', 'BodyOwnership', 'Test', sheetName);

    BodyData = ReadExcel(BodyData, excelFilePath, 'D13:G13', 'Agency', 'Baseline', sheetName);
    BodyData = ReadExcel(BodyData, excelFilePath, 'D23:G23', 'Agency', 'Train', sheetName);
    BodyData = ReadExcel(BodyData, excelFilePath, 'D33:G33', 'Agency', 'Test', sheetName);

    BodyData = ReadExcel(BodyData, excelFilePath, 'D15:G15', 'Tactile', 'Baseline', sheetName);
    BodyData = ReadExcel(BodyData, excelFilePath, 'D25:G25', 'Tactile', 'Train', sheetName);
    BodyData = ReadExcel(BodyData, excelFilePath, 'D35:G35', 'Tactile', 'Test', sheetName);

    BodyData = ReadExcel(BodyData, excelFilePath, 'D17:F17', 'Location', 'Baseline', sheetName);
    BodyData = ReadExcel(BodyData, excelFilePath, 'D27:F27', 'Location', 'Train', sheetName);
    BodyData = ReadExcel(BodyData, excelFilePath, 'D37:F37', 'Location', 'Test', sheetName);

    BodyData = ReadExcel(BodyData, excelFilePath, 'D19:G19', 'ExternalAppearance', 'Baseline', sheetName);
    BodyData = ReadExcel(BodyData, excelFilePath, 'D29:G29', 'ExternalAppearance', 'Train', sheetName);
    BodyData = ReadExcel(BodyData, excelFilePath, 'D39:G39', 'ExternalAppearance', 'Test', sheetName);
    
    NasaData = ReadExcel(NasaData, excelFilePath, 'C7:H7', 'Category', 'Baseline', sheetName);
    NasaData = ReadExcel(NasaData, excelFilePath, 'C8:H8', 'Category', 'Train', sheetName);
    NasaData = ReadExcel(NasaData, excelFilePath, 'C9:H9', 'Category', 'Test', sheetName);
end
toc
%%

%%

% OwnershipScore
scoreData = [];
variable_names = {'Group', 'Condition', 'Score'};
condition_temp = {};
BodyScoreTable = table({}, {}, scoreData, 'VariableNames', variable_names);
    groupname_temp = cell('');
    condition_temp = cell('');

GroupNames = fieldnames(BodyData);
% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    SubCategory = BodyData.(GroupNames{i});

    % This loops in each participant of each group - Baseline
    for j = 1:length(fieldnames(SubCategory.BodyOwnership.Baseline))
        subjects = SubCategory.BodyOwnership.Baseline;
        subjectID = (fieldnames(subjects));

        
        Answers = subjects.(subjectID{j});
        
        BaselineBodyanswers{i, j} = subjects.(subjectID{j});
        BaselineBodyScore{i, j} = Answers(1) - Answers(2) - Answers(3);

        groupname_temp = cell('');
        condition_temp = cell('');
        condition_temp = [condition_temp; 'Baseline'];
        groupname_temp = [groupname_temp; GroupNames{i}];

        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, BaselineBodyScore{i, j}, ...
            'VariableNames', variable_names);
        
        BodyScoreTable = [BodyScoreTable; newTable];
    end

    % This loops in each participant of each group - Train
    for j = 1:length(fieldnames(SubCategory.BodyOwnership.Train))
        subjects = SubCategory.BodyOwnership.Train;
        subjectID = (fieldnames(subjects));
        Answers = subjects.(subjectID{j});
        TrainBodyanswers{i, j} = subjects.(subjectID{j});
        TrainBodyScore{i, j} = Answers(1) - Answers(2) - Answers(3);

        groupname_temp = cell('');
        condition_temp = cell('');
        condition_temp = [condition_temp; 'Train'];
        groupname_temp = [groupname_temp; GroupNames{i}];

        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, TrainBodyScore{i, j}, ...
            'VariableNames', variable_names);
        
        BodyScoreTable = [BodyScoreTable; newTable];
    end

    % This loops in each participant of each group - Test
    for j = 1:length(fieldnames(SubCategory.BodyOwnership.Test))
        subjects = SubCategory.BodyOwnership.Test;
        subjectID = (fieldnames(subjects));
        Answers = subjects.(subjectID{j});
        TestBodyanswers{i, j} = subjects.(subjectID{j});
        TestBodyScore{i, j} = Answers(1) - Answers(2) - Answers(3);

        groupname_temp = cell('');
        condition_temp = cell('');
        condition_temp = [condition_temp; 'Test'];
        groupname_temp = [groupname_temp; GroupNames{i}];

        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, TestBodyScore{i, j}, ...
            'VariableNames', variable_names);
        
        BodyScoreTable = [BodyScoreTable; newTable];
    end
end

% Create categorical array for x-axis labels with desired order
BodyScoreTable.Condition = categorical(BodyScoreTable.Condition);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
BodyScoreTable.Condition = reordercats(BodyScoreTable.Condition, desiredOrder);


figure
    centre = [1, 2.75, 4.5];
    bias = 0.3;
    x_data1 = [(centre(1) - bias) * ones(1, 11), (centre(2) - bias) * ones(1, 11), (centre(3) - bias) * ones(1, 11)];
%     x_data1 = repmat(x_data1, 1, 11);
%     x_data2 = centre + bias;
    x_data2 = [(centre(1) + bias) * ones(1, 11), (centre(2) + bias) * ones(1, 11), (centre(3) + bias) * ones(1, 11)];
%     x_data2 = repmat(x_data2, 1, 11);
    % x_data2 = repmat(x_data1, 1, 11);
    y_data1 = BodyScoreTable.Score(1:33);
    y_data2 = BodyScoreTable.Score(34:end);
    score_boxchart = boxchart(x_data1, y_data1);
    hold on
    boxchart(x_data2, y_data2)
    score_boxchart.Parent.XTick = centre;
    score_boxchart.Parent.XTickLabel = {'Baseline','Train','Test'};
    score_boxchart.Parent.YLim = [-9.5 10];
    score_boxchart.Parent.YTick
    score_boxchart.Parent.YTick = score_boxchart.Parent.YTick(1:end-1);

    score_legend = legend("WithHaptics","WithoutHaptics");
    excludeIndex = 2;
    legendEntries = score_legend.EntryContainer.Children;
    legendEntries(3:end) = [];
    score_legend.String = {'WithHaptics', 'WithoutHaptics'};
    score_legend.Location = 'best';
    title('Body Ownership');
    ylabel('Score');
    
    xlabel('Conditions');

    bias2 = 0.02;
    StatisticalLines(centre(1) - bias, centre(2) - bias, '*', 9.5, 0.2, 2, score_legend)
    
%% Statistical test on Body Ownership
    
with_haptics_baseline_body = BodyScoreTable((strcmp(BodyScoreTable.Group, 'WithHaptics') & BodyScoreTable.Condition == 'Baseline'), :);
with_haptics_train_body = BodyScoreTable((strcmp(BodyScoreTable.Group, 'WithHaptics') & BodyScoreTable.Condition == 'Train'), :);
with_haptics_test_body = BodyScoreTable((strcmp(BodyScoreTable.Group, 'WithHaptics') & BodyScoreTable.Condition == 'Test'), :);

without_haptics_baseline_body = BodyScoreTable((strcmp(BodyScoreTable.Group, 'WithoutHaptics') & BodyScoreTable.Condition == 'Baseline'), :);
without_haptics_train_body = BodyScoreTable((strcmp(BodyScoreTable.Group, 'WithoutHaptics') & BodyScoreTable.Condition == 'Train'), :);
without_haptics_test_body = BodyScoreTable((strcmp(BodyScoreTable.Group, 'WithoutHaptics') & BodyScoreTable.Condition == 'Test'), :);

with_haptics_baseline_body = with_haptics_baseline_body.Score;
with_haptics_train_body = with_haptics_train_body.Score;
with_haptics_test_body = with_haptics_test_body.Score;

without_haptics_baseline_body = without_haptics_baseline_body.Score;
without_haptics_train_body = without_haptics_train_body.Score;
without_haptics_test_body = without_haptics_test_body.Score;

clc
disp('WithHapticsBaseline vs. WithHapticsTrain:')
[p, hStat, stats] = ranksum(with_haptics_baseline_body, with_haptics_train_body)


%%

% Agency and Motor Control
scoreData = [];
variable_names = {'Group', 'Condition', 'Score'};
condition_temp = {};
AgencyScoreTable = table({}, {}, scoreData, 'VariableNames', variable_names);
    groupname_temp = cell('');
    condition_temp = cell('');

GroupNames = fieldnames(BodyData);
% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    SubCategory = BodyData.(GroupNames{i});

    % This loops in each participant of each group - Baseline
    for j = 1:length(fieldnames(SubCategory.Agency.Baseline))
        subjects = SubCategory.Agency.Baseline;
        subjectID = (fieldnames(subjects));

        Answers = subjects.(subjectID{j});
        BaselineAgencyanswers{i, j} = subjects.(subjectID{j});
        BaselineAgencyScore{i, j} = Answers(1) + Answers(2) + Answers(3) - Answers(4);

        groupname_temp = cell('');
        condition_temp = cell('');
        condition_temp = [condition_temp; 'Baseline'];
        groupname_temp = [groupname_temp; GroupNames{i}];

        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, BaselineAgencyScore{i, j}, ...
            'VariableNames', variable_names);
        
        AgencyScoreTable = [AgencyScoreTable; newTable];
    end

    % This loops in each participant of each group - Train
    for j = 1:length(fieldnames(SubCategory.Agency.Train))
        subjects = SubCategory.Agency.Train;
        subjectID = (fieldnames(subjects));
        Answers = subjects.(subjectID{j});
        TrainAgencyanswers{i, j} = subjects.(subjectID{j});
        TrainAgencyScore{i, j} = Answers(1) + Answers(2) + Answers(3) - Answers(4);

        groupname_temp = cell('');
        condition_temp = cell('');
        condition_temp = [condition_temp; 'Train'];
        groupname_temp = [groupname_temp; GroupNames{i}];

        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, TrainAgencyScore{i, j}, ...
            'VariableNames', variable_names);
        
        AgencyScoreTable = [AgencyScoreTable; newTable];
    end

    % This loops in each participant of each group - Test
    for j = 1:length(fieldnames(SubCategory.Agency.Test))
        subjects = SubCategory.Agency.Test;
        subjectID = (fieldnames(subjects));
        Answers = subjects.(subjectID{j});
        TestAgencyanswers{i, j} = subjects.(subjectID{j});
        TestAgencyScore{i, j} = Answers(1) + Answers(2) + Answers(3) - Answers(4);

        groupname_temp = cell('');
        condition_temp = cell('');
        condition_temp = [condition_temp; 'Test'];
        groupname_temp = [groupname_temp; GroupNames{i}];

        % Make the table to have data of all conditions together
        newTable = table(groupname_temp, condition_temp, TestAgencyScore{i, j}, ...
            'VariableNames', variable_names);
        
        AgencyScoreTable = [AgencyScoreTable; newTable];
    end
end

% Create categorical array for x-axis labels with desired order
AgencyScoreTable.Condition = categorical(AgencyScoreTable.Condition);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
AgencyScoreTable.Condition = reordercats(AgencyScoreTable.Condition, desiredOrder);

figure
    centre = [1, 2.75, 4.5];
    bias = 0.3;
    x_data1 = [(centre(1) - bias) * ones(1, 11), (centre(2) - bias) * ones(1, 11), (centre(3) - bias) * ones(1, 11)];
%     x_data1 = repmat(x_data1, 1, 11);
%     x_data2 = centre + bias;
    x_data2 = [(centre(1) + bias) * ones(1, 11), (centre(2) + bias) * ones(1, 11), (centre(3) + bias) * ones(1, 11)];
%     x_data2 = repmat(x_data2, 1, 11);
    % x_data2 = repmat(x_data1, 1, 11);
    y_data1 = AgencyScoreTable.Score(1:33);
    y_data2 = AgencyScoreTable.Score(34:end);
    score_boxchart = boxchart(x_data1, y_data1);
    hold on
    boxchart(x_data2, y_data2)
    score_boxchart.Parent.XTick = centre;
    score_boxchart.Parent.XTickLabel = {'Baseline','Train','Test'};

    score_legend = legend("WithHaptics","WithoutHaptics");
    excludeIndex = 2;
    legendEntries = score_legend.EntryContainer.Children;
    legendEntries(3:end) = [];
    score_legend.String = {'WithHaptics', 'WithoutHaptics'};
    score_legend.Location = 'best';
    title('Agency and Motor Control');
    ylabel('Score');
    ylim([-12, +12])
    xlabel('Conditions');
    
%% Statistical test on Agency and Motor Control
    
with_haptics_baseline_agency = AgencyScoreTable((strcmp(AgencyScoreTable.Group, 'WithHaptics') & AgencyScoreTable.Condition == 'Baseline'), :);
with_haptics_train_agency = AgencyScoreTable((strcmp(AgencyScoreTable.Group, 'WithHaptics') & AgencyScoreTable.Condition == 'Train'), :);
with_haptics_test_agency = AgencyScoreTable((strcmp(AgencyScoreTable.Group, 'WithHaptics') & AgencyScoreTable.Condition == 'Test'), :);

without_haptics_baseline_agency = AgencyScoreTable((strcmp(AgencyScoreTable.Group, 'WithoutHaptics') & AgencyScoreTable.Condition == 'Baseline'), :);
without_haptics_train_agency = AgencyScoreTable((strcmp(AgencyScoreTable.Group, 'WithoutHaptics') & AgencyScoreTable.Condition == 'Train'), :);
without_haptics_test_agency = AgencyScoreTable((strcmp(AgencyScoreTable.Group, 'WithoutHaptics') & AgencyScoreTable.Condition == 'Test'), :);

with_haptics_baseline_agency = with_haptics_baseline_agency.Score;
with_haptics_train_agency = with_haptics_train_agency.Score;
with_haptics_test_agency = with_haptics_test_agency.Score;

without_haptics_baseline_agency = without_haptics_baseline_agency.Score;
without_haptics_train_agency = without_haptics_train_agency.Score;
without_haptics_test_agency = without_haptics_test_agency.Score;

% clc
% disp('WithHapticsBaseline vs. WithHapticsTrain:')
% [p, hStat, stats] = ranksum(without_haptics_test_agency, without_haptics_train_agency)
%%
% Tactile Sensation

scoreData = [];
variable_names = {'Group', 'Condition', 'Score'};
condition_temp = {};
TactileScoreTable = table({}, {}, scoreData, 'VariableNames', variable_names);
    groupname_temp = cell('');
    condition_temp = cell('');

GroupNames = fieldnames(BodyData);
% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    SubCategory = BodyData.(GroupNames{i});

    % This loops in each participant of each group - Baseline
    for j = 1:length(fieldnames(SubCategory.Tactile.Baseline))
        subjects = SubCategory.Tactile.Baseline;
        subjectID = (fieldnames(subjects));

        Answers = subjects.(subjectID{j});
        if ~isempty(Answers)
            BaselineTactileanswers{i, j} = subjects.(subjectID{j});
            BaselineTactileScore{i, j} = Answers(1) - Answers(2) + Answers(3) + Answers(4);
            groupname_temp = cell('');
            condition_temp = cell('');
            condition_temp = [condition_temp; 'Baseline'];
            groupname_temp = [groupname_temp; GroupNames{i}];
    
            % Make the table to have data of all conditions together
            newTable = table(groupname_temp, condition_temp, BaselineTactileScore{i, j}, ...
                'VariableNames', variable_names);
            
            TactileScoreTable = [TactileScoreTable; newTable];
        end
        
    end

    % This loops in each participant of each group - Train
    for j = 1:length(fieldnames(SubCategory.Tactile.Train))
        subjects = SubCategory.Tactile.Train;
        subjectID = (fieldnames(subjects));
        Answers = subjects.(subjectID{j});
        if ~isempty(Answers)
            TrainTactileanswers{i, j} = subjects.(subjectID{j});
            TrainTactileScore{i, j} = Answers(1) - Answers(2) + Answers(3) + Answers(4);
            groupname_temp = cell('');
            condition_temp = cell('');
            condition_temp = [condition_temp; 'Train'];
            groupname_temp = [groupname_temp; GroupNames{i}];
    
            % Make the table to have data of all conditions together
            newTable = table(groupname_temp, condition_temp, TrainTactileScore{i, j}, ...
                'VariableNames', variable_names);
            
            TactileScoreTable = [TactileScoreTable; newTable];
        end
        
    end

    % This loops in each participant of each group - Test
    for j = 1:length(fieldnames(SubCategory.Tactile.Test))
        subjects = SubCategory.Tactile.Test;
        subjectID = (fieldnames(subjects));
        Answers = subjects.(subjectID{j});
        if ~isempty(Answers)
            TestTactileanswers{i, j} = subjects.(subjectID{j});
            TestTactileScore{i, j} = Answers(1) - Answers(2) + Answers(3) + Answers(4);
            groupname_temp = cell('');
            condition_temp = cell('');
            condition_temp = [condition_temp; 'Test'];
            groupname_temp = [groupname_temp; GroupNames{i}];
    
            % Make the table to have data of all conditions together
            newTable = table(groupname_temp, condition_temp, TestTactileScore{i, j}, ...
                'VariableNames', variable_names);
            
            TactileScoreTable = [TactileScoreTable; newTable];
        end
        
    end
end

% Create categorical array for x-axis labels with desired order
TactileScoreTable.Condition = categorical(TactileScoreTable.Condition);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
TactileScoreTable.Condition = reordercats(TactileScoreTable.Condition, desiredOrder);


figure
    centre = [1, 2.75, 4.5];
    bias = 0.3;
    x_data1 = [(centre(1) - bias) * ones(1, 11), (centre(2) - bias) * ones(1, 11), (centre(3) - bias) * ones(1, 11)];
%     x_data1 = repmat(x_data1, 1, 11);
%     x_data2 = centre + bias;
    x_data2 = [(centre(1) + bias) * ones(1, 11), (centre(2) + bias) * ones(1, 11), (centre(3) + bias) * ones(1, 11)];
%     x_data2 = repmat(x_data2, 1, 11);
    % x_data2 = repmat(x_data1, 1, 11);
    y_data1 = TactileScoreTable.Score(1:33);
    y_data2 = TactileScoreTable.Score(34:end);
    score_boxchart = boxchart(x_data1, y_data1);
    hold on
    boxchart(x_data2, y_data2)
    score_boxchart.Parent.XTick = centre;
    score_boxchart.Parent.XTickLabel = {'Baseline','Train','Test'};

    score_legend = legend("WithHaptics","WithoutHaptics");
    excludeIndex = 2;
    legendEntries = score_legend.EntryContainer.Children;
    legendEntries(3:end) = [];
    score_legend.String = {'WithHaptics', 'WithoutHaptics'};
    score_legend.Location = 'best';
    title('Tactile Sensation');
    ylabel('Score');
    ylim([-12, +12])
    xlabel('Conditions');

    bias2 = 0.02;
    StatisticalLines(centre(2) - bias, centre(2) + bias, '*', 10, 0.2, 2, score_legend)
    StatisticalLines(centre(3) - bias, centre(3) + bias, '*', 10, 0.2, 2, score_legend)
%% Statistical test on Agency and Motor Control
    
with_haptics_baseline_tactile = TactileScoreTable((strcmp(TactileScoreTable.Group, 'WithHaptics') & TactileScoreTable.Condition == 'Baseline'), :);
with_haptics_train_tactile = TactileScoreTable((strcmp(TactileScoreTable.Group, 'WithHaptics') & TactileScoreTable.Condition == 'Train'), :);
with_haptics_test_tactile = TactileScoreTable((strcmp(TactileScoreTable.Group, 'WithHaptics') & TactileScoreTable.Condition == 'Test'), :);

without_haptics_baseline_tactile = TactileScoreTable((strcmp(TactileScoreTable.Group, 'WithoutHaptics') & TactileScoreTable.Condition == 'Baseline'), :);
without_haptics_train_tactile = TactileScoreTable((strcmp(TactileScoreTable.Group, 'WithoutHaptics') & TactileScoreTable.Condition == 'Train'), :);
without_haptics_test_tactile = TactileScoreTable((strcmp(TactileScoreTable.Group, 'WithoutHaptics') & TactileScoreTable.Condition == 'Test'), :);

with_haptics_baseline_tactile = with_haptics_baseline_tactile.Score;
with_haptics_train_tactile = with_haptics_train_tactile.Score;
with_haptics_test_tactile = with_haptics_test_tactile.Score;

without_haptics_baseline_tactile = without_haptics_baseline_tactile.Score;
without_haptics_train_tactile = without_haptics_train_tactile.Score;
without_haptics_test_tactile = without_haptics_test_tactile.Score;

clc
disp('Tactile Sensation')
disp('-----------------')
disp('WithHapticsTrain vs. WithoutHapticsTrain:')
[p, hStat, stats] = ranksum(without_haptics_train_tactile, with_haptics_train_tactile)

disp('WithHapticsTest vs. WithoutHapticsTest:')
[p, hStat, stats] = ranksum(without_haptics_test_tactile, with_haptics_test_tactile)


%% Location of the body

scoreData = [];
variable_names = {'Group', 'Condition', 'Score'};
condition_temp = {};
LocationScoreTable = table({}, {}, scoreData, 'VariableNames', variable_names);
    groupname_temp = cell('');
    condition_temp = cell('');


GroupNames = fieldnames(BodyData);
% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    SubCategory = BodyData.(GroupNames{i});

    % This loops in each participant of each group - Baseline
    for j = 1:length(fieldnames(SubCategory.Location.Baseline))
        subjects = SubCategory.Location.Baseline;
        subjectID = (fieldnames(subjects));

        Answers = subjects.(subjectID{j});
        if ~isempty(Answers)
            BaselineLocationanswers{i, j} = subjects.(subjectID{j});
            BaselineLocationScore{i, j} = Answers(1) - Answers(2) + Answers(3);
            groupname_temp = cell('');
            condition_temp = cell('');
            condition_temp = [condition_temp; 'Baseline'];
            groupname_temp = [groupname_temp; GroupNames{i}];
    
            % Make the table to have data of all conditions together
            newTable = table(groupname_temp, condition_temp, BaselineLocationScore{i, j}, ...
                'VariableNames', variable_names);
            
            LocationScoreTable = [LocationScoreTable; newTable];
        end
        
    end

    % This loops in each participant of each group - Train
    for j = 1:length(fieldnames(SubCategory.Location.Train))
        subjects = SubCategory.Location.Train;
        subjectID = (fieldnames(subjects));
        Answers = subjects.(subjectID{j});
        if ~isempty(Answers)
            TrainLocationanswers{i, j} = subjects.(subjectID{j});
            TrainLocationScore{i, j} = Answers(1) - Answers(2) + Answers(3);
            groupname_temp = cell('');
            condition_temp = cell('');
            condition_temp = [condition_temp; 'Train'];
            groupname_temp = [groupname_temp; GroupNames{i}];
    
            % Make the table to have data of all conditions together
            newTable = table(groupname_temp, condition_temp, TrainLocationScore{i, j}, ...
                'VariableNames', variable_names);
            
            LocationScoreTable = [LocationScoreTable; newTable];
        end
        
    end

    % This loops in each participant of each group - Test
    for j = 1:length(fieldnames(SubCategory.Location.Test))
        subjects = SubCategory.Location.Test;
        subjectID = (fieldnames(subjects));
        Answers = subjects.(subjectID{j});
        if ~isempty(Answers)
            TestLocationanswers{i, j} = subjects.(subjectID{j});
            TestLocationScore{i, j} = Answers(1) - Answers(2) + Answers(3);
            groupname_temp = cell('');
            condition_temp = cell('');
            condition_temp = [condition_temp; 'Test'];
            groupname_temp = [groupname_temp; GroupNames{i}];
    
            % Make the table to have data of all conditions together
            newTable = table(groupname_temp, condition_temp, TestLocationScore{i, j}, ...
                'VariableNames', variable_names);
            
            LocationScoreTable = [LocationScoreTable; newTable];
        end
        
    end
end

% Create categorical array for x-axis labels with desired order
LocationScoreTable.Condition = categorical(LocationScoreTable.Condition);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
LocationScoreTable.Condition = reordercats(LocationScoreTable.Condition, desiredOrder);

figure
    centre = [1, 2.75, 4.5];
    bias = 0.3;
    x_data1 = [(centre(1) - bias) * ones(1, 11), (centre(2) - bias) * ones(1, 11), (centre(3) - bias) * ones(1, 11)];
%     x_data1 = repmat(x_data1, 1, 11);
%     x_data2 = centre + bias;
    x_data2 = [(centre(1) + bias) * ones(1, 11), (centre(2) + bias) * ones(1, 11), (centre(3) + bias) * ones(1, 11)];
%     x_data2 = repmat(x_data2, 1, 11);
    % x_data2 = repmat(x_data1, 1, 11);
    y_data1 = LocationScoreTable.Score(1:33);
    y_data2 = LocationScoreTable.Score(34:end);
    score_boxchart = boxchart(x_data1, y_data1);
    hold on
    boxchart(x_data2, y_data2)
    score_boxchart.Parent.XTick = centre;
    score_boxchart.Parent.XTickLabel = {'Baseline','Train','Test'};

    score_legend = legend("WithHaptics","WithoutHaptics");
    excludeIndex = 2;
    legendEntries = score_legend.EntryContainer.Children;
    legendEntries(3:end) = [];
    score_legend.String = {'WithHaptics', 'WithoutHaptics'};
    score_legend.Location = 'best';
    title('Location of the Body');
    ylabel('Score');
    ylim([-9, +9])
    xlabel('Conditions');

%% External appearance
scoreData = [];
variable_names = {'Group', 'Condition', 'Score'};
condition_temp = {};
ExternalAppearanceScoreTable = table({}, {}, scoreData, 'VariableNames', variable_names);
    groupname_temp = cell('');
    condition_temp = cell('');


GroupNames = fieldnames(BodyData);
% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    SubCategory = BodyData.(GroupNames{i});

    % This loops in each participant of each group - Baseline
    for j = 1:length(fieldnames(SubCategory.ExternalAppearance.Baseline))
        subjects = SubCategory.ExternalAppearance.Baseline;
        subjectID = (fieldnames(subjects));

        Answers = subjects.(subjectID{j});
        if ~isempty(Answers)
            BaselineExternalAppearanceanswers{i, j} = subjects.(subjectID{j});
            BaselineExternalAppearanceScore{i, j} = Answers(1) + Answers(2) + Answers(3) + Answers(4);
            groupname_temp = cell('');
            condition_temp = cell('');
            condition_temp = [condition_temp; 'Baseline'];
            groupname_temp = [groupname_temp; GroupNames{i}];
    
            % Make the table to have data of all conditions together
            newTable = table(groupname_temp, condition_temp, BaselineExternalAppearanceScore{i, j}, ...
                'VariableNames', variable_names);
            
            ExternalAppearanceScoreTable = [ExternalAppearanceScoreTable; newTable];
        end
        
    end

    % This loops in each participant of each group - Train
    for j = 1:length(fieldnames(SubCategory.ExternalAppearance.Train))
        subjects = SubCategory.ExternalAppearance.Train;
        subjectID = (fieldnames(subjects));
        Answers = subjects.(subjectID{j})
        if ~isempty(Answers)
            TrainExternalAppearanceanswers{i, j} = subjects.(subjectID{j});
            TrainExternalAppearanceScore{i, j} = Answers(1) + Answers(2) + Answers(3) + Answers(4);
            groupname_temp = cell('');
            condition_temp = cell('');
            condition_temp = [condition_temp; 'Train'];
            groupname_temp = [groupname_temp; GroupNames{i}];
    
            % Make the table to have data of all conditions together
            newTable = table(groupname_temp, condition_temp, TrainExternalAppearanceScore{i, j}, ...
                'VariableNames', variable_names);
            
            ExternalAppearanceScoreTable = [ExternalAppearanceScoreTable; newTable];
        end
        
    end

    % This loops in each participant of each group - Test
    for j = 1:length(fieldnames(SubCategory.ExternalAppearance.Test))
        subjects = SubCategory.ExternalAppearance.Test;
        subjectID = (fieldnames(subjects));
        Answers = subjects.(subjectID{j});
        if ~isempty(Answers)
            TestExternalAppearanceanswers{i, j} = subjects.(subjectID{j});
            TestExternalAppearanceScore{i, j} = Answers(1) + Answers(2) + Answers(3) + Answers(4);
            groupname_temp = cell('');
            condition_temp = cell('');
            condition_temp = [condition_temp; 'Test'];
            groupname_temp = [groupname_temp; GroupNames{i}];
    
            % Make the table to have data of all conditions together
            newTable = table(groupname_temp, condition_temp, TestExternalAppearanceScore{i, j}, ...
                'VariableNames', variable_names);
            
            ExternalAppearanceScoreTable = [ExternalAppearanceScoreTable; newTable];
        end
    end
end

% Create categorical array for x-axis labels with desired order
ExternalAppearanceScoreTable.Condition = categorical(ExternalAppearanceScoreTable.Condition);

% Define the desired order of x-axis categories
desiredOrder = {'Baseline', 'Train', 'Test'};  % Change the order as needed

% Reorder the unique values in DropPosTable.Condition
ExternalAppearanceScoreTable.Condition = reordercats(ExternalAppearanceScoreTable.Condition, desiredOrder);

figure
    centre = [1, 2.75, 4.5];
    bias = 0.3;
    x_data1 = [(centre(1) - bias) * ones(1, 11), (centre(2) - bias) * ones(1, 11), (centre(3) - bias) * ones(1, 11)];
%     x_data1 = repmat(x_data1, 1, 11);
%     x_data2 = centre + bias;
    x_data2 = [(centre(1) + bias) * ones(1, 11), (centre(2) + bias) * ones(1, 11), (centre(3) + bias) * ones(1, 11)];
%     x_data2 = repmat(x_data2, 1, 11);
    % x_data2 = repmat(x_data1, 1, 11);
    y_data1 = ExternalAppearanceScoreTable.Score(1:33);
    y_data2 = ExternalAppearanceScoreTable.Score(34:end);
    score_boxchart = boxchart(x_data1, y_data1);
    hold on
    boxchart(x_data2, y_data2)
    score_boxchart.Parent.XTick = centre;
    score_boxchart.Parent.XTickLabel = {'Baseline','Train','Test'};

    score_legend = legend("WithHaptics","WithoutHaptics");
    excludeIndex = 2;
    legendEntries = score_legend.EntryContainer.Children;
    legendEntries(3:end) = [];
    score_legend.String = {'WithHaptics', 'WithoutHaptics'};
    score_legend.Location = 'best';
    title('External Appearance');
    ylabel('Score');
    ylim([-12.5, +12])
    xlabel('Conditions');
    
%% NASA-TLX

scoreData = [];
variable_names = {'Group', 'Condition', 'Question', 'Score'};
condition_temp = {};
NASATable = table({}, {}, {}, scoreData, 'VariableNames', variable_names);

question_temp = cell('');
groupname_temp = cell('');
condition_temp = cell('');


GroupNames = fieldnames(NasaData);
% This loops in the "withHaptics" and "withoutHaptics" groups
for i = 1:length(GroupNames)
    % i = 1 WithoutHaptics
    % i = 2 WithHaptics

    SubCategory = NasaData.(GroupNames{i}).Category;
%     Baseline = SubCategory.Baseline;
%     Train = SubCategory.Train;
%     Test = SubCategory.Test;
    
    % Loops through every condition
    for j = 1:length(fieldnames(SubCategory))
        Conditions = fieldnames(SubCategory);
        Condition = SubCategory.(Conditions{j});
        
        for k = 1:length(fieldnames(Condition))
            subjects = fieldnames(Condition);
            answers = Condition.(subjects{k});
            
            % Make the table to have data of all conditions together
            newTable = table(GroupNames(i), Conditions(j), {'Q1'}, answers(1) * (6/21) - 3, ...
                'VariableNames', variable_names);
            
            NASATable = [NASATable; newTable];
            
            % Make the table to have data of all conditions together
            newTable = table(GroupNames(i), Conditions(j), {'Q2'}, answers(2) * (6/21) - 3, ...
                'VariableNames', variable_names);
            
            NASATable = [NASATable; newTable];
            
            % Make the table to have data of all conditions together
            newTable = table(GroupNames(i), Conditions(j), {'Q3'}, answers(3) * (6/21) - 3, ...
                'VariableNames', variable_names);
            
            NASATable = [NASATable; newTable];
            
            % Make the table to have data of all conditions together
            newTable = table(GroupNames(i), Conditions(j), {'Q4'}, answers(4) * (6/21) - 3, ...
                'VariableNames', variable_names);
            
            NASATable = [NASATable; newTable];
            
            % Make the table to have data of all conditions together
            newTable = table(GroupNames(i), Conditions(j), {'Q5'}, answers(5) * (6/21) - 3, ...
                'VariableNames', variable_names);
            
            NASATable = [NASATable; newTable];
            
            % Make the table to have data of all conditions together
            newTable = table(GroupNames(i), Conditions(j), {'Q6'}, answers(6) * (6/21) - 3, ...
                'VariableNames', variable_names);
            
            NASATable = [NASATable; newTable];
        end
    end  
end

% NASATable(NASATable.Group = 'WithHaptics')



%% Plot NASA-TLX
close all
figure
    centre = linspace(1,30,6);
    bias_between_groups = 0.3;
    bias_between_conditions = 1.3;
    bias_between_questions = 0.7;
    color_withhaptics = [0 0.4470 0.7410];
    color_withouthaptics = [0.8500 0.3250 0.0980];

    %%% Q1
    %%%% Baseline
    withhaptics_baseline_q1_x = (centre(1) - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_baseline_q1_x = (centre(1) - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_baseline_q1_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q1", :);
    withhaptics_baseline_q1_ydata = withhaptics_baseline_q1_ytable.Score;
    withouthaptics_baseline_q1_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q1", :);
    withouthaptics_baseline_q1_ydata = withouthaptics_baseline_q1_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_baseline_q1_x, withhaptics_baseline_q1_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;

    hold on
    score_boxchart = boxchart(withouthaptics_baseline_q1_x, withouthaptics_baseline_q1_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    
    %%%% Train
    withhaptics_train_q1_x = (centre(1) - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_train_q1_x = (centre(1) + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_train_q1_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q1", :);
    withhaptics_train_q1_ydata = withhaptics_train_q1_ytable.Score;
    withouthaptics_train_q1_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q1", :);
    withouthaptics_train_q1_ydata = withouthaptics_train_q1_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_train_q1_x, withhaptics_train_q1_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_train_q1_x, withouthaptics_train_q1_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    score_boxchart.Parent.Parent.Units = 'centimeters';
    score_boxchart.Parent.Parent.Position = [10   10   35  12];

    %%%% Test
    withhaptics_test_q1_x = (centre(1) + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_test_q1_x = (centre(1) + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_test_q1_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q1", :);
    withhaptics_test_q1_ydata = withhaptics_test_q1_ytable.Score;
    withouthaptics_test_q1_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q1", :);
    withouthaptics_test_q1_ydata = withouthaptics_test_q1_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_test_q1_x, withhaptics_test_q1_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_test_q1_x, withouthaptics_test_q1_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    %%% Q2
    %%%% Baseline
    withhaptics_baseline_q2_x = (centre(2) - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_baseline_q2_x = (centre(2) - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_baseline_q2_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q2", :);
    withhaptics_baseline_q2_ydata = withhaptics_baseline_q2_ytable.Score;
    withouthaptics_baseline_q2_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q2", :);
    withouthaptics_baseline_q2_ydata = withouthaptics_baseline_q2_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_baseline_q2_x, withhaptics_baseline_q2_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_baseline_q2_x, withouthaptics_baseline_q2_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    %%%% Train
    withhaptics_train_q2_x = (centre(2) - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_train_q2_x = (centre(2) + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_train_q2_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q2", :);
    withhaptics_train_q2_ydata = withhaptics_train_q2_ytable.Score;
    withouthaptics_train_q2_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q2", :);
    withouthaptics_train_q2_ydata = withouthaptics_train_q2_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_train_q2_x, withhaptics_train_q2_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_train_q2_x, withouthaptics_train_q2_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    
    %%%% Test
    withhaptics_test_q2_x = (centre(2) + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_test_q2_x = (centre(2) + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_test_q2_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q2", :);
    withhaptics_test_q2_ydata = withhaptics_test_q2_ytable.Score;
    withouthaptics_test_q2_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q2", :);
    withouthaptics_test_q2_ydata = withouthaptics_test_q2_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_test_q2_x, withhaptics_test_q2_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_test_q2_x, withouthaptics_test_q2_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    %%% Q3
    %%%% Baseline
    withhaptics_baseline_q3_x = (centre(3) - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_baseline_q3_x = (centre(3) - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_baseline_q3_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q3", :);
    withhaptics_baseline_q3_ydata = withhaptics_baseline_q3_ytable.Score;
    withouthaptics_baseline_q3_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q3", :);
    withouthaptics_baseline_q3_ydata = withouthaptics_baseline_q3_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_baseline_q3_x, withhaptics_baseline_q3_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_baseline_q3_x, withouthaptics_baseline_q3_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    %%%% Train
    withhaptics_train_q3_x = (centre(3) - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_train_q3_x = (centre(3) + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_train_q3_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q3", :);
    withhaptics_train_q3_ydata = withhaptics_train_q3_ytable.Score;
    withouthaptics_train_q3_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q3", :);
    withouthaptics_train_q3_ydata = withouthaptics_train_q3_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_train_q3_x, withhaptics_train_q3_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_train_q3_x, withouthaptics_train_q3_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    
    %%%% Test
    withhaptics_test_q3_x = (centre(3) + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_test_q3_x = (centre(3) + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_test_q3_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q3", :);
    withhaptics_test_q3_ydata = withhaptics_test_q3_ytable.Score;
    withouthaptics_test_q3_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q3", :);
    withouthaptics_test_q3_ydata = withouthaptics_test_q3_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_test_q3_x, withhaptics_test_q3_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_test_q3_x, withouthaptics_test_q3_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    %%% Q4
    %%%% Baseline
    withhaptics_baseline_q4_x = (centre(4) - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_baseline_q4_x = (centre(4) - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_baseline_q4_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q4", :);
    withhaptics_baseline_q4_ydata = withhaptics_baseline_q4_ytable.Score;
    withouthaptics_baseline_q4_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q4", :);
    withouthaptics_baseline_q4_ydata = withouthaptics_baseline_q4_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_baseline_q4_x, withhaptics_baseline_q4_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_baseline_q4_x, withouthaptics_baseline_q4_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    %%%% Train
    withhaptics_train_q4_x = (centre(4) - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_train_q4_x = (centre(4) + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_train_q4_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q4", :);
    withhaptics_train_q4_ydata = withhaptics_train_q4_ytable.Score;
    withouthaptics_train_q4_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q4", :);
    withouthaptics_train_q4_ydata = withouthaptics_train_q4_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_train_q4_x, withhaptics_train_q4_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_train_q4_x, withouthaptics_train_q4_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    
    %%%% Test
    withhaptics_test_q4_x = (centre(4) + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_test_q4_x = (centre(4) + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_test_q4_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q4", :);
    withhaptics_test_q4_ydata = withhaptics_test_q4_ytable.Score;
    withouthaptics_test_q4_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q4", :);
    withouthaptics_test_q4_ydata = withouthaptics_test_q4_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_test_q4_x, withhaptics_test_q4_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_test_q4_x, withouthaptics_test_q4_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    %%% Q5
    %%%% Baseline
    withhaptics_baseline_q5_x = (centre(5) - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_baseline_q5_x = (centre(5) - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_baseline_q5_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q5", :);
    withhaptics_baseline_q5_ydata = withhaptics_baseline_q5_ytable.Score;
    withouthaptics_baseline_q5_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q5", :);
    withouthaptics_baseline_q5_ydata = withouthaptics_baseline_q5_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_baseline_q5_x, withhaptics_baseline_q5_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_baseline_q5_x, withouthaptics_baseline_q5_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    %%%% Train
    withhaptics_train_q5_x = (centre(5) - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_train_q5_x = (centre(5) + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_train_q5_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q5", :);
    withhaptics_train_q5_ydata = withhaptics_train_q5_ytable.Score;
    withouthaptics_train_q5_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q5", :);
    withouthaptics_train_q5_ydata = withouthaptics_train_q5_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_train_q5_x, withhaptics_train_q5_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_train_q5_x, withouthaptics_train_q5_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    
    %%%% Test
    withhaptics_test_q5_x = (centre(5) + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_test_q5_x = (centre(5) + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_test_q5_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q5", :);
    withhaptics_test_q5_ydata = withhaptics_test_q5_ytable.Score;
    withouthaptics_test_q5_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q5", :);
    withouthaptics_test_q5_ydata = withouthaptics_test_q5_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_test_q5_x, withhaptics_test_q5_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_test_q5_x, withouthaptics_test_q5_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;


    %%% Q6
    %%%% Baseline
    withhaptics_baseline_q6_x = (centre(6) - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_baseline_q6_x = (centre(6) - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_baseline_q6_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q6", :);
    withhaptics_baseline_q6_ydata = withhaptics_baseline_q6_ytable.Score;
    withouthaptics_baseline_q6_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q6", :);
    withouthaptics_baseline_q6_ydata = withouthaptics_baseline_q6_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_baseline_q6_x, withhaptics_baseline_q6_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_baseline_q6_x, withouthaptics_baseline_q6_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    %%%% Train
    withhaptics_train_q6_x = (centre(6) - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_train_q6_x = (centre(6) + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_train_q6_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q6", :);
    withhaptics_train_q6_ydata = withhaptics_train_q6_ytable.Score;
    withouthaptics_train_q6_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q6", :);
    withouthaptics_train_q6_ydata = withouthaptics_train_q6_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_train_q6_x, withhaptics_train_q6_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_train_q6_x, withouthaptics_train_q6_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    
    %%%% Test
    withhaptics_test_q6_x = (centre(6) + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_test_q6_x = (centre(6) + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_test_q6_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q6", :);
    withhaptics_test_q6_ydata = withhaptics_test_q6_ytable.Score;
    withouthaptics_test_q6_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q6", :);
    withouthaptics_test_q6_ydata = withouthaptics_test_q6_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_test_q6_x, withhaptics_test_q6_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_test_q6_x, withouthaptics_test_q6_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    score_boxchart.Parent.XTick = centre;
    score_boxchart.Parent.XTickLabel = {'Q1','Q2','Q3', 'Q4','Q5','Q6'};
    score_boxchart.Parent.XLim = [centre(1) - bias_between_conditions - 5*bias_between_groups, centre(end) + bias_between_conditions + 5*bias_between_groups];
    score_boxchart.Parent.XLabel.String = "Questions";
    score_boxchart.Parent.YLabel.String = "Score";


%%
close all
NASAFigure = figure;
    NASAFigure.Units = 'centimeters';
    NASAFigure.Position = [15, 15, 15, 11.12];
    NASAFigure.PaperUnits = 'centimeters';
    NASAFigure.PaperPosition = [15, 15, 15, 15];


ygap = 20;
    centre = 1;
    bias_between_groups = 0.3;
    bias_between_conditions = 1.5;
    bias_between_questions = 0.7;
    color_withhaptics = [0 0.4470 0.7410];
    color_withouthaptics = [0.8500 0.3250 0.0980];
%%% Q1
subplot(2, 3, 1)  
    %%%% Baseline
    withhaptics_baseline_q1_x = (centre(1) - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_baseline_q1_x = (centre(1) - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_baseline_q1_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q1", :);
    withhaptics_baseline_q1_ydata = withhaptics_baseline_q1_ytable.Score;
    withouthaptics_baseline_q1_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q1", :);
    withouthaptics_baseline_q1_ydata = withouthaptics_baseline_q1_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_baseline_q1_x, withhaptics_baseline_q1_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;

    hold on
    score_boxchart = boxchart(withouthaptics_baseline_q1_x, withouthaptics_baseline_q1_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    
    %%%% Train
    withhaptics_train_q1_x = (centre(1) - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_train_q1_x = (centre(1) + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_train_q1_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q1", :);
    withhaptics_train_q1_ydata = withhaptics_train_q1_ytable.Score;
    withouthaptics_train_q1_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q1", :);
    withouthaptics_train_q1_ydata = withouthaptics_train_q1_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_train_q1_x, withhaptics_train_q1_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_train_q1_x, withouthaptics_train_q1_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    score_boxchart.Parent.Parent.Units = 'centimeters';
    score_boxchart.Parent.XLabel.FontName = 'Linux Libertine G';
    score_boxchart.Parent.XLabel.Units = 'points';
    score_boxchart.Parent.XLabel.FontSize = 9;
    %%%% Test
    withhaptics_test_q1_x = (centre(1) + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_test_q1_x = (centre(1) + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_test_q1_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q1", :);
    withhaptics_test_q1_ydata = withhaptics_test_q1_ytable.Score;
    withouthaptics_test_q1_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q1", :);
    withouthaptics_test_q1_ydata = withouthaptics_test_q1_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_test_q1_x, withhaptics_test_q1_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_test_q1_x, withouthaptics_test_q1_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    score_boxchart.Parent.XTick = [centre - bias_between_conditions, centre, centre + bias_between_conditions];
    score_boxchart.Parent.XTickLabel = {''};
    score_boxchart.Parent.XLim = [centre(1) - bias_between_conditions - bias_between_groups - score_boxchart.BoxWidth, centre(1) + bias_between_conditions + bias_between_groups + score_boxchart.BoxWidth];
%     score_boxchart.Parent.XLabel.String = "Conditions";
    score_boxchart.Parent.YLabel.String = "Score";
    score_boxchart.Parent.YLabel.FontName = 'Linux Libertine G';
    score_boxchart.Parent.YLabel.FontUnits = "points";
    score_boxchart.Parent.YLabel.FontSize = 9;

    score_boxchart.Parent.Subtitle.String = "Mental Demand";
    score_boxchart.Parent.Subtitle.FontName = 'Linux Libertine G';
    score_boxchart.Parent.Subtitle.Units = 'points';
    score_boxchart.Parent.Subtitle.FontSize = 9;
    score_boxchart.Parent.FontName = 'Linux Libertine G';
    score_boxchart.Parent.Units = 'points';
    score_boxchart.Parent.FontSize = 9;

    score_boxchart.Parent.Position(2) = score_boxchart.Parent.Position(2) - ygap;

%%% Q2
subplot(2, 3, 2)

    %%%% Baseline
    withhaptics_baseline_q2_x = (centre - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_baseline_q2_x = (centre - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_baseline_q2_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q2", :);
    withhaptics_baseline_q2_ydata = withhaptics_baseline_q2_ytable.Score;
    withouthaptics_baseline_q2_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q2", :);
    withouthaptics_baseline_q2_ydata = withouthaptics_baseline_q2_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_baseline_q2_x, withhaptics_baseline_q2_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_baseline_q2_x, withouthaptics_baseline_q2_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    %%%% Train
    withhaptics_train_q2_x = (centre - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_train_q2_x = (centre + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_train_q2_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q2", :);
    withhaptics_train_q2_ydata = withhaptics_train_q2_ytable.Score;
    withouthaptics_train_q2_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q2", :);
    withouthaptics_train_q2_ydata = withouthaptics_train_q2_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_train_q2_x, withhaptics_train_q2_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_train_q2_x, withouthaptics_train_q2_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    
    %%%% Test
    withhaptics_test_q2_x = (centre + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_test_q2_x = (centre + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_test_q2_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q2", :);
    withhaptics_test_q2_ydata = withhaptics_test_q2_ytable.Score;
    withouthaptics_test_q2_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q2", :);
    withouthaptics_test_q2_ydata = withouthaptics_test_q2_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_test_q2_x, withhaptics_test_q2_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_test_q2_x, withouthaptics_test_q2_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    score_boxchart.Parent.XTick = [centre - bias_between_conditions, centre, centre + bias_between_conditions];
    score_boxchart.Parent.XTickLabel = {''};
    score_boxchart.Parent.XLim = [centre(1) - bias_between_conditions - bias_between_groups - score_boxchart.BoxWidth, centre(1) + bias_between_conditions + bias_between_groups + score_boxchart.BoxWidth];
%     score_boxchart.Parent.XLabel.String = "Conditions";
%     score_boxchart.Parent.YLabel.String = "Score";
    score_boxchart.Parent.Subtitle.String = "Physical Demand";
    score_boxchart.Parent.Subtitle.FontName = 'Linux Libertine G';
    score_boxchart.Parent.Subtitle.Units = 'points';
    score_boxchart.Parent.Subtitle.FontSize = 9;
    score_boxchart.Parent.FontName = 'Linux Libertine G';
    score_boxchart.Parent.Units = 'points';
    score_boxchart.Parent.FontSize = 9;
    score_boxchart.Parent.Position(2) = score_boxchart.Parent.Position(2) - ygap;

%%% Q3
subplot(2, 3, 3)

    %%%% Baseline
    withhaptics_baseline_q3_x = (centre - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_baseline_q3_x = (centre - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_baseline_q3_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q3", :);
    withhaptics_baseline_q3_ydata = withhaptics_baseline_q3_ytable.Score;
    withouthaptics_baseline_q3_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q3", :);
    withouthaptics_baseline_q3_ydata = withouthaptics_baseline_q3_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_baseline_q3_x, withhaptics_baseline_q3_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_baseline_q3_x, withouthaptics_baseline_q3_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    %%%% Train
    withhaptics_train_q3_x = (centre - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_train_q3_x = (centre + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_train_q3_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q3", :);
    withhaptics_train_q3_ydata = withhaptics_train_q3_ytable.Score;
    withouthaptics_train_q3_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q3", :);
    withouthaptics_train_q3_ydata = withouthaptics_train_q3_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_train_q3_x, withhaptics_train_q3_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_train_q3_x, withouthaptics_train_q3_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    
    %%%% Test
    withhaptics_test_q3_x = (centre + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_test_q3_x = (centre + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_test_q3_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q3", :);
    withhaptics_test_q3_ydata = withhaptics_test_q3_ytable.Score;
    withouthaptics_test_q3_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q3", :);
    withouthaptics_test_q3_ydata = withouthaptics_test_q3_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_test_q3_x, withhaptics_test_q3_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_test_q3_x, withouthaptics_test_q3_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    score_boxchart.Parent.XTick = [centre - bias_between_conditions, centre, centre + bias_between_conditions];
    score_boxchart.Parent.XTickLabel = {''};
    score_boxchart.Parent.XLim = [centre(1) - bias_between_conditions - bias_between_groups - score_boxchart.BoxWidth, centre(1) + bias_between_conditions + bias_between_groups + score_boxchart.BoxWidth];
%     score_boxchart.Parent.XLabel.String = "Conditions";
%     score_boxchart.Parent.YLabel.String = "Score";
    score_boxchart.Parent.Subtitle.String = "Temporal Demand";
    score_boxchart.Parent.Subtitle.FontName = 'Linux Libertine G';
    score_boxchart.Parent.Subtitle.Units = 'points';
    score_boxchart.Parent.Subtitle.FontSize = 9;
%     a = score_boxchart
    legend("With haptics", "Without haptics", "Location", "Best")
%     score_boxchart.Parent.Legend.String = ("With haptics", "Without haptics");
%     score_boxchart.Parent.Legend.Location = "BestOutside";
    score_boxchart.Parent.Legend.Units = 'points';
    score_boxchart.Parent.Legend.FontSize = 9;
    score_boxchart.Parent.Legend.FontName = 'Linux Libertine G';
    score_boxchart.Parent.Legend.Orientation = 'horizontal';
    score_boxchart.Parent.Legend.Position = [200 290 183.7500 13.5000];
    score_boxchart.Parent.FontName = 'Linux Libertine G';
    score_boxchart.Parent.Units = 'points';
    score_boxchart.Parent.FontSize = 9;
    score_boxchart.Parent.Position(2) = score_boxchart.Parent.Position(2) - ygap;
%     score_boxchart.Parent.Legend.Title.FontSize = 'points';
%     score_boxchart.Parent.Legend.FontSize = 9;
%     score_boxchart.Parent.Legend.Font
%     a = score_boxchart
%%% Q4
subplot(2, 3, 4)
    
    %%%% Baseline
    withhaptics_baseline_q4_x = (centre - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_baseline_q4_x = (centre - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_baseline_q4_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q4", :);
    withhaptics_baseline_q4_ydata = withhaptics_baseline_q4_ytable.Score;
    withouthaptics_baseline_q4_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q4", :);
    withouthaptics_baseline_q4_ydata = withouthaptics_baseline_q4_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_baseline_q4_x, withhaptics_baseline_q4_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_baseline_q4_x, withouthaptics_baseline_q4_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    %%%% Train
    withhaptics_train_q4_x = (centre - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_train_q4_x = (centre + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_train_q4_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q4", :);
    withhaptics_train_q4_ydata = withhaptics_train_q4_ytable.Score;
    withouthaptics_train_q4_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q4", :);
    withouthaptics_train_q4_ydata = withouthaptics_train_q4_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_train_q4_x, withhaptics_train_q4_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_train_q4_x, withouthaptics_train_q4_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    
    %%%% Test
    withhaptics_test_q4_x = (centre + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_test_q4_x = (centre + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_test_q4_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q4", :);
    withhaptics_test_q4_ydata = withhaptics_test_q4_ytable.Score;
    withouthaptics_test_q4_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q4", :);
    withouthaptics_test_q4_ydata = withouthaptics_test_q4_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_test_q4_x, withhaptics_test_q4_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_test_q4_x, withouthaptics_test_q4_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    score_boxchart.Parent.XTick = [centre - bias_between_conditions, centre, centre + bias_between_conditions];
    score_boxchart.Parent.XTickLabel = {'Baseline', 'Train', 'Test'};
    score_boxchart.Parent.FontName = 'Linux Libertine G';
    score_boxchart.Parent.Units = 'points';
    score_boxchart.Parent.FontSize = 9;
    score_boxchart.Parent.XLim = [centre(1) - bias_between_conditions - bias_between_groups - score_boxchart.BoxWidth, centre(1) + bias_between_conditions + bias_between_groups + score_boxchart.BoxWidth];
%     score_boxchart.Parent.XLabel.String = "Conditions";
    score_boxchart.Parent.YLabel.String = "Score";
    score_boxchart.Parent.YLabel.FontName = 'Linux Libertine G';
    score_boxchart.Parent.YLabel.FontUnits = "points";
    score_boxchart.Parent.YLabel.FontSize = 9;
    score_boxchart.Parent.Subtitle.String = "Performance";
    score_boxchart.Parent.Subtitle.FontName = 'Linux Libertine G';
    score_boxchart.Parent.Subtitle.Units = 'points';
    score_boxchart.Parent.Subtitle.FontSize = 9;
    score_boxchart.Parent.FontName = 'Linux Libertine G';
    score_boxchart.Parent.Units = 'points';
    score_boxchart.Parent.FontSize = 9;

    %%% Q5
subplot(2, 3, 5)
    %%%% Baseline
    withhaptics_baseline_q5_x = (centre - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_baseline_q5_x = (centre - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_baseline_q5_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q5", :);
    withhaptics_baseline_q5_ydata = withhaptics_baseline_q5_ytable.Score;
    withouthaptics_baseline_q5_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q5", :);
    withouthaptics_baseline_q5_ydata = withouthaptics_baseline_q5_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_baseline_q5_x, withhaptics_baseline_q5_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_baseline_q5_x, withouthaptics_baseline_q5_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    %%%% Train
    withhaptics_train_q5_x = (centre - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_train_q5_x = (centre + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_train_q5_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q5", :);
    withhaptics_train_q5_ydata = withhaptics_train_q5_ytable.Score;
    withouthaptics_train_q5_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q5", :);
    withouthaptics_train_q5_ydata = withouthaptics_train_q5_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_train_q5_x, withhaptics_train_q5_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_train_q5_x, withouthaptics_train_q5_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    
    %%%% Test
    withhaptics_test_q5_x = (centre + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_test_q5_x = (centre + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_test_q5_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q5", :);
    withhaptics_test_q5_ydata = withhaptics_test_q5_ytable.Score;
    withouthaptics_test_q5_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q5", :);
    withouthaptics_test_q5_ydata = withouthaptics_test_q5_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_test_q5_x, withhaptics_test_q5_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_test_q5_x, withouthaptics_test_q5_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    score_boxchart.Parent.XTick = [centre - bias_between_conditions, centre, centre + bias_between_conditions];
    score_boxchart.Parent.XTickLabel = {'Baseline', 'Train', 'Test'};
    score_boxchart.Parent.FontName = 'Linux Libertine G';
    score_boxchart.Parent.Units = 'points';
    score_boxchart.Parent.FontSize = 9;
    score_boxchart.Parent.XLim = [centre(1) - bias_between_conditions - bias_between_groups - score_boxchart.BoxWidth, centre(1) + bias_between_conditions + bias_between_groups + score_boxchart.BoxWidth];
%     score_boxchart.Parent.XLabel.String = "Conditions";
%     score_boxchart.Parent.YLabel.String = "Score";
    score_boxchart.Parent.Subtitle.String = "Effort";
    score_boxchart.Parent.Subtitle.FontName = 'Linux Libertine G';
    score_boxchart.Parent.Subtitle.Units = 'points';
    score_boxchart.Parent.Subtitle.FontSize = 9;
    %%% Q6
subplot(2, 3, 6)
    %%%% Baseline
    withhaptics_baseline_q6_x = (centre - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_baseline_q6_x = (centre - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_baseline_q6_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q6", :);
    withhaptics_baseline_q6_ydata = withhaptics_baseline_q6_ytable.Score;
    withouthaptics_baseline_q6_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q6", :);
    withouthaptics_baseline_q6_ydata = withouthaptics_baseline_q6_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_baseline_q6_x, withhaptics_baseline_q6_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_baseline_q6_x, withouthaptics_baseline_q6_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    %%%% Train
    withhaptics_train_q6_x = (centre - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_train_q6_x = (centre + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_train_q6_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q6", :);
    withhaptics_train_q6_ydata = withhaptics_train_q6_ytable.Score;
    withouthaptics_train_q6_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q6", :);
    withouthaptics_train_q6_ydata = withouthaptics_train_q6_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_train_q6_x, withhaptics_train_q6_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_train_q6_x, withouthaptics_train_q6_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    
    %%%% Test
    withhaptics_test_q6_x = (centre + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_test_q6_x = (centre + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_test_q6_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q6", :);
    withhaptics_test_q6_ydata = withhaptics_test_q6_ytable.Score;
    withouthaptics_test_q6_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q6", :);
    withouthaptics_test_q6_ydata = withouthaptics_test_q6_ytable.Score;
    
    score_boxchart = boxchart(withhaptics_test_q6_x, withhaptics_test_q6_ydata);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_test_q6_x, withouthaptics_test_q6_ydata);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;

    score_boxchart.Parent.XTick = [centre - bias_between_conditions, centre, centre + bias_between_conditions];
    score_boxchart.Parent.XTickLabel = {'Baseline', 'Train', 'Test'};
    score_boxchart.Parent.FontName = 'Linux Libertine G';
    score_boxchart.Parent.Units = 'points';
    score_boxchart.Parent.FontSize = 9;

    score_boxchart.Parent.XLim = [centre(1) - bias_between_conditions - bias_between_groups - score_boxchart.BoxWidth, centre(1) + bias_between_conditions + bias_between_groups + score_boxchart.BoxWidth];
%     score_boxchart.Parent.XLabel.String = "Conditions";
%     score_boxchart.Parent.YLabel.String = "Score";
    score_boxchart.Parent.Subtitle.String = "Frustration";
    score_boxchart.Parent.Subtitle.FontName = 'Linux Libertine G';
    score_boxchart.Parent.Subtitle.Units = 'points';
    score_boxchart.Parent.Subtitle.FontSize = 9;