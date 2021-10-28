function download_spm_eeg_ds(download_data, clean)
    %
    % (C) Copyright 2021 Remi Gau
    
    if nargin < 1
        download_data = false;
    end
    if nargin < 2
        clean = false;
    end

    working_directory = fileparts(mfilename('fullpath'));
    
    % clean previous runs
    output_dir = fullfile(working_directory, 'sourcedata');
    
    if download_data
        dataset_url = 'http://www.fil.ion.ucl.ac.uk/spm/download/data/mmfaces/multimodal_eeg.zip';
        fprintf('%-10s:', 'Downloading dataset...');
        urlwrite(dataset_url, 'multimodal_eeg.zip');
        fprintf(1, ' Done\n\n');
    end
    
    fprintf('%-10s:', 'Unzipping dataset...');
    % unzip('multimodal_eeg.zip');
    % movefile('EEG', output_dir);
    fprintf(1, ' Done\n\n');
    
    fprintf('%-10s:', 'Reorganize dataset...');
    
    [~, ~, ~] = mkdir(fullfile(output_dir, 'EEG', 'run1'));
    movefile(fullfile(output_dir, 'EEG', 'faces_run1.bdf'), ...
        fullfile(output_dir, 'EEG', 'run1', 'faces_run1.bdf'));
    [~, ~, ~] = mkdir(fullfile(output_dir, 'EEG', 'run2'));
    movefile(fullfile(output_dir, 'EEG', 'faces_run2.bdf'), ...
        fullfile(output_dir, 'EEG', 'run2', 'faces_run2.bdf'));
    fprintf(1, ' Done\n\n');
    
end
