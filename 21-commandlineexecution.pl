
#!/usr/bin/perl

#exec 'perl ~/Scripts/30-fastqrandomsample.pl -1 ~/ROBIN/XonL_GTAGAG_L007_R1_001\ \(paired\)\ trimmed\ \(paired\)_1.fastq -2 ~/ROBIN/XonL_GTAGAG_L007_R1_001\ \(paired\)\ trimmed\ \(paired\)_2.fastq -n 2000000'; 
#exec 'perl ~/Scripts/23-interleavepairedfiles.pl -1 XonL_GTAGAG_L007_R1_001\ \(paired\)\ trimmed\ \(paired\)_1.2M_2nd.fastq -2 XonL_GTAGAG_L007_R1_001\ \(paired\)\ trimmed\ \(paired\)_2.2M_2nd.fastq';
#exec 'perl 30b-fastqrandomsample.pl -1 ~/MILO/TRIMMED/MM-1_ATCACG_L008_R1_001\ trimmed.fastq  -n 2000000 -b 3'
#exec 'perl distribution1.pl'
#exec 'pbsim --data-type CLR --accuracy-mean 0.85 --length-mean 2500 --model_qc ~/software/pbsim-1.0.2/data/model_qc_clr CAENORHABDITIS_ELEGANS/Caenorhabditis_elegans.fasta'
#exec 'mv sd_00* /home/amodupe/CAENORHABDITIS_ELEGANS/PBSIM-CAE/CLRpbsimmodelmodifiedCaenorhabditis_elegans'

#5/31/2013
#exec 'pbsim --data-type CCS --accuracy-mean 0.85 --length-mean 2500 --model_qc ~/software/pbsim-1.0.2/data/model_qc_ccs ~/POPULUS_TRICHOCARPA/Populus_trichocarpa.fasta'

#6/17/2013
#exec 'perl ~/COFFEE/qualityscore.pl -1 ~/POPULUS_TRICHOCARPA/PBSIM/CLR/sd_cont.qua'

#6/26/2013
#exec 'perl ~/Scripts/20-w_osplitpairedfile.pl -a /datastore/amodupe/Populus_trichocarpa.fastq'

#6/27/2013
#exec 'perl testing.pl -a datastore/Populus_trichocarpa.fastq'

#6/28/2013
#exec 'perl testingfinal.pl -a datastore/Populus_trichocarpa.fastq'

#7/1/2013
#exec 'perl ~/Scripts/20-w_osplitpairedfile.pl -a datastore/Populus_trichocarpa-new_version.fastq'

#7/29/2013
#exec 'pbsim --data-type CLR --accuracy-mean 0.85 --length-mean 2500 --model_qc ~/software/pbsim-1.0.2/data/model_qc_clr ~/POPULUS_TRICHOCARPA/Populus_trichocarpa/sequence/Populus_trichocarpa.fasta'

#7/30/2013
#exec 'perl ~/Scripts/34-renamingtheheaders.pl -a datastore/Populus_trichocarpa-edit.fastq'

#7/31/2013
#exec 'perl ~/Scripts/23-interleavepairedfiles.pl -1 datastore/Populus_trichocarpa-new_version_1.fq -2 datastore/Populus_trichocarpa-new_version_2.fq'

#5/14/2014
exec 'perl improvementLSC.pl ARABIDOPSIS/LSC/outputs/corrected_LR.fna'
