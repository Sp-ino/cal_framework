function xy_array = xy_arr(n_iterations,...
                            model,...
                            settings_file,...
                            meas_data_files)

    % This function is used by a testbench for model calbration algorithms. 
    % It generates a 2-dimensional cell-array of
    % size n_iterations x 1, being n_iterations the number
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
    % - meas_data_files: vector containing the names(s) of the
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

        
    % -------------------------------Parse model type-------------------------------
    if isa(model, 'char') % In this case we use functions that produce simulated data to generate the output array
        switch model
        case 'lin_sim'
            model_func = @lin_model_sim;
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
        model_func = model;

        % Load external data
        current_path = fileparts(mfilename( 'fullpath' ));
        [inputs, targets] = load_traces(strcat(current_path, '/../../../data/', meas_data_files));

        % Compute actual number of iterations as the minimum between the number of traces and n_iterations
        n_iterations = min(n_iterations, size(inputs, 2));

        % Define a flag variable that tells whether or not we are using simulated data
        sim_data = false;

    else
        msg = strcat(sprintf("gen_xy_array:the model must be specified as either a char array or a function handle to a\n"),...
                    sprintf("custom model."));
        error(msg)
    end
    % ------------------------------------------------------------------------------

    % -------------Read settings from file and create xy_array----------------------
    xy_array = cell(n_iterations, 1);
    settings = read_settings(settings_file)
    % ------------------------------------------------------------------------------
    
    % --------------Generate output array containing (X1, X2, y) triplets-----------
    for idx = 1:n_iterations
        if sim_data
            [X1, X2, y] = model_func(settings);
        else
            [X1, X2, y] = model_func(inputs(:, idx), targets(:, idx), settings);
        end

        xy_array{idx}.X1 = X1;
        xy_array{idx}.X2 = X2;
        xy_array{idx}.y = y;
    end
    % ------------------------------------------------------------------------------

end