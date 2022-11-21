function show_instrum_res(algorithm)
    % This function automatically tries to call showInstrumentationResults
    % if the name of the specified algorithm ends with _mex.
    % 
    % Input arguments:
    % - algorithm: handle to the function under test

    if not(input("Show instrumentation results?\n No  => Enter 0\n Yes => Enter any other number\n> "))
        return
    end

    alg_info = functions(algorithm);
    alg_name = alg_info.function;
    alg_path = fileparts(alg_info.file);

    if strcmp(alg_name(end-3:end), "_mex")
        initial_path = pwd();
        cd(alg_path)
        showInstrumentationResults(alg_name, '-printable', '-proposeWL')
        cd(initial_path)
    else
        fprintf("show_instrum_res:warning:there are no instrumentation results to show\nbecause the algorithm under test is not a mex function.\n\n")
    end
