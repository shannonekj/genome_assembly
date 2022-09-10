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
#### male
m_hifi_a = config['M_hifi_a']
m_hifi_b = config['M_hifi_b']

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
        expand("input/data/raw/{sample}.fastq", sample=LONG_SAMPLES),
#        expand("input/data/raw/{sample}.fastq.gz", sample=SHORT_SAMPLES),
        expand("output/fastqc/{sample}_fastqc.html", sample=SHORT_SAMPLES),
        expand("output/fastqc/{sample}_fastqc.zip", sample=SHORT_SAMPLES),
        expand("output/kat_raw/{sex}_{shrt_tech}_k{kmer}_kat_hist{suffix}", sex=SEX, shrt_tech=['tnx', 'hic'], kmer=KMER, suffix=[".dist_analysis.json", ".png"]),

rule rename_files:
    input:
        f_hfa = f_hifi_a,
        f_hfb = f_hifi_b,
        f_hfc = f_hifi_c,
        m_hfa = m_hifi_a,
        m_hfb = m_hifi_b,
    output:
        f_hfa = 'input/data/raw/F_hifi_a.fastq',
        f_hfb = 'input/data/raw/F_hifi_b.fastq',
        f_hfc = 'input/data/raw/F_hifi_c.fastq',
        m_hfa = 'input/data/raw/M_hifi_a.fastq',
        m_hfb = 'input/data/raw/M_hifi_b.fastq',
    shell:'''
        ln -s {input.f_hfa} {output.f_hfa}
        ln -s {input.f_hfb} {output.f_hfb}
        ln -s {input.f_hfc} {output.f_hfc}
        ln -s {input.m_hfa} {output.m_hfa}
        ln -s {input.m_hfb} {output.m_hfb}
        '''


# SHORT READ STATS
rule get_longqc:
    input:
        "input/data/raw/{sample}.fastq"
    output:
        "{sample}_average_qv.png",
        "{sample}_coverage.png",
        "{sample}_gcfrac.png",
        "{sample}_length.png",
        "{sample}_masked_region.png",
    conda: "envs/lqc.yml"
    shell:'''
        python {params.script_dir}/longQC.py sampleqc -x pb-hifi 
        '''

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

rule kat_hist:
    input:
        "input/data/raw/{sex}_{shrt_tech}_R1.fastq.gz",
        "input/data/raw/{sex}_{shrt_tech}_R2.fastq.gz",
    output:
        "output/kat_raw/{sex}_{shrt_tech}_k{kmer}_kat_hist.dist_analysis.json",
        "output/kat_raw/{sex}_{shrt_tech}_k{kmer}_kat_hist.png",
    conda: 'envs/kat.yml'
    threads: workflow.cores
    shell:'''
        kat hist -o output/kat_raw/{wildcards.sex}_{wildcards.shrt_tech}_k{wildcards.kmer}_kat_hist -m {wildcards.kmer} -t {threads} {input}
        '''


