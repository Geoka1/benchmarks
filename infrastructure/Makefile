STATIC_OUTPUTS = target/lines_of_code.csv target/nodes_in_scripts.csv target/scripts_to_benchmark.csv

static: $(STATIC_OUTPUTS)

target/scripts_to_benchmark.csv: scripts_to_benchmark.py
	python3 $< | sort > $@

target/lines_of_code.csv: count_lines_of_code.py 
	python3 $< | sort > $@
	
target/nodes_in_scripts.csv: count_nodes_in_scripts.py syntax_analysis.py
	python3 $< | sort > $@

static-test: tests/test_syntax_analysis.py
	python3 -m unittest $<

clean-static: 
	rm -f $(STATIC_OUTPUTS)

dynamic:

.PHONY: static dynamic clean-static static-test
