import timm
import traceback

print("Scanning for Swin models with embed_dim=96...")
models = timm.list_models('*swin*')
matches = []

for m in models:
    try:
        model = timm.create_model(m, pretrained=False, num_classes=0)
        
        # Swin v1 and v2 have different ways of getting patch_embed
        if hasattr(model, 'patch_embed'):
            weight = model.patch_embed.proj.weight
            if weight.shape[0] == 96:
                matches.append(m)
                print(f"MATCH: {m} (shape: {weight.shape})")
    except Exception as e:
        pass

print(f"\nFound {len(matches)} matching architectures:")
for m in matches:
    print(m)
