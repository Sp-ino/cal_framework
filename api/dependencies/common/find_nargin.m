function nargs = find_nargin(algorithm)
    % This function finds the number of argument
    % a handle accepts. The function is designed
    % to work in the new setup written for implementation
    % and testing of calibration algorithms.
    % 
    % This function automatically detects if the
    % argument is a handle to a mex function,
    % given that the .mexw64 extension is specified
    % in the filename.
    % In that case, it will try to retrieve
    % the number of arguments by checking for
    % a MATLAB function with the same name (minus the
    % _mex appendix) in the same folder in which
    % the mex function is.
    
    [alg_path, alg_name, extension] = fileparts(functions(algorithm).file);
    
    if strcmp(extension, '.mexw64')
        nonmex_name = alg_name(1:end-4);
        nonmex_algorithm = str2func(nonmex_name);
        
        try
            nargs = nargin(nonmex_algorithm);
        catch
            try
                nonmex_name = alg_name(1:end-7);
                nonmex_algorithm = str2func(nonmex_name);
                nargs = nargin(nonmex_algorithm);
            catch
                error("Could not apply nargin to function handle %s\n Since the function handle that has been passed refers to a mex function, make sure its name ends with _mex", alg_name)
            end
        end
        return
    end
    
    nargs = nargin(algorithm);
end


% function result = is_split(algorithm)
%     % This function detects whether the algorithm
%     % which is passed as a function handle takes
%     % 3 arguments (split algorithm, that requires
%     % the input matrix X to be separated in its
%     % linear and nonlinear part) or 2 arguments
%     % (joint algorithm, that accepts the whole matrix
%     % X and does not need to distinguish between
%     % linear and nonlinear part).
    
%     n_args = find_nargin(algorithm);
%     if n_args == 2
%         result = false;
%     elseif n_args == 3
%         result = true;
%     else
%         error("testbench:the handle must point to an algorithm that accepts either 2 or 3 arguments.")
%     end
% end