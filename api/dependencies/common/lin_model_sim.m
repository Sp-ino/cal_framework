function xy_array = lin_model_sim(n_iterations, settings)
    % Applies linear simulated model a total of n_iterations times

    xy_array = cell(n_iterations, 1);
    
    for idx = 1:n_iterations
        [X1, X2, y] = lin_model_sim_run(settings);

        xy_array{idx}.X1 = X1;
        xy_array{idx}.X2 = X2;
        xy_array{idx}.y = y;
    end
end



function [X1, X2, y, M] = lin_model_sim_run(settings)
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
        filt_len = s.lin_len;
        sequ_len = s.sequ_len;
        output_width = s.output_width;
        noise_stddev = s.noise_stddev;
    catch
        fprintf("Error: %s\n\n", err.message);
        error(sprintf("lin_model_sim:check that the settings file has the correct fields."))
    end

    % generate white noise with std deviation = 0.3
    scaling = 0.3;
    % x = scaling*randn(sequ_len, 1);
    x = rand([sequ_len, 1])*2 - 1;

    X = zeros(sequ_len, lin_len);
    for i = 1 : lin_len
        X(:, i) = filter([zeros(1, i-1) 1], 1, x);
    end

    M = scaling*randn(lin_len, output_width);
    y = X*M + noise_stddev*randn(sequ_len, output_width);
    X1 = X;
    X2 = [];
end
