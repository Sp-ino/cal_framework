function xy_array = lin_model_simulink_debug(n_iterations, settings)
    % Applies linear simulated model a total of n_iterations times

    xy_array = cell(n_iterations);
    
    for idx = 1:n_iterations
        [X1, X2, y] = lin_model_simulink_run(settings);

        xy_array{idx}.X1 = X1;
        xy_array{idx}.X2 = X2;
        xy_array{idx}.y = y;
    end
end



function [X1, X2, y, M] = lin_model_simulink_run(settings)
    % Generates data for testing least-squares (LS) algorithms. In particular, this function
    % generates a random input sequence x, then filters it with the (random) matrix M and adds 
    % white gaussian noise to simulate a noisy LTI system with measurement noise.
    % (each column of M represent the impulse response of a SISO
    % LTI system). The output sequence y is the result of these operations. 
    % The input sequence x is a white gaussian random signal.
    % 
    % Copyright (c) 2022 Valerio Spinogatti
    % Licensed under GNU License

    % Read linear settings
    try
        s = settings.lin_settings;
        lin_len = 32;
        sequ_len = s.sequ_len;
    catch
        fprintf("Error: %s\n\n", err.message);
        error(sprintf("lin_model_sim:check that the settings file has the correct fields."))
    end

    % generate white noise with std deviation = 1
    rng(0, 'v4')
    x = randn(sequ_len, 1);

    X = zeros(sequ_len, lin_len);
    for i = 1 : lin_len
        X(:, i) = filter([zeros(1, i-1) 1], 1, x);
    end

    M = [0.5 -0.4 0.34 -0.91 0.13 0.33 0.67 -0.1 0.5 0.23 -0.3 0.33 0.2 0.2 0.2 0.1 0.44 0.55 0.66 0.7 0.2 0.1 -0.2 -0.1 -0.18 0.13 .011 0.77 0.14 0.75 -0.1 -0.34]';
    y = X*M;
    X1 = X;
    X2 = [];
end
