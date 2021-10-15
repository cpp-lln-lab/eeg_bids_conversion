function config()

    cfg.source_data = 

    cfg.dataset_description.Name = 'baby eeg';

    cfg.method    = 'copy';
    cfg.datatype  = 'eeg';


    % specify some general information that will be added to the eeg.json file
    cfg.InstitutionName             = 'University of California San Diego';
    cfg.InstitutionalDepartmentName = 'Schwartz Center for Computational Neuroscience';
    cfg.InstitutionAddress          = '9500 Gilman Drive # 0559; La Jolla CA 92093, USA';

    % provide the mnemonic and long description of the task
    cfg.TaskName        = 'change detection';
    cfg.TaskDescription = 'Subjects were responding as fast as possible upon a change in a visually presented stimulus.';

    % these are EEG specific
    cfg.eeg.SoftwareFilters  = struct();
    cfg.eeg.PowerLineFrequency = 60;   % since recorded in the USA
    cfg.eeg.EEGReference       = 'M1'; % actually I do not know, but let's assume it was left mastoid