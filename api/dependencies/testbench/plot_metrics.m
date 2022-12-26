function plot_metrics(metrics)
    % Plots metrics as curves. On the x axis of the plot there
    % are the iterations (each iteration corresponds
    % to an input-target pair) and on the y axis there are
    % the values of SNDR.

    figure
    hold on
    plot(metrics.sndr)
    plot(metrics.sndr_bench_lin)
    if isa(metrics.sndr_bench_nonlin, 'double')
        plot(metrics.sndr_bench_nonlin)
    hold off

    set(get(gca, 'XLabel'), 'String', 'Iteration');
    set(get(gca, 'YLabel'), 'String', 'SNDR [dB]');
    legend('SNDR of algorithm under test',...
            'SNDR of linear batch estimator',...
            'SNDR of nonlinear batch estimator',...
            'Location', 'best')

    figure
    plot(metrics.fom)

    set(get(gca, 'XLabel'), 'String', 'Iteration');
    set(get(gca, 'YLabel'), 'String', 'FOM');
end