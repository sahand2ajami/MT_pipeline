clc, clear, close all
%%
n_withhaptics = 11;
n_withouthaptics = 11;

data_path = "D:\OneDrive - University of Waterloo\MT project\DataAnalysis\mt_pipeline2\Questionnaire\Data";
cd(data_path)

% Define the path to your Excel file
excelFilePath = 'QuestionnaireData.xlsx';

% Get sheet names from the Excel file
[~, sheetNames] = xlsfinfo(excelFilePath);

PresenceData = struct();
NasaData = struct();
BodyData = struct();

WithHapticsCounter = 1;
WithoutHapticsCounter = 1;
%%
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

%%
clc
data = without_haptics_test_body;
mean(data)
std(data)
%%
clc
disp('WithHapticsBaseline vs. WithHapticsTrain:')
[p, hStat, stats] = signrank(with_haptics_baseline_body, with_haptics_train_body)
% Run ANOVA
[p_anova, hStat, stats] = anova1([with_haptics_baseline_body, with_haptics_train_body, with_haptics_test_body], [], "on")
comparison = multcompare(stats, 'CType', 'hsd')
%%
[p_anova, hStat, stats] = anova1([without_haptics_baseline_body, without_haptics_train_body, without_haptics_test_body], [], "on")
comparison = multcompare(stats, 'CType', 'hsd');

%% Body Ownership plot
close all
y1 = with_haptics_baseline_body;
y2 = without_haptics_baseline_body;
y3 = with_haptics_train_body;
y4 = without_haptics_train_body;
y5 = with_haptics_test_body;
y6 = without_haptics_test_body;

y_label = "Body Ownership";
y_lim = [-9, 9];

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, '', '', '', y_label, y_lim, "", 0.5, 0.6);


%% Check normality
close all
data = without_haptics_baseline_body;
qqplot(without_haptics_test_body)

%%
[h, p] = ttest2(without_haptics_baseline_body, with_haptics_baseline_body)

%% Agency and Motor Control
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
%%
clc
data = with_haptics_train_agency;
mean(data)
std(data)
% clc
% disp('WithHapticsBaseline vs. WithHapticsTrain:')
% [p, hStat, stats] = ranksum(without_haptics_test_agency, without_haptics_train_agency)
%% RUN ANOVA
[p_anova, hStat, stats] = anova1([with_haptics_baseline_agency, with_haptics_train_agency, with_haptics_test_agency], [], "on")
comparison = multcompare(stats, 'CType', 'hsd')
%%
[p_anova, hStat, stats] = anova1([without_haptics_baseline_agency, without_haptics_train_agency, without_haptics_test_agency], [], "on")
comparison = multcompare(stats, 'CType', 'hsd');

%% Agency Plot

close all
y1 = with_haptics_baseline_agency;
y2 = without_haptics_baseline_agency;
y3 = with_haptics_train_agency;
y4 = without_haptics_train_agency;
y5 = with_haptics_test_agency;
y6 = without_haptics_test_agency;

y_label = "Agency & Motor Control";
y_lim = [-12, 12];

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, '', '', '', y_label, y_lim, "", 0.5, 0.6);

%% Tactile Sensation

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

%% Statistical test on Tactile Sensation

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

%%

% clc
% disp('Tactile Sensation')
% disp('-----------------')
% disp('WithHapticsTrain vs. WithoutHapticsTrain:')
% [p, hStat, stats] = ranksum(without_haptics_train_tactile, with_haptics_train_tactile)
% 
% disp('WithHapticsTest vs. WithoutHapticsTest:')
% [p, ~, stats] = ranksum(without_haptics_test_tactile, with_haptics_test_tactile)

[p,tbl,stats] = anova2([with_haptics_train_tactile, without_haptics_train_tactile]);
p
close all
comparison = multcompare(stats)
p = comparison(:, end)
%%
% [H, pValue, W] = swtest(without_haptics_train_tactile, 0.05)
%% RUN ANOVA
[p_anova, hStat, stats] = anova1([with_haptics_baseline_tactile, with_haptics_train_tactile, with_haptics_test_tactile], [], "on")
% comparison = multcompare(stats, 'CType', 'hsd')
%%
[p_anova, hStat, stats] = anova1([without_haptics_baseline_tactile, without_haptics_train_tactile, without_haptics_test_tactile], [], "on")
% comparison = multcompare(stats, 'CType', 'hsd');
%% Tactile Sensation plot
close all
y1 = with_haptics_baseline_tactile;
y2 = without_haptics_baseline_tactile;
y3 = with_haptics_train_tactile;
y4 = without_haptics_train_tactile;
y5 = with_haptics_test_tactile;
y6 = without_haptics_test_tactile;

