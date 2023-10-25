function print_results(y, ys)
    % Computes SNDR and MSE and prints them
    % 
    % Input arguments:
    % - y: target sequence
    % - ys: estimated sequence
    
    [rse, mse] = compute_metrics(y, ys);
    fprintf("\nOutput MSE: %f", mse);
    fprintf("\nOutput RSE: %f dB\n", rse);
end
