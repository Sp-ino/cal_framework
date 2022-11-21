function print_results(y, ys)
    % Computes SNDR and MSE and prints them
    % 
    % Input arguments:
    % - y: target sequence
    % - ys: estimated sequence
    
    [sndr, mse] = compute_metrics(y, ys);
    fprintf("\nOutput MSE: %f", mse);
    fprintf("\nOutput SNDR: %f dB\n", sndr);
end