y_label = "Tactile Sensation";
y_lim = [-12, 12];

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', y_label, y_lim, "", 0.5, 0.6);
StatisticalLines(x3, x4, '**', 9, 0.5, 9)

%% Normality check
close all
data = [with_haptics_baseline_tactile; with_haptics_train_tactile; with_haptics_test_tactile]
mean_baseline = mean(with_haptics_baseline_tactile);
mean_train = mean(with_haptics_train_tactile);
mean_test = mean(with_haptics_test_tactile);
res_baseline = with_haptics_baseline_tactile - mean_baseline;
res_train = with_haptics_train_tactile - mean_train;
res_test = with_haptics_test_tactile - mean_test;
res_ = [res_baseline; res_train; res_test];
qqplot(res_)

%%
[h, p] = ttest2(without_haptics_train_tactile, with_haptics_train_tactile)

[h, p] = ttest2(without_haptics_test_tactile, with_haptics_test_tactile)
%%
% close all
[p,tbl,stats] = anova2([with_haptics_train_tactile, without_haptics_train_tactile]);
p
close all
comparison = multcompare(stats)
p = comparison(:, end)
%%
[p,tbl,stats] = anova2([with_haptics_train_tactile, without_haptics_train_tactile]);
p
close all
comparison = multcompare(stats)
p = comparison(:, end)
%%
% [H, pValue, W] = swtest(without_haptics_test_tactile, 0.05)
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

%%
with_haptics_baseline_location = LocationScoreTable((strcmp(LocationScoreTable.Group, 'WithHaptics') & LocationScoreTable.Condition == 'Baseline'), :);
with_haptics_train_location = LocationScoreTable((strcmp(LocationScoreTable.Group, 'WithHaptics') & LocationScoreTable.Condition == 'Train'), :);
with_haptics_test_location = LocationScoreTable((strcmp(LocationScoreTable.Group, 'WithHaptics') & LocationScoreTable.Condition == 'Test'), :);

without_haptics_baseline_location = LocationScoreTable((strcmp(LocationScoreTable.Group, 'WithoutHaptics') & LocationScoreTable.Condition == 'Baseline'), :);
without_haptics_train_location = LocationScoreTable((strcmp(LocationScoreTable.Group, 'WithoutHaptics') & LocationScoreTable.Condition == 'Train'), :);
without_haptics_test_location = LocationScoreTable((strcmp(LocationScoreTable.Group, 'WithoutHaptics') & LocationScoreTable.Condition == 'Test'), :);

with_haptics_baseline_location = with_haptics_baseline_location.Score;
with_haptics_train_location = with_haptics_train_location.Score;
with_haptics_test_location = with_haptics_test_location.Score;

without_haptics_baseline_location = without_haptics_baseline_location.Score;
without_haptics_train_location = without_haptics_train_location.Score;
without_haptics_test_location = without_haptics_test_location.Score;

%% Location of the Body plot
close all
y1 = with_haptics_baseline_location;
y2 = without_haptics_baseline_location;
y3 = with_haptics_train_location;
y4 = without_haptics_train_location;
y5 = with_haptics_test_location;
y6 = without_haptics_test_location;

y_label = "Location of the Body";
y_lim = [-9, 9];

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, ...
    y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', ...
    y_label, y_lim, "", 0.5, 0.6);


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

%% Final Embodiment score

weight_q1 = 20;
weight_q2 = 30;
weight_q3 = 30;
weight_q4 = 20;

%%% Body Ownership
withouthaptics_baseline_q1_ydata = BodyScoreTable(BodyScoreTable.Group == "WithoutHaptics" & BodyScoreTable.Condition == "Baseline", :).Score;
withhaptics_baseline_q1_ydata = BodyScoreTable(BodyScoreTable.Group == "WithHaptics" & BodyScoreTable.Condition == "Baseline", :).Score;

withouthaptics_train_q1_ydata = BodyScoreTable(BodyScoreTable.Group == "WithoutHaptics" & BodyScoreTable.Condition == "Train", :).Score;
withhaptics_train_q1_ydata = BodyScoreTable(BodyScoreTable.Group == "WithHaptics" & BodyScoreTable.Condition == "Train", :).Score;

