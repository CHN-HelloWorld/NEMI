// Shader: NEMI Skeleton Remapper
// Origin: WWMI-Package (https://github.com/SpectrumQT/WWMI-Package, GPLv3)
// Adaptation: Aether @ NEMI Project
// Comment: Remaps VG ids in merged skeleton buffer copy according to "forward" VG map (Mapped -> OG).
//   ForwardMap: i.e. {0:0, 1:2} map transforms [VG0_DATA, VG1_DATA, VG2_DATA] to [VG0_DATA, VG2_DATA]

Buffer<uint>    ForwardMap      : register(t37);
Buffer<float4>  MergedSkeleton  : register(t38);

RWBuffer<float4> RemappedSkeleton : register(u5);
// RWBuffer<float4> DebugRW        : register(u7);

Texture1D<float4> IniParams : register(t120);

#define VertexGroupCount IniParams[1].w
#define RemapId          IniParams[2].x


#ifdef COMPUTE_SHADER

[numthreads(64,1,1)]
void main(uint3 ThreadId : SV_DispatchThreadID)
{
    int vg_id = ThreadId.x;

    if (vg_id >= VertexGroupCount) {
        return;
    }

    int vg_offset      = vg_id * 3;
    int map_offset     = RemapId * 512;
    int remapped_vg_id = ForwardMap[map_offset+vg_id] * 3;

    RemappedSkeleton[vg_offset]   = MergedSkeleton[remapped_vg_id];
    RemappedSkeleton[vg_offset+1] = MergedSkeleton[remapped_vg_id+1];
    RemappedSkeleton[vg_offset+2] = MergedSkeleton[remapped_vg_id+2];
}

#endif
