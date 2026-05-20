import torch
ckpt = torch.load('pawscan_swin_final.pth', map_location='cpu')
print("Keys in checkpoint:", ckpt.keys())

state = ckpt.get('model_state', ckpt)
keys = list(state.keys())
print("\nFirst 10 layers in state_dict:")
for k in keys[:10]:
    print(k, state[k].shape)

print("\nSpecific SWIN layers:")
for k in keys:
    if 'swin.layers.1.downsample' in k or 'swin.patch_embed.proj.weight' in k:
        print(k, state[k].shape)
