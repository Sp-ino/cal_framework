function xy_array = gen_xy_array(n_iterations,...
                                is_split,...
                                lin_data_only,...
                                use_meas_data,...
                                meas_data_files,...
                                data_settings_path)
    % This function is used by a testbench for RLS algorithms. 
    % It generates a 2-dimensional cell-array of
    % size n_iterations x 1, being n_iterations the number
    % of (X1, X2, y) triplets to use for testing an algorithm.
    % Each row corresponds to a test iteration and contains
    % a struct with the linear data matrix (X1), the
    % nonlinear data matrix (X2) and the desired output
    % (y).
    % 
    % Input arguments:
    % - n_iterations: number of (X1, X2, y) triplets to generate
    % - lin_data_only: X2 is left empty if this argument is
    %   true
    % - use_meas_data: if true the function loads measured data
    %   from file(s) inside the data folder
    % - meas_data_files: vector containing the names(s) of the
    %   file(s) in which measured data is stored
    % 
    % Output arguments:
    % - xy_array: cell array. Each line contains a struct with 3 fields:
    %       - X1 => linear input data matrix
    %       - X2 => nonlinear input data matrix
    %       - y => target output sequence
    
    current_path = fileparts(mfilename( 'fullpath' ));
    addpath(data_settings_path);
    
    xy_array_file_path = strcat(current_path, '/../../../data/meas_xy_array.mat');
    
    % This guard clause checks that measured data is true and that
    % the file meas_xy_array.mat exists. meas_xy_array.mat contains
    % the (X1, X2, y) triplets generated from gen_nonlin_inputs_meas.
    % This avoids performing pruning when it has already been done.
    if use_meas_data
        if isfile(xy_array_file_path)
            xy_array_cell = struct2cell(load(xy_array_file_path));
            xy_array = xy_array_cell{1};

            n_iterations = min(n_iterations, length(xy_array));
            xy_array = xy_array(1:n_iterations);

            if lin_data_only
                for ind = 1:length(xy_array)
                    xy_array{ind}.X2 = [];
                end
            end
            return
        end
    end
    
    % Read settings from file
    if is_split
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
    noise_stddev = settings.noise_stddev;

    % Load measured data if required
    if use_meas_data
        [inputs, targets] = load_traces(strcat(current_path, '/../../../data/', meas_data_files));
    end    

    
    % Generate X1, X2, and y for each test iteration and store them into xy_array
    xy_array = cell(n_iterations, 1);
    
    for iteration = 1:n_iterations
        if lin_data_only
            if use_meas_data
                [X1, y] = gen_lin_inputs_meas(inputs(:, iteration), targets(:, iteration));
                X2 = [];
            else
                [X1, y] = gen_lin_inputs_simulated(N, L1, W, noise_stddev);
                X2 = [];
            end
        else
            if use_meas_data
                [X1, X2, y] = gen_volterra_inputs_meas(inputs(:, iteration), targets(:, iteration), L1, L2);
            else
                [X1, X2, y] = gen_nonlin_inputs_simulated(N, L1, L2, W);
            end
        end

        xy_array{iteration}.X1 = X1;
        xy_array{iteration}.X2 = X2;
        xy_array{iteration}.y = y;
    end

    % If I reached this point then no file storing xy_array has been
    % found, therefore I create the file for the next simulations if
    % xy_array has been generated from measured data and lin_data_only is false
    if use_meas_data && not(lin_data_only)
        save(xy_array_file_path, 'xy_array');
    end
end