withouthaptics_test_q1_ydata = BodyScoreTable(BodyScoreTable.Group == "WithoutHaptics" & BodyScoreTable.Condition == "Test", :).Score;
withhaptics_test_q1_ydata = BodyScoreTable(BodyScoreTable.Group == "WithHaptics" & BodyScoreTable.Condition == "Test", :).Score;

%%% Agency and Motor Control
withouthaptics_baseline_q2_ydata = AgencyScoreTable(AgencyScoreTable.Group == "WithoutHaptics" & AgencyScoreTable.Condition == "Baseline", :).Score;
withhaptics_baseline_q2_ydata = AgencyScoreTable(AgencyScoreTable.Group == "WithHaptics" & AgencyScoreTable.Condition == "Baseline", :).Score;

withouthaptics_train_q2_ydata = AgencyScoreTable(AgencyScoreTable.Group == "WithoutHaptics" & AgencyScoreTable.Condition == "Train", :).Score;
withhaptics_train_q2_ydata = AgencyScoreTable(AgencyScoreTable.Group == "WithHaptics" & AgencyScoreTable.Condition == "Train", :).Score;

withouthaptics_test_q2_ydata = AgencyScoreTable(AgencyScoreTable.Group == "WithoutHaptics" & AgencyScoreTable.Condition == "Test", :).Score;
withhaptics_test_q2_ydata = AgencyScoreTable(AgencyScoreTable.Group == "WithHaptics" & AgencyScoreTable.Condition == "Test", :).Score;

%%% Tactile Sensation
withouthaptics_baseline_q3_ydata = TactileScoreTable(TactileScoreTable.Group == "WithoutHaptics" & TactileScoreTable.Condition == "Baseline", :).Score;
withhaptics_baseline_q3_ydata = TactileScoreTable(TactileScoreTable.Group == "WithHaptics" & TactileScoreTable.Condition == "Baseline", :).Score;

withouthaptics_train_q3_ydata = TactileScoreTable(TactileScoreTable.Group == "WithoutHaptics" & TactileScoreTable.Condition == "Train", :).Score;
withhaptics_train_q3_ydata = TactileScoreTable(TactileScoreTable.Group == "WithHaptics" & TactileScoreTable.Condition == "Train", :).Score;

withouthaptics_test_q3_ydata = TactileScoreTable(TactileScoreTable.Group == "WithoutHaptics" & TactileScoreTable.Condition == "Test", :).Score;
withhaptics_test_q3_ydata = TactileScoreTable(TactileScoreTable.Group == "WithHaptics" & TactileScoreTable.Condition == "Test", :).Score;

%%% Location of the Body
withouthaptics_baseline_q4_ydata = LocationScoreTable(LocationScoreTable.Group == "WithoutHaptics" & LocationScoreTable.Condition == "Baseline", :).Score;
withhaptics_baseline_q4_ydata = LocationScoreTable(LocationScoreTable.Group == "WithHaptics" & LocationScoreTable.Condition == "Baseline", :).Score;

withouthaptics_train_q4_ydata = LocationScoreTable(LocationScoreTable.Group == "WithoutHaptics" & LocationScoreTable.Condition == "Train", :).Score;
withhaptics_train_q4_ydata = LocationScoreTable(LocationScoreTable.Group == "WithHaptics" & LocationScoreTable.Condition == "Train", :).Score;

withouthaptics_test_q4_ydata = LocationScoreTable(LocationScoreTable.Group == "WithoutHaptics" & LocationScoreTable.Condition == "Test", :).Score;
withhaptics_test_q4_ydata = LocationScoreTable(LocationScoreTable.Group == "WithHaptics" & LocationScoreTable.Condition == "Test", :).Score;

%%%
withouthaptics_baseline_score = weight_q1 .* (withouthaptics_baseline_q1_ydata + 9)./18 + ...
    weight_q2 .* (withouthaptics_baseline_q2_ydata + 12)./ 24 + ...
    weight_q3 .* (withouthaptics_baseline_q3_ydata + 12)./24 + ...
    weight_q4 .* (withouthaptics_baseline_q4_ydata + 9)./18;
  

withouthaptics_train_score = weight_q1 .* (withouthaptics_train_q1_ydata + 9)./18 + ...
    weight_q2 .* (withouthaptics_train_q2_ydata + 12)./24 + ...
    weight_q3 .* (withouthaptics_train_q3_ydata + 12)./24 + ...
    weight_q4 .* (withouthaptics_train_q4_ydata + 9)./18;

