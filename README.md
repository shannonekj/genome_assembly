# genome_assembly
Pipeline for genome assembly of eukaryotic organisms...hopefully. 

Built with: _Hypomesus transpacificus_
Test case: _Spirinchus thaleichthys_

Data types:
* longreads (PacBio)
* pseudo-longreads (10X)
* hi-c (Phase & Arima)

dag.pdf built from `snakemake --forceall --dag | dot -Tpdf > dag.pdf`
rulecall.pdf built from `snakemake --forceall --rulegraph | dot -Tpdf > rulegraph.pdf`
