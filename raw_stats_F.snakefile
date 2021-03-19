configfile: 'docs/conf_data_F.yml'

## load in configuration things
### general info
sex = config['sex']
species_id = config['speciesID']
genome_size = config['genomesize']

### raw data
hifi_a = config['hifi_a']
hifi_b = config['hifi_b']
hifi_c = config['hifi_c']
tenx_r1 = config['tenx_r1']
tenx_r2 = config['tenx_r2']
hic_r1 = config['hic_r1']
hic_r2 = config['hic_r2']

cpu = config['cpu']

# other
prefix = species_id + '_' + sex
KMER = ["21", "31", "41"]

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
        expand("input/data/raw/{sample}.fastq", sample=LONG_SAMPLES),
#        expand("input/data/raw/{sample}.fastq.gz", sample=SHORT_SAMPLES),
        expand("output/fastqc/{sample}_fastqc.html", sample=SHORT_SAMPLES),
        expand("output/fastqc/{sample}_fastqc.zip", sample=SHORT_SAMPLES),
        expand("output/kat_raw/tnx_k{kmer}_kat_hist{suffix}", kmer=KMER, suffix=[".dist_analysis.json", ".png"]),
        expand("output/kat_raw/hic_k{kmer}_kat_hist{suffix}", kmer=KMER, suffix=[".dist_analysis.json", ".png"]),
        expand("output/kat_raw/tnx_k{kmer}_kat_gcp{suffix}", kmer=KMER, suffix=[".dist_analysis.json", ".mx", ".mx.png"]),
        expand("output/kat_raw/hic_k{kmer}_kat_gcp{suffix}", kmer=KMER, suffix=[".dist_analysis.json", ".mx", ".mx.png"]),

rule rename_files:
    input:
        hfa = hifi_a,
        hfb = hifi_b,
        hfc = hifi_c,
        tr1 = tenx_r1,
        tr2 = tenx_r2,
        hc1 = hic_r1,
        hc2 = hic_r2
    output:
        hfa = 'input/data/raw/hifi_a.fastq',
        hfb = 'input/data/raw/hifi_b.fastq',
        hfc = 'input/data/raw/hifi_c.fastq',
        tr1 = 'input/data/raw/tnx_R1.fastq.gz',
        tr2 = 'input/data/raw/tnx_R2.fastq.gz',
        hc1 = 'input/data/raw/hic_R1.fastq.gz',
        hc2 = 'input/data/raw/hic_R2.fastq.gz'
    shell:'''
        ln -s {input.hfa} {output.hfa}
        ln -s {input.hfb} {output.hfb}
        ln -s {input.hfc} {output.hfc}
        ln -s {input.tr1} {output.tr1}
        ln -s {input.tr2} {output.tr2}
        ln -s {input.hc1} {output.hc1}
        ln -s {input.hc2} {output.hc2}
        '''


# SHORT READ STATS
rule get_fastqc:
    input:
        "input/data/raw/{sample}.fastq.gz"
    output:
        "output/fastqc/{sample}_fastqc.html",
        "output/fastqc/{sample}_fastqc.zip"
    params:
        outdir = directory("output/fastqc")
    conda: 'envs/short_qc.yml'
    shell:'''
        fastqc -o {params.outdir} {input}
        '''

rule kat_hist_tnx:
    input:
        expand("input/data/raw/tnx_R{r}.fastq.gz", r=[1, 2])
    output:
        "output/kat_raw/tnx_k{kmer}_kat_hist.dist_analysis.json",
        "output/kat_raw/tnx_k{kmer}_kat_hist.png"
    conda: 'envs/kat.yml'
    threads: workflow.cores * 0.3
    shell:'''
        kat hist -o tnx_k{wildcards.kmer}_kat_hist -m {wildcards.kmer} -t {threads} {input}
        '''

rule kat_hist_hic:
    input:
        expand("input/data/raw/hic_R{r}.fastq.gz", r=[1, 2])
    output:
        "output/kat_raw/hic_k{kmer}_kat_hist.dist_analysis.json",
        "output/kat_raw/hic_k{kmer}_kat_hist.png"
    conda: 'envs/kat.yml'
    threads: workflow.cores * 0.3
    shell:'''
        kat hist -o hic_k{wildcards.kmer}_kat_hist -m {wildcards.kmer} -t {threads} {input}
        '''

rule kat_gcp_tnx:
    input:
        expand("input/data/raw/tnx_R{r}.fastq.gz", r=[1, 2])
    output:
        "output/kat_raw/tnx_k{kmer}_kat_gcp.dist_analysis.json",
        "output/kat_raw/tnx_k{kmer}_kat_gcp.mx",
        "output/kat_raw/tnx_k{kmer}_kat_gcp.mx.png",
    params:
        tech = 'tnx'
    conda: 'envs/kat.yml'
    threads: workflow.cores * 0.3
    shell:'''
        kat gcp -o {params.tech}_k{wildcards.kmer}_kat_gcp -m {wildcards.kmer} -t {threads} {input}
        '''

rule kat_gcp_hic:
    input:
        expand("input/data/raw/hic_R{r}.fastq.gz", r=[1, 2])
    output:
        "output/kat_raw/hic_k{kmer}_kat_gcp.dist_analysis.json",
        "output/kat_raw/hic_k{kmer}_kat_gcp.mx",
        "output/kat_raw/hic_k{kmer}_kat_gcp.mx.png",
    params:
        tech = 'hic'
    conda: 'envs/kat.yml'
    threads: workflow.cores * 0.3
    shell:'''
        kat gcp -o {params.tech}_k{wildcards.kmer}_kat_gcp -m {wildcards.kmer} -t {threads} {input}
        '''




