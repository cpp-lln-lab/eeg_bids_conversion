function convert_to_bids(cfg)
  %
  % (C) Copyright 2021 Remi Gau

  if cfg.init
    bids.init(cfg.bidsroot);
  end

  fprintf(1, 'Reading data from %s\n\n', cfg.source_data);

  participants = bids.util.tsvread(cfg.participants_file);

  participants_folder = participants.source_folder;

  nb_subjects = numel(participants_folder);

  for i_sub = 1:numel(nb_subjects)

    cfg.sub = get_participant_label(participants, i_sub);
    fprintf(1, 'Reading data from subject %s\n\n', cfg.sub);

    cfg.participants = extract_participant(participants, i_sub);

    sub_input_folder = fullfile(cfg.source_data, participants_folder{i_sub});

    run_folders = bids.internal.file_utils('FPList', ...
                             sub_input_folder, ...
                             'dir', ...
                             ['^' cfg.run_folder_prefix '.*$']);

    nb_runs = size(run_folders, 1);

    for i_run = 1:nb_runs
      % TODO make sure that runs are converted in the right order
      datafile = bids.internal.file_utils('FPList', ...
                            run_folders(i_run, :), ...
                            ['^.*.' cfg.extension '$']);
      cfg.run = zero_pad(i_run);
      cfg.dataset = datafile;
      data2bids(cfg);
    end

  end

  % add data dictionary for TSV files

  create_data_dictionary(fullfile(cfg.bidsroot, 'participants.tsv'));

  BIDS = bids.layout(cfg.bidsroot);
    events = bids.query(BIDS, 'data', 'suffix', 'events');
    for i = 1:size(events, 1)
        create_data_dictionary(events{i})
    end

  dashed_line = '\n----------------------------------';
  fprintf(1, dashed_line);
  fprintf(1, '\nRemember to validate your dataset:');
  fprintf(1, '\n https://bids-standard.github.io/bids-validator/');
  fprintf(1, dashed_line);
  fprintf(1, '\n');

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
