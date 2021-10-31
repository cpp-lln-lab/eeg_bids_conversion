function cfg = conversion_config()
  %
  % (C) Copyright 2021 Remi Gau

  working_directory = fileparts(mfilename('fullpath'));

  cfg.init = true;

  cfg.run_folder_prefix = 'run';
  cfg.extension = 'bdf';

  cfg.bidsroot  = fullfile(working_directory, '..');
  cfg.source_data = fullfile(working_directory, '..', 'sourcedata');

  cfg.participants_file = fullfile(working_directory, 'participants_map.tsv');

  %% fieldtrip data2bids config

  cfg.dataset_description.Name = 'spm multimodal - EEG';

  cfg.method = 'copy';
  cfg.datatype = 'eeg';

  % specify some general information that will be added to the eeg.json file
  cfg.InstitutionName = ['Crossmodal perception and plasticity lab,', ...
                         ' Universite catholique de Louvain'];
  cfg.InstitutionalDepartmentName = '';
  cfg.InstitutionAddress = 'Belgium';

  % provide the mnemonic and long description of the task
  cfg.TaskName = 'facetask';
  cfg.TaskDescription = ['Subjects were responding as fast as possible '...
                         'upon a change in a visually presented stimulus.'];

  % these are EEG specific
  cfg.eeg.SoftwareFilters = struct();
  cfg.eeg.PowerLineFrequency = 50;
  cfg.eeg.EEGReference = 'M1';

end
