function csv2mat(start, stop)

    % with'*.' dir will read folder names only
    folderName = dir('*');
    
    % i starts fom 3 becasue folderName first two elements are '.' and '..'
    for i = start:stop
        
        % go to the folder
        folderName(i).name
        cd(folderName(i).name)
    
        % with'*.csv' dir will read csv files only
        fileName = dir('*.csv');
    
        for j = 1:length(fileName)
            % convert the '.csv' file into a '.mat' file. 
             data = csv22mat(string(fileName(j).name));
             
            % (1:end-4) removes the '.csv' from the end of the fileName(4) letting matlab save delsys as a '.mat' file.
            save(string(fileName(j).name(1:end-4)), "data");
        end
    
        % go back to the main folder
        cd ..
    end
end