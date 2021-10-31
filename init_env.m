function init_env()
    %
    % (C) Copyright 2021 Remi Gau

    try
        ft_defaults();
    catch
    end

    paths_to_add = {
        fullfile(fileparts(mfilename('fullpath')), 'src');
        };

    for i = size(paths_to_add, 1)
        addpath(paths_to_add{i});
    end


end
