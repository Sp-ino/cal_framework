function xy_array = nonlin_model_sim(n_iterations, settings)
    % Applies nonlinear simulated model a total of n_iterations times

    xy_array = cell(n_iterations);

    for idx = 1:n_iterations
        [X1, X2, y] = nonlin_model_sim_run(settings);

        xy_array{idx}.X1 = X1;
        xy_array{idx}.X2 = X2;
        xy_array{idx}.y = y;
    end
end



function [X1, X2, y, M] = nonlin_model_sim_run(settings)
    % Generates data for testing least-squares (LS) 
    % algorithms. In particular, this function
    % generates a random input sequence x, then 
    % filters it with the (random) matrix M in a
    % nonlinear fashion. The nonlinearity is given
    % by an instantaneous polynomial input-output
    % relationship. The input sequence x is also a
    % white gaussian random signal.
    % 
    % Copyright (c) 2022 Valerio Spinogatti
    % Licensed under GNU License

    % Read nonlinear settings
    try
        s = settings.nonlin_settings;
        lin_len = s.lin_len;
        nonlin_len = s.nonlin_len;
        sequ_len = s.sequ_len;
        output_width = s.output_width;
        noise_stddev = s.noise_stddev;
    catch
        fprintf("Error: %s\n\n", err.message);
        error(sprintf("nonlin_model_sim:check that the settings file has the correct fields."))
    end

    % generate white noise with std deviation = 0.1
    scaling = 0.1;
    x = scaling*randn(sequ_len, 1);

    M = scaling*randn(lin_len+nonlin_len, 1); % model
    y = zeros(sequ_len, 1);
    X = zeros(sequ_len, lin_len+nonlin_len);
    
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