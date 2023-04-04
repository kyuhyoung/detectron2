#: << 'END'
fn_config=configs/densepose_rcnn_R_50_FPN_s1x.yaml
path_model=https://dl.fbaipublicfiles.com/densepose/densepose_rcnn_R_50_FPN_s1x/165712039/model_final_162be9.pkl
declare -A di_scene_id_cam_ids
di_scene_id_cam_ids[313]=1_2_3_4_5_6_7_8_9_10_11_12_13_14_15_16_17_18_19_22_23
di_scene_id_cam_ids[315]=1_2_3_4_5_6_7_8_9_10_11_12_13_14_15_16_17_18_19_22_23
di_scene_id_cam_ids[377]=1_2_3_4_5_6_7_8_9_10_11_12_13_14_15_16_17_18_19_20_21_22_23
di_scene_id_cam_ids[386]=1_2_3_4_5_6_7_8_9_10_11_12_13_14_15_16_17_18_19_20_21_22_23
di_scene_id_cam_ids[387]=1_2_3_4_5_6_7_8_9_10_11_12_13_14_15_16_17_18_19_20_21_22_23
di_scene_id_cam_ids[390]=1_2_3_4_5_6_7_8_9_10_11_12_13_14_15_16_17_18_19_20_21_22_23
di_scene_id_cam_ids[392]=1_2_3_4_5_6_7_8_9_10_11_12_13_14_15_16_17_18_19_20_21_22_23
#for scene_id in 313 315 377 386 387 390 392
for scene_id in 313
do
    scene=CoreView_${scene_id}
    cam_ids=${di_scene_id_cam_ids[${scene_id}]}
    dir_pre=/data/zju_mocap/${scene}
    dir_out_dp=${dir_pre}/densepose_raw
    #rm -rf "${dir_out_dp}";  mkdir "${dir_out_dp}" 
    mkdir "${dir_out_dp}" 
    dir_out_uv=${dir_pre}/densepose
    #dir_out_uv=./output/${scene}/densepose
    rm -rf "${dir_out_uv}";  mkdir "${dir_out_uv}" 
    for cam_id in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23
    #for cam_id in 1
    do
        if [[ ${scene_id} == "313" || ${scene_id} == "315" ]]; then
            dir_img="/data/zju_mocap/${scene}/Camera (${cam_id})"
        else
            dir_img="/data/zju_mocap/${scene}/Camera_B${cam_id}"
        fi
        if [ ! -d "${dir_img}" ]; then
            echo "Directory ${dir_img} does NOT exist. Skipping ..."
            continue
        fi     
        echo "dir_img" ${dir_img}
        fn_out=${dir_out_dp}/cam_${cam_id}.pkl
        #cd ./projects/DensePose/; python3 apply_net.py dump ${fn_config} ${path_model} "${dir_img}" --output ${fn_out} -v; cd -
    done
    cd ./projects/DensePose/; python3 densepose_iuv.py --seq_name ${scene} --dir_in ${dir_out_dp} --dir_out ${dir_out_uv} --cam_ids ${cam_ids}; cd -
done    
#END
#python3 projects/DensePose/apply_net.py dump configs/densepose_rcnn_R_50_FPN_s1x.yaml https://dl.fbaipublicfiles.com/densepose/densepose_rcnn_R_50_FPN_s1x/165712039/model_final_162be9.pkl "/data/zju_mocap/CoreView_313/Camera (1)" --output dump.pkl -v
