

clean:
	rm -rf lib/fieldtrip
install:
	git clone --depth 1 https://github.com/fieldtrip/fieldtrip.git  lib/fieldtrip

install_bids_matlab:
	rm -rf lib/bids-matlab
	git clone -b dev --depth 1 git@github.com:bids-standard/bids-matlab.git  lib/bids-matlab
	rm -rf lib/bids-matlab.git
	rm -rf lib/bids-matlab.github
	rm -rf lib/bids-matlabbinder
	rm -rf lib/bids-matlabdocs
	rm -rf lib/bids-matlabtemplates
	rm -rf lib/bids-matlabcommenting_images
