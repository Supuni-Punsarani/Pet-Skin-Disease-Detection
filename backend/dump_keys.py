import torch

state = torch.load('model/pawscan_swin_final.pth', map_location='cpu').get('model_state', {})
print("CHECKPOINT KEYS AND SHAPES:")
for k in sorted(state.keys()):
    if 'swin.layers' in k and ('downsample' in k or 'proj.weight' in k):
        print(k, state[k].shape)
