function spm_01_download_ds(download_data, clean)
  %
  % (C) Copyright 2021 Remi Gau

  if nargin < 1
    download_data = true;
  end
  if nargin < 2
    clean = false;
  end

  working_directory = fileparts(mfilename('fullpath'));

  if download_data
    dataset_url = 'https://sccn.ucsd.edu/mediawiki/images/9/9c/Eeglab_data.set';
    fprintf('%-10s:', 'Downloading dataset...');
    urlwrite(dataset_url, 'Eeglab_data.set');
    fprintf(1, ' Done\n\n');
  end

  output_dir = fullfile(working_directory, '..', 'sourcedata');
  if clean && exist(output_dir, 'dir')
    rmdir(output_dir, 's');
  end


  subjects = {'MaBa', 'ReGa', 'CeBa'};

  fprintf('%-10s:', 'Reorganize dataset...');

  [~, ~, ~] = mkdir(fullfile(output_dir, 'run1'));
  movefile(fullfile(output_dir, 'faces_run1.bdf'), ...
           fullfile(output_dir, 'run1', 'faces_run1.bdf'));
  [~, ~, ~] = mkdir(fullfile(output_dir, 'run2'));
  movefile(fullfile(output_dir, 'faces_run2.bdf'), ...
           fullfile(output_dir, 'run2', 'faces_run2.bdf'));
  fprintf(1, ' Done\n\n');

end
