function settings = read_settings(settings_file)
    % Reads settings from the file specified by
    % settings_file.
    % 
    % Input arguments:
    % - settings_file: string containing the path of the
    %   JSON file that stores the settings.
    % 
    % Output arguments:
    % - settings: struct that contains the settings
    %   read from file
    %   
    % The settings file must be organized according to a certain scheme.
    % Below is a minimal example of how the file should look like:
    % 
    % {
    %     "lin_settings": {
    %                     "filt_len":20,
    %                     "sequ_len":16384,
    %                     "output_width":1,
    %                     "noise_stddev":1e-2
    %                 },
    %     "nonlin_settings": {
    %                     "lin_len": 20,
    %                     "nonlin_len": 13,
    %                     "sequ_len": 16384,
    %                     "output_width": 1,
    %                     "noise_stddev": 1e-2
    %                 }
    %     }
    % 
    % Other fields and subfields can be added as long as the ones
    % specified above are present.
    % 
    % Copyright (c) 2022 Valerio Spinogatti
    % Licensed under GNU License

    % Read and decode json file
    try
        sfile = fileread(settings_file);
    catch err
        msg = sprintf("\nread_settings:something went wrong while trying to read the settings file.\n\n");
        msg = strcat(msg, sprintf("Error: %s\n", err.message));
        error(msg)
    end

    settings = jsondecode(sfile);

    % Sanity checks
    are_settings_valid(settings)
end



function are_settings_valid(sett)
    % Performs sanity checks on settings struct
    % 
    % Input arguments:
    % - sett: structure containing settings
    % 
    % Output arguments:
    % - out: boolean, true if sett is valid, false otherwise

    if not(isfield(sett, 'lin_settings'))
        error('lin_settings field not found in the settings file!')
    elseif not(isfield(sett, 'nonlin_settings'))
        error('nonlin_settings field not found in the settings file!')
    end
    
    l = sett.lin_settings;
    nl = sett.nonlin_settings;

    if not(isfield(l, 'lin_len'))
        error('lin_len subfield not found in linear settings!')
    elseif not(isfield(l, 'sequ_len'))
        error('sequ_len subfield not found in linear settings!')
    elseif not(isfield(l, 'output_width'))
        error('output_width subfield not found in linear settings!')
    elseif not(isfield(l, 'noise_stddev'))
        error('noise_stddev subfield not found in linear settings!')
    end

    if not(isfield(nl, 'lin_len'))
        error('nonlin_settings subfield not found in nonlinear settings!')
    elseif not(isfield(nl, 'nonlin_len'))
        error('nonlin_len subfield not found in nonlinear settings!')
    elseif not(isfield(nl, 'sequ_len'))
        error('sequ_len subfield not found in nonlinear settings!')
    elseif not(isfield(nl, 'output_width'))
        error('output_width subfield not found in nonlinear settings!')
    elseif not(isfield(nl, 'noise_stddev'))
        error('noise_stddev subfield not found in nonlinear settings!')
    end
end