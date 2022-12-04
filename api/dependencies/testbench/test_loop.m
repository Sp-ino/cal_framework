function result_arr = test_loop(algorithm, xy_array)
    % This function runs the test loop by calling
    % the function under test repeatedly on the
    % function under test. The number of iterations
    % corresponds to the length of xy_array.
    % 
    % Input arguments:
    % - algorithm: function handle that points to the
    %   function under test
    % - xy_array: cell array that contains (X1, X2 ,y)
    %   triplets 
    % - is_split: bool that specifies whether the
    %   algorithm is split or not
    % 
    % Output arguments:
    % - result_arr: cell array containing structs. Each
    %   struct has two fields:
    %       - y => target sequence
    %       - ys => estimated sequence
    % 
    % Copyright (c) 2022 Valerio Spinogatti
    % Licensed under GNU License

    n_iterations = size(xy_array, 1);

    result_arr = cell(n_iterations, 1);

    for iteration = 1:n_iterations
        fprintf("\nRunning iteration n. %d", iteration);

        X1 = xy_array{iteration}.X1;
        X2 = xy_array{iteration}.X2;
        y = xy_array{iteration}.y;

        ys = single_run_with_checks(algorithm, X1, X2, y);

        print_results(y, ys);

        result_arr{iteration}.y = y;
        result_arr{iteration}.ys = ys;
    end
end



function ys = single_run_with_checks(algorithm, X1, X2, y)
    % Runs an algorithm by checking the number of arguments
    % to find whether it is linear or nonlinear. Also, performs
    % additional checks and prints detailed error messages
    % if something is wrong.
    % 
    % Input arguments:
    % - algorithm: handle to the algorithm under test
    % - X1: linear design matrix
    % - X2: nonlinear design matrix
    % - y: target sequence
    % 
    % Output arguments:
    % - ys: estimated sequence
    % 
    % Copyright (c) 2022 Valerio Spinogatti
    % Licensed under GNU License


    current_path = fileparts(mfilename( 'fullpath' ));
    addpath(strcat(current_path, '/../common'));

    nargs = find_nargin(algorithm);

    switch nargs
    case 3
        if isempty(X2)
            % fprintf(strcat("\n\ntest_loop:could not run algorithm because the nonlinear matrix X2 is empty\n",...
            % "but the algorithm under test requires both a linear and a nonlinear input data matrix\n",...
            % "Check that the setting about nonlinear data generation is correct in your testbench.\n\n"));
            % error("test_loop:could not run algorithm under test.")
            warning("single_run_with_checks:you are running a nonlinear algorithm on a linear model. Make sure that the algorithm and the model are correct.")
            warning('off')
        end

        try
            ys = algorithm(X1, X2, y);
        catch err
            if strcmp(err.identifier, 'EMLRT:runTime:MATLABExprIsNotCorrectSize')
                msg = strcat(sprintf("\n\ntest_loop:could not run algorithm because the size of the input arguments is incorrect."),...
                            sprintf("\nCheck that the settings you specified are correct. If the algorithm under test\n"),...
                            sprintf("is a mex function, make sure that you generated the function with the correct input size\n\n"));
            else
                msg = err_msg_with_stack(err, sprintf("\nsingle_run_with_checks: error! Check that the algorithm you are passing to the testbench() function is working.\n"));
            end
            error(msg)
        end
        ys = double(ys);

    case 2
        try
            ys = algorithm(X1, y);
        catch err
            if strcmp(err.identifier, 'EMLRT:runTime:MATLABExprIsNotCorrectSize')
                msg = strcat(sprintf("\n\ntest_loop:could not run algorithm because the size of the input arguments is incorrect."),...
                            sprintf("\nCheck that the settings you specified are correct. If the algorithm under test\n"),...
                            sprintf("is a mex function, make sure that you generated the function with the correct input size\n\n"));
            else
                msg = err_msg_with_stack(err, sprintf("\nsingle_run_with_checks: error! Check that the algorithm you are passing to the testbench() function is working.\n"));
            end
            error(msg)
        end
        ys = double(ys);

    otherwise
        msg = strcat(sprintf("single_run_with_checks:the algorithm under test must should have 2 or 3 input arguments.\n"),...
                    sprintf("In particular, you should have:\n"),...
                    sprintf(" - 2 input arguments for linear calibration algorithm (X1 and y)"),...
                    sprintf(" - 3 input arguments for nonlinear calibration algorithm (X1, X2 and y"));
        error(msg)
    end
end



function msg = err_msg_with_stack(err, additional_msg)
    msg = strcat(additional_msg, sprintf("\nError message: %s\n\n    Stack trace:\n", err.message));
    for idx = 1:numel(err.stack)
        msg = strcat(msg, sprintf("In %s, line %d\n", err.stack(idx).name, err.stack(idx).line));
    end
end