withouthaptics_test_score = weight_q1 .* (withouthaptics_test_q1_ydata + 9)./18 + ...
    weight_q2 .* (withouthaptics_test_q2_ydata + 12)./24 + ...
    weight_q3 .* (withouthaptics_test_q3_ydata + 12)./24 + ...
    weight_q4 .* (withouthaptics_test_q4_ydata + 9)./18 ;


withhaptics_baseline_score = weight_q1 .* (withhaptics_baseline_q1_ydata + 9)./18 + ...
    weight_q2 .* (withhaptics_baseline_q2_ydata + 12)./24 + ...
    weight_q3 .* (withhaptics_baseline_q3_ydata + 12)./24 + ...
    weight_q4 .* (withhaptics_baseline_q4_ydata + 9)./18;
  

withhaptics_train_score = weight_q1 .* (withhaptics_train_q1_ydata + 9)./18 + ...
    weight_q2 .* (withhaptics_train_q2_ydata + 12)./24 + ...
    weight_q3 .* (withhaptics_train_q3_ydata + 12)./24 + ...
    weight_q4 .* (withhaptics_train_q4_ydata + 9)./18 ;
   

withhaptics_test_score = weight_q1 .* (withhaptics_test_q1_ydata + 9)./18 + ...
    weight_q2 .* (withhaptics_test_q2_ydata + 12)./24 + ...
    weight_q3 .* (withhaptics_test_q3_ydata + 12)./24 + ...
    weight_q4 .* (withhaptics_test_q4_ydata + 9)./18;
%% Overall Embodiment Perception plot

close all
y1 = withhaptics_baseline_score;
y2 = withouthaptics_baseline_score;
y3 = withhaptics_train_score;
y4 = withouthaptics_train_score;
y5 = withhaptics_test_score;
y6 = withouthaptics_test_score;

y_label = "Embodiment Perception";
y_lim = [0, 100];

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, ...
    y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', ...
    y_label, y_lim, "", 0.5, 0.6);
StatisticalLines(x3, x4, '*', 90, 2, 9)

%%
% STAT TEST - TTEST2
x = withouthaptics_train_score;
y = withhaptics_train_score;
[h,p,ci,stats] = ttest2(x,y)

%% Stats on Overall embodiment
% Analyzing the normality
% [H, pValue, W] = swtest(withouthaptics_train_score, 0.05);
% [H, pValue, W] = swtest(withhaptics_train_score, 0.05);
% 
% % run the test


% [p,tbl,stats] = anova2([withouthaptics_train_score, withhaptics_train_score])
% p
% close all
% comparison = multcompare(stats);
% p = comparison(:, end)
% [p, h] = ttest(withouthaptics_train_score, withhaptics_train_score)
% [h, p] = ttest2(with_haptics_test_time, without_haptics_test_time)
% [h, p] = 
% ranksum(withouthaptics_train_score, withhaptics_train_score+0.2)
%% STAT TEST - TTEST2
x = withouthaptics_train_score;
y = withhaptics_train_score;
[h,p,ci,stats] = ttest2(x,y)
%% Statistical tests on Embodiment score
% [p, hStat, stats] = ranksum(withhaptics_train_score, withouthaptics_train_score)
%%
% [p, hStat, stats] = ranksum(withhaptics_test_score, withouthaptics_test_score)

%%
% [p_anova, hStat, stats] = anova1([withouthaptics_baseline_score, withouthaptics_train_score, withouthaptics_test_score], [], "on")
% comparison = multcompare(stats, 'CType', 'hsd');

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
            newTable = table(GroupNames(i), Conditions(j), {'Q1'}, answers(1), ...
                'VariableNames', variable_names);
            
            NASATable = [NASATable; newTable];
            
            % Make the table to have data of all conditions together
            newTable = table(GroupNames(i), Conditions(j), {'Q2'}, answers(2), ...
                'VariableNames', variable_names);
            
            NASATable = [NASATable; newTable];
            
            % Make the table to have data of all conditions together
            newTable = table(GroupNames(i), Conditions(j), {'Q3'}, answers(3), ...
                'VariableNames', variable_names);
            
            NASATable = [NASATable; newTable];
            
            % Make the table to have data of all conditions together
            newTable = table(GroupNames(i), Conditions(j), {'Q4'}, answers(4), ...
                'VariableNames', variable_names);
            
            NASATable = [NASATable; newTable];
            
            % Make the table to have data of all conditions together
            newTable = table(GroupNames(i), Conditions(j), {'Q5'}, answers(5), ...
                'VariableNames', variable_names);
            
            NASATable = [NASATable; newTable];
            
            % Make the table to have data of all conditions together
            newTable = table(GroupNames(i), Conditions(j), {'Q6'}, answers(6), ...
                'VariableNames', variable_names);
            
            NASATable = [NASATable; newTable];
        end
    end  
