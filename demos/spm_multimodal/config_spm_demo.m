function cfg = config_spm_demo()
  %
  % (C) Copyright 2021 Remi Gau

  working_directory = fileparts(mfilename('fullpath'));

  cfg.subjects(1).label = '01';
  cfg.subjects(1).age = 11;
  cfg.subjects(1).sex = 'f';
  cfg.subjects(1).handedness = 'r';

  cfg.run_folder_prefix = 'run';
  cfg.extension = 'bdf';

  cfg.source_data = fullfile(working_directory, 'sourcedata');

  cfg.bidsroot  = fullfile(working_directory, 'raw');

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
  % actually I do not know, but let's assume it was left mastoid
  cfg.eeg.EEGReference = 'M1';

end
