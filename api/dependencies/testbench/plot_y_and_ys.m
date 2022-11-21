function plot_y_and_ys(y, ys)
    figure
    plot(y)
    hold on
    plot(ys)
    hold off
    title("Comparison between estimated sequence and target sequence")
    legend("Target sequence", "Estimated sequence")
end