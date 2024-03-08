function XTickLabels = BoxPlot(n_datapoints, xloc, ydata, color, MarkerEdgeAlpha, ...
    MarkerFaceAlpha, MarkerSize, scatter_bias, SizeData, x_label, FontName, ...
    FontSize)



xdata = xloc * ones(1, n_datapoints);
box_chart = boxchart(xdata, ydata);
box_chart.BoxFaceColor = color;
box_chart.MarkerColor = color;
box_chart.MarkerSize = MarkerSize;
box_chart.WhiskerLineColor = color;
box_chart.Parent.XTick = [xloc];
XTickLabels = [XTickLabels, x_label];
box_chart.Parent.XTickLabel = XTickLabels;
box_chart.Parent.Subtitle.FontName = FontName;

hold on
xdata = (xloc + scatter_bias) * ones(1, n_datapoints);
scatter_boxchart = scatter(xdata, ydata);
scatter_boxchart.CData = color;
scatter_boxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
scatter_boxchart.MarkerFaceColor = color;
scatter_boxchart.MarkerFaceAlpha = MarkerFaceAlpha;
scatter_boxchart.SizeData = SizeData;
XTickLabels = [XTickLabels, newLabel];
    



%     score_scatterboxchart = scatter(withhaptics_baseline_q6_x, withhaptics_baseline_gamescore/60*100);
    

%     score_scatterboxchart = scatter(withouthaptics_baseline_q6_x,withouthaptics_baseline_gamescore/60*100);
%     score_scatterboxchart.CData = color_withouthaptics;
%     score_scatterboxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
%     score_scatterboxchart.MarkerFaceColor = color_withouthaptics;
%     score_scatterboxchart.MarkerFaceAlpha = MarkerFaceAlpha;
%     score_scatterboxchart.SizeData = SizeData;



%     %%%% Train
%     score_boxchart = boxchart(withhaptics_train_q6_x, withhaptics_train_gamescore/60*100);
%     score_boxchart.BoxFaceColor = color_withhaptics;
%     score_boxchart.MarkerColor = color_withhaptics;
%     score_boxchart.MarkerSize = 3;
%     score_boxchart.WhiskerLineColor = color_withhaptics;
%     hold on
%     score_boxchart = boxchart(withouthaptics_train_q6_x, withouthaptics_train_gamescore/60*100);
%     score_boxchart.BoxFaceColor = color_withouthaptics;
%     score_boxchart.MarkerColor = color_withouthaptics;
%     score_boxchart.MarkerSize = 3;
%     score_boxchart.WhiskerLineColor = color_withouthaptics;
%     
%     score_scatterboxchart = scatter(withhaptics_train_q6_x, withhaptics_train_gamescore/60*100);
%     score_scatterboxchart.CData = color_withhaptics;
%     score_scatterboxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
%     score_scatterboxchart.MarkerFaceColor = color_withhaptics;
%     score_scatterboxchart.MarkerFaceAlpha = MarkerFaceAlpha;
%     score_scatterboxchart.SizeData = SizeData;
% 
%     score_scatterboxchart = scatter(withouthaptics_train_q6_x,withouthaptics_train_gamescore/60*100);
%     score_scatterboxchart.CData = color_withouthaptics;
%     score_scatterboxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
%     score_scatterboxchart.MarkerFaceColor = color_withouthaptics;
%     score_scatterboxchart.MarkerFaceAlpha = MarkerFaceAlpha;
%     score_scatterboxchart.SizeData = SizeData;

    %%%% Test
%     score_boxchart = boxchart(withhaptics_test_q6_x, withhaptics_test_gamescore/60*100);
%     score_boxchart.BoxFaceColor = color_withhaptics;
%     score_boxchart.MarkerColor = color_withhaptics;
%     score_boxchart.MarkerSize = 3;
%     hold on
%     score_boxchart = boxchart(withouthaptics_test_q6_x, withouthaptics_test_gamescore/60*100);
%     score_boxchart.BoxFaceColor = color_withouthaptics;
%     score_boxchart.MarkerColor = color_withouthaptics;
%     score_boxchart.MarkerSize = 3;
%     score_legend = legend("With haptics", "Without haptics", "Location", "northOutside")
%     score_boxchart.Parent.Legend.Units = 'points';
%     score_boxchart.Parent.Legend.FontSize = 9;
%     score_boxchart.Parent.Legend.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.Legend.Orientation = 'horizontal';

%     score_boxchart.Parent.XTick = [centre - bias_between_conditions, centre, centre + bias_between_conditions];
%     score_boxchart.Parent.XTickLabel = {'Baseline', 'Train', 'Test'};
%     score_boxchart.Parent.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.Units = 'points';
%     score_boxchart.Parent.FontSize = 9;

%     score_boxchart.Parent.XLim = [centre(1) - bias_between_conditions - bias_between_groups - score_boxchart.BoxWidth, centre(1) + bias_between_conditions + bias_between_groups + score_boxchart.BoxWidth];
%     score_boxchart.Parent.Subtitle.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.Subtitle.Units = 'points';
%     score_boxchart.Parent.Subtitle.FontSize = 9;

