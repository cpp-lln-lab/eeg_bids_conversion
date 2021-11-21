function convert_to_bids(cfg)
  %
  % (C) Copyright 2021 Remi Gau

  if cfg.init
    bids.init(cfg.bidsroot);
  end

  fprintf(1, 'Reading data from %s\n\n', cfg.source_data);

  participants = bids.util.tsvread(cfg.participants_file);
  participants_folder = participants.source_folder;

  for i_sub = 1:size(participants_folder, 1)

    cfg.sub = get_participant_label(participants, i_sub);
    fprintf(1, 'Reading data from subject %s\n\n', cfg.sub);

    cfg.participants = extract_participant(participants, i_sub);

    sub_input_folder = fullfile(cfg.source_data, participants_folder{i_sub});

    convert_subject(sub_input_folder, cfg);

  end

  % Add data dictionary for TSV files
  create_data_dictionary(fullfile(cfg.bidsroot, 'participants.tsv'));

  BIDS = bids.layout(cfg.bidsroot);
  events = bids.query(BIDS, 'data', 'suffix', 'events');
%   for i = 1:size(events, 1)
%     create_data_dictionary(events{i});
%   end

  dashed_line = '\n----------------------------------';
  fprintf(1, dashed_line);
  fprintf(1, '\nRemember to validate your dataset:');
  fprintf(1, '\n https://bids-standard.github.io/bids-validator/');
  fprintf(1, dashed_line);
  fprintf(1, '\n');

end

function convert_subject(sub_input_folder, cfg)
  %
  % if we find folders with the run prefix we convert them and don't dig deeper
  % if not we dig one level deeper assuming there is a session level
  %

  [run_folders, nb_runs] = get_run_folders(sub_input_folder, cfg);

  if nb_runs > 0
    convert_run_data(run_folders, cfg);

  else
    ses_folders = bids.internal.file_utils('FPList', sub_input_folder, 'dir', '^.*$');

    if isempty(ses_folders)
      warning('Found no session or run for subject:\n %s', sub_input_folder);

    else

      ses_folders = cellstr(ses_folders);

      for i = 1:size(ses_folders, 1)

        [run_folders, nb_runs] = get_run_folders(ses_folders{i}, cfg);

        if nb_runs > 0
          cfg.ses = bids.internal.file_utils(ses_folders{i}, 'basename');
          convert_run_data(run_folders, cfg);

        else
          warning('Found no session or run for subject:\n %s', ses_folders{i});

        end

      end

    end

  end

end

function convert_run_data(run_folders, cfg)

  run_folders = cellstr(run_folders);

  for i = 1:size(run_folders, 1)

    run_name = bids.internal.file_utils(run_folders{i}, 'basename');
    run_idx = strrep(run_name, cfg.run_folder_prefix, '');
    run_idx = str2double(run_idx);
    cfg.run = zero_pad(run_idx);

    datafile = bids.internal.file_utils('FPList', ...
                                        run_folders{i}, ...
                                        ['^.*.' cfg.extension '$']);
    cfg.dataset = datafile;

    data2bids(cfg);

  end
end

function [run_folders, nb_runs] = get_run_folders(sub_input_folder, cfg)

  run_folders = bids.internal.file_utils('FPList', ...
                                         sub_input_folder, ...
                                         'dir', ...
                                         ['^' cfg.run_folder_prefix '.*$']);

  nb_runs = size(run_folders, 1);

end

function this_participant = extract_participant(participants, index)
  fields = fieldnames(participants);
  this_participant = struct();
  for i_field = 1:numel(fields)
    this_field = fields{i_field};
    if ~ismember(this_field, {'label', 'source_folder'})
      this_participant.(this_field) = participants.(this_field)(index);
    end
  end
end

function label = get_participant_label(participants, index)
  label = participants.label(index);
  if ~ischar(label)
    label = zero_pad(label);
  end
end

function zero_padded = zero_pad(not_zero_padded)
  zero_padded = sprintf('%03.0f', not_zero_padded);
end
