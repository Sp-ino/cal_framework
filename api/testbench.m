function result_arr = testbench(algorithm, n_iterations, lin_data_only, use_meas_data, meas_data_files)
    % This function provides a generic testbench for
    % adaptive filtering algorithms.
    % 
    % Input arguments:
    % - algorithm: handle to the function that implements the algorithm under test
    % - n_iterations: number of test iterations to be performed. If measured
    %   data is used, then the actual number of iterations is given by
    %   min(n_iteration, len(dataset)), where len(dataset) is the number of
    %   points in the dataset.
    % - lin_data_only: whether the  algorithm under test works with
    %   linear data or nonlinear data.
    % - use_meas_data: whether to use measured data (use_meas_data=true) or
    %   simulated data (use_meas_data=false).
    % - meas_data_files: list of string literals containing the names of the
    %   files from which measured data is loaded
    % 
    % Output arguments:
    % - result_arr: cell array containing structs. Each
    %   struct has two fields:
    %       - y => target sequence
    %       - ys => estimated sequence
    
    current_path = fileparts(mfilename( 'fullpath' ));
    addpath(strcat(current_path, '/dependencies/common'));
    addpath(strcat(current_path, '/dependencies/testbench'));

    is_split_alg = is_split(algorithm);

    xy_array = gen_xy_array(n_iterations, is_split_alg, lin_data_only, use_meas_data, meas_data_files);

    result_arr = test_loop(algorithm, xy_array, is_split_alg);

    log_results(result_arr, xy_array);

    plot_y_and_ys(result_arr{1}.y, result_arr{1}.ys);

    show_instrum_res(algorithm);
end