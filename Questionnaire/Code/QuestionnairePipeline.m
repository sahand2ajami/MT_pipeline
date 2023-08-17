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
    BodyData = ReadExcel(excelFilePath, 'D29:F29', 'ExternalAppearance', 'Train', sheetName);
    BodyData = ReadExcel(excelFilePath, 'D39:F39', 'ExternalAppearance', 'Test', sheetName);

    
    % Display or process the data as needed
%     disp(['Sheet: ' sheetName]);
%     disp('Data:');
%     disp(data);
end

