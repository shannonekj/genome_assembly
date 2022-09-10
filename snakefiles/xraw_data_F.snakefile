import pandas as pd

configfile: 'docs/conf_data_F.yml'

samples_lng = pd.read_table('input/long_reads.fofn').set_index("file", drop=False)
sample_lng_names = list(samples_lng['file'])

samples_sht = pd.read_table('input/shrt_reads.fofn').set_index("file", drop=False)
sample_sht_names = list(samples_sht['file'])



###############
###  r00lz  ###
###############

# short reads
## fastqc
rule fastqc:
    input:
        
        expand("output/fastqc/
## multiqc
## kat
### kat hist
### kat gc comp


