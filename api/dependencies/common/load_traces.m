function [inputs, targets] = load_traces(file_paths, start, stop)
    % This function loads data from .mat files
    % that are expected to contain 2 fields: xIF
    % and yIF. xIF represents the ideal signal
    % while yIF is the noisy and distorted signal.
    % The function also performs some preprocessing
    % on the sequences it loads. Specifically,
    % sequences are normalized so that their standard
    % deviation is equal to 0.1.
    % 
    % Input arguments:
    % - file_paths: vector in which the file names are stored as strings
    % - start: first sample to consider in each trace
    % - stop: last sample to consider in each trace
    % 
    % Output arguments:
    % - inputs: matrix containing input traces (each column is a trace)
    % - targets: matrix containing target traces (each column is a trace)
    % 
    % Copyright (c) 2022 Valerio Spinogatti
    % Licensed under GNU License


    current_path = fileparts(mfilename( 'fullpath' ));

    if nargin == 1
        start = 1;
        stop  = 'end';
    elseif nargin == 2
        stop = 'end';
    end

    initial = true;
    for file = file_paths
        if initial
            [inputs, targets] = load_from_single_file(file, start, stop);
            initial = false;
        else
            [inp, targ] = load_from_single_file(file, start, stop);
            inputs = cat(2, inputs, inp);
            targets = cat(2, targets, targ);
        end
    end
end



function [inputs, targets] = load_from_single_file(file_path, start, stop)

    data = load(file_path);

    try
        idata = data.idata; % xIf is the input *to the channel + analog front end*
        odata2 = data.odata2; % yIf is the output *of the channel + analog front end* (noisy and distorted).
        % t = data.t;
        
        if strcmp(stop, 'end')
            idata = idata(start:end, :);
            odata2 = odata2(start:end, :, :);
        else        
            idata = idata(start:stop, :);
            odata2 = odata2(start:stop, :, :);
        end
    
        sequ_len = size(idata, 1);
        n_input_traces = size(idata, 2);
        
        % ystd = std(idata, [], 'all');
        % xstd = std(odata2, [], 'all');
        inputs = zeros(sequ_len, 2*n_input_traces);
        targets = zeros(sequ_len, 2*n_input_traces);
        
        for input_idx = 1:n_input_traces                
            x1 = odata2(:, input_idx, 1);
            x2 = odata2(:, input_idx, 2);
            y = idata(:, input_idx);
            
            xmax1 = max(abs(x1), [], 'all');
            xmax2 = max(abs(x2), [], 'all');
            ymax = max(abs(y), [], 'all');
            xscaling1 = 0.9/xmax1;
            xscaling2 = 0.9/xmax2;
            yscaling = 0.9/ymax;
    
            y = y';
            x1 = x1';
            x2 = x2';
            
            inputs(:, input_idx*2-1) = xscaling1*x1;
            inputs(:, input_idx*2) = xscaling2*x2;
            targets(:, input_idx*2-1) = yscaling*y;
            targets(:, input_idx*2) = yscaling*y;
        end
    catch
        idata = data.idata; % xIf is the input *to the channel + analog front end*
        odata = data.odata; % yIf is the output *of the channel + analog front end* (noisy and distorted).
        % t = data.t;
        
        if strcmp(stop, 'end')
            idata = idata(start:end, :);
            odata = odata(start:end, :, :);
        else        
            idata = idata(start:stop, :);
            odata = odata(start:stop, :, :);
        end
    
        sequ_len = size(idata, 1);
        n_input_traces = size(idata, 2);
        inputs = zeros(sequ_len, n_input_traces);
        targets = zeros(sequ_len, n_input_traces);
        
        for input_idx = 1:n_input_traces                
            x = odata(:, input_idx);
            y = idata(:, input_idx);
            
            xmax1 = max(abs(x), [], 'all');
            ymax = max(abs(y), [], 'all');
            xscaling1 = 0.9/xmax1;
            yscaling = 0.9/ymax;
    
            y = y';
            x = x';
            
            inputs(:, input_idx) = xscaling1*x;
            targets(:, input_idx) = yscaling*y;
        end
    end
end
