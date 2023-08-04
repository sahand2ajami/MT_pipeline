function PlotTrajInfo(data1,data2, myYlabel, myTitle)
     % Calculate mean and standard deviation
    mean1 = mean(data1);
    std1 = std(data1);
    mean2 = mean(data2);
    std2 = std(data2);
        


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
%         xlabel(["Baseline", "Test"]);
    ylabel(myYlabel);
    legend('Baseline', 'Test', 'Location','bestoutside');
    title(myTitle);
    
    % Adjust the x-axis limits
    xlim([min(barPositions)-barWidth, max(barPositions)+2*barWidth]);
    
    % Adjust the x-axis tick labels
    xticks([]);
end

