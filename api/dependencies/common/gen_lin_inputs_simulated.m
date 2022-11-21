function [X, y, M] = gen_lin_inputs_simulated(input_len, filter_len, output_width, noise_stddev)
    % Generates data for testing least-squares (LS) algorithms. In particular, this function
    % generates a random input sequence x, then filters it with the (random) matrix M and adds 
    % white gaussian noise to simulate a noisy LTI system with measurement noise.
    % (each column of M represent the impulse response of a SISO
    % LTI system). The output sequence y is the result of these operations. 
    % The input sequence x is a white gaussian random signal.
    
    % generate white noise with std deviation = 0.1
    scaling = 0.1;
    x = scaling*randn(input_len, 1);

    X = zeros(input_len, filter_len);
    for i = 1 : filter_len
        X(:, i) = filter([zeros(1, i-1) 1], 1, x);
    end

    M = scaling*randn(filter_len, output_width);
    y = X*M + noise_stddev*randn(input_len, output_width);
end
