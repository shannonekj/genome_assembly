# genome_assembly
Pipeline for genome assembly of eukaryotic organisms. 

The first test cases are with smelts:
* Built with: _Hypomesus transpacificus_ (delta smelt)
* Test case: _Spirinchus thaleichthys_ (longfin smelt)

Data types:
* longreads (PacBio)
* pseudo-longreads (10X)
* hi-c (Phase & Arima)

dag.pdf built from `snakemake --forceall --dag | dot -Tpdf > dag.pdf`
rulecall.pdf built from `snakemake --forceall --rulegraph | dot -Tpdf > rulegraph.pdf`
