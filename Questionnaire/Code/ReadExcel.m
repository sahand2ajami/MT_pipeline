function myStruct = ReadExcel(myStruct, excelFilePath, cellRange, QuestionnaireString, CondtionString, sheetName)
%     data = xlsread(excelFilePath, sheetName, cellRange);
    data = readmatrix(excelFilePath, 'Sheet', sheetName, 'Range', cellRange);
    myStruct.(sheetName(4:end)).(QuestionnaireString).(CondtionString).(strcat('S', sheetName(1:2))) = data;
    
end