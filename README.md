# EEG data conversion to BIDS

Wrapper around FieldTrip `data2bids` to facilitate conversion to BIDS.

## Requirements

- MATLAB - version ???? (not tested on Octave)
- [Fieldtrip](https://github.com/fieldtrip/fieldtrip.git) - version ????
- bids-matlab is already shipped as a library in the `lib` folder.

You can install Fieldtrip and update bids-matlab by running:

```
make install
```

## Usage

### Organize your source data

```
sourcedata
└── subject1
    ├── run1
    │   └── faces_run1.bdf
    └── run2
        └── faces_run2.bdf
```

#### Participant mapping

Create a TSV file that contains the information on how a given subject folder is
mapped to a participant in the final BIDS data set.

The REQUIRED columns are `label` and `source_folder`, but it can contain extra
info.

```tsv
label	source_folder	age	gender	group	handedness
1	BB01	25	F	ctrl	r
```

#### Configuration

Create `conversion_config.m` file with the configuration details needed for the
conversion. There is a template for this in the `templates` folder.

```matlab
  cfg.run_folder_prefix = prefix_used_for_run_folder;
  cfg.extension = extension_of_the_data_file;

  cfg.bidsroot  = path_where_to_create_the_bids_data;
  cfg.source_data = path_to_the_source_data_is;

  cfg.participants_file = path_to_participant_map;
```

<!-- TODO add more info about the config -->

### Run the conversion

```
init_env()
cfg = conversion_config();
convert_to_bids(cfg);

```

`src/convert_to_bids.m` which is a wrapper function around `data2bids.m` from
Fieldtrip.

## TODO

- create a function to check the `cfg` structure content
- labels cannot contain spaces otherwise we will have
  `sub-01_task-foo bar_eeg.bdf` and that's just not OK.
- `events.json` not created
- `participants.json` not created
