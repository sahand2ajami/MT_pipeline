function PlotData(Data)
    
    GroupNames = fieldnames(Data);
    % DropPosErrorData = struct();
    
    k = 1;
    figure
    
    % Change the dimensions of the figure
    newWidth = 1000;  % New width in pixels
    newHeight = 800; % New height in pixels
    % set(gcf, 'Position', [100, 100, newWidth, newHeight]);
    set(gca, 'XTickLabel', {});
    set(gca, 'XTick', []);
    
    % This loops in the "withHaptics" and "withoutHaptics" groups
    for i = 1:length(GroupNames)
        % i = 1 WithoutHaptics
        % i = 2 WithHaptics
    
        Participants = Data.(GroupNames{i});
        
        % This loops in each participant of each group
        for j = 1:length(fieldnames(Participants))
            ParticipantNames = fieldnames(Participants);
     
            myData = Participants.(ParticipantNames{j});
    
            % Example data
            data1 = myData.error_baseline;
            data2 = myData.error_test(end-4:end);
    %         data2 = Data.error_test(1:end);
            
            % Calculate mean and standard deviation
            mean1 = mean(data1);
            std1 = std(data1);
            mean2 = mean(data2);
            std2 = std(data2);
            
            % Create a figure
            subplot(length(GroupNames), length(fieldnames(Participants)), k)
    
            % Set the position of each bar chart
            barPositions = 0;
            barWidth = 0.3;
            set(gca, 'XTick', []);
            % Plot the first bar chart
            bar(barPositions, mean1, barWidth);
            hold on;
            bar(barPositions + barWidth, mean2, barWidth);
            
            errorbar(barPositions, mean1, std1, 'k.', 'LineWidth', 1);
            
            % Plot the second bar chart
            errorbar(barPositions + barWidth, mean2, std2, 'k.', 'LineWidth', 1);
            
            % Customize the chart
            ylabel('Error [m]');
            legend('Baseline', 'Test', 'Location','bestoutside');
            title(strcat(GroupNames{i}, ' - P', num2str(j)));
            
            % Adjust the x-axis limits
            xlim([min(barPositions)-barWidth, max(barPositions)+2*barWidth]);
            
            % Adjust the x-axis tick labels
            xticks([]);
            k = k + 1;
        end
    end
end

