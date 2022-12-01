function gen_mex(algorithm, settings_file)
    % This function automatizes the generation of an instrumented
    % mex file with buildInstrumentedMex. The function uses the
    % settings stored in split_tb_settings.json or in joint_tb_settings.json
    % to generate examples of inputs for code acceleration. Then
    % it accelerates the code by calling buildInstrumentedMex on
    % the specified function.
    % 
    % Input arguments:
    % - algorithm: function handle that points to the function to be
    %   accelerated.
    % - settings_file: absolute path of the file in which data settings
    %   are stored
    % 
    % Copyright (c) 2022 Valerio Spinogatti
    % Licensed under GNU License

    if not(input("Accelerate algorithm?\n No  => Enter 0\n Yes => Enter any other number\n> "))
        return
    end

    initial_path = pwd();

    current_path = fileparts(mfilename( 'fullpath' ));
    addpath((strcat(current_path, '/dependencies/common')));

    nargs = find_nargin(algorithm);
    settings = read_settings(settings_file);

    switch nargs
    case 3
        try
            is_lin = false;
            s = settings.lin_settings;
            L1 = s.lin_len;
            N = s.sequ_len;
            W = s.output_width;
        catch err
            msg = sprintf("\gen_mex:check that the settings file has the correct fields.\n\n");
            msg = strcat(msg, sprintf("Error: %s\n", err.message));
            error(msg)
        end
    
    case 2
        try
            is_lin = true;
            s = settings.nonlin_settings;
            L1 = s.lin_len;
            L2 = s.nonlin_len;
            N = s.sequ_len;
            W = s.output_width;
        catch err
            msg = sprintf("\volterra_model:check that the settings file has the correct fields.\n\n");
            msg = strcat(msg, sprintf("Error: %s\n", err.message));
            error(msg)
        end    
    end

    % Generate examples of inputs
    if not(is_lin)
        X1_example = zeros(N, L1);
        X2_example = zeros(N, L2);
    else
        X1_example = zeros(N, L1);
    end
    y_example = zeros(N, W);
    
    % Retrieve information about the algorithm pointed by the handle
    alg_info = functions(algorithm);
    alg_name = alg_info.function;
    [alg_path, ~, extension] = fileparts(alg_info.file);

    % Check that the handle does not point to a mex function
    if strcmp(extension, '.mexw64')
        fprintf(strcat("\naccelerate_fix:warning:the handle that has been passed\n",...
        "seems to correspond to a function that has been already accelerated.\n",...
        "Therefore, I'm not generating the accelerated code.\n\n"))
        return
    end

    % If everything is fine, call buildInstrumentedMex to generate the instrumented
    % mex function.
    cd(alg_path)

    fprintf("\ngen_mex:info:building instrumented mex function...\n");
    if not(is_lin)
        buildInstrumentedMex(alg_name, '-args', {X1_example, X2_example, y_example});
    else
        buildInstrumentedMex(alg_name, '-args', {X1_example, y_example});
    end

    cd(initial_path)
    fprintf("\ngen_mex:info:build completed, the mex function is stored at \n%s\n\n", alg_path);
end