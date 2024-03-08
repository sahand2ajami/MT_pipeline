%% Score plot
close all
plot_width = 8.6;

PerformanceFigure = figure;
PerformanceFigure.Units = "centimeters";
%     old_pos = PerformanceFigure.Position;
    PerformanceFigure.Position(3) = plot_width/2;
    PerformanceFigure.Position(4) = 4; %% ????

    MarkerEdgeAlpha = 1;
    scatter_bias = 0.3;
    MarkerFaceAlpha = 0.4;
    SizeData = 3;

    n_withhaptics = 11;
    n_withouthaptics = 11;
    centre = 1;
    bias_between_groups = 0.3;
    bias_between_conditions = 1.5;
    bias_between_questions = 0.7;
    color_withhaptics = [0 0.4470 0.7410];
    color_withouthaptics = [0.8500 0.3250 0.0980];
    bias2 = 0.02;

    withhaptics_baseline_q6_x = (centre - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_baseline_q6_x = (centre - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    withhaptics_train_q6_x = (centre - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_train_q6_x = (centre + bias_between_groups) * ones(1, n_withouthaptics);
    withhaptics_test_q6_x = (centre + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_test_q6_x = (centre + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);

    score_boxchart = boxchart(withhaptics_baseline_q6_x, withhaptics_baseline_gamescore/60*100);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    score_boxchart.MarkerSize = 3;
    score_boxchart.WhiskerLineColor = color_withhaptics;
   
    hold on
    score_boxchart = boxchart(withouthaptics_baseline_q6_x, withouthaptics_baseline_gamescore/60*100);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    score_boxchart.MarkerSize = 3;
    score_boxchart.WhiskerLineColor = color_withouthaptics;
%     score_boxchart.BoxEdgeColorMode = 
    
    score_scatterboxchart = scatter(withhaptics_baseline_q6_x, withhaptics_baseline_gamescore/60*100);
    score_scatterboxchart.CData = color_withhaptics;
    score_scatterboxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    score_scatterboxchart.MarkerFaceColor = color_withhaptics;
    score_scatterboxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    score_scatterboxchart.SizeData = SizeData;

    score_scatterboxchart = scatter(withouthaptics_baseline_q6_x,withouthaptics_baseline_gamescore/60*100);
    score_scatterboxchart.CData = color_withouthaptics;
    score_scatterboxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    score_scatterboxchart.MarkerFaceColor = color_withouthaptics;
    score_scatterboxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    score_scatterboxchart.SizeData = SizeData;



    %%%% Train
    score_boxchart = boxchart(withhaptics_train_q6_x, withhaptics_train_gamescore/60*100);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    score_boxchart.MarkerSize = 3;
    score_boxchart.WhiskerLineColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_train_q6_x, withouthaptics_train_gamescore/60*100);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    score_boxchart.MarkerSize = 3;
    score_boxchart.WhiskerLineColor = color_withouthaptics;
    
    score_scatterboxchart = scatter(withhaptics_train_q6_x, withhaptics_train_gamescore/60*100);
    score_scatterboxchart.CData = color_withhaptics;
    score_scatterboxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    score_scatterboxchart.MarkerFaceColor = color_withhaptics;
    score_scatterboxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    score_scatterboxchart.SizeData = SizeData;

    score_scatterboxchart = scatter(withouthaptics_train_q6_x,withouthaptics_train_gamescore/60*100);
    score_scatterboxchart.CData = color_withouthaptics;
    score_scatterboxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    score_scatterboxchart.MarkerFaceColor = color_withouthaptics;
    score_scatterboxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    score_scatterboxchart.SizeData = SizeData;

    %%%% Test
    score_boxchart = boxchart(withhaptics_test_q6_x, withhaptics_test_gamescore/60*100);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    score_boxchart.MarkerSize = 3;
    score_boxchart.WhiskerLineColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_test_q6_x, withouthaptics_test_gamescore/60*100);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    score_boxchart.MarkerSize = 3;
    score_boxchart.WhiskerLineColor = color_withouthaptics;
%     score_legend = legend("With haptics", "Without haptics", "Location", "northOutside")
%     score_boxchart.Parent.Legend.Units = 'points';
%     score_boxchart.Parent.Legend.FontSize = 9;
%     score_boxchart.Parent.Legend.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.Legend.Orientation = 'horizontal';

    score_boxchart.Parent.XTick = [centre - bias_between_conditions, centre, centre + bias_between_conditions];
    score_boxchart.Parent.XTickLabel = {'Baseline', 'Train', 'Test'};
    score_boxchart.Parent.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.Units = 'points';
%     score_boxchart.Parent.FontSize = 9;

    score_boxchart.Parent.XLim = [centre(1) - bias_between_conditions - bias_between_groups - score_boxchart.BoxWidth, centre(1) + bias_between_conditions + bias_between_groups + score_boxchart.BoxWidth];
    score_boxchart.Parent.Subtitle.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.Subtitle.Units = 'points';
%     score_boxchart.Parent.Subtitle.FontSize = 9;

    score_boxchart.Parent.YLabel.String = "Success rate";
    score_boxchart.Parent.YLabel.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.YLabel.FontUnits = "points";
%     score_boxchart.Parent.YLabel.FontSize = 9;
    score_boxchart.MarkerSize = 3;

    score_scatterboxchart = scatter(withhaptics_test_q6_x, withhaptics_test_gamescore/60*100);
    score_scatterboxchart.CData = color_withhaptics;
    score_scatterboxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    score_scatterboxchart.MarkerFaceColor = color_withhaptics;
    score_scatterboxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    score_scatterboxchart.SizeData = SizeData;

    score_scatterboxchart = scatter(withouthaptics_test_q6_x,withouthaptics_test_gamescore/60*100);
    score_scatterboxchart.CData = color_withouthaptics;
    score_scatterboxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    score_scatterboxchart.MarkerFaceColor = color_withouthaptics;
    score_scatterboxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    score_scatterboxchart.SizeData = SizeData;


    ylim([0, 105])
    StatisticalLines2(withhaptics_baseline_q6_x(1), withhaptics_test_q6_x(1) - bias2, '**', 90, 2, 9)
    StatisticalLines2(withhaptics_test_q6_x(1) + bias2, withouthaptics_test_q6_x(1), '***', 90, 2, 9)
    StatisticalLines2(withouthaptics_baseline_q6_x(1), withouthaptics_test_q6_x(1), '***', 99, 2, 9)
    ax  = gca();
    ax.FontSize=9;

%% STAT TEST - TTEST2
x = withouthaptics_baseline_gamescore;
y = withouthaptics_test_gamescore;
[h,p,ci,stats] = ttest(x,y)
%%
PerformanceFigure = figure;
PerformanceFigure.Units = "centimeters";
%     old_pos = PerformanceFigure.Position;
    PerformanceFigure.Position(3) = plot_width/2;
    PerformanceFigure.Position(4) = 4;
% ScorePlot = subplot(1, 2, 2);
% ScorePlot.Units = "centimeters";
% ScorePlot.Position(2) = 1;
% ScorePlot.Position(4) = 4;
    n_withhaptics = 11;
    n_withouthaptics = 11;
    centre = 1;
    bias_between_groups = 0.3;
    bias_between_conditions = 1.5;
    bias_between_questions = 0.7;
    color_withhaptics = [0 0.4470 0.7410];
    color_withouthaptics = [0.8500 0.3250 0.0980];
    bias2 = 0.02;

    withhaptics_baseline_q6_x = (centre - bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_baseline_q6_x = (centre - bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_train_q6_x = (centre - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_train_q6_x = (centre + bias_between_groups) * ones(1, n_withouthaptics);
    
    withhaptics_test_q6_x = (centre + bias_between_conditions - bias_between_groups) * ones(1, n_withhaptics);
    withouthaptics_test_q6_x = (centre + bias_between_conditions + bias_between_groups) * ones(1, n_withouthaptics);
 
%%%Baseline
    score_boxchart = boxchart(withhaptics_baseline_q6_x, with_haptics_baseline_time);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    score_boxchart.MarkerSize = 3;
    score_boxchart.WhiskerLineColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_baseline_q6_x, without_haptics_baseline_time);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    score_boxchart.MarkerSize = 3;
    score_boxchart.WhiskerLineColor = color_withouthaptics;

    score_scatterboxchart = scatter(withhaptics_baseline_q6_x, with_haptics_baseline_time);
    score_scatterboxchart.CData = color_withhaptics;
    score_scatterboxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    score_scatterboxchart.MarkerFaceColor = color_withhaptics;
    score_scatterboxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    score_scatterboxchart.SizeData = SizeData;

    score_scatterboxchart = scatter(withouthaptics_baseline_q6_x,without_haptics_baseline_time);
    score_scatterboxchart.CData = color_withouthaptics;
    score_scatterboxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    score_scatterboxchart.MarkerFaceColor = color_withouthaptics;
    score_scatterboxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    score_scatterboxchart.SizeData = SizeData;

    %%%% Train
    score_boxchart = boxchart(withhaptics_train_q6_x, with_haptics_train_time);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    score_boxchart.MarkerSize = 3;
    score_boxchart.WhiskerLineColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_train_q6_x, without_haptics_train_time);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    score_boxchart.MarkerSize = 3;
    score_boxchart.WhiskerLineColor = color_withouthaptics;
    
    score_scatterboxchart = scatter(withhaptics_train_q6_x, with_haptics_train_time);
    score_scatterboxchart.CData = color_withhaptics;
    score_scatterboxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    score_scatterboxchart.MarkerFaceColor = color_withhaptics;
    score_scatterboxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    score_scatterboxchart.SizeData = SizeData;

    score_scatterboxchart = scatter(withouthaptics_train_q6_x,without_haptics_train_time);
    score_scatterboxchart.CData = color_withouthaptics;
    score_scatterboxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    score_scatterboxchart.MarkerFaceColor = color_withouthaptics;
    score_scatterboxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    score_scatterboxchart.SizeData = SizeData;

    %%%% Test
    score_boxchart = boxchart(withhaptics_test_q6_x, with_haptics_test_time);
    score_boxchart.BoxFaceColor = color_withhaptics;
    score_boxchart.MarkerColor = color_withhaptics;
    score_boxchart.MarkerSize = 3;
    score_boxchart.WhiskerLineColor = color_withhaptics;
    hold on
    score_boxchart = boxchart(withouthaptics_test_q6_x, without_haptics_test_time);
    score_boxchart.BoxFaceColor = color_withouthaptics;
    score_boxchart.MarkerColor = color_withouthaptics;
    score_boxchart.MarkerSize = 3;
    score_boxchart.WhiskerLineColor = color_withouthaptics;

    score_scatterboxchart = scatter(withhaptics_test_q6_x, with_haptics_test_time);
    score_scatterboxchart.CData = color_withhaptics;
    score_scatterboxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    score_scatterboxchart.MarkerFaceColor = color_withhaptics;
    score_scatterboxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    score_scatterboxchart.SizeData = SizeData;

    score_scatterboxchart = scatter(withouthaptics_test_q6_x,without_haptics_test_time);
    score_scatterboxchart.CData = color_withouthaptics;
    score_scatterboxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    score_scatterboxchart.MarkerFaceColor = color_withouthaptics;
    score_scatterboxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    score_scatterboxchart.SizeData = SizeData;

    score_boxchart.Parent.XTick = [centre - bias_between_conditions, centre, centre + bias_between_conditions];
    score_boxchart.Parent.XTickLabel = {'Baseline', 'Train', 'Test'};
    score_boxchart.Parent.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.Units = 'points';
%     score_boxchart.Parent.FontSize = 9;

    score_boxchart.Parent.XLim = [centre(1) - bias_between_conditions - bias_between_groups - score_boxchart.BoxWidth, centre(1) + bias_between_conditions + bias_between_groups + score_boxchart.BoxWidth];
    score_boxchart.Parent.Subtitle.FontName = 'Linux Libertine G';
    score_boxchart.Parent.Subtitle.Units = 'points';
%     score_boxchart.Parent.Subtitle.FontSize = 9;
%     score_legend = legend("With haptics", "Without haptics", "Location", "northoutside")
%     score_boxchart.Parent.Legend.Units = 'points';
%     score_boxchart.Parent.Legend.FontSize = 9;
%     score_boxchart.Parent.Legend.FontName = 'Linux Libertine G';
%     score_boxchart.Parent.Legend.Orientation = 'horizontal';
%     score_boxchart.Parent.Legend.Position = [200 290 183.7500 13.5000];
    score_boxchart.Parent.YLabel.String = "Time [s]";
    score_boxchart.Parent.YLabel.FontName = 'Linux Libertine G';
    score_boxchart.Parent.YLabel.FontUnits = "points";
%     score_boxchart.Parent.YLabel.FontSize = 9;
    score_boxchart.MarkerSize = 3;

%     score_boxchart.Parent.Position(2) = 70
    ylim([0, 2.6])
    ax  = gca();
    ax.FontSize=9;

% % Create a legend in the middle of the figure
% hLegend = legend('With haptics', 'Without haptics', 'Location', 'best', 'Orientation','horizontal');
% 
% % Adjust the position of the legend
% pos = get(hLegend, 'Position');
% pos(1) = 0.5 - pos(3)/2; % Center the legend horizontally
% pos(2) = 1 - pos(4);     % Place the legend at the top of the figure
% set(hLegend, 'Position', pos);

%%
close all
y1 = withhaptics_baseline_gamescore/60*100;
y2 = withouthaptics_baseline_gamescore/60*100;
y3 = withhaptics_train_gamescore/60*100;
y4 = withouthaptics_train_gamescore/60*100;
y5 = withhaptics_test_gamescore/60*100;
y6 = withouthaptics_test_gamescore/60*100;


[my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, y3, y4, y5, y6, 5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', 'Success rate', [0, 100], "", 0.5, 0.6);
StatisticalLines(x1, 0.995*x5, '**', 90, 2, 7)
StatisticalLines(1.005*x5, x6, '***', 90, 2, 7)
StatisticalLines(x2, x5, '**', 97, 2, 7)
%%
close all
y1 = with_haptics_baseline_time;
y2 = without_haptics_baseline_time;
y3 = with_haptics_train_time;
y4 = without_haptics_train_time;
y5 = with_haptics_test_time;
y6 = without_haptics_test_time;


[my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, y3, y4, y5, y6, 5, 'Linux Libertine G', 9, 'Baseline', 'Train', 'Test', 'Time [s]', [0, 3], "", 0.5, 0.6);

% StatisticalLines(x1, 0.995*x5, '**', 90, 2, 15, hLegend)
% StatisticalLines(1.005*x5, x6, '***', 90, 2, 15, hLegend)
% StatisticalLines(x2, x5, '**', 95, 2, 15, hLegend)