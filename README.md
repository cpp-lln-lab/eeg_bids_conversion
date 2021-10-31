# EEG data conversion to BIDS

## Requirements

- MATLAB - version ???? (not tested on Octave)
- [Fieldtrip](https://github.com/fieldtrip/fieldtrip.git) - version ????
- bids-matlab is shipped as a library

You can install Fieldtrip and update bids-matlab by doing `make install`.

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

Create `conversion_config.m` with the configuration details needed for the conversion.

## TODO

- create a function to check the `cfg` structure content
- labels cannot contain spaces otherwise we will have
  `sub-01_task-foo bar_eeg.bdf` and that's just not OK.
- `events.json` not created
- `participants.json` not created
