function report(varargin)
  %
  % Create a short summary of the acquisition parameters of a BIDS dataset.
  %
  % The output can be saved to a markdown file and/or printed to the screen.
  %
  % USAGE::
  %
  %     bids.report(BIDS, sub, ses, output_path, 'read_nifti', read_nifti, 'verbose', verbose);
  %
  % :param BIDS:  Path to BIDS dataset or output of bids.layout [Default: pwd]
  % :type  BIDS:  string or structure
  % :param sub:   Specifies which the subject label to take as template.
  %               [Default is the first subject]
  % :type  sub:   string
  % :param ses:   Specifies which the session label to take as template.
  % :type  ses:   string
  % :param output_path:  Folder where the report should be printed. If empty
  %                      (default) then the output is sent to the prompt.
  % :type  output_path:  string
  % :param read_nifti:  If set to ``true`` (default) the function will try to read the
  %                     NIfTI file to get more information. This relies on the
  %                     ``spm_vol.m`` function from SPM.
  % :type  read_nifti:  boolean
  %
  %
  % (C) Copyright 2018 BIDS-MATLAB developers

  % TODO
  % --------------------------------------------------------------------------
  % - deal with DWI bval/bvec values not read by bids.query
  % - deal with "EEG" / "MEG"
  % - deal with "events": compute some summary statistics as suggested in COBIDAS report
  % - report summary statistics on participants as suggested in COBIDAS report
  % - check if all subjects have the same content?
  % - take care of other recommended metafield in BIDS specs or COBIDAS?
  % - add a dataset description (ethics, grant, scanner details...)

  default_BIDS = pwd;
  default_sub = false;
  default_ses = false;
  default_output_path = '';
  default_read_nifti = true;
  default_verbose = false;

  p = inputParser;

  charOrStruct = @(x) ischar(x) || isstruct(x);
  addOptional(p, 'BIDS', default_BIDS, charOrStruct);
  addOptional(p, 'sub', default_sub, @ischar);
  addOptional(p, 'ses', default_ses, @ischar);
  addOptional(p, 'output_path', default_output_path, @ischar);

  %   addOptional(p, 'filter', default_filter, @isstruct);

  addParameter(p, 'read_nifti', default_read_nifti);
  addParameter(p, 'verbose', default_verbose);

  parse(p, varargin{:});

  BIDS = p.Results.BIDS;
  if ~isstruct(p.Results.BIDS)
    BIDS = bids.layout(p.Results.BIDS);
  end

  sub = select_subject(BIDS, p);

  [ses, nb_ses] = select_session(BIDS, p, sub);

  read_nii = p.Results.read_nifti & exist('spm_vol', 'file') == 2;

  file_id = open_output_file(BIDS, p.Results.output_path, p.Results.verbose);

  for iSess = 1:nb_ses

    clear filter;

    filter.sub = sub;

    if ~isempty(ses)
      filter.ses = ses{iSess};

      if nb_ses > 1
        text = sprintf('\n Working on session: %s\n', ses{iSess});
        print_to_output(text, file_id, p.Results.verbose);
      end

    end

    suffixes = bids.query(BIDS, 'suffixes', filter);

    for iType = 1:numel(suffixes)

      filter.suffix = suffixes{iType};

      tasks = bids.query(BIDS, 'tasks', filter);
      filter = update_filter_with_task_label(BIDS, filter);

      boilerplate_text = get_boilerplate(suffixes{iType});

      switch suffixes{iType}

        % TODO
        % use schema to identify suffixes
        case {'T1w' 'inplaneT2' 'T1map' 'FLASH'}

          fprintf(file_id, '\nANATOMICAL REPORT\n\n');

          [filter, nb_runs] = update_filter_with_run_label(BIDS, filter);

          [filename, metadata] = get_filemane_and_metadata(BIDS, filter);
          boilerplate_text = replace_placeholders(boilerplate_text, metadata);

          acq_param = get_acq_param(BIDS, filter, read_nii, p.Results.verbose);

          text = sprintf(boilerplate_text, ...
                         acq_param.n_slices, ...
                         acq_param.te, ...
                         acq_param.fov, ...
                         acq_param.ms, ...
                         acq_param.vs);

          print_base_report(file_id, metadata, p.Results.verbose);
          print_to_output(text, file_id, p.Results.verbose);

          % TODO
          % should cover all functional suffixes
        case 'bold'

          fprintf(file_id, '\nFUNCTIONAL REPORT\n\n');

          for iTask = 1:numel(tasks)

            filter.task = tasks{iTask};
            [filter, nb_runs] = update_filter_with_run_label(BIDS, filter);

            [filename, metadata] = get_filemane_and_metadata(BIDS, filter);
            boilerplate_text = replace_placeholders(boilerplate_text, metadata);

            acq_param = get_acq_param(BIDS, filter, read_nii, p.Results.verbose);

            acq_param.n_runs = num2str(nb_runs);

            % set run duration
            %             if ~strcmp(acq_param.tr, '[XXtrXX]') && ...
            %                     ~strcmp(acq_param.n_vols, '[XXn_volsXX]')
            %
            %               acq_param.length = ...
            %                   num2str(str2double(acq_param.tr) / 1000 * ...
            %                           str2double(acq_param.n_vols) / 60);
            %
            %             end

            text = sprintf(boilerplate_text, ...
                           acq_param.n_runs, ...
                           acq_param.n_slices, ...
                           acq_param.so_str, ...
                           acq_param.te, ...
                           acq_param.fov, ...
                           acq_param.ms, ...
                           acq_param.vs, ...
                           acq_param.mb_str, ...
                           acq_param.pr_str, ...
                           acq_param.length, ...
                           acq_param.n_vols);

            print_base_report(file_id, metadata, p.Results.verbose);
            print_to_output(text, file_id, p.Results.verbose);

          end

          % TODO
          % should cover all fmap suffixes
        case 'phasediff'

          fprintf(file_id, '\nFIELD MAP REPORT\n\n');

          [filter, nb_runs] = update_filter_with_run_label(BIDS, filter);

          [filename, metadata] = get_filemane_and_metadata(BIDS, filter);
          boilerplate_text = replace_placeholders(boilerplate_text, metadata);

          acq_param = get_acq_param(BIDS, filter, read_nii, p.Results.verbose);

          %           acq_param.for = sprintf('for %i runs of %s, ', nb_runs, this_task);

          acq_param.for = 'TODO';

          text = sprintf(boilerplate_text, ...
                         acq_param.n_slices, ...
                         acq_param.te, ...
                         acq_param.fov, ...
                         acq_param.ms, ...
                         acq_param.vs, ...
                         acq_param.for);

          print_base_report(file_id, metadata, p.Results.verbose);
          print_to_output(text, file_id, p.Results.verbose);

        case 'dwi'

          fprintf(file_id, '\nDWI REPORT\n\n');

          [filter, nb_runs] = update_filter_with_run_label(BIDS, filter);

          [filename, metadata] = get_filemane_and_metadata(BIDS, filter);
          boilerplate_text = replace_placeholders(boilerplate_text, metadata);

          acq_param = get_acq_param(BIDS, filter, read_nii, p.Results.verbose);

          % dirty hack to try to look into the BIDS structure as bids.query does not
          % support querying directly for bval and bvec
          try
            acq_param.n_vecs = num2str(size(BIDS.subjects(sub).dwi.bval, 2));
            %             acq_param.bval_str = ???
          catch
            msg = 'Could not read the bval & bvec values.';
            bids.internal.error_handling(mfilename, ...
                                         'cannotReadBvalBvec', ...
                                         msg, ...
                                         true, ...
                                         p.Results.verbose);
          end

          text = sprintf(boilerplate_text, ...
                         acq_param.n_slices, ...
                         acq_param.so_str, ...
                         acq_param.te, ...
                         acq_param.fov, ...
                         acq_param.ms, ...
                         acq_param.vs, ...
                         acq_param.bval_str, ...
                         acq_param.n_vecs, ...
                         acq_param.mb_str);

          print_base_report(file_id, metadata, p.Results.verbose);
          print_to_output(text, file_id, p.Results.verbose);

        case 'physio'
          msg = 'physio not supported yet';
          bids.internal.error_handling(mfilename, ...
                                       'physioNotSupported', ...
                                       msg, ...
                                       true, ...
                                       p.Results.verbose);

        case {'meg' 'eeg'}

          for iTask = 1:numel(tasks)

            filter.task = tasks{iTask};
            [filter, nb_runs] = update_filter_with_run_label(BIDS, filter);

            [filename, metadata] = get_filemane_and_metadata(BIDS, filter);
            boilerplate_text = replace_placeholders(boilerplate_text, metadata);

            print_base_report(file_id, metadata, p.Results.verbose);

          end

        case 'events'
          msg = 'events not supported yet';
          bids.internal.error_handling(mfilename, ...
                                       'eventsNotSupported', ...
                                       msg, ...
                                       true, ...
                                       p.Results.verbose);

        otherwise
          % 'channels' 'headshape'

      end

      print_to_output('\n', file_id, p.Results.verbose);

    end

  end

  print_credit(file_id, p.Results.verbose);

