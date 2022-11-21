function result_arr = test_loop(algorithm, xy_array, is_split)
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

    current_path = fileparts(mfilename( 'fullpath' ));
    addpath(strcat(current_path, '/../common'));

    n_iterations = size(xy_array, 1);

    result_arr = cell(n_iterations, 1);

    for iteration = 1:n_iterations
        fprintf("\nRunning iteration n. %d", iteration);

        X1 = xy_array{iteration}.X1;
        X2 = xy_array{iteration}.X2;
        y = xy_array{iteration}.y;

        ys = single_run_with_checks(algorithm, X1, X2, y, is_split);

        print_results(y, ys);

        result_arr{iteration}.y = y;
        result_arr{iteration}.ys = ys;
    end
end