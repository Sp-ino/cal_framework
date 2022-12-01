function out = is_valid(handle)
    % Checks whether a function handle corresponds
    % to an actual function defined in some file.
    % 
    % Input arguments:
    % - handle: handle to be tested
    % 
    % Output arguments:
    % - out: true if the handle is valid, false otherwise
    % 
    % Copyright (c) 2022 Valerio Spinogatti
    % Licensed under GNU License


    info = functions(handle);
    if strcmp(info.file, '')
        return false
    end

    return true
end