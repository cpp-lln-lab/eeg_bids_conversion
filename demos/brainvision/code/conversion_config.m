function cfg = conversion_config()
  %
  % (C) Copyright 2021 Remi Gau

  working_directory = fileparts(mfilename('fullpath'));

  cfg.init = true;

  cfg.run_folder_prefix = 'run';
  cfg.extension = 'vhdr';

  cfg.bidsroot  = fullfile(working_directory, '..');
  cfg.source_data = fullfile(working_directory, '..', 'sourcedata');

  cfg.participants_file = fullfile(working_directory, 'participants_map.tsv');

  %% fieldtrip data2bids config

  cfg.dataset_description.Name = 'brainvision example dataset';

  cfg.method = 'copy';
  cfg.datatype = 'eeg';

  % specify some general information that will be added to the eeg.json file
  cfg.InstitutionAddress = 'Dijon';

  % provide the mnemonic and long description of the task
  cfg.TaskName        = 'FPAS';

  % these are EEG specific
  cfg.eeg.SoftwareFilters = struct();
  cfg.eeg.PowerLineFrequency = 50;
  cfg.eeg.EEGReference = 'M1';

end
