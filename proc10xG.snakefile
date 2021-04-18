configfile: 'docs/conf_data.yml'

## load in configuration things
### general info
#sex = config['sex']
species_id = config['speciesID']
genome_size = config['genomesize']

### raw data
#### female
f_hifi_a = config['F_hifi_a']
f_hifi_b = config['F_hifi_b']
f_hifi_c = config['F_hifi_c']
f_tenx_r1 = config['F_tenx_r1']
f_tenx_r2 = config['F_tenx_r2']
f_hic_r1 = config['F_hic_r1']
f_hic_r2 = config['F_hic_r2']
#### male
m_hifi_a = config['M_hifi_a']
m_hifi_b = config['M_hifi_b']
m_tenx_r1 = config['M_tenx_r1']
m_tenx_r2 = config['M_tenx_r2']
m_hic_r1 = config['M_hic_r1']
m_hic_r2 = config['M_hic_r2']

cpu = config['cpu']

# other
#prefix = species_id + '_' + sex
KMER = ["21", "31", "41"]
SEX = ["F", "M"]

# lists
## long reads
long_samples = config['sample_long_links']
LONG_SAMPLES = long_samples.keys()
## short reads
short_samples = config['sample_short_links']
SHORT_SAMPLES = short_samples.keys()


###############
###  r00lz  ###
###############

rule all:
    input:
        expand("input/data/filtered/{sex}_tnx_filt_R{n}_001.fastq.gz", sex=SEX, n=["1", "2"])

# SHORT READ STATS
rule download_proctnxG:
    output:
        "scripts/proc10xG/process_10xReads.py",
        "scripts/proc10xG/filter_10xReads.py",
    shell:'''
        git -C scripts clone https://github.com/shannonekj/proc10xG.git
        '''

rule process_tnx:
    input:
        script = "scripts/proc10xG/process_10xReads.py",
        r1 = "input/data/raw/{sex}_tnx_R1.fastq.gz",
        r2 = "input/data/raw/{sex}_tnx_R2.fastq.gz",
    output:
        "input/data/filtered/{sex}_tnx_proc_R1_001.fastq.gz",
        "input/data/filtered/{sex}_tnx_proc_R2_001.fastq.gz",
    conda: 'envs/py2.7.14.yml'
    shell:'''
        python2 {input.script} -1 {input.r1} -2 {input.r2} -o input/data/filtered/{wildcards.sex}_tnx_proc -a
        '''

rule filter_tnx:
    input:
        script = "scripts/proc10xG/filter_10xReads.py",
        r1 = "input/data/filtered/{sex}_tnx_proc_R1_001.fastq.gz",
        r2 = "input/data/filtered/{sex}_tnx_proc_R2_001.fastq.gz",
    output:
        "input/data/filtered/{sex}_tnx_filt_R1_001.fastq.gz",
        "input/data/filtered/{sex}_tnx_filt_R2_001.fastq.gz",
    conda: 'envs/py2.7.14.yml'
    shell:'''
        python2 {input.script} -1 {input.r1} -2 {input.r2} -o input/data/filtered/{wildcards.sex}_tnx_filt
        '''


#rule kat_comp:
#    input:
#        "input/data/raw/{sex}_{shrt_tech}_R1.fastq.gz",
#        "input/data/raw/{sex}_{shrt_tech}_R2.fastq.gz",
#    output:
#        "output/kat_raw/{sex}_{shrt_tech}_k{kmer}_kat_comp-main.mx",
#        "output/kat_raw/{sex}_{shrt_tech}_k{kmer}_kat_comp-main.mx.density.png",
#        "output/kat_raw/{sex}_{shrt_tech}_k{kmer}_kat_comp.stats",
#    conda: 'envs/kat.yml'
#    threads: workflow.cores
#    shell:'''
#        kat comp -n -o output/kat_raw/{wildcards.sex}_{wildcards.shrt_tech}_k{wildcards.kmer}_kat_comp -m {wildcards.kmer} -t {threads} {input}
#        '''


