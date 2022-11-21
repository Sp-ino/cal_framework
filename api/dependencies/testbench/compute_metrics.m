function [sndr, mse] = compute_metrics(y, ys)
    % This function computes SNDR (in dB) and MSE given
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
    % - sndr: SNDR computed from y and ys. SNDR is defined as
    %               SNDR = rms(y)/rms(y-ys)
    % - mse: MSE computed from y and ys 

    indices = floor(3*size(y, 1)/4):size(y,1);
    mse = immse(double(y(indices)), double(ys(indices)));
    sndr = db(rms(double(y(indices)))/rms(double(y(indices))-double(ys(indices))));
end
