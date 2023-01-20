function metrics = compute_and_log_results(results, xy_array)
    % This function prettyprints the results of a testbench run
    % for an RLS algorithm. The performance of the algorithm
    % at each iteration is compared with a benchmark given by
    % a double precision batch estimator, if the array of
    % (X1, X2, y) triplets is passed as argument.
    % The function can also return an array that contains the
    % computed rses.
    % 
    % Input arguments:
    % - results: cell array. Each cell must contain a struct with
    %   two fields: y (the true sequence) and ys (the estimated
    %   sequence)
    % - xy_array: cell array. Each cell must contain a struct with
    %   3 fields: X1 (linear input data matrix), X2 (nonlinear
    %   input data matrix) and y (true sequence).
    % 
    % Output arguments:
    % - metrics: cell array containing structs. Each struct contains
    %   3 fields:
    %       - rse => relative squared error resulting from the algorithm under test
    %       - rse_bench_nonlin => relative squared error resulting from nonlinear
    %         benchmark results (contains '    N/A' if X2 is empty)
    %       - rse_bench_lin => relative squared error resulting from linear
    %         benchmark results

    n_iterations = length(results);
    metrics.rse = zeros(n_iterations, 1);
    metrics.rse_bench_lin = zeros(n_iterations, 1);
    metrics.rse_bench_nonlin = zeros(n_iterations, 1);
    metrics.fom = zeros(n_iterations, 1);


    fprintf('\n\n%9s %3s %6s %3s %16s %3s %16s\n',...
    'Dataset point', '',...
    'RSE ','',...
    'RSE_bench_nonlin', '',...
    'RSE_bench_lin   ');

    warning('off');

    for iteration = 1:n_iterations
        % Retrieve y and ys and compute RSE for the current iteration
        y = results{iteration}.y;
        ys = results{iteration}.ys;
        rse = compute_metrics(y, ys);
        
        % Retrieve X and compute benchmark RSE if xy_array argument is passed
        rse_bench = [];
        if nargin == 2
            X1 = xy_array{iteration}.X1;
            X2 = xy_array{iteration}.X2;
            X = [X1 X2];
            
            Ms_bench_lin = (X1'*X1)\(X1'*y);
            ys_bench_lin = X1*Ms_bench_lin;
            rse_bench_lin = compute_metrics(y, ys_bench_lin);
            
            if isempty(X2)
                rse_bench_nonlin = "        N/A";    
                fom = "        N/A";    
            else
                % do not print nonlinear benchmark results if X2 is empty
                Ms_bench_nonlin = (X'*X)\(X'*y);
                ys_bench_nonlin = X*Ms_bench_nonlin;
                rse_bench_nonlin = compute_metrics(y, ys_bench_nonlin);
                fom = (rse_bench_nonlin - rse)/(rse_bench_nonlin - rse_bench_lin);
            end
        end

        % Save rse
        metrics.rse(iteration) = rse;
        metrics.rse_bench_nonlin(iteration) = rse_bench_nonlin;
        metrics.rse_bench_lin(iteration) = rse_bench_lin;
        metrics.fom(iteration) = fom;

        % Print rse and rse benchmark
        % fprintf("%d\t\t\t\t%.2f\t\t%.2f\n", iteration, rse, rse_bench);
        if isempty(X2)
            fprintf('\n%9d %8s %3.2f %3s %s %3s %13.2f',...
            iteration, '',...
            rse, '',...
            rse_bench_nonlin, '',...
            rse_bench_lin)
        else
            fprintf('\n%9d %8s %3.2f %3s %13.2f %3s %13.2f',...
            iteration, '',...
            rse, '',...
            rse_bench_nonlin, '',...
            rse_bench_lin)
        end
    end
    
    fprintf('\n\n');
    warning('on');
end