function [scatter_boxchart, my_boxchart, x1, x2, x3, x4, x5, x6] = my_boxplot(y1, y2, y3, y4, y5, y6, markersize, ...
    font, font_size, condition1, condition2, condition3, y_label, y_lim, my_title, box_width, ...
    line_width)
%MY_BOXPLOT Summary of this function goes here
%   Detailed explanation goes here
plot_width = 8.6;
my_figure = figure;
my_figure.Units = "centimeters";
my_figure.Position(3) = plot_width/2;
my_figure.Position(4) = 4;

x_centreloc = 1;
bias = box_width*1.5;
MarkerEdgeAlpha = 0.2;
MarkerFaceAlpha = 0.2;

color1 = [0 0.4470 0.7410];
color2 = [0.8500 0.3250 0.0980];

n_group1 = length(y1);
n_group2 = length(y2);
n_group3 = length(y3);
n_group4 = length(y4);
n_group5 = length(y5);
n_group6 = length(y6);

x1_loc_boxchart = (x_centreloc + 0*bias) * ones(1, n_group1);
x2_loc_boxchart = (x_centreloc + 1*bias) * ones(1, n_group2);
x3_loc_boxchart = (x_centreloc + 2.25*bias) * ones(1, n_group3);
x4_loc_boxchart = (x_centreloc + 3.25*bias) * ones(1, n_group4);
x5_loc_boxchart = (x_centreloc + 4.5*bias) * ones(1, n_group5);
x6_loc_boxchart = (x_centreloc + 5.5*bias) * ones(1, n_group6);

x1 = x1_loc_boxchart(1);
x2 = x2_loc_boxchart(1);
x3 = x3_loc_boxchart(1);
x4 = x4_loc_boxchart(1);
x5 = x5_loc_boxchart(1);
x6 = x6_loc_boxchart(1);

% Add jitter to x-coordinates for scatter plot
jitter_amount = 0.1; % adjust this value as needed for your data scale
x1_jitter = x1_loc_boxchart + (rand(1, n_group1) - 0.25) * jitter_amount;
x2_jitter = x2_loc_boxchart + (rand(1, n_group2) - 0.25) * jitter_amount;
x3_jitter = x3_loc_boxchart + (rand(1, n_group3) - 0.25) * jitter_amount;
x4_jitter = x4_loc_boxchart + (rand(1, n_group4) - 0.25) * jitter_amount;
x5_jitter = x5_loc_boxchart + (rand(1, n_group5) - 0.25) * jitter_amount;
x6_jitter = x6_loc_boxchart + (rand(1, n_group6) - 0.25) * jitter_amount;


my_boxchart = boxchart(x1_loc_boxchart, y1);
    my_boxchart.BoxFaceColor = color1;
    my_boxchart.BoxEdgeColor = color1;
    my_boxchart.MarkerColor = color1;
    my_boxchart.WhiskerLineColor = color1;
    my_boxchart.MarkerSize = markersize;
    my_boxchart.BoxFaceAlpha = 0;
    my_boxchart.BoxWidth = box_width;
    my_boxchart.LineWidth = line_width;

hold on
my_boxchart = boxchart(x2_loc_boxchart, y2);
    my_boxchart.BoxFaceColor = color2;
    my_boxchart.BoxEdgeColor = color2;
    my_boxchart.MarkerColor = color2;
    my_boxchart.WhiskerLineColor = color2;
    my_boxchart.MarkerSize = markersize;
    my_boxchart.BoxFaceAlpha = 0;
    my_boxchart.BoxWidth = box_width;
    my_boxchart.LineWidth = line_width;
    
my_boxchart = boxchart(x3_loc_boxchart, y3);
    my_boxchart.BoxFaceColor = color1;
    my_boxchart.BoxEdgeColor = color1;
    my_boxchart.MarkerColor = color1;
    my_boxchart.WhiskerLineColor = color1;
    my_boxchart.MarkerSize = markersize;
    my_boxchart.BoxFaceAlpha = 0;
    my_boxchart.BoxWidth = box_width;
    my_boxchart.LineWidth = line_width;

