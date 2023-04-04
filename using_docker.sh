#docker_name=u_18_cpp_7_5_py_3_6_cuda_11_1_cudnn_8_0_cv_4_7_torch_1_10_tv_0_11_tb_2_5
#docker_name=u_20_cpp_9_4_py_3_9_cuda_11_3_cudnn_8_2_cv_4_7_torch_2_0_tv_0_15
#docker_name=u_xx
#docker_name=u_20_cpp_9_4_py_3_9_cuda_11_3_cudnn_8_2_cv_4_7_torch_1_12_tv_0_13
docker_name=u_18_cpp_7_5_py_3_7_cuda_11_3_cudnn_8_2_torch_1_10_tv_0_11_tb_2_11
#docker_name_full=${docker_name}:v0
docker_name_full=detectron2:v0
dir_cur=/workspace/${PWD##*/}
dir_data=/mnt/d/data
#: << 'END'
#################################################################################################
#   docker build
cd docker_file/; docker build --force-rm --shm-size=64g --build-arg USER_ID=$UID -t ${docker_name_full} -f Dockerfile_${docker_name} .; cd -
#END
#cd docker/; docker build --build-arg USER_ID=$UID -t ${docker_name_full} .; cd -

#: << 'END'
#################################################################################################
#   docker info.
docker run --rm -it -w $PWD -v $PWD:$PWD ${docker_name_full} sh -c ". ~/.bashrc && . docker_file/extract_docker_info.sh"
#END

#: << 'END'
#################################################################################################
#   docker run
#docker run --rm -it --shm-size=64g --gpus '"device=0"' --user appuser -e DISPLAY=$DISPLAY -w ${dir_cur} -v ${dir_data}:/data -v $PWD:${dir_cur} -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro -v /etc/shadow:/etc/shadow:ro -v /etc/sudoers.d:/etc/sudoers.d:ro -v /tmp/.X11-unix:/tmp/.X11-unix:rw ${docker_name_full} bash
#END
#docker run --gpus all -it --shm-size=8gb --env="DISPLAY" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" -w ${dir_cur} -v ${dir_data}:/data -v $PWD:${dir_cur} --name=${docker_name} ${docker_name_full}
docker run --gpus all -it --shm-size=8gb --env="DISPLAY" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" -w ${dir_cur} -v ${dir_data}:/data -v $PWD:${dir_cur} ${docker_name_full} fish

