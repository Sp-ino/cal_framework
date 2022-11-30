function [X1, X2, y, M] = lin_model_sim(settings)
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
    s = settings.lin_settings;
    lin_len = s.filt_len;
    sequ_len = s.sequ_len;
    output_width = s.output_width;
    noise_stddev = s.noise_stddev;

    % generate white noise with std deviation = 0.1
    scaling = 0.1;
    x = scaling*randn(sequ_len, 1);

    X = zeros(sequ_len, filt_len);
    for i = 1 : filt_len
        X(:, i) = filter([zeros(1, i-1) 1], 1, x);
    end

    M = scaling*randn(filt_len, output_width);
    y = X*M + noise_stddev*randn(sequ_len, output_width);
    X1 = X;
    X2 = [];
end
