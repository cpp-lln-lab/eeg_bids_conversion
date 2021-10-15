sub = {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10'};

% for subject 3 the age is unknown, for subject 2 the sex is not specified
age = [11  96  nan 77  82  87  18 40  26  80];
sex = {'f' [] 'f' 'f' 'f' 'm' 'm' 'm' 'm' 'm'};
handedness = {'r'};


for subindx=1%:numel(sub)

  cfg = [];
  


  % specify the input file name, here we are using the same file for every subject
  cfg.dataset   = fullfile(pwd, 'source', 'BB10', 'FPAS2_BB10.vhdr');

  % specify the output directory
  cfg.bidsroot  = 'bids';
  cfg.sub       = sub{subindx};

  % specify the information for the participants.tsv file
  % this is optional, you can also pass other pieces of info
  cfg.participants.age = age(subindx);
  cfg.participants.sex = sex{subindx};
  cfg.participants.handedness = handedness{subindx};

  % specify the information for the scans.tsv file
  % this is optional, you can also pass other pieces of info
  cfg.scans.acq_time = datestr(now, 'yyyy-mm-ddThh:MM:SS'); % according to RFC3339

  data2bids(cfg);

end