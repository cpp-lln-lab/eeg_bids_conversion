function init_env()
  %
  % (C) Copyright 2021 Remi Gau

  this_path = fileparts(mfilename('fullpath'));

  try
    ft_defaults();
  catch
    try
      if exist(fullfile(this_path, 'lib', 'fieldtrip'), 'dir')
        addpath(fullfile(this_path, 'lib', 'fieldtrip'));
        ft_defaults();
      end
    catch
      error('Could not initialize FieldTrip. Is it in the Matlab path? Run "make install".');
    end
  end

  paths_to_add = {
                  fullfile(this_path, 'src')
                  fullfile(this_path, 'lib', 'bids-matlab')
                 };

  fprintf(1, '\nAdding to MATLAB path:');
  for i = 1:size(paths_to_add, 1)
    fprintf(1, '\n%s', paths_to_add{i});
    addpath(paths_to_add{i});
  end
  fprintf(1, '\n\n');

end
