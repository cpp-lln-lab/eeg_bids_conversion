# SPM multimodal dataset: EEG conversion

`spm_01_download_ds.m` downloads the data and organizes the sourcedata like
this.

```
sourcedata
└── BB01
    ├── run1
    │   └── faces_run1.bdf
    └── run2
        └── faces_run2.bdf
```

`conversion_config.m` has the configuration details needed for the conversion.

`spm_02_convert.m` does the actual conversion into BIDS by calling
`src/convert_to_bids.m` which is a wrapper function around `data2bids.m` from
Fieldtrip.

`participants_map.tsv` contains the information on how a given subject folder is
mapped to a participant in the final BIDS data set.
