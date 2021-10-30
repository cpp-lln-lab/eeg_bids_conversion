function convert_to_bids(cfg)
  %
  % (C) Copyright 2021 Remi Gau

  fprintf(1, 'Reading data from %s\n\n', cfg.source_data);
  
  % TODO load participants.tsv

  sub = cfg.subjects;

  nb_subjects = numel(sub);

  for i_sub = 1:numel(nb_subjects)

    this_sub = sub(i_sub);
    cfg.sub = this_sub.label;
    this_sub = rmfield(this_sub, 'label');

    fprintf(1, 'Reading data from subject %s\n\n', cfg.sub);

    cfg.participants = this_sub;

    sub_folder = fullfile(cfg.source_data, cfg.sub);

    run_folders = bids.internal.file_utils('FPList', ...
                                           sub_folder, ...
                                           'dir', ...
                                           ['^' cfg.run_folder_prefix '.*$']);

    nb_runs = size(run_folders, 1);

    for i_run = 1:nb_runs
      % TODO make sure that runs are converted in the right order
      datafile = bids.internal.file_utils('FPList', ...
                                          run_folders(i_run, :), ...
                                          ['^.*.' cfg.extension '$']);
      cfg.dataset = datafile;
      data2bids(cfg);
    end

  end

  dashed_line = '\n----------------------------------';
  fprintf(1, dashed_line)
  fprintf(1, '\nRemember to validate your dataset:')
  fprintf(1, '\nVALIDATOR_URL')
  fprintf(1, dashed_line)
  fprintf(1, '\n')