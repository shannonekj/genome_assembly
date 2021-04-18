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
        expand("input/data/raw/{sample}.fastq", sample=LONG_SAMPLES),
#        expand("input/data/raw/{sample}.fastq.gz", sample=SHORT_SAMPLES),
        expand("output/fastqc/{sample}_fastqc.html", sample=SHORT_SAMPLES),
        expand("output/fastqc/{sample}_fastqc.zip", sample=SHORT_SAMPLES),
        expand("output/kat_raw/{sex}_{shrt_tech}_k{kmer}_kat_hist{suffix}", sex=SEX, shrt_tech=['tnx', 'hic'], kmer=KMER, suffix=[".dist_analysis.json", ".png"]),
        expand("output/kat_raw/{sex}_{shrt_tech}_k{kmer}_kat_gcp{suffix}", sex=SEX, shrt_tech=['tnx', 'hic'], kmer=KMER, suffix=[".dist_analysis.json", ".mx", ".mx.png"]),
        expand("output/kat_raw/{sex}_{shrt_tech}_k{kmer}_kat_comp{suffix}", sex=SEX, shrt_tech=['tnx', 'hic'], kmer=KMER, suffix=["-main.mx", "-main.mx.density.png", ".stats"]),

rule rename_files:
    input:
        f_hfa = f_hifi_a,
        f_hfb = f_hifi_b,
        f_hfc = f_hifi_c,
        f_tr1 = f_tenx_r1,
        f_tr2 = f_tenx_r2,
        f_hc1 = f_hic_r1,
        f_hc2 = f_hic_r2,
        m_hfa = m_hifi_a,
        m_hfb = m_hifi_b,
        m_tr1 = m_tenx_r1,
        m_tr2 = m_tenx_r2,
        m_hc1 = m_hic_r1,
        m_hc2 = m_hic_r2,
    output:
        f_hfa = 'input/data/raw/F_hifi_a.fastq',
        f_hfb = 'input/data/raw/F_hifi_b.fastq',
        f_hfc = 'input/data/raw/F_hifi_c.fastq',
        f_tr1 = 'input/data/raw/F_tnx_R1.fastq.gz',
        f_tr2 = 'input/data/raw/F_tnx_R2.fastq.gz',
        f_hc1 = 'input/data/raw/F_hic_R1.fastq.gz',
        f_hc2 = 'input/data/raw/F_hic_R2.fastq.gz',
        m_hfa = 'input/data/raw/M_hifi_a.fastq',
        m_hfb = 'input/data/raw/M_hifi_b.fastq',
        m_tr1 = 'input/data/raw/M_tnx_R1.fastq.gz',
        m_tr2 = 'input/data/raw/M_tnx_R2.fastq.gz',
        m_hc1 = 'input/data/raw/M_hic_R1.fastq.gz',
        m_hc2 = 'input/data/raw/M_hic_R2.fastq.gz',
    shell:'''
        ln -s {input.f_hfa} {output.f_hfa}
        ln -s {input.f_hfb} {output.f_hfb}
        ln -s {input.f_hfc} {output.f_hfc}
        ln -s {input.f_tr1} {output.f_tr1}
        ln -s {input.f_tr2} {output.f_tr2}
        ln -s {input.f_hc1} {output.f_hc1}
        ln -s {input.f_hc2} {output.f_hc2}
        ln -s {input.m_hfa} {output.m_hfa}
        ln -s {input.m_hfb} {output.m_hfb}
        ln -s {input.m_tr1} {output.m_tr1}
        ln -s {input.m_tr2} {output.m_tr2}
        ln -s {input.m_hc1} {output.m_hc1}
        ln -s {input.m_hc2} {output.m_hc2}
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

rule kat_gcp:
    input:
        "input/data/raw/{sex}_{shrt_tech}_R1.fastq.gz",
        "input/data/raw/{sex}_{shrt_tech}_R2.fastq.gz",
    output:
        "output/kat_raw/{sex}_{shrt_tech}_k{kmer}_kat_gcp.dist_analysis.json",
        "output/kat_raw/{sex}_{shrt_tech}_k{kmer}_kat_gcp.mx",
        "output/kat_raw/{sex}_{shrt_tech}_k{kmer}_kat_gcp.mx.png",
    conda: 'envs/kat.yml'
    threads: workflow.cores
    shell:'''
        kat gcp -o output/kat_raw/{wildcards.sex}_{wildcards.shrt_tech}_k{wildcards.kmer}_kat_gcp -m {wildcards.kmer} -t {threads} {input}
        '''

rule kat_comp:
    input:
        "input/data/raw/{sex}_{shrt_tech}_R1.fastq.gz",
        "input/data/raw/{sex}_{shrt_tech}_R2.fastq.gz",
    output:
        "output/kat_raw/{sex}_{shrt_tech}_k{kmer}_kat_comp-main.mx",
        "output/kat_raw/{sex}_{shrt_tech}_k{kmer}_kat_comp-main.mx.density.png",
        "output/kat_raw/{sex}_{shrt_tech}_k{kmer}_kat_comp.stats",
    conda: 'envs/kat.yml'
    threads: workflow.cores
    shell:'''
        kat comp -n -o output/kat_raw/{wildcards.sex}_{wildcards.shrt_tech}_k{wildcards.kmer}_kat_comp -m {wildcards.kmer} -t {threads} {input}
        '''


