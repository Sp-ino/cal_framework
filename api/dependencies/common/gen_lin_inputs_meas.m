function [X, y] = gen_lin_inputs_meas(input, target)
    x = input';
    y = target';

    % fs = round(t(2)^-1); 
    Np = length(x);
    Neq = 16;
    
    % -----------Generate only linear part of Volterra model------------------
    X = ones(Np, 1);
    V = filter([zeros(1, Neq) 1], 1, y');
    
    % linear
    for i = 1 : 2*Neq+1
        dm = filter([zeros(1, i-1) 1], 1, x');
        X = [X, dm];
    end

    X = X(:, 2:2+2*Neq);
    y = V;
    % ------------------------------------------------------------------------
end