%     score_boxchart.Parent.YLabel.String = "Success rate";
%     score_boxchart.Parent.YLabel.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.YLabel.FontUnits = "points";
%     score_boxchart.Parent.YLabel.FontSize = 9;
% % % % %     score_boxchart.MarkerSize = 3;
% % % % %     ylim([0, 105])
% % % % %     StatisticalLines2(withhaptics_baseline_q6_x(1), withhaptics_test_q6_x(1) - bias2, '**', 90, 2, 9)
% % % % %     StatisticalLines2(withhaptics_test_q6_x(1) + bias2, withouthaptics_test_q6_x(1), '***', 90, 2, 9)
% % % % %     StatisticalLines2(withouthaptics_baseline_q6_x(1), withouthaptics_test_q6_x(1), '***', 99, 2, 9)
    ax  = gca();
    ax.FontSize=FontSize;

% %% STAT TEST - TTEST2
% x = withouthaptics_baseline_gamescore;
% y = withouthaptics_test_gamescore;
% [h,p,ci,stats] = ttest(x,y)
% %%
% PerformanceFigure = figure;
% PerformanceFigure.Units = "centimeters";
% %     old_pos = PerformanceFigure.Position;
%     PerformanceFigure.Position(3) = plot_width/2;
%     PerformanceFigure.Position(4) = 4;
% % ScorePlot = subplot(1, 2, 2);
% % ScorePlot.Units = "centimeters";
% % ScorePlot.Position(2) = 1;
% % ScorePlot.Position(4) = 4;
%     n_withhaptics = 11;
%     n_withouthaptics = 11;
%     centre = 1;
%     bias_between_groups = 0.3;
%     bias_between_conditions = 1.5;
%     bias_between_questions = 0.7;
%     color_withhaptics = [0 0.4470 0.7410];
%     color_withouthaptics = [0.8500 0.3250 0.0980];
%     bias2 = 0.02;
% 
%     withhaptics_baseline_q6_x = (centre - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
%     withouthaptics_baseline_q6_x = (centre - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
%     
%     withhaptics_train_q6_x = (centre - bias_between_groups) * ones(1, n_withhaptics);
%     withouthaptics_train_q6_x = (centre + bias_between_groups) * ones(1, n_withouthaptics);
%     
%     withhaptics_test_q6_x = (centre + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
%     withouthaptics_test_q6_x = (centre + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
%  
% %%%Baseline
%     score_boxchart = boxchart(withhaptics_baseline_q6_x, with_haptics_baseline_time);
%     score_boxchart.BoxFaceColor = color_withhaptics;
%     score_boxchart.MarkerColor = color_withhaptics;
%     score_boxchart.MarkerSize = 3;
%     hold on
%     score_boxchart = boxchart(withouthaptics_baseline_q6_x, without_haptics_baseline_time);
%     score_boxchart.BoxFaceColor = color_withouthaptics;
%     score_boxchart.MarkerColor = color_withouthaptics;
%     score_boxchart.MarkerSize = 3;
% 
%     %%%% Train
%     score_boxchart = boxchart(withhaptics_train_q6_x, with_haptics_train_time);
%     score_boxchart.BoxFaceColor = color_withhaptics;
%     score_boxchart.MarkerColor = color_withhaptics;
%     score_boxchart.MarkerSize = 3;
%     hold on
%     score_boxchart = boxchart(withouthaptics_train_q6_x, without_haptics_train_time);
%     score_boxchart.BoxFaceColor = color_withouthaptics;
%     score_boxchart.MarkerColor = color_withouthaptics;
%     score_boxchart.MarkerSize = 3;
%     
%     %%%% Test
%     score_boxchart = boxchart(withhaptics_test_q6_x, with_haptics_test_time);
%     score_boxchart.BoxFaceColor = color_withhaptics;
%     score_boxchart.MarkerColor = color_withhaptics;
%     score_boxchart.MarkerSize = 3;
%     hold on
%     score_boxchart = boxchart(withouthaptics_test_q6_x, without_haptics_test_time);
%     score_boxchart.BoxFaceColor = color_withouthaptics;
%     score_boxchart.MarkerColor = color_withouthaptics;
%     score_boxchart.MarkerSize = 3;
% 
%     score_boxchart.Parent.XTick = [centre - bias_between_conditions, centre, centre + bias_between_conditions];
%     score_boxchart.Parent.XTickLabel = {'Baseline', 'Train', 'Test'};
%     score_boxchart.Parent.FontName = 'Linux Libertine G';
% %     score_boxchart.Parent.Units = 'points';
% %     score_boxchart.Parent.FontSize = 9;
% 
%     score_boxchart.Parent.XLim = [centre(1) - bias_between_conditions - bias_between_groups - score_boxchart.BoxWidth, centre(1) + bias_between_conditions + bias_between_groups + score_boxchart.BoxWidth];
%     score_boxchart.Parent.Subtitle.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.Subtitle.Units = 'points';
% %     score_boxchart.Parent.Subtitle.FontSize = 9;
% %     score_legend = legend("With haptics", "Without haptics", "Location", "northoutside")
% %     score_boxchart.Parent.Legend.Units = 'points';
% %     score_boxchart.Parent.Legend.FontSize = 9;
% %     score_boxchart.Parent.Legend.FontName = 'Linux Libertine G';
% %     score_boxchart.Parent.Legend.Orientation = 'horizontal';
% %     score_boxchart.Parent.Legend.Position = [200 290 183.7500 13.5000];
%     score_boxchart.Parent.YLabel.String = "Time [s]";
%     score_boxchart.Parent.YLabel.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.YLabel.FontUnits = "points";
% %     score_boxchart.Parent.YLabel.FontSize = 9;
%     score_boxchart.MarkerSize = 3;
% 
% %     score_boxchart.Parent.Position(2) = 70
%     ylim([0, 2.6])
%     ax  = gca();
%     ax.FontSize=9;
