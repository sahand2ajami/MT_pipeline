function StatisticalLines(First, Last, StarString, YLevel, Yclearance, StarFont, LegendProperties)
    hold on
    plot([First, Last], [YLevel, YLevel], 'k')
    LegendProperties.String(end) = [];
    plot([First, First], [YLevel, YLevel - Yclearance], 'k')
    LegendProperties.String(end) = [];
    plot([Last, Last], [YLevel, YLevel - Yclearance], 'k')
    LegendProperties.String(end) = [];
    text((First+Last)/2, YLevel + Yclearance, StarString, HorizontalAlignment='center')
end