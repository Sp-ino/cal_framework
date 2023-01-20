function [rse, mse] = compute_metrics(y, ys)
    % This function computes RSE (in dB) and MSE given
    % a target sequence and an estimated sequence.
    % Since the estimated sequence is expected to
    % be the output of an adaptive filter, the SNDR
    % and the MSE are computed by considering only
    % the second half of the two sequences.
    % 
    % Input arguments:
    % - y: true sequence
    % - ys: estimated sequence
    % 
    % Output arguments:
    % - rse: relative squared error computed from y and ys. 
    %   The relative squared error is defined as
    %               rse = 1 - sum((y - ys).^2)/sum((y - mean(y)).^2)
    % - mse: MSE computed from y and ys

    if not(size(y, 2) == 1)
        error("compute_metrics:y must be a column vector!")
    end
    if not(size(y, 1) > 1)
        error("compute_metrics:y is scalar!")
    end
    
    indices = floor(3*size(y, 1)/4):size(y,1);
    y = double(y(indices));
    ys = double(ys(indices));
    
    % Compute MSE
    mse = immse(y, ys);

    % Compute coefficient of determination
    e = y - ys;
    sigma_err = sum(e.^2); % Note that we do not subtract mean from residuals because residuals have mean=0
    sigma_y = sum((y - mean(y)).^2);
    rse = db(sigma_y/sigma_err);
end
