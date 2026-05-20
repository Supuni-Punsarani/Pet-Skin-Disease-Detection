import torch
import timm

state = torch.load('model/pawscan_swin_final.pth', map_location='cpu').get('model_state', {})
m = timm.models.swin_transformer.SwinTransformer(img_size=224, patch_size=4, in_chans=3, num_classes=0, embed_dim=48, depths=(2, 2, 6, 2), num_heads=(3, 6, 12, 24), window_size=7)

ckpt_keys = set(state.keys())
model_keys = set(m.state_dict().keys())

print(f"Num ckpt keys: {len(ckpt_keys)}")
# The ckpt keys have 'swin.' prefix, so we prefix model_keys
model_keys_with_prefix = set('swin.' + k for k in model_keys)

missing_in_model = ckpt_keys - model_keys_with_prefix
missing_in_ckpt = model_keys_with_prefix - ckpt_keys

print(f"Keys in ckpt but not in model (prefix swin.): {len([k for k in missing_in_model if 'swin.' in k])}")
print(f"Example ckpt keys not in model:")
for k in sorted([k for k in missing_in_model if 'swin.' in k])[:20]:
    print(f"  {k}: {state[k].shape}")

print(f"\nKeys in model but not in ckpt:")
for k in sorted(missing_in_ckpt)[:20]:
    print(f"  {k}")
