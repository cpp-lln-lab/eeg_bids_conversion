

clean:
	rm -rf lib/fieldtrip
install:
	git clone --depth 1 https://github.com/fieldtrip/fieldtrip.git  lib/fieldtrip

install_bids_matlab:
	rm -rf lib/bids-matlab
	git clone -b dev --depth 1 git@github.com:bids-standard/bids-matlab.git  lib/bids-matlab
	rm -rf lib/bids-matlab/.git
	rm -rf lib/bids-matlab/.github