end

%% NASATLX Category data

%%% Q1
    %%%% Baseline
    withhaptics_baseline_q1_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q1", :);
    withhaptics_baseline_q1_ydata = withhaptics_baseline_q1_ytable.Score;
    withouthaptics_baseline_q1_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q1", :);
    withouthaptics_baseline_q1_ydata = withouthaptics_baseline_q1_ytable.Score;
    
    %%%% Train
    withhaptics_train_q1_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q1", :);
    withhaptics_train_q1_ydata = withhaptics_train_q1_ytable.Score;
    withouthaptics_train_q1_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q1", :);
    withouthaptics_train_q1_ydata = withouthaptics_train_q1_ytable.Score;

    %%%% Test
    withhaptics_test_q1_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q1", :);
    withhaptics_test_q1_ydata = withhaptics_test_q1_ytable.Score;
    withouthaptics_test_q1_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q1", :);
    withouthaptics_test_q1_ydata = withouthaptics_test_q1_ytable.Score;

%%% Q2
    %%%% Baseline    
    withhaptics_baseline_q2_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q2", :);
    withhaptics_baseline_q2_ydata = withhaptics_baseline_q2_ytable.Score;
    withouthaptics_baseline_q2_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q2", :);
    withouthaptics_baseline_q2_ydata = withouthaptics_baseline_q2_ytable.Score;

    %%%% Train    
    withhaptics_train_q2_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q2", :);
    withhaptics_train_q2_ydata = withhaptics_train_q2_ytable.Score;
    withouthaptics_train_q2_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q2", :);
    withouthaptics_train_q2_ydata = withouthaptics_train_q2_ytable.Score;
    
    %%%% Test
    withhaptics_test_q2_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q2", :);
    withhaptics_test_q2_ydata = withhaptics_test_q2_ytable.Score;
    withouthaptics_test_q2_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q2", :);
    withouthaptics_test_q2_ydata = withouthaptics_test_q2_ytable.Score;

%%% Q3
    %%%% Baseline
    withhaptics_baseline_q3_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q3", :);
    withhaptics_baseline_q3_ydata = withhaptics_baseline_q3_ytable.Score;
    withouthaptics_baseline_q3_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q3", :);
    withouthaptics_baseline_q3_ydata = withouthaptics_baseline_q3_ytable.Score;

    %%%% Train
    withhaptics_train_q3_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q3", :);
    withhaptics_train_q3_ydata = withhaptics_train_q3_ytable.Score;
    withouthaptics_train_q3_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q3", :);
    withouthaptics_train_q3_ydata = withouthaptics_train_q3_ytable.Score;
    
    %%%% Test
    withhaptics_test_q3_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q3", :);
    withhaptics_test_q3_ydata = withhaptics_test_q3_ytable.Score;
    withouthaptics_test_q3_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q3", :);
    withouthaptics_test_q3_ydata = withouthaptics_test_q3_ytable.Score;

%%% Q4
subplot(2, 3, 4)
    ylim([0, 21])
    %%%% Baseline
    withhaptics_baseline_q4_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q4", :);
    withhaptics_baseline_q4_ydata = withhaptics_baseline_q4_ytable.Score;
    withouthaptics_baseline_q4_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q4", :);
    withouthaptics_baseline_q4_ydata = withouthaptics_baseline_q4_ytable.Score;
    
    %%%% Train
    withhaptics_train_q4_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q4", :);
    withhaptics_train_q4_ydata = withhaptics_train_q4_ytable.Score;
    withouthaptics_train_q4_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q4", :);
    withouthaptics_train_q4_ydata = withouthaptics_train_q4_ytable.Score;

    %%%% Test
    withhaptics_test_q4_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q4", :);
    withhaptics_test_q4_ydata = withhaptics_test_q4_ytable.Score;
    withouthaptics_test_q4_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q4", :);
    withouthaptics_test_q4_ydata = withouthaptics_test_q4_ytable.Score;

