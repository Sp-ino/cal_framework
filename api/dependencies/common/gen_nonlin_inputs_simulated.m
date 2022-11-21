function [X1, X2, y, M] = gen_nonlin_inputs_simulated(input_len, lin_len, nonlin_len, output_width)
    % Generates data for testing least-squares (LS) algorithms. In particular, this function
    % generates a random input sequence x, then filters it with the (random) matrix M in a nonlinear
    % fashion. The nonlinearity is given by an instantaneous polynomial input-output relationship.
    % The input sequence x is also a white gaussian random signal.
    
    % generate white noise with std deviation = 0.1
    scaling = 0.1;
    x = scaling*randn(input_len, 1);

    M = scaling*randn(lin_len+nonlin_len, 1); % model
    y = zeros(input_len, 1);
    X = zeros(input_len, lin_len+nonlin_len);
    
    for i = 1 : lin_len
        X(:, i) = filter([zeros(1, i-1) 1], 1, x);
    end
    for i = 1 : nonlin_len
        X(:, lin_len+i) = x.^(i+1);
    end

    y = X*M;
    X1 = X(:, 1:lin_len);
    X2 = X(:, lin_len+1:end);
end