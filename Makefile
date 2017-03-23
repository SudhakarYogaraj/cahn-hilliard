# Bunch = file with a list of tests
# Problem = the current test

live     = .bunches/.installed
bunch   ?= $(shell test -s $(live) && cat $(live) || echo default)
problem ?= $(shell cat .bunches/$(bunch) | tail -1)
fzf     ?= sources/bin/fzf-0.16.3-linux_386

###################
#  Install bunch  #
###################
bunch :
	find .bunches/* -printf "%f\n" 2>/dev/null | $(fzf) --print-query | tail -1 > $(live);

#######################################################
#  Install and uninstall a test to the current bunch  #
#######################################################
install :
	@find inputs -type d -printf '%P\n' | \
		while read l; do test -n "$$(find inputs/$$l/* -type d)" || echo $$l; done | \
		$(fzf) -m --bind=ctrl-t:toggle >> .bunches/$(bunch) || echo "No change";

uninstall :
	cat .bunches/$(bunch) | $(fzf) -m --bind=ctrl-t:toggle | while read p; do sed -i "\#$${p}#d" .bunches/$(bunch); done;

# Select in bunch
select :
	@p=$$(cat .bunches/$(bunch) | $(fzf)); \
	  test -n "$${p}" && sed -i "\#$${p}#d" .bunches/$(bunch) && \
	  echo $${p} >> .bunches/$(bunch) || echo "No change";

#################################
#  Set up environment for test  #
#################################
link :
	mkdir -p $(addprefix tests/$(problem)/, output pictures logs);
	cp -alft tests/$(problem) sources/* $$(realpath inputs/$(problem)/*);

unlink :
	rm -rf tests/$(problem)

#####################
#  For convenience  #
#####################
fetch :
	mkdir -p reports
	mv tests/$(problem)/report* reports

################################
#  Act on all installed tests  #
################################

# Execute command for all problems in individual directories
all :
	for p in $$(cat .bunches/$(bunch)); do $(command); done

# Execute target for all problems in top directory
all-% :
	for p in $$(cat .bunches/$(bunch)); do make $* problem=$${p}; done

clean-all :
	rm -rf tests

#################################
#  Acts on last installed test  #
#################################
.DEFAULT :
	$(MAKE) -C tests/$(problem) $@