%%% Q5
    %%%% Baseline
    withhaptics_baseline_q5_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q5", :);
    withhaptics_baseline_q5_ydata = withhaptics_baseline_q5_ytable.Score;
    withouthaptics_baseline_q5_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q5", :);
    withouthaptics_baseline_q5_ydata = withouthaptics_baseline_q5_ytable.Score;

    %%%% Train
    withhaptics_train_q5_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q5", :);
    withhaptics_train_q5_ydata = withhaptics_train_q5_ytable.Score;
    withouthaptics_train_q5_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q5", :);
    withouthaptics_train_q5_ydata = withouthaptics_train_q5_ytable.Score;

    %%%% Test
    withhaptics_test_q5_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q5", :);
    withhaptics_test_q5_ydata = withhaptics_test_q5_ytable.Score;
    withouthaptics_test_q5_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q5", :);
    withouthaptics_test_q5_ydata = withouthaptics_test_q5_ytable.Score;
    
%%% Q6
    %%%% Baseline
    withhaptics_baseline_q6_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q6", :);
    withhaptics_baseline_q6_ydata = withhaptics_baseline_q6_ytable.Score;
    withouthaptics_baseline_q6_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Baseline" & NASATable.Question(:) == "Q6", :);
    withouthaptics_baseline_q6_ydata = withouthaptics_baseline_q6_ytable.Score;

    %%%% Train
    withhaptics_train_q6_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q6", :);
    withhaptics_train_q6_ydata = withhaptics_train_q6_ytable.Score;
    withouthaptics_train_q6_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Train" & NASATable.Question(:) == "Q6", :);
    withouthaptics_train_q6_ydata = withouthaptics_train_q6_ytable.Score;
 
    %%%% Test
    withhaptics_test_q6_ytable = NASATable(NASATable.Group(:) == "WithHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q6", :);
    withhaptics_test_q6_ydata = withhaptics_test_q6_ytable.Score;
    withouthaptics_test_q6_ytable = NASATable(NASATable.Group(:) == "WithoutHaptics" & NASATable.Condition(:) == "Test" & NASATable.Question(:) == "Q6", :);
    withouthaptics_test_q6_ydata = withouthaptics_test_q6_ytable.Score;
%% NASATLX Category subplot
close all
figure
%%% Mental Demand
subplot(2, 3, 1)
y1 = withhaptics_baseline_q1_ydata;
y2 = withouthaptics_baseline_q1_ydata;
y3 = withhaptics_train_q1_ydata;
y4 = withouthaptics_train_q1_ydata;
y5 = withhaptics_test_q1_ydata;
y6 = withouthaptics_test_q1_ydata;

y_label = "Score";
y_lim = [0, 21];
my_title = "Mental Demand";

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = NASATLXSubplot(y1, y2, ...
    y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, '', '', '', ...
    y_label, y_lim, my_title, 0.5, 0.6);

%%% Physical Demand
subplot(2, 3, 2)
y1 = withhaptics_baseline_q2_ydata;
y2 = withouthaptics_baseline_q2_ydata;
y3 = withhaptics_train_q2_ydata;
y4 = withouthaptics_train_q2_ydata;
y5 = withhaptics_test_q2_ydata;
y6 = withouthaptics_test_q2_ydata;

y_label = "";
y_lim = [0, 21];
my_title = "Mental Demand";

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = NASATLXSubplot(y1, y2, ...
    y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, '', '', '', ...
    y_label, y_lim, my_title, 0.5, 0.6);
StatisticalLines(x3, x4, '*', 20, 0.5, 9)

%%% Temporal Demand
subplot(2, 3, 3)
y1 = withhaptics_baseline_q3_ydata;
y2 = withouthaptics_baseline_q3_ydata;
y3 = withhaptics_train_q3_ydata;
y4 = withouthaptics_train_q3_ydata;
y5 = withhaptics_test_q3_ydata;
y6 = withouthaptics_test_q3_ydata;

y_label = "";
y_lim = [0, 21];
my_title = "Temporal Demand";

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = NASATLXSubplot(y1, y2, ...
    y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, '', '', '', ...
    y_label, y_lim, my_title, 0.5, 0.6);
StatisticalLines(x3, x4, '*', 20, 0.5, 9)

%%% Performance
subplot(2, 3, 4)
y1 = withhaptics_baseline_q4_ydata;
y2 = withouthaptics_baseline_q4_ydata;
y3 = withhaptics_train_q4_ydata;
y4 = withouthaptics_train_q4_ydata;
y5 = withhaptics_test_q4_ydata;
y6 = withouthaptics_test_q4_ydata;

y_label = "Score";
y_lim = [0, 21];
my_title = "Performance";

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = NASATLXSubplot(y1, y2, ...
    y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', ...
    y_label, y_lim, my_title, 0.5, 0.6);

