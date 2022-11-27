function ys = single_run_with_checks(algorithm, X1, X2, y, is_split)
    if is_split
        if isempty(X2)
            fprintf(strcat("\n\ntest_loop:could not run algorithm because the nonlinear matrix X2 is empty\n",...
            "but the algorithm under test requires both a linear and a nonlinear input data matrix\n",...
            "Check that the setting about nonlinear data generation is correct in your testbench.\n\n"));
            error("test_loop:could not run algorithm under test.")
        end

        try
            ys = algorithm(X1, X2, y);
        catch err
            if strcmp(err.identifier, 'EMLRT:runTime:MATLABExprIsNotCorrectSize')
                msg = strcat("\n\ntest_loop:could not run algorithm because the size of the input arguments is incorrect.",...
                "\nCheck that the settings you specified are correct. If the algorithm under test\n",...
                "is a mex function, make sure that you generated the function with the correct input size\n\n");
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
    else
        X = [X1 X2];
        try
            ys = algorithm(X, y);
        catch err
            if strcmp(err.identifier, 'EMLRT:runTime:MATLABExprIsNotCorrectSize')
                msg = strcat("\n\ntest_loop:could not run algorithm because the size of the input arguments is incorrect.",...
                "\nCheck that the settings you specified are correct. If the algorithm under test\n",...
                "is a mex function, make sure that you generated the function with the correct input size\n\n");
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
    end
end