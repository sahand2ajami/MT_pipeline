function myStruct = ReadExcel(excelFilePath, cellRange, QuestionnaireString, CondtionString, sheetName)
    global myStruct
    data = xlsread(excelFilePath, sheetName, cellRange);
    myStruct.(sheetName(4:end)).(QuestionnaireString).(CondtionString).(strcat('S', sheetName(1:2))) = data;
end