hold on
my_boxchart = boxchart(x4_loc_boxchart, y4);
    my_boxchart.BoxFaceColor = color2;
    my_boxchart.BoxEdgeColor = color2;
    my_boxchart.MarkerColor = color2;
    my_boxchart.WhiskerLineColor = color2;
    my_boxchart.MarkerSize = markersize;
    my_boxchart.BoxFaceAlpha = 0;
    my_boxchart.BoxWidth = box_width;
    my_boxchart.LineWidth = line_width;
    
my_boxchart = boxchart(x5_loc_boxchart, y5);
    my_boxchart.BoxFaceColor = color1;
    my_boxchart.BoxEdgeColor = color1;
    my_boxchart.MarkerColor = color1;
    my_boxchart.WhiskerLineColor = color1;
    my_boxchart.MarkerSize = markersize;
    my_boxchart.BoxFaceAlpha = 0;
    my_boxchart.BoxWidth = box_width;
    my_boxchart.LineWidth = line_width;

my_boxchart = boxchart(x6_loc_boxchart, y6);
    my_boxchart.BoxFaceColor = color2;
    my_boxchart.BoxEdgeColor = color2;
    my_boxchart.MarkerColor = color2;
    my_boxchart.WhiskerLineColor = color2;
    my_boxchart.MarkerSize = markersize;
    my_boxchart.BoxFaceAlpha = 0;
    my_boxchart.BoxWidth = box_width;
    my_boxchart.LineWidth = line_width;


my_boxchart.Parent.XTick = [(x1_loc_boxchart(1) + x2_loc_boxchart(1)) / 2, ...
    (x3_loc_boxchart(1) + x4_loc_boxchart(1)) / 2, (x5_loc_boxchart(1) + x6_loc_boxchart(1)) / 2];
my_boxchart.Parent.XTickLabel = {condition1, condition2, condition3};
my_boxchart.Parent.FontName = font; % 'Linux Libertine G'
my_boxchart.Parent.Units = 'points';
my_boxchart.Parent.FontSize = font_size; % 9
my_boxchart.Parent.Title.String = my_title;
my_boxchart.BoxFaceAlpha = 0;
ylim(y_lim)
ylabel(y_label)

scatter_boxchart = scatter(x1_jitter, y1);
    scatter_boxchart.CData = color1;
    scatter_boxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    scatter_boxchart.MarkerFaceColor = color1;
    scatter_boxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    scatter_boxchart.SizeData = markersize*2;
hold on
    scatter_boxchart = scatter(x2_jitter, y2);
    scatter_boxchart.CData = color2;
    scatter_boxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    scatter_boxchart.MarkerFaceColor = color2;
    scatter_boxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    scatter_boxchart.SizeData = markersize*2;

scatter_boxchart = scatter(x3_jitter, y3);
    scatter_boxchart.CData = color1;
    scatter_boxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    scatter_boxchart.MarkerFaceColor = color1;
    scatter_boxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    scatter_boxchart.SizeData = markersize*2;

scatter_boxchart = scatter(x4_jitter, y4);
    scatter_boxchart.CData = color2;
    scatter_boxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    scatter_boxchart.MarkerFaceColor = color2;
    scatter_boxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    scatter_boxchart.SizeData = markersize*2;

scatter_boxchart = scatter(x5_jitter, y5);
    scatter_boxchart.CData = color1;
    scatter_boxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    scatter_boxchart.MarkerFaceColor = color1;
    scatter_boxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    scatter_boxchart.SizeData = markersize*2;

scatter_boxchart = scatter(x6_jitter, y6);
    scatter_boxchart.CData = color2;
    scatter_boxchart.MarkerEdgeAlpha = MarkerEdgeAlpha;
    scatter_boxchart.MarkerFaceColor = color2;
    scatter_boxchart.MarkerFaceAlpha = MarkerFaceAlpha;
    scatter_boxchart.SizeData = markersize*2;

% Create a legend in the middle of the figure
% hLegend = legend('With haptics', 'Without haptics', 'Location', 'northoutside', 'Orientation','horizontal');

% % Adjust the position of the legend
% pos = get(hLegend, 'Position');
% pos(1) = 0.5 - pos(3)/2; % Center the legend horizontally
% pos(2) = 1 - pos(4);     % Place the legend at the top of the figure
% set(hLegend, 'Position', pos);
% return my_boxchart
end

