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
    % The settings file should have a precise structure.
    % Below is an example of how the file should be organized:
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
    % Copyright (c) 2022 Valerio Spinogatti
    % Licensed under GNU License

    try
        sfile = fileread(settings_file);
    catch
        error(sprintf("Something went wrong while trying to read settings from the file you specified.\n Check that the format of the file is correct."))
    end

    settings = jsondecode(sfile);
end
