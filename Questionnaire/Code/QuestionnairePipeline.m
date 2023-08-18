clc, clear, close all

cd('C:\Users\s2ajami\OneDrive - University of Waterloo\MT project\DataAnalysis\mt_pipeline\Questionnaire\Data')

% Define the path to your Excel file
excelFilePath = 'QuestionnaireData.xlsx';

% Get sheet names from the Excel file
[~, sheetNames] = xlsfinfo(excelFilePath);


global PresenceData
global NasaData
global BodyData 

PresenceData = struct();
NasaData = struct();
BodyData = struct();

WithHapticsCounter = 1;
WithoutHapticsCounter = 1;
tic
% Loop through each sheet and read specific cells
for sheetIndex = 1:numel(sheetNames)
    sheetName = sheetNames{sheetIndex};
    
    BodyData = ReadExcel(excelFilePath, 'D11:F11', 'BodyOwnership', 'Baseline', sheetName);
    BodyData = ReadExcel(excelFilePath, 'D21:F21', 'BodyOwnership', 'Train', sheetName);
    BodyData = ReadExcel(excelFilePath, 'D31:F31', 'BodyOwnership', 'Test', sheetName);

    BodyData = ReadExcel(excelFilePath, 'D13:G13', 'Agency', 'Baseline', sheetName);
    BodyData = ReadExcel(excelFilePath, 'D23:G23', 'Agency', 'Train', sheetName);
    BodyData = ReadExcel(excelFilePath, 'D33:G33', 'Agency', 'Test', sheetName);

    BodyData = ReadExcel(excelFilePath, 'D15:G15', 'Tactile', 'Baseline', sheetName);
    BodyData = ReadExcel(excelFilePath, 'D25:G25', 'Tactile', 'Train', sheetName);
    BodyData = ReadExcel(excelFilePath, 'D35:G35', 'Tactile', 'Test', sheetName);

    BodyData = ReadExcel(excelFilePath, 'D17:F17', 'Location', 'Baseline', sheetName);
    BodyData = ReadExcel(excelFilePath, 'D27:F27', 'Location', 'Train', sheetName);
    BodyData = ReadExcel(excelFilePath, 'D37:F37', 'Location', 'Test', sheetName);

    BodyData = ReadExcel(excelFilePath, 'D19:G19', 'ExternalAppearance', 'Baseline', sheetName);
    BodyData = ReadExcel(excelFilePath, 'D29:G29', 'ExternalAppearance', 'Train', sheetName);
    BodyData = ReadExcel(excelFilePath, 'D39:G39', 'ExternalAppearance', 'Test', sheetName);
end
toc
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
        
        BodyScoreTable = [BodyScoreTable; newTable]
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

    score_legend = legend("WithHaptics","WithoutHaptics");
    excludeIndex = 2;
    legendEntries = score_legend.EntryContainer.Children;
    legendEntries(3:end) = [];
    score_legend.String = {'WithHaptics', 'WithoutHaptics'};
    score_legend.Location = 'best';
    title('Body Ownership');
    ylabel('Score');
    ylim([-9, +9])
    xlabel('Conditions');

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
    for j = 1:length(fieldnames(SubCategory.BodyOwnership.Train))
        subjects = SubCategory.BodyOwnership.Train;
        subjectID = (fieldnames(subjects));
        Answers = subjects.(subjectID{j});
        TrainAgencyanswers{i, j} = subjects.(subjectID{j});
        TrainAgencyScore{i, j} = Answers(1) - Answers(2) - Answers(3);

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
        TestAgencyScore{i, j} = Answers(1) - Answers(2) - Answers(3);

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

figure
    centre = [1, 2.75, 4.5];
    bias = 0.3;
    x_data1 = centre - bias;
    x_data1 = repmat(x_data1, 1, 11);
    x_data2 = centre + bias;
    x_data2 = repmat(x_data2, 1, 11);
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

figure
    centre = [1, 2.75, 4.5];
    bias = 0.3;
    x_data1 = centre - bias;
    x_data1 = repmat(x_data1, 1, 11);
    x_data2 = centre + bias;
    x_data2 = repmat(x_data2, 1, 11);
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
    title('Tactile');
    ylabel('Score');
    ylim([-12, +12])
    xlabel('Conditions');

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

figure
    centre = [1, 2.75, 4.5];
    bias = 0.3;
    x_data1 = centre - bias;
    x_data1 = repmat(x_data1, 1, 11);
    x_data2 = centre + bias;
    x_data2 = repmat(x_data2, 1, 11);
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

figure
    centre = [1, 2.75, 4.5];
    bias = 0.3;
    x_data1 = centre - bias;
    x_data1 = repmat(x_data1, 1, 11);
    x_data2 = centre + bias;
    x_data2 = repmat(x_data2, 1, 11);
    % x_data2 = repmat(x_data1, 1, 11);
    y_data1 = ExternalAppearanceScoreTable.Score(1:33);
    y_data2 = ExternalAppearanceScoreTable.Score(34:end-1);
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
    ylim([-12, +12])
    xlabel('Conditions');