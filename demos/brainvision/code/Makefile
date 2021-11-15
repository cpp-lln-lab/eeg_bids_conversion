MATLAB = /usr/local/MATLAB/R2017a/bin/matlab
ARG    = -nodisplay -nosplash -nodesktop

all: bids

clean:
	rm -rf ../sourcedata
	rm -rf ../sub-*
	rm -rf ../*.tsv
	rm -rf ../*.json
	rm -rf ../README
	rm -rf ../CHANGES

setup:
	$(MATLAB) $(ARG) -r "run('brainvision_01_setup_ds.m');exit;"

bids: sourcedata
	$(MATLAB) $(ARG) -r "run('brainvision_02_convert.m');exit;"
