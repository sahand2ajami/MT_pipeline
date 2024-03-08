function StatisticalLines2(First, Last, StarString, YLevel, Yclearance, StarFont)
    hold on
    plot([First, Last], [YLevel, YLevel], 'k')

    plot([First, First], [YLevel, YLevel - Yclearance], 'k')

    plot([Last, Last], [YLevel, YLevel - Yclearance], 'k')

    text((First+Last)/2, YLevel + Yclearance, StarString, HorizontalAlignment='center', FontSize=StarFont)
end