%%% Effort
subplot(2, 3, 5)
y1 = withhaptics_baseline_q5_ydata;
y2 = withouthaptics_baseline_q5_ydata;
y3 = withhaptics_train_q5_ydata;
y4 = withouthaptics_train_q5_ydata;
y5 = withhaptics_test_q5_ydata;
y6 = withouthaptics_test_q5_ydata;

y_label = "";
y_lim = [0, 21];
my_title = "Effort";

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = NASATLXSubplot(y1, y2, ...
    y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', ...
    y_label, y_lim, my_title, 0.5, 0.6);

%%% Frustration
subplot(2, 3, 6)
y1 = withhaptics_baseline_q6_ydata;
y2 = withouthaptics_baseline_q6_ydata;
y3 = withhaptics_train_q6_ydata;
y4 = withouthaptics_train_q6_ydata;
y5 = withhaptics_test_q6_ydata;
y6 = withouthaptics_test_q6_ydata;

y_label = "";
y_lim = [0, 21];
my_title = "Frustration";

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = NASATLXSubplot(y1, y2, ...
    y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', ...
    y_label, y_lim, my_title, 0.5, 0.6);

%%
clc
% [p, hStat, stats] = ranksum(withouthaptics_train_q2_ydata, withhaptics_train_q2_ydata)
% [H, pValue, W] = swtest(withhaptics_train_q2_ydata, 0.05)
%%
[p,tbl,stats] = anova2([withouthaptics_train_q2_ydata, withhaptics_train_q2_ydata]);
p
close all
comparison = multcompare(stats)
p = comparison(:, end)
%%
% [H, pValue, W] = swtest(withhaptics_train_q3_ydata, 0.05)
%%
% [p, hStat, stats] = ranksum(withouthaptics_train_q3_ydata, withhaptics_train_q3_ydata)
[p,tbl,stats] = anova2([withouthaptics_train_q3_ydata, withhaptics_train_q3_ydata]);
p
close all
comparison = multcompare(stats)
p = comparison(:, end)

%% Mental Demand
close all
y1 = withhaptics_baseline_q1_ydata;
y2 = withouthaptics_baseline_q1_ydata;
y3 = withhaptics_train_q1_ydata;
y4 = withouthaptics_train_q1_ydata;
y5 = withhaptics_test_q1_ydata;
y6 = withouthaptics_test_q1_ydata;

y_label = "Score";
y_lim = [0, 21];
my_title = "Mental Demand";

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, ...
    y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, '', '', '', ...
    y_label, y_lim, my_title, 0.5, 0.6);

%% Physical Demand
close all 
y1 = withhaptics_baseline_q2_ydata;
y2 = withouthaptics_baseline_q2_ydata;
y3 = withhaptics_train_q2_ydata;
y4 = withouthaptics_train_q2_ydata;
y5 = withhaptics_test_q2_ydata;
y6 = withouthaptics_test_q2_ydata;

y_label = "";
y_lim = [0, 21];
my_title = "Physical Demand";

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, ...
    y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, '', '', '', ...
    y_label, y_lim, my_title, 0.5, 0.6);
StatisticalLines(x3, x4, '*', 20, 0.5, 9)

%% Temporal Demand
close all 
y1 = withhaptics_baseline_q3_ydata;
y2 = withouthaptics_baseline_q3_ydata;
y3 = withhaptics_train_q3_ydata;
y4 = withouthaptics_train_q3_ydata;
y5 = withhaptics_test_q3_ydata;
y6 = withouthaptics_test_q3_ydata;

y_label = "Score";
y_lim = [0, 21];
my_title = "Temporal Demand";

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, ...
    y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, '', '', '', ...
    y_label, y_lim, my_title, 0.5, 0.6);
StatisticalLines(x3, x4, '*', 20, 0.5, 9)

%% Performance
close all 
y1 = withhaptics_baseline_q4_ydata;
y2 = withouthaptics_baseline_q4_ydata;
y3 = withhaptics_train_q4_ydata;
y4 = withouthaptics_train_q4_ydata;
y5 = withhaptics_test_q4_ydata;
y6 = withouthaptics_test_q4_ydata;

y_label = "";
y_lim = [0, 21];
my_title = "Performance";

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, ...
    y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, '', '', '', ...
    y_label, y_lim, my_title, 0.5, 0.6);

%% Effort
close all 
y1 = withhaptics_baseline_q5_ydata;
y2 = withouthaptics_baseline_q5_ydata;
y3 = withhaptics_train_q5_ydata;
y4 = withouthaptics_train_q5_ydata;
y5 = withhaptics_test_q5_ydata;
y6 = withouthaptics_test_q5_ydata;

