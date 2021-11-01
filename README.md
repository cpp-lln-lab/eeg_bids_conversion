# EEG data conversion to BIDS

Wrapper around FieldTrip `data2bids` to facilitate conversion to BIDS.

- [EEG data conversion to BIDS](#eeg-data-conversion-to-bids)
  - [Requirements](#requirements)
  - [Usage](#usage)
    - [Organize your source data](#organize-your-source-data)
      - [Participant mapping](#participant-mapping)
      - [Configuration](#configuration)
    - [Run the conversion](#run-the-conversion)
  - [TODO](#todo)

## Requirements

- MATLAB - version ???? (not tested on Octave)
- [Fieldtrip](https://github.com/fieldtrip/fieldtrip.git) - version ????
- bids-matlab is already shipped as a library in the `lib` folder.

You can install Fieldtrip and update bids-matlab by running:

```
make install
```

## Usage

Add the proper folder to the Matlab path. Running the `init_env.m` function will
do this for you and also check that you have Fieldtrip installed.

### Organize your source data

**Rules**

- sujbect folder should start with a letter
- run folders should start with the same prefix (in this case `run`)
- one datafile per run folder
- you can have one extra level for sessions (this folder can only include
  characters and/or numbers)

<details><summary> <b> Example </b> </font> </summary><br>
<pre>
sourcedata
└── subject1
    ├── run1
    │   └── faces_run1.bdf
    └── run2
        └── faces_run2.bdf
</pre>
</details>

<details><summary> <b> Example with session level </b> </font> </summary><br>
<pre>
sourcedata
└── subject1
    └──day1
       ├── run1
       │   └── faces_run1.bdf
       └── run2
           └── faces_run2.bdf
</pre>
</details>

You can use some of bids-matlab function to help you create this folder tree:
```
prfx = 'run';
subjects = {'BB1', 'sub-02', 'ReGa'};
sessions = {'day1', 'beh'};
runs = {[prfx '1'],[prfx '2'], [prfx '5']};

bids.util.mkdir('sourcedata', subjects, sessions, runs);
```

Will create this.

```
sourcedata
├── BB1
│   ├── beh
│   │   ├── run1
│   │   ├── run2
│   │   └── run5
│   └── day1
│       ├── run1
│       ├── run2
│       └── run5
├── ReGa
│   ├── beh
│   │   ├── run1
│   │   ├── run2
│   │   └── run5
│   └── day1
│       ├── run1
│       ├── run2
│       └── run5
└── sub-02
    ├── beh
    │   ├── run1
    │   ├── run2
    │   └── run5
    └── day1
        ├── run1
        ├── run2
        └── run5
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
