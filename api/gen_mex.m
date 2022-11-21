function gen_mex(algorithm, data_settings_path)
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
    % - data_settings_path: absolute path of the folder in which data settings
    %   are stored

    initial_path = pwd();

    current_path = fileparts(mfilename( 'fullpath' ));
    addpath(strcat(current_path, '/dependencies/settings'));
    addpath((strcat(current_path, '/dependencies/common')));
    addpath(data_settings_path);

    % Find whether the algorithm is split or joint
    is_split_alg = is_split(algorithm);

    % Load settings
    if is_split_alg
        sfile = fileread('split_tb_settings.json'); 
    else
        sfile = fileread('joint_tb_settings.json'); 
    end
    settings = jsondecode(sfile);
    L1 = settings.lin_len;
    L2 = settings.nonlin_len;
    L = L1 + L2;
    N = settings.sequ_len;
    W = settings.output_width;        

    % Generate examples of inputs
    if is_split_alg
        X1_example = zeros(N, L1);
        X2_example = zeros(N, L2);
    else
        X_example = zeros(N, L);
    end
    y_example = zeros(N, W);
    
    % Retrieve information about the algorithm pointed by the handle
    alg_info = functions(algorithm);
    alg_name = alg_info.function;
    [alg_path, ~, extension] = fileparts(alg_info.file);

    % Check that the handle does not point to a mex function
    if strcmp(extension, '.mexw64')
        fprintf(strcat("\naccelerate_fix:warning:the handle that has been passed ",...
        "seems to correspond to a function that has been already accelerated. ",...
        "Therefore, I'm not generating the accelerated code.\n\n"))
    end

    % If everything is fine, call buildInstrumentedMex to generate the instrumented
    % mex function.
    cd(alg_path)

    fprintf("\ngen_mex:info:building instrumented mex function...\n");
    if is_split_alg
        buildInstrumentedMex(alg_name, '-args', {X1_example, X2_example, y_example});
    else
        buildInstrumentedMex(alg_name, '-args', {X_example, y_example});
    end

    cd(initial_path)
    fprintf("\ngen_mex:info:build completed, the mex function is stored at \n%s\n\n", alg_path);
end