y_label = "Score";
y_lim = [0, 21];
my_title = "Effort";

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, ...
    y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', ...
    y_label, y_lim, my_title, 0.5, 0.6);

%% Frustration
close all
y1 = withhaptics_baseline_q6_ydata;
y2 = withouthaptics_baseline_q6_ydata;
y3 = withhaptics_train_q6_ydata;
y4 = withouthaptics_train_q6_ydata;
y5 = withhaptics_test_q6_ydata;
y6 = withouthaptics_test_q6_ydata;

y_label = "";
y_lim = [0, 21];
my_title = "Frustration";

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, ...
    y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', ...
    y_label, y_lim, my_title, 0.5, 0.6);
%% Final TLX score

weight_q1 = 20;
weight_q2 = 20;
weight_q3 = 20;
weight_q4 = 20;
weight_q5 = 10;
weight_q6 = 10;


withouthaptics_baseline_score = weight_q1 .* withouthaptics_baseline_q1_ydata./21 + ...
    weight_q2 .* withouthaptics_baseline_q2_ydata./21 + ...
    weight_q3 .* withouthaptics_baseline_q3_ydata./21 + ...
    weight_q4 .* withouthaptics_baseline_q4_ydata./21 + ...
    weight_q5 .* withouthaptics_baseline_q5_ydata./21 + ...
    weight_q6 .* withouthaptics_baseline_q6_ydata./21;

withouthaptics_train_score = weight_q1 .* withouthaptics_train_q1_ydata./21 + ...
    weight_q2 .* withouthaptics_train_q2_ydata./21 + ...
    weight_q3 .* withouthaptics_train_q3_ydata./21 + ...
    weight_q4 .* withouthaptics_train_q4_ydata./21 + ...
    weight_q5 .* withouthaptics_train_q5_ydata./21 + ...
    weight_q6 .* withouthaptics_train_q6_ydata./21;

withouthaptics_test_score = weight_q1 .* withouthaptics_test_q1_ydata./21 + ...
    weight_q2 .* withouthaptics_test_q2_ydata./21 + ...
    weight_q3 .* withouthaptics_test_q3_ydata./21 + ...
    weight_q4 .* withouthaptics_test_q4_ydata./21 + ...
    weight_q5 .* withouthaptics_test_q5_ydata./21 + ...
    weight_q6 .* withouthaptics_test_q6_ydata./21;

withhaptics_baseline_score = weight_q1 .* withhaptics_baseline_q1_ydata./21 + ...
    weight_q2 .* withhaptics_baseline_q2_ydata./21 + ...
    weight_q3 .* withhaptics_baseline_q3_ydata./21 + ...
    weight_q4 .* withhaptics_baseline_q4_ydata./21 + ...
    weight_q5 .* withhaptics_baseline_q5_ydata./21 + ...
    weight_q6 .* withhaptics_baseline_q6_ydata./21;

withhaptics_train_score = weight_q1 .* withhaptics_train_q1_ydata./21 + ...
    weight_q2 .* withhaptics_train_q2_ydata./21 + ...
    weight_q3 .* withhaptics_train_q3_ydata./21 + ...
    weight_q4 .* withhaptics_train_q4_ydata./21 + ...
    weight_q5 .* withhaptics_train_q5_ydata./21 + ...
    weight_q6 .* withhaptics_train_q6_ydata./21;

withhaptics_test_score = weight_q1 .* withhaptics_test_q1_ydata./21 + ...
    weight_q2 .* withhaptics_test_q2_ydata./21 + ...
    weight_q3 .* withhaptics_test_q3_ydata./21 + ...
    weight_q4 .* withhaptics_test_q4_ydata./21 + ...
    weight_q5 .* withhaptics_test_q5_ydata./21 + ...
    weight_q6 .* withhaptics_test_q6_ydata./21;

%% Overall NASATLX plot
close all
y1 = withhaptics_baseline_score;
y2 = withouthaptics_baseline_score;
y3 = withhaptics_train_score;
y4 = withouthaptics_train_score;
y5 = withhaptics_test_score;
y6 = withouthaptics_test_score;

y_label = "NASA-TLX";
y_lim = [0, 100];

[scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, ...
    y3, y4, y5, y6, 2.5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', ...
    y_label, y_lim, "", 0.5, 0.6);

%%
[p, hStat, stats] = ranksum(withhaptics_train_score, withouthaptics_train_score)
