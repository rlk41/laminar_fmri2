#!/bin/bash

"""
3DTcorr1D  Sess-04-Run04 


"""


compare_metrics () {

  #set -e 

  local epi=$1
  local seed=$2
  local out_dir=$3

  local epi_base=$(basename $(basename $epi .nii.gz) .nii) 
  local seed_base=$(basename $seed)

  local out_file_corr=$out_dir/$epi_base-$seed_base-CORR.nii.gz
  local out_file_DECONV=$out_dir/$epi_base-$seed_base-DECONV.nii.gz

  # rim, parc_hcp_kenshu layers 

  echo $rim 
  echo $parc_hcp_kenshu 
  echo $layers
  echo $epi $seed 
  echo $out_file_corr
  echo $out_file_DECONV

  mkdir -p $out_dir
  cd  $out_dir

  rm $out_dir/*


  3dTcorr1D -prefix $out_file_corr -mask $rim $epi $seed -overwrite


  3dDeconvolve -input $epi -mask $rim -polort 2 \
  -num_stimts 1 -stim_file 1 $seed -stim_label 1 "seed_tc" \
  -rout -fout -tout -bucket deconv
  #-fitts full_model.fit -errts residual_error.fit \

  3dresample -orient RPI -inset deconv+orig.HEAD[0] -prefix deconv_FULLR2.nii 
  3dresample -orient RPI -inset deconv+orig.HEAD[1] -prefix deconv_Fstat.nii 
  3dresample -orient RPI -inset deconv+orig.HEAD[2] -prefix deconv_Coef.nii 

  #'Full_R^2'
  #'Full_Fstat'
  #'seed_tc#0_Coef'


  LN2_todataframe.py --input $out_file_corr  --columns  $parc_hcp_kenshu --layers  $layers 
  LN2_todataframe.py --input deconv_FULLR2.nii  --columns  $parc_hcp_kenshu --layers  $layers 
  LN2_todataframe.py --input deconv_Fstat.nii  --columns  $parc_hcp_kenshu --layers  $layers 
  LN2_todataframe.py --input deconv_Coef.nii  --columns  $parc_hcp_kenshu --layers  $layers 



  # LN2_PROFILE -input $out_file_corr \
  # -layers $roi_dir/LIPd_layers.nii \
  # -plot -output $out_dir/$epi_base-$seed_base-LIPd-corr-profile.txt

  # LN2_PROFILE -input deconv_FULLR2.nii \
  # -layers $roi_dir/LIPd_layers.nii \
  # -plot -output $out_dir/$epi_base-$seed_base-LIPd-deconv0-profile.txt
  
  # LN2_PROFILE -input deconv_Fstat.nii \
  # -layers $roi_dir/LIPd_layers.nii \
  # -plot -output $out_dir/$epi_base-$seed_base-LIPd-deconv1-profile.txt
  
  # LN2_PROFILE -input deconv_Coef.nii \
  # -layers $roi_dir/LIPd_layers.nii \
  # -plot -output $out_dir/$epi_base-$seed_base-LIPd-deconv2-profile.txt



}



export work_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons/"
#export work_dir="./"
export data_dir=$work_dir/data
export out_dir=$work_dir/out
export roi_dir=$work_dir/rois

mkdir -p $work_dir $data_dir $out_dir 

export run=$data_dir/sub-02_ses-04_task-movie_run-04_VASO.nii
export run_preproced_FSL=$data_dir/prewhitened_sub-02_ses-04_task-movie_run-04_VASO.nii.gz

export seed_file_pca000=$data_dir/1010.L_FEF.2D.pca_000.1D
export seed_file_pca000_preproced_FSL=$data_dir/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_000.1D

export seed_file_pca001=$data_dir/1010.L_FEF.2D.pca_001.1D
export seed_file_pca001_preproced_FSL=$data_dir/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_001.1D

export seed_file_mean=$data_dir/sub-02_ses-04_task-movie_run-04_VASO.nii-1010.L_FEF.2D.mean
export seed_file_mean_preproced_FSL=$data_dir/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.mean

export layers=$data_dir/sub-02_layers.nii
export rim=$data_dir/sub-02_layers_bin.nii.gz
export parc_hcp_kenshu=$data_dir/parc_hcp_kenshu_uthr.nii.gz





compare_metrics $run                  $seed_file_pca000                  $out_dir/raw_pca000_v2
compare_metrics $run_preproced_FSL    $seed_file_pca000_preproced_FSL    $out_dir/prewhitened_pca000_v2

compare_metrics $run                  $seed_file_pca001                  $out_dir/raw_pca001_v2
compare_metrics $run_preproced_FSL    $seed_file_pca001_preproced_FSL    $out_dir/prewhitened_pca001_v2

compare_metrics $run                  $seed_file_mean                    $out_dir/raw_mean_v2
compare_metrics $run_preproced_FSL    $seed_file_mean_preproced_FSL      $out_dir/prewhitened_mean_v2


source_wholebrain2.0
cd /data/NIMH_scratch/kleinrl/analyses/wb3/ALL/pca_num5_all10_nomask/fsl_feat_1010.L_FEF_pca5/DAY0/ds003216-download_derivatives_sub-02_VASO_fun2_sub-02_ses-04_task-movie_run-04_VASO.2D.pca_001/ds003216-download_derivatives_sub-02_VASO_fun2_sub-02_ses-04_task-movie_run-04_VASO-ds003216-download_derivatives_sub-02_VASO_fun2_sub-02_ses-04_task-movie_run-04_VASO.feat/


LN2_todataframe.py --input stats/zstat1.nii.gz  --columns  $parc_hcp_kenshu --layers  $layers 
LN2_todataframe.py --input stats/tstat1.nii.gz  --columns  $parc_hcp_kenshu --layers  $layers 
LN2_todataframe.py --input stats/pe1.nii.gz  --columns  $parc_hcp_kenshu --layers  $layers 
LN2_todataframe.py --input thresh_zstat1.nii.gz  --columns  $parc_hcp_kenshu --layers  $layers 









# rois=( $rois_hcp_kenshu/*.L_FEF.nii)


# run_preproced="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_working_TR5/orig/prewhitened_sub-02_ses-04_task-movie_run-04_VASO.nii.gz"
# run="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2/sub-02_ses-04_task-movie_run-04_VASO.nii"

# layers="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii"
# rim="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers_bin.nii"

# work_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons/"
# data_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons/orig"
# roi_dir=$work_dir/rois

# timeseries_maindir=$work_dir/timeseries
# mkdir -p $timeseries_maindir


# out_dir=$work_dir/out
# mkdir -p $out_dir 



# mkdir -p $work_dir $data_dir $roi_dir 

# cd $roi_dir 
# cp $layers $roi_dir 

# cp $rois_hcp_kenshu/1010.L_FEF.nii $roi_dir 
# fslmaths $layers -mas 1010.L_FEF.nii  FEF_layers.nii.gz 

# cp $rois_hcp_kenshu/1048.L_LIPv.nii $roi_dir 
# fslmaths $layers -mas $roi_dir/1048.L_LIPv.nii $roi_dir/LIPv_layers.nii.gz 

# cp $rois_hcp_kenshu/1095.L_LIPd.nii $roi_dir 
# fslmaths $layers -mas $roi_dir/1095.L_LIPd.nii $roi_dir/LIPd_layers.nii.gz 

# #cd $data_dir 
# #cp $run_preproced $run . 



# cd $timeseries_maindir
# extract_and_build_timeseries_v2.sh $timeseries_maindir $run $rois_hcp_kenshu/1010.L_FEF.nii
# extract_and_build_timeseries_v2.sh $timeseries_maindir $run_preproced $rois_hcp_kenshu/1010.L_FEF.nii







# timeseries="/data/NIMH_scratch/kleinrl/analyses/wb3/aim1_v3.0-FEF_averages/FEF_ave_pc0_rand36_6/fsl_feat_FEF.l06.nii.gz_pca0/timeseries/analyses_wb3_aim1_v3.0-FEF_averages_FEF_ave_pc0_rand36_6_fsl_feat_FEF.l06.nii.gz_pca0_rand_sample.nii.gz.1D"

# out_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_prewhitten_TR5/"

# work_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_working_TR5/"
# orig=$work_dir"/orig"

# batches=$work_dir"/batches"

# ## Generate Seeds 
# timeseries_maindir=$work_dir/timeseries
# roi_dir=$work_dir/rois
# mkdir -p $roi_dir 
# mkdir -p $timeseries_dir 


# layers="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii"
# rim="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers_bin.nii"































# mkdir -p $out_dir/raw_mean/
# cd $out_dir/raw_mean/

# # out_file_corr=$out_dir/raw/sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_000.1D-CORR.nii.gz
# # out_file_DECONV=$out_dir/raw/sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_000.1D-DECONV.nii.gz
# #seed_file="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons//timeseries/sub-02_ses-04_task-movie_run-04_VASO.nii/sub-02_ses-04_task-movie_run-04_VASO.nii-1010.L_FEF.2D.pca_000.1D"
# out_file_corr=$out_dir/raw_mean/sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.mean.1D-CORR.nii.gz
# out_file_DECONV=$out_dir/raw_mean/sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.mean.1D-DECONV.nii.gz
# seed_file="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons//timeseries/sub-02_ses-04_task-movie_run-04_VASO.nii/sub-02_ses-04_task-movie_run-04_VASO.nii-1010.L_FEF.2D.mean"
# 3dTcorr1D -prefix $out_file_corr -mask $rim $run $seed_file -overwrite


# 3dDeconvolve -input $run -mask $rim -polort 2 \
# -num_stimts 1 -stim_file 1 $seed_file -stim_label 1 "seed_tc" \
# -rout -fout -tout -bucket deconv
# #-fitts full_model.fit -errts residual_error.fit \

# 3dresample -orient RPI -inset deconv+orig.HEAD -prefix deconv.nii

# #3dREMLfit -input $epi -matim $seed_file -Rbeta $out_file_REML

# ############
# ############

# mkdir -p $out_dir/prewhitened_mean
# cd  $out_dir/prewhitened_mean
# #out_file_corr=$out_dir/prewhite/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_000.1D-CORR.nii.gz
# #out_file_DECONV=$out_dir/prewhite/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_000.1D-DECONV.nii.gz
# #seed_file="$timeseries_maindir/prewhitened_sub-02_ses-04_task-movie_run-04_VASO.nii/prewhitened_sub-02_ses-04_task-movie_run-04_VASO.nii-1010.L_FEF.2D.pca_000.1D"
# #seed_file="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons//timeseries/prewhitened_sub-02_ses-04_task-movie_run-04_VASO/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_000.1D"
# out_file_corr=$out_dir/prewhitened_mean/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.mean.1D-CORR.nii.gz
# out_file_DECONV=$out_dir/prewhitened_mean/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.mean.1D-DECONV.nii.gz
# seed_file="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons//timeseries/prewhitened_sub-02_ses-04_task-movie_run-04_VASO/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.mean"
# 3dTcorr1D -prefix $out_file_corr -mask $rim $run_preproced $seed_file -overwrite

# 3dDeconvolve -input $run_preproced -mask $rim -polort 2 \
# -num_stimts 1 -stim_file 1 $seed_file -stim_label 1 "seed_tc" \
# -rout -fout -tout -bucket deconv
# #-fitts full_model.fit -errts residual_error.fit \

# 3dresample -orient RPI -inset deconv+orig.HEAD -prefix deconv.nii


# LN2_PROFILE -input prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.mean.1D-CORR.nii.gz \
#  -layers $roi_dir/FEF_layers.nii -plot -output $work_dir/profiles/prewhitened_corr_profile.txt


# # Number of values stored at each pixel = 6
# #   -- At sub-brick #0 'Full_R^2' datum type is float:            0 to      0.277591
# #      statcode = fibt;  statpar = 0.5 88
# #   -- At sub-brick #1 'Full_Fstat' datum type is float:            0 to       67.6293
# #      statcode = fift;  statpar = 1 176
# #   -- At sub-brick #2 'seed_tc#0_Coef' datum type is float:     -182.333 to       185.162





# mkdir -p $out_dir/prewhitened_pca_000
# cd  $out_dir/prewhitened_pca_000
# out_file_corr=$out_dir/prewhitened_pca_000/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_000.1D-CORR.nii.gz
# #out_file_DECONV=$out_dir/prewhite/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_000.1D-DECONV.nii.gz
# #seed_file="$timeseries_maindir/prewhitened_sub-02_ses-04_task-movie_run-04_VASO.nii/prewhitened_sub-02_ses-04_task-movie_run-04_VASO.nii-1010.L_FEF.2D.pca_000.1D"
# seed_file="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons//timeseries/prewhitened_sub-02_ses-04_task-movie_run-04_VASO/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_000.1D"

# 3dTcorr1D -prefix $out_file_corr -mask $rim $run_preproced $seed_file -overwrite

# 3dDeconvolve -input $run_preproced -mask $rim -polort 2 \
# -num_stimts 1 -stim_file 1 $seed_file -stim_label 1 "seed_tc" \
# -rout -fout -tout -bucket deconv
# #-fitts full_model.fit -errts residual_error.fit \

# 3dresample -orient RPI -inset deconv+orig.HEAD -prefix deconv.nii

# LN2_todataframe.py --input $out_file_corr  --columns  $parc_hcp_kenshu --layers  $layers 

# run="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2/sub-02_ses-04_task-movie_run-04_VASO.nii"
# run_preproced_FSL="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_working_TR5/orig/prewhitened_sub-02_ses-04_task-movie_run-04_VASO.nii.gz"

# #seed_file="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons//timeseries/sub-02_ses-04_task-movie_run-04_VASO.nii/sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_000.1D"
# seed_file_pca000="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons//timeseries/sub-02_ses-04_task-movie_run-04_VASO.nii/1010.L_FEF.2D.pca_000.1D"
# seed_file_pca000_preproced_FSL="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons//timeseries/prewhitened_sub-02_ses-04_task-movie_run-04_VASO/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_000.1D"

# seed_file_pca001="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons//timeseries/sub-02_ses-04_task-movie_run-04_VASO.nii/1010.L_FEF.2D.pca_001.1D"
# seed_file_pca001_preproced_FSL="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons//timeseries/prewhitened_sub-02_ses-04_task-movie_run-04_VASO/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.pca_001.1D"

# seed_file_mean="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons//timeseries/sub-02_ses-04_task-movie_run-04_VASO.nii/sub-02_ses-04_task-movie_run-04_VASO.nii-1010.L_FEF.2D.mean"
# seed_file_mean_preproced_FSL="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_comparisons//timeseries/prewhitened_sub-02_ses-04_task-movie_run-04_VASO/prewhitened_sub-02_ses-04_task-movie_run-04_VASO-1010.L_FEF.2D.mean"

# export layers="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii"
# export rim="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers_bin.nii.gz"


# cp $run $run_preproced_FSL $data_dir
# cp $seed_file_pca000 $seed_file_pca000_preproced_FSL $seed_file_pca001 $seed_file_pca001_preproced_FSL $seed_file_mean $seed_file_mean_preproced_FSL $data_dir
# cp $layers $rim $data_dir














# EPIs=(/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_Preproc/*.nii)

# swarm_file="$out_dir/prewhiten.swarm"
# swarm_log="$out_dir/prewhiten.log"
# swarm_ts="$out_dir/timeseries.log"


# rm $swarm_file

# for epi in ${EPIs[@]}; do 

#     epi_base=$(basename $epi .nii )
#     feat_dir="$out_dir/$epi_base"

#     mkdir -p $feat_dir

#     echo "/home/kleinrl/projects/laminar_fmri/scripts_batch_wholebrain/fsl_feat_job_prewhitten.sh $epi $timeseries $feat_dir" >> $swarm_file
# done 

# cat $swarm_file
# cat $swarm_file | wc 

# dep_feat_prewhiten=$(swarm -f $swarm_file -g 30 -t 1 --job-name feat_prewhiten --logdir $swarm_log --time 05:00:00 )






# mkdir -p $work_dir 

# mkdir -p $batch5 
# mkdir -p $batch10 
# mkdir -p $batch15 
# mkdir -p $batch20 


#  for f in $out_dir/*.feat; do 
#  echo $(basename $f .feat); 
#  echo $f/stats*/prewhitened_data.nii.gz; 
#  cp $f/stats*/prewhitened_data.nii.gz $work_dir/orig/prewhitened_$(basename $f .feat).nii.gz; 
#  done 



# EPIs=($orig/pre*.nii.gz)
# EPIs_size=${#EPIs[@]}

# #echo ${EPI_total[@]}
# #size=${#EPI_total[@]}

# rand_nums=$(seq 0 $(($EPIs_size-1)))

# log_dir="$work_dir/logs"
# mkdir -p $log_dir

# for j in $(seq 1 1 10); do 
# for i in $(seq 5 5 20); do 

#   echo "Selecting $i  random EPIs " | tee -a $log 
#   selected_EPIs=()
#   indexes=""
#   log="$log_dir/batch${i}_iter${j}.log"
#   rm -f $log & touch $log

#   for i in $(seq 1 $i ); do 
#     index=$(($RANDOM % $EPIs_size))
#     EPI_to_add=${EPIs[$index]}
#     selected_EPIs+=($EPI_to_add)

#     echo $EPI_to_add >> $log 

#   done 

#   echo $i $j 
#   echo $indexes 

#   3dMean -prefix "$batches/batch${i}_iter${j}.nii.gz" ${selected_EPIs[@]}
#   echo "$indexes" > batch${i}_iter${j}.log 

# done 
# done 



# # cd $roi_dir 
# # cp $layers $roi_dir
# # #cp $columns $roi_dir
# # cp $parc_hcp_kenshu $roi_dir


# # 3dcalc -a $layers -expr 'equals(a,1)' -overwrite -prefix l01.nii.gz 
# # 3dcalc -a $layers -expr 'equals(a,2)' -overwrite -prefix l02.nii.gz 
# # 3dcalc -a $layers -expr 'equals(a,3)' -overwrite -prefix l03.nii.gz 
# # 3dcalc -a $layers -expr 'equals(a,4)' -overwrite -prefix l04.nii.gz 
# # 3dcalc -a $layers -expr 'equals(a,5)' -overwrite -prefix l05.nii.gz 
# # 3dcalc -a $layers -expr 'equals(a,6)' -overwrite -prefix l06.nii.gz 


# # 3dcalc -a $parc_hcp_kenshu -expr 'equals(a,1010)' -overwrite -prefix FEF.nii.gz


# # 3dcalc -a FEF.nii.gz -b $columns -expr 'equals(a,1) * b' -overwrite -prefix FEF.columns.nii.gz 

# # fslmaths $layers -mas FEF.nii.gz  FEF_layers.nii.gz 

# # 3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,1)' -overwrite -prefix FEF.l01.nii.gz 
# # 3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,2)' -overwrite -prefix FEF.l02.nii.gz 
# # 3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,3)' -overwrite -prefix FEF.l03.nii.gz 
# # 3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,4)' -overwrite -prefix FEF.l04.nii.gz 
# # 3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,5)' -overwrite -prefix FEF.l05.nii.gz 
# # 3dcalc -a FEF_layers.nii.gz  -expr 'equals(a,6)' -overwrite -prefix FEF.l06.nii.gz 


# # rois=(
# #     $roi_dir/FEF.l*.nii.gz
# #     $roi_dir/FEF.nii.gz
# # )


# #mask="$rois_hcp_kenshu/1010.L_FEF.nii"
# #mask_base=$(basename $mask .nii) 




# swarm_ts="$out_dir/extract_and_build_timeseries.swarm"

# #EPIs=($batches/*.nii.gz)
# EPIs=($orig/pre*.nii.gz)
# for roi in ${rois[@]}; do
# for epi in ${EPIs[@]}; do 

#     # timeseries_dir=$timeseries_maindir/$(basename $epi .nii.gz)
#     # timeseries_2D="$timeseries_dir/$(basename $roi .nii).2D"
#     # timeseries_2D_null=${timeseries_2D}.perm
#     # timeseries_1D_mean_null=${timeseries_2D}.mean.perm

#     # mkdir -p $timeseries_dir
#     # cd $timeseries_dir
    
#     # 3dmaskdump -noijk -mask $roi -o $timeseries_2D -overwrite $epi 

#     # 2D_rotate_timeseries.py --input $timeseries_2D 

#     # get_pcas.py --file $timeseries_2D   #--var 0.50
#     # get_pcas.py --file $timeseries_2D_null   #--var 0.50


#     echo "extract_and_build_timeseries.sh $timeseries_maindir $epi $roi" >> $swarm_ts 

# done 
# done 


# dep_swarm=$(swarm -b 50 -f $swarm_ts -g 10 --job-name extract_and_build_ts )


# swarm_ts="$out_dir/extract_and_build_timeseries.swarm"
# rm -f $swarm_ts & touch $swarm_ts 
# #EPIs=($batches/*.nii.gz)
# EPIs=($batches/*.nii.gz
#       $orig/*.nii.gz)

# for roi in ${rois[@]}; do
# for epi in ${EPIs[@]}; do 
#     echo $timeseries_maindir $epi $roi 
#     echo "extract_and_build_timeseries.sh $timeseries_maindir $epi $roi" >> $swarm_ts 

# done 
# done 


# dep_swarm=$(swarm -b 25 -f $swarm_ts -g 10 --job-name extract_and_build_ts )







# work_dir="/data/NIMH_scratch/kleinrl/ds003216-download/derivatives/sub-02/VASO_fun2_working_TR5/"
# orig=$work_dir"/orig"
# layers="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii"
# rim="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers_bin.nii"

# EPIs=($orig/pre*.nii.gz)
# swarm_dir=$work_dir/swarm
# swarm_smooth=$work_dir/swarm/smooth.swarm 
# swarm_corrs=$work_dir/swarm/corrs.swarm 
# swarm_corrs_rim=$work_dir/swarm/corrs_rim.swarm 


# mkdir -p $swarm_dir 
# rm -f $swarm_corrs & touch $swarm_corrs 
# rm -f $swarm_corrs_rim & touch $swarm_corrs_rim
# rm -f $swarm_smooth & touch $swarm_smooth 

# #seeds=(1010.L_FEF.2D.pca_000.1D 1010.L_FEF.2D.pca_001.1D 1010.L_FEF.2D.pca_002.1D 1010.L_FEF.2D.pca_003.1D 1010.L_FEF.2D.pca_004.1D)
# #seeds_null=(1010.L_FEF.2D.perm.pca_000.1D 1010.L_FEF.2D.perm.pca_001.1D 1010.L_FEF.2D.perm.pca_002.1D 1010.L_FEF.2D.perm.pca_003.1D 1010.L_FEF.2D.perm.pca_004.1D)
# #seeds=(${seeds_null[@]} ${seeds[@]})

# #1068.L_8Ad.2D.mean.perm 

# #seeds=($timeseries_maindir/batch20_*/*mean* )
# # seeds=($timeseries_maindir/batch20_*/*pca_000* )
# # seeds+=($timeseries_maindir/batch20_*/*pca_001* )
# # seeds+=($timeseries_maindir/batch20_*/*pca_002* )
# # seeds+=($timeseries_maindir/batch20_*/*pca_003* )
# # seeds+=($timeseries_maindir/batch20_*/*pca_004* )


# # seeds=($timeseries_maindir/pre*/*pca_000* )
# # seeds+=($timeseries_maindir/pre*/*pca_001* )
# # seeds+=($timeseries_maindir/pre*/*pca_002* )
# # seeds+=($timeseries_maindir/pre*/*pca_003* )
# # seeds+=($timeseries_maindir/pre*/*pca_004* )

# seeds=($timeseries_maindir/pre*/*pca_{000..004}* )



# #EPIs=($batches/batch20*)
# # EPIs=($orig/pre*ses-05*.nii.gz)
# # EPIs+=($orig/pre*ses-04*.nii.gz)

# EPIs=($orig/pre*ses-{04..06}*.nii.gz)


# for seed in ${seeds[@]}; do 
# for epi in ${EPIs[@]}; do 

# seed_base=$(basename $seed)

# out_dir=$work_dir/corrs/$seed_base

# out_file=$out_dir/$seed_base-$epi_base.nii.gz 
# out_file_REML=$out_dir/$seed_base-${epi_base}_REML.nii.gz 
# out_file_DECONVOLVE=$out_dir/$seed_base-${epi_base}_DECONVOLVE.nii.gz 
# out_file_smoothed1=$out_dir/$seed_base-$epi_base-SMOOTHED1.nii.gz 
# out_file_smoothed3=$out_dir/$seed_base-$epi_base-SMOOTHED3.nii.gz 
# out_file_smoothed5=$out_dir/$seed_base-$epi_base-SMOOTHED5.nii.gz 

# epi_base=$(basename $epi .nii.gz)
# seed_file=$timeseries_maindir/$epi_base/$seed_base 

# mkdir -p $out_dir 

# #echo $out_dir 
# #echo $out_file 
# #echo $epi
# #echo $seed_file

# #echo "3dTcorr1D -prefix $out_file $epi $seed_file" >> $swarm_corrs
# echo "3dTcorr1D -prefix $out_file -mask $rim $epi $seed_file -overwrite" >> $swarm_corrs_rim

# #echo "3dDeconvolve -input $epi -input1D $seed_file -"
# #echo "3dREMLfit -input $epi -matim $seed_file -Rbeta $out_file_REML"

# #echo "LN_LAYER_SMOOTH -layer_file $layers -input $out_file -FWHM 1 -output $out_file_smoothed1" >> $swarm_smooth
# #echo "LN_LAYER_SMOOTH -layer_file $layers -input $out_file -FWHM 3 -output $out_file_smoothed3" >> $swarm_smooth 
# #echo "LN_LAYER_SMOOTH -layer_file $layers -input $out_file -FWHM 5 -output $out_file_smoothed5" >> $swarm_smooth 
# done 
# done 


# dep_swarm=$(swarm -b 50 -f $swarm_corrs -g 10 --job-name corrs )

# dep_swarm=$(swarm -b 500 -f $swarm_corrs_rim -g 10 --job-name corrs )

# dep_swarm=$(swarm -b 50 -f $swarm_smooth -g 10 --job-name LN_SMOOTH --dependency=$dep_swarm)




# layers="/data/NIMH_scratch/kleinrl/gdown/sub-02_layers.nii"

# df_dir="$work_dir/dataframes"
# mkdir -p $df_dir 

# swarm_todataframe="$out_dir/todataframe.swarm"
# rm -f $swarm_todataframe | touch $swarm_todataframe

# #corrs=($work_dir/corrs/*mean*/*batch20*.nii.gz)
# corrs=($work_dir/corrs/*pca*/*.nii.gz)

# for corr in ${corrs[@]}; do 
# #echo "LN2_todataframe.py --input $corr --columns  $parc_hcp_kenshu --layers  $layers " | tee -a  $swarm_todataframe 
# echo "LN2_todataframe.py --input $corr --columns  $parc_hcp_kenshu --layers  $layers --output $df_dir" | tee -a  $swarm_todataframe 
# done 


# # --columns  "/data/kleinrl/Wholebrain2.0/ANAT/ANAT_working_recon-all/ANAT_mri_make_surf/LAYNII_2/columns/columns_ev_30000_borders.nii" \

# dep_swarm=$(swarm -b 100 -f $swarm_todataframe -g 10 --job-name 2df )


# # cd $roi_dir 
# # cp $layers $roi_dir
# # #cp $columns $roi_dir
# # cp $parc_hcp_kenshu $roi_dir


# # 3dcalc -a $layers -expr 'equals(a,1)' -overwrite -prefix l01.nii.gz 
# # 3dcalc -a $layers -expr 'equals(a,2)' -overwrite -prefix l02.nii.gz 
# # 3dcalc -a $layers -expr 'equals(a,3)' -overwrite -prefix l03.nii.gz 
# # 3dcalc -a $layers -expr 'equals(a,4)' -overwrite -prefix l04.nii.gz 
# # 3dcalc -a $layers -expr 'equals(a,5)' -overwrite -prefix l05.nii.gz 
# # 3dcalc -a $layers -expr 'equals(a,6)' -overwrite -prefix l06.nii.gz 


# # for roi in ${rois[@]}; do 

# # #echo "$roi" | tr "."
# # #roi_id=(echo $(basename $roi .nii) | tr "." "\n")

# # roi_id=($(echo $(basename $roi .nii) | tr "." "\n"))
# # roi_id=${roi_id[0]}
# # roi_name=${roi_id[1]}
# # roi_layers=$roi_dir/${roi_id}-${roi_name}-layers.nii.gz 


# # echo "$roi_id $roi_name $roi"

# # # roi_file=$roi_dir/$(basename $roi)
# # # 3dcalc -a $parc_hcp_kenshu -expr 'equals(a,'$roi_id')' -overwrite -prefix $roi_file
# # #3dcalc -a FEF.nii.gz -b $columns -expr 'equals(a,1) * b' -overwrite -prefix FEF.columns.nii.gz 


# # fslmaths $layers -mas $roi  $roi_layers


# # 3dcalc -a $roi_layers  -expr 'equals(a,1)' -overwrite -prefix $roi_dir/${roi_id}-${roi_name}-l01.nii.gz 
# # 3dcalc -a $roi_layers  -expr 'equals(a,2)' -overwrite -prefix $roi_dir/${roi_id}-${roi_name}-l02.nii.gz 
# # 3dcalc -a $roi_layers  -expr 'equals(a,3)' -overwrite -prefix $roi_dir/${roi_id}-${roi_name}-l03.nii.gz 
# # 3dcalc -a $roi_layers  -expr 'equals(a,4)' -overwrite -prefix $roi_dir/${roi_id}-${roi_name}-l04.nii.gz 
# # 3dcalc -a $roi_layers  -expr 'equals(a,5)' -overwrite -prefix $roi_dir/${roi_id}-${roi_name}-l05.nii.gz 
# # 3dcalc -a $roi_layers  -expr 'equals(a,6)' -overwrite -prefix $roi_dir/${roi_id}-${roi_name}-l06.nii.gz 

# # done 




# # roi_layers=($roi_dir/*-l??.nii.gz)
# # corrs=($work_dir/corrs/*mean*/*batch20*)

# # extracted_layers=$work_dir/extracted_layers
# # mkdir -p $extracted_layer_values 

# # swarm_extract_layer=$swarm_dir/extract_layers.swarm 
# # rm -f $swarm_extract_layer & touch $swarm_extract_layer

# # echo ${#roi_layers[@]} ${#corrs[@]}


# # for roi in ${roi_layers[@]}; do 
# # for corr in ${corrs[@]}; do


# # corr_base=$(basename $corr .nii.gz)
# # roi_base=$(basename $roi .nii.gz)

# # out_file=$extracted_layers/$corr_base-TARG-$roi_base.AVE_VALUE

# # #echo $corr
# # #echo $out_file 

# # echo "3dmaskave -quiet -mask $roi $corr > $out_file" >> $swarm_extract_layer

# # done 
# # done 



# python V4abstract.py 

