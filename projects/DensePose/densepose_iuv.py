import numpy as np
import torch
from PIL import Image
import pickle
from os.path import join
import os
from tqdm import tqdm
import argparse

"""
Process densepose extracted data of IUV maps (in .pkl files) into IUV images in the ZJUMoCap folder structure.
 - DensePose: https://github.com/facebookresearch/detectron2/blob/main/projects/DensePose/README.md
 - ZJUMoCap structure: https://github.com/fanegg/UV-Volumes/blob/main/INSTALL.md#get-the-pre-defined-uv-unwrap-in-densepose
"""

parser = argparse.ArgumentParser(description = 'apply denspose for preparing uv-volumes')
parser.add_argument('--seq_name', type = str, required = True)
parser.add_argument('--dir_out', type = str, required = True)
parser.add_argument('--dir_in', type = str, required = True)
parser.add_argument('--cam_ids', type = str, required = True)
args = parser.parse_args()

#seq_name = "CoreView_313"
seq_name = args.seq_name
#path_to_seq = f"/home/sergio/data/human/zjumocap/{seq_name}/densepose" # 
path_to_seq = args.dir_out
#path_to_densepose_data = "/home/sergio/data/densepose_raw/" # Path to pkl files
path_to_densepose_data = args.dir_in
#cam_idxs = list(np.arange(1,20)) + [22, 23]
cam_idxs = args.cam_ids.split('_')
#print(f'cam_idxs : {cam_idxs}');    exit() ['1', '2', '3', '4', .... ]
for idx in cam_idxs:
    #seq_cam_name = "Camera (" + str(idx) + ")" # Structure from sequences 313, 315, ... (There are others with different ones)
    #print(f'seq_name : {seq_name}');    exit() #   CoreView_313
    if seq_name in ['CoreView_313', 'CoreView_315']:
        seq_cam_name = "Camera (" + idx + ")" # Structure from sequences 313, 315, ... (There are others with different ones)
    else:
        seq_cam_name = "Camera_B" + idx # Structure from sequences 313, 315, ... (There are others with different ones)
    cam_densepose_path = join(path_to_seq, seq_cam_name)
    #print(f'cam_densepose_path : {cam_densepose_path}');    exit()
    os.makedirs(cam_densepose_path, exist_ok=True)
    #t1 = join(path_to_densepose_data, f'cam_{idx}.pkl');    print(f't1 : {t1}');    exit()
    densepose_data = torch.load(join(path_to_densepose_data, f'cam_{idx}.pkl'), map_location="cpu")

    for img_idx in tqdm(range(len(densepose_data)), desc=f"{seq_name}: Extracting cam. {idx}"):
        # Extract IUV map from pkl
        dp_item = densepose_data[img_idx]
        i = dp_item['pred_densepose'][0].labels.cpu().numpy()
        uv = dp_item['pred_densepose'][0].uv.cpu().numpy()
        iuv = np.stack((uv[1,:,:], uv[0,:,:], i))
        iuv = np.transpose(iuv, (1,2,0))
        iuv_img = Image.fromarray(np.uint8(iuv*255), "RGB")
        
        # iuv_img.show()

        # Show person IUV with original image size, at its corresponding position and save to 
        # corresponding file in the folder structure
        box = dp_item["pred_boxes_XYXY"][0]
        box[2] = box[2] - box[0]
        box[3] = box[3] - box[1]
        x, y, w, h = [int(v) for v in box]

        img_filename = dp_item["file_name"]
        #print(f'img_filename : {img_filename}');    exit(0)
        img = Image.open(img_filename)
        img_w, img_h = img.size
        
        bg=np.zeros((img_h, img_w, 3))
        bg[y:y+h, x:x+w, :]=iuv
        bg_img = Image.fromarray(np.uint8(bg*255), "RGB")
        name_iuv_file = img_filename.split("/")[-1]
        name_iuv_file = name_iuv_file[:-4]+"_IUV.jpg"
        path_to_save_IUV = join(cam_densepose_path, name_iuv_file)
        #print(f'path_to_save_IUV : {path_to_save_IUV}');    exit()
        bg_img.save(path_to_save_IUV)

