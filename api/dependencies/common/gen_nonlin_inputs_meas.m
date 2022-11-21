function [X1, X2, y] = gen_nonlin_inputs_meas(input, target, lin_len, nonlin_len)
    remove_offset = 0;

    x = input';
    y = target';

    % fs = round(t(2)^-1); 
    Np = length(x);

    if rem(lin_len, 2) || lin_len < 2
        error("gen_nonlin_inputs_meas:lin_len must be even and greater than 2.")
    end
    Neq = (lin_len-2)/2;

    % -----perform calibration with linear equalizer to have a benchmark------
    % equalized output (FIR filter)
    % uncalibrated output (gain and offset calibration)
    X = ones(Np, 2*Neq + 2);
    V = zeros(Np, 1);
    for i = 1 : 2*Neq + 1
        X(:, i) = filter([zeros(1, i-1) 1], 1, x);
        if i == Neq + 1
            V(:) = filter([zeros(1, i-1) 1], 1, y);
        end
    end
    yd = V';
    M = X'*X\X'*V;
    zIFe = (X*M)';
    Ee = rms(zIFe-yd)/rms(yd);
    
    fprintf('\nGenerating Volterra model and performing pruning...\n')
    fprintf('Benchmark results:\n')
    disp(['SNDRe = ' num2str(-20*log10(Ee)) ' dB'])
    % ------------------------------------------------------------------------
    
    % ---------------------Generate Volterra model----------------------------
    % calibration with noncausal OMP and Volterra
    LAGS = [Neq 1 3 1 2]; %[Neq 2 4 2 3];
    X = ones(Np, 1);
    V = filter([zeros(1, LAGS(1)) 1], 1, y');
    
    % linear
    for i = 1 : 2*LAGS(1)+2
        dm = filter([zeros(1, i-1) 1], 1, x');
        X = [X, dm];
    end
    % disp(size(X))
    
    % quadratic
    for i1 = 1 : 2*LAGS(2)+1
        dm1 = filter([zeros(1, LAGS(1)-LAGS(2)+i1-1) 1], 1, x');
        for i2 = i1 : 2*LAGS(2)+1
            dm2 = filter([zeros(1, LAGS(1)-LAGS(2)+i2-1) 1], 1, x');
            X = [X, dm1 .* dm2];
        end
    end

    % cubic
    for i1 = 1 : 2*LAGS(3)+1
        dm1 = filter([zeros(1, LAGS(1)-LAGS(3)+i1-1) 1], 1, x');
        for i2 = i1 : 2*LAGS(3)+1
            dm2 = filter([zeros(1, LAGS(1)-LAGS(3)+i2-1) 1], 1, x');
            for i3 = i2 : 2*LAGS(3)+1
                dm3 = filter([zeros(1, LAGS(1)-LAGS(3)+i3-1) 1], 1, x');
                X = [X, dm1 .* dm2 .* dm3];
            end
        end
    end

    % quartic
    for i1 = 1 : 2*LAGS(4)+1
        dm1 = filter([zeros(1, LAGS(1)-LAGS(4)+i1-1) 1], 1, x');
        for i2 = i1 : 2*LAGS(4)+1
            dm2 = filter([zeros(1, LAGS(1)-LAGS(4)+i2-1) 1], 1, x');
            for i3 = i2 : 2*LAGS(4)+1
                dm3 = filter([zeros(1, LAGS(1)-LAGS(4)+i3-1) 1], 1, x');
                for i4 = i3 : 2*LAGS(4)+1
                    dm4 = filter([zeros(1, LAGS(1)-LAGS(4)+i4-1) 1], 1, x');
                    X = [X, dm1 .* dm2 .* dm3 .* dm4];
                end
            end
        end
    end

    % quintic
    for i1 = 1 : 2*LAGS(5)+1
        dm1 = filter([zeros(1, LAGS(1)-LAGS(5)+i1-1) 1], 1, x');
        for i2 = i1 : 2*LAGS(5)+1
            dm2 = filter([zeros(1, LAGS(1)-LAGS(5)+i2-1) 1], 1, x');
            for i3 = i2 : 2*LAGS(5)+1
                dm3 = filter([zeros(1, LAGS(1)-LAGS(5)+i3-1) 1], 1, x');
                for i4 = i3 : 2*LAGS(5)+1
                    dm4 = filter([zeros(1, LAGS(1)-LAGS(5)+i4-1) 1], 1, x');
                    for i5 = i4 : 2*LAGS(5)+1
                        dm5 = filter([zeros(1, LAGS(1)-LAGS(5)+i5-1) 1], 1, x');
                        X = [X, dm1 .* dm2 .* dm3 .* dm4 .* dm5];
                    end
                end
            end
        end
    end


    M = X'*X\X'*V;
    Xl = X(:, 1:3+2*LAGS(1));
    Xnl = X(:, 4+2*LAGS(1):end);

    % [E, Vc, Mc, Ic] = omp(Xl, Xnl, V);

    zIFc = (X*M)';
    yd = V';
    Ec = rms(zIFc - yd) / rms(yd);

    disp(['SNDRc = ' num2str(-20*log10(Ec)) ' dB'])
    % ------------------------------------------------------------------------

    % ----------------------------pruning with omp----------------------------
    X1 = Xl;
    X2 = Xnl;
    
    L1 = size(X1, 2);
    L2 = size(X2, 2);
    
    % removing X1 from V and X2
    Vr = V - X1*(X1'*X1\X1'*V);
    X2r = X2 - X1*(X1'*X1\X1'*X2);
    
    Ic = zeros(1, L2);
    Es = zeros(1, L2);
    for i = 1 : L2
        % find highest correlation
        rho = zeros(1, L2);
        for j = 1 : L2
            if ismember(j, Ic)
                continue
            end
            rho(j) = abs(sum(Vr .* X2r(:, j)) / sqrt(sum(X2r(:, j) .^ 2)));
        end
        [~, Ic(i)] = max(abs(rho));
        
        % regress over Ic(i) -> chosen columns have 0 values
        dmX2 = X2r(:, Ic(i));
        Vr = Vr - dmX2*(dmX2'*dmX2\dmX2'*Vr);
        X2r = X2r - dmX2*(dmX2'*dmX2\dmX2'*X2r);
        
        Es(i) = rms(Vr)/rms(V);
        
        XX = [X1, X2(:, Ic(1:i))];
        MM = XX'*XX\XX'*V;
        Ms{i}([(1:L1), L1+Ic(1:i)]) = MM;
        Vs{i} = XX*MM;
    end
    % ------------------------------------------------------------------------
    
    % --------------Compute pruned matrix and regress over it-----------------
    X1 = X1(:, 2:end); % I'm not sure how to manage offset calibration, so for the moment I'll just remove it
    X2 = X2(:, Ic(1:nonlin_len));
    X = [X1 X2];
    y = V;

    if remove_offset
        y = y - mean(y);
        for i = 1:size(X1,2)
            X1(:, i) = X1(:, i) - mean(X1(:, i));
        end
        for i = 1:size(X2,2)
            X2(:, i) = X2(:, i) - mean(X2(:, i));
        end
    end

    MM = X'*X\X'*V;
    Vs = X*MM;
    Ecp = rms(V - Vs)/rms(V);
    disp(['SNDRcp = ' num2str(-20*log10(Ecp)) ' dB'])
    fprintf(['\nSNDRe is the SNDR after linear equalization.\nSNDRc is the SNDR after nonlinear calibration.\n'...
        'SNDRcp is the SNDR after calibration with pruned model.\n'])
    % ------------------------------------------------------------------------
    
end