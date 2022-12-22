function [result_arr, metrics] = testbench(algorithm,...
                                        model,...
                                        n_iterations,...
                                        meas_data_files,...
                                        settings_file)
    % This function provides a generic testbench for
    % adaptive filtering algorithms.
    % 
    % Input arguments:
    % - algorithm: handle to the function that implements the algorithm under test
    % - model: handle to the function that implements the model under test
    % - n_iterations: number of test iterations to be performed. If measured
    %   data is used, then the actual number of iterations is given by
    %   min(n_iteration, len(dataset)), where len(dataset) is the number of
    %   points in the dataset.
    % - meas_data_files: list of string literals containing the names of the
    %   files from which measured data is loaded
    % - settings_file: absolute path of the folder in which data settings
    %   are stored
    % 
    % Output arguments:
    % - result_arr: cell array containing structs. Each
    %   struct has two fields:
    %       - y => target sequence
    %       - ys => estimated sequence
    % 
    % Copyright (c) 2022 Valerio Spinogatti
    % Licensed under GNU License
    
    current_path = fileparts(mfilename( 'fullpath' ));
    addpath(strcat(current_path, '/dependencies/testbench'));
    addpath(strcat(current_path, '/dependencies/common'));

    % Check that valid handles have been passed
    if not(is_valid(algorithm))
        fprintf("\n\nerror:testbench:invalid algorithm handle, I'm not running the testbench\n\n");
    end

    % Apply model to data, run test loop and display results
    xy_array = apply_model(n_iterations,...
                            model,...
                            settings_file,...
                            meas_data_files);

    result_arr = test_loop(algorithm, xy_array);

    metrics = compute_and_log_results(result_arr, xy_array);

    plot_metrics(metrics)
    % plot_y_and_ys(result_arr{1}.y, result_arr{1}.ys);

    show_instrum_res(algorithm);
end