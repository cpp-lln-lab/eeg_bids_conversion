
%
% creates the structure to host the source data for the conversion
%
% (C) Copyright 2021 Remi Gau

% Adds the code of eeg_bids_conversion
% you can also simply run the function manually
run ../../../init_env.m;

prfx = 'run';
subjects = {'BB01', 'BB02', 'BB03'};
runs = {[prfx '1']};

working_directory = fileparts(mfilename('fullpath'));

bids.util.mkdir(fullfile(working_directory, '..', 'sourcedata'), subjects, runs);