end

function sub = select_subject(BIDS, p)

  sub = p.Results.sub;
  if isempty(p.Results.sub)
    subjects = bids.query(BIDS, 'subjects');
    sub = subjects{1};
  end

end

function [ses, nb_ses] = select_session(BIDS, p, sub)

  ses = p.Results.ses;
  sessions = bids.query(BIDS, 'sessions', 'sub', sub);
  if isempty(ses) || ~ismember(ses, sessions)
    ses = sessions;
  end
  if ischar(ses)
    ses = {ses};
  end

  nb_ses = numel(ses);
  if nb_ses < 1
    nb_ses = 1;
  end

end

function file_id = open_output_file(BIDS, output_path, verbose)

  file_id = 1;

  if ~isempty(output_path)

    bids.util.mkdir(output_path);

    [~, folder] = fileparts(BIDS.pth);

    filename = fullfile( ...
                        output_path, ...
                        ['dataset-' folder '_bids-matlab_report.md']);

    file_id = fopen(filename, 'w+');

    if file_id == -1

      msg = 'Unable to write file %s. Will print to screen.';
      bids.internal.error_handling(mfilename, 'cannotWriteToFile', msg, true, verbose);

      file_id = 1;

    else

      text = sprintf('Dataset description saved in:  %s\n\n', filename);
      print_to_output(text, file_id, verbose);

    end

  end

