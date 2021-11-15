MATLAB = /usr/local/MATLAB/R2017a/bin/matlab
ARG    = -nodisplay -nosplash -nodesktop

all: bids
clean:
	rm -rf ../sourcedata/BB01
	rm -rf ../sub-*
	rm -rf ../*.tsv
	rm -rf ../*.json
	rm -rf ../README
	rm -rf ../CHANGES

sourcedata:
	$(MATLAB) $(ARG) -r "run ../../../init_env.m; run('spm_01_download_ds');exit;"

bids: sourcedata
	$(MATLAB) $(ARG) -r "run('spm_02_convert.m');exit;"
