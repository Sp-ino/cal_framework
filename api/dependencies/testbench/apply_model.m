function xy_array = apply_model(n_iterations,...
                            model,...
                            settings_file,...
                            meas_data)
                            
    % This function is used by a testbench for model calbration algorithms. 
    % It applies a model to generate a 2-dimensional cell-array of
    % size n_iterations x 1, n_iterations being the number
    % of (X1, X2, y) triplets to use for testing an algorithm.
    % Each row corresponds to a test iteration and contains
    % a struct with the linear design matrix (X1), the
    % nonlinear design matrix (X2) and the desired output
    % (y).
    % 
    % Input arguments:
    % - n_iterations: number of (X1, X2, y) triplets to generate
    % - model: model according to which the design matrix is 
    %   generated. Ignored if use_meas_data it false
    % - meas_data: vector containing the names(s) of the
    %   file(s) in which measured data is stored. Ignored if
    %   model is a char array
    % - settings_file: char array that specifies the name of the
    %   JSON file containing settings. The file should be structured
    %   in a precise way
    % 
    % Output arguments:
    % - xy_array: cell array. Each line contains a struct with 3 fields:
    %       - X1 => linear input data matrix
    %       - X2 => nonlinear input data matrix. Left empty if the model is nonlinear
    %       - y => target output sequence
    % 
    % Copyright (c) 2022 Valerio Spinogatti
    % Licensed under GNU License
                            
    % --------------------------Read settings from file-----------------------------
    settings = read_settings(settings_file);
    % ------------------------------------------------------------------------------
    
    % -------------------------------Parse model type-------------------------------
    if isa(model, 'char') % In this case we use functions that produce simulated data to generate the output array
        switch model
        case 'lin_sim'
            model_func = @lin_model_sim;
        case 'lin_simulink_debug'
            model_func = @lin_model_simulink_debug;
        case 'nonlin_sim'
            model_func = @nonlin_model_sim;
        otherwise
            msg = strcat(sprintf("gen_xy_array:invalid model name specified. It looks like you passed a string to specify\n"),...
                        sprintf("a model that uses simulated data, but the name of the model is invalid. Use\n"),...
                        sprintf(" - 'lin_sim' if you wish to use a simulated linear model"),...
                        sprintf(" - 'nonlin_sim' if you wish to use a simulated nonlinear model"));
            error(msg)
        end

        % Define a flag variable that tells whether or not we are using simulated data
        sim_data = true;

    elseif isa(model, 'function_handle') % In this case we apply a custom model to external data to generate the output array      
        if not(is_valid(model))
            fprintf("\n\nerror:testbench:invalid model handle, I'm not running the testbench\n\n");
        end
        
        model_func = model;

        % Load external data
        if isa(meas_data, 'function_handle')
            xy_pairs = meas_data(n_iterations, settings);
            % sequ_len = size(xy_pairs{1}.y, 1);
            % inputs = zeros(sequ_len, n_iterations);
            % targets = zeros(sequ_len, n_iterations);

            for idx = 1:n_iterations
                inputs(:, idx) = xy_pairs{idx}.X1(:, 1);
                targets(:, idx) = xy_pairs{idx}.y;
            end
        else
            current_path = fileparts(mfilename( 'fullpath' ));
            [inputs, targets] = load_traces(strcat(current_path, '/../../../data/', meas_data));

            % Compute actual number of iterations as the minimum between the number of traces and n_iterations
            n_iterations = min(n_iterations, size(inputs, 2));
            inputs = inputs(:, 1:n_iterations);
            targets = targets(:, 1:n_iterations);
        end

        % Define a flag variable that tells whether or not we are using simulated data
        sim_data = false;

    else
        msg = strcat(sprintf("gen_xy_array:the model must be specified as either a char array or a function handle to a\n"),...
                    sprintf("custom model."));
        error(msg)
    end
    % ------------------------------------------------------------------------------

    % --------------Generate output array containing (X1, X2, y) triplets-----------
    if sim_data
        xy_array = model_func(n_iterations, settings);
    else
        xy_array = model_func(inputs, targets, settings);
    end
    % ------------------------------------------------------------------------------

end



function model_sanity_checks(X1, X2, y)
    if size(y, 1) ~= size(X1, 1)
        error(sprintf('testbench:xy_arr:size mismatch between X1 (size %s x %s) and y (size %s x %s). X1 and y should have the same number of rows.',...
                num2str(size(X1, 1)), num2str(size(X1, 2)), num2str(size(y, 1)), num2str(size(y, 2))));
    end

    if size(X1, 1) ~= size(X2, 1)
        error(sprintf('testbench:xy_arr:size mismatch between X1 (size %s x %s) and X2 (size %s x %s). X1 and X2 should have the same number of rows.',...
                num2str(size(X1, 1)), num2str(size(X1, 2)), num2str(size(X2, 1)), num2str(size(X2, 2))));
    end
end