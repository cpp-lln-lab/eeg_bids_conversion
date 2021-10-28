function convert_to_bids(cfg)
%
% (C) Copyright 2021 Remi Gau

sub = cfg.subjects;

nb_subjects = numel(sub);

for i_sub = 1:numel(nb_subjects)

  this_sub = sub(i_sub);
  cfg.sub = this_sub.label;
  this_sub = rmfield(this_sub, 'label');

  cfg.participants = this_sub;
  
  sub_folder = fullfile(cfg.source_data, cfg.sub);

  run_folders = bids.internal.file_utils('FPList', ...
                                          sub_folder, ...
                                          'dir', ...
                                          ['^' cfg.run_folder_prefix '.*$']);
  
  nb_runs = size(run_folders, 1);
  
  for i_run = 1:nb_runs
      datafile = bids.internal.file_utils('FPList', ...
                                          run_folders(i_run, :), ...
                                          ['^.*.' cfg.extension '$']);
      cfg.dataset = datafile;
      data2bids(cfg);
  end


end