end

function filter = update_filter_with_task_label(BIDS, filter)

  if isfield(filter, 'task')
    filter = rmfield(filter, 'task');
  end

end

function [filter, nb_runs] = update_filter_with_run_label(BIDS, filter)

  runs_ls = bids.query(BIDS, 'runs', filter);
  nb_runs = 0;

  if ~isempty(runs_ls)
    filter.run = runs_ls{1};
    nb_runs = numel(runs_ls);
  else
    if isfield(filter, 'run')
      filter = rmfield(filter, 'run');
    end
  end

end

function template = get_boilerplate(type)

  file = '';

  switch type

    case {'institution', 'device_info'}
      file = [type '.tmp'];

    case {'T1w' 'inplaneT2' 'T1map' 'FLASH'}
      file = 'anat.tmp';

    case 'bold'
      file = 'func.tmp';

    case   'phasediff'
      file = 'fmap.tmp';

    case 'dwi'
      file = 'dwi.tmp';

    case 'credit'
      file = 'credit.tmp';

  end

  if ~isempty(file)
    fid = fopen(fullfile(fileparts(mfilename('fullpath')), '..', ...
                         'templates', 'boilerplates', file));
    C = textscan(fid, '%s');
    fclose(fid);
    template = strjoin(C{1}, ' ');
  else
    template = '';
  end

