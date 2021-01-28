# Arima Mapping Pipeline
Scripts taken from https://github.com/shannonekj/mapping_pipeline and modified in the following ways:
1. `01_mapping_arima.sh`
    * `head -16 01_mapping_arima.sh > run_arima_mapping.sh`
    * change output paths (lines 17-37)
    * `tail -68 01_mapping_arima.sh >> run_arima_mapping.sh`
    * `sed -i 's/java -Xmx4G -Djava.io.tmpdir=temp\/ -jar //'` run_arima_mapping.sh 
    * `sed -i 's/java -Xmx30G -XX:-UseGCOverheadLimit -Djava.io.tmpdir=temp\/ -jar //'` run_arima_mapping.sh
    * `chmod a+x run_arima_mapping.sh`
    * `chmod a+x \*.pl`
2. `filter_five_end.pl`
3. `get_stats.pl`
4. `two_read_bam_combiner.pl`
