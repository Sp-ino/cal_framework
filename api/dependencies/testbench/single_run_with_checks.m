function ys = single_run_with_checks(algorithm, X1, X2, y)

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
                msg = strcat(sprintf("\nsingle_run_with_checks: error! Check that the algorithm you are passing to the testbench() function is working.\n"),...
                            sprintf("\nError message: %s\n\n    Stack trace:\n", err.message));
                for idx = 1:numel(err.stack)
                    msg = strcat(msg, sprintf("In %s, line %d\n", err.stack(idx).name, err.stack(idx).line));
                end
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
                msg = strcat(sprintf("\nsingle_run_with_checks: error! Check that the algorithm you are passing to the testbench() function is working.\n"),...
                            sprintf("\nError message: %s\n\nStack trace:\n", err.message));
                for idx = 1:numel(err.stack)
                    msg = strcat(msg, sprintf("In %s, line %d\n", err.stack(idx).name, err.stack(idx).line));
                end
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