end

function acq_param = get_acq_param(BIDS, filter, read_gz, verbose)
  % Will get info from acquisition parameters from the BIDS structure or from
  % the NIfTI files

  acq_param = set_default_acq_param();

  [filename, metadata] = get_filemane_and_metadata(BIDS, filter);

  if verbose
    fprintf('\n  Getting parameters - %s\n\n', filename{1});
  end

  fields_list = { ...
                 'te', 'EchoTime'; ...
                 'so_str', 'SliceTiming'; ...
                 'for_str', 'IntendedFor'};

  acq_param = get_parameter(acq_param, metadata, fields_list);

  if isfield(metadata, 'EchoTime1') && isfield(metadata, 'EchoTime2')
    acq_param.te = [metadata.EchoTime1 metadata.EchoTime2];
  end

  % TODO
  % acq_param = convert_field_to_millisecond(acq_param, {'tr', 'te'});

  if isfield(metadata, 'EchoTime1') && isfield(metadata, 'EchoTime2')
    acq_param.te = sprintf('%0.2f / %0.2f', acq_param.te);
  end

  acq_param = convert_field_to_str(acq_param);

  acq_param.so_str = define_slice_timing(acq_param.so_str);

  acq_param = read_nifti(read_gz, filename{1}, acq_param, verbose);

end

function acq_param = read_nifti(read_gz, filename, acq_param, verbose)

  % -Try to read the relevant NIfTI file to get more info from it
  % --------------------------------------------------------------------------
  if read_gz
    fprintf(' Opening file - %s.\n\n', filename{1});
    try
      % read the header of the NIfTI file
      hdr = spm_vol(filename{1});

      % nb volumes
      acq_param.n_vols  = num2str(numel(hdr));

      hdr = hdr(1);
      dim = abs(hdr.dim);

      % nb slices
      acq_param.n_slices = sprintf('%i', dim(3));

      % matrix size
      acq_param.ms = sprintf('%i X %i', dim(1), dim(2));

      % voxel size
      vs = abs(diag(hdr.mat));
      acq_param.vs = sprintf('%.2f X %.2f X %.2f', vs(1), vs(2), vs(3));

      % field of view
      acq_param.fov = sprintf('%.2f X %.2f', vs(1) * dim(1), vs(2) * dim(2));

    catch

      msg = sprintf('Could not read the header from file %s.\n', filename{1});
      bids.internal.error_handling(mfilename, 'cannotReadHeader', msg, true, verbose);

    end
  end

end

function acq_param = set_default_acq_param()

  acq_param.te = '[XXteXX]';

  % number of runs (dealt with outside this function but initialized here)
  acq_param.n_runs  = '[XXn_runsXX]';
  acq_param.so_str  = '[XXso_strXX]'; % slice order string
  acq_param.mb_str  = '[XXmb_strXX]'; % multiband
  acq_param.pr_str  = '[XXpr_strXX]'; % parallel imaging
  acq_param.length  = '[XXlengthXX]';

  acq_param.for_str = '[XXfor_strXX]'; % for fmap: for which run this fmap is for.

  acq_param.bval_str = '[XXbval_strXX]';
  acq_param.n_vecs = '[XXn_vecsXX]';

  acq_param.fov = '[XXfovXX]';
  acq_param.n_slices = '[XXn_slicesXX]';
  acq_param.ms = '[XXmsXX]'; % matrix size
  acq_param.vs = '[XXvsXX]'; % voxel size
  acq_param.n_vols  = '[XXn_volsXX]';

end

function [filename, metadata] = get_filemane_and_metadata(BIDS, filter)
  filename = bids.query(BIDS, 'data', filter);
  metadata = bids.query(BIDS, 'metadata', filter);
end

function acq_param = get_parameter(acq_param, metadata, fields_list)

  for iField = 1:size(fields_list, 1)

    if isfield(metadata, fields_list{iField})
      acq_param.(fields_list{iField, 1}) = metadata.(fields_list{iField, 2});
    end

  end

end

function acq_param = convert_field_to_str(acq_param)

  fields_list = fieldnames(acq_param);

  for iField = 1:numel(fields_list)
    if isnumeric(acq_param.(fields_list{iField}))
      acq_param.(fields_list{iField}) = num2str(acq_param.(fields_list{iField}));
    end
  end

end

function acq_param = convert_field_to_millisecond(acq_param, fields_list)

  for iField = 1:numel(fields_list)
    if isnumeric(acq_param.(fields_list{iField}))
      acq_param.(fields_list{iField}) = acq_param.(fields_list{iField}) * 1000;
    end
  end

end

function so_str = define_slice_timing(slice_timing)

  so_str = slice_timing;
  if strcmp(so_str, '[XXso_strXX]')
    return
  end

  % Try to figure out the order the slices were acquired from their timing
  if iscell(so_str)
    so_str = cell2mat(so_str);
  end

  [~, I] = sort(so_str);

  if all(I == (1:numel(I))')
    so_str = 'ascending';

  elseif all(I == (numel(I):-1:1)')
    so_str = 'descending';

  elseif I(1) < I(2)
    so_str = 'interleaved ascending';

  elseif I(1) > I(2)
    so_str = 'interleaved descending';

  else
    so_str = '????';

  end

end

function print_to_output(text, file_id, verbose)

  text = [text '\n'];
  text = strrep(text, '{{', '');
  text = strrep(text, '}}', '');

  text = add_word_wrap(text);

  fprintf(file_id,  text);

  % Print to screen
  if verbose && file_id ~= 1
    fprintf(1, text);
  end
end

function text = add_word_wrap(text)

  linelength = 80;

  space = strfind(text, ' ');

  linebreaks = find(diff(mod(space, linelength)) < 1) + 1;

  for i_linebreaks = 1:numel(linebreaks)

    % the line break shift the string sequence
    % so the breaks should be offsetted;
    offset = 2 * (i_linebreaks - 1);

    this_break = space(linebreaks(i_linebreaks)) + offset;

    text = [text(1:this_break), ...
            '\n', ...
            text(this_break + 1:end)];
  end
end

function boilerplate_text = replace_placeholders(boilerplate_text, metadata)

  placeholders = return_list_placeholders(boilerplate_text);

  for i = 1:numel(placeholders)

    this_placeholder = placeholders{i}{1};

    if isfield(metadata, this_placeholder) && ...
            ~isempty(metadata.(this_placeholder))

      text_to_insert = metadata.(this_placeholder);

    else
      text_to_insert = ['XXX' placeholders{i}{1} 'XXX'];

    end

    if isnumeric(text_to_insert)
      text_to_insert = num2str(text_to_insert);
    end

    boilerplate_text = strrep(boilerplate_text, ...
                              this_placeholder,  ...
                              text_to_insert);

  end

end

function placeholders = return_list_placeholders(boilerplate_text)
  placeholders = regexp(boilerplate_text, '{{(\w*)}}', 'tokens');
end

function print_base_report(file_id, metadata, verbose)
  print_institution_info(file_id, metadata, verbose);
  print_device_info(file_id, metadata, verbose);
end

function print_institution_info(file_id, metadata, verbose)
  boilerplate_text = get_boilerplate('institution');
  boilerplate_text = replace_placeholders(boilerplate_text, metadata);
  print_to_output(boilerplate_text, file_id, verbose);
end

function print_device_info(file_id, metadata, verbose)
  boilerplate_text = get_boilerplate('device_info');
  boilerplate_text = replace_placeholders(boilerplate_text, metadata);
  print_to_output(boilerplate_text, file_id, verbose);
end

function print_credit(file_id, verbose)
  boilerplate_text = get_boilerplate('credit');
  print_to_output(boilerplate_text, file_id, verbose);
end
