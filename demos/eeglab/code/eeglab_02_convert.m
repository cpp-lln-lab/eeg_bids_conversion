%
% (C) Copyright 2021 Remi Gau

% Adds the code of eeg_bids_conversion
% you can also simply run the function manually
run ../../../init_env.m;

% Load config
cfg = conversion_config();

% Runs the conversion
convert_to_bids(cfg);
