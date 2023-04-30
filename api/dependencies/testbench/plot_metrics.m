function plot_metrics(metrics)
    % Plots metrics as curves. On the x axis of the plot there
    % are the iterations (each iteration corresponds
    % to an input-target pair) and on the y axis there are
    % the values of RSE.

    figure
    hold on
    if not(isnan(metrics.rse_bench_nonlin))
        plot(metrics.rse_bench_nonlin)
    end
    plot(metrics.rse_bench_lin)
    plot(metrics.rse)
    hold off

    set(get(gca, 'XLabel'), 'String', 'Dataset point');
    set(get(gca, 'YLabel'), 'String', 'RSE [dB]');
    if not(isnan(metrics.rse_bench_nonlin))
        legend('RSE of nonlinear batch estimator',...
                'RSE of linear batch estimator',...
                'RSE of algorithm under test',... 
                'Location', 'best')
    else
        legend('RSE of linear batch estimator',...
                'RSE of algorithm under test',... 
                'Location', 'best')
    end

    figure
    plot(metrics.fom)

    set(get(gca, 'XLabel'), 'String', 'Dataset point');
    set(get(gca, 'YLabel'), 'String', 'FOM');
end