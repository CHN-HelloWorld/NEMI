// Shader: NEMI Blend Remapper
// Origin: WWMI-Package (https://github.com/SpectrumQT/WWMI-Package, GPLv3)
// Adaptation: Aether @ NEMI Project
//
// Comment: Remaps VG ids in Blend.buf copy according to "reverse" VG map (OG -> Mapped)
//   Input t34 : ReverseMap - 16-bit VG id lookup table, size = max_remaps * 512
//   Input t35 : FullRangeVGBuffer - full-range 16-bit VG ids per vertex
//   Output u4 : RemappedBlendBuffer - 8-bit ids result (as stored in original Blend.buf)

Buffer<uint>  ReverseMap         : register(t34);
Buffer<uint>  FullRangeVGBuffer  : register(t35);

RWBuffer<uint> RemappedBlendBuffer : register(u4);
// RWBuffer<float4> DebugRW       : register(u7);

Texture1D<float4> IniParams : register(t120);

#define VertexCount          IniParams[0].y
#define RemapId              IniParams[2].x
#define WeightsPerVertexCount (IniParams[2].y > 0 ? IniParams[2].y : 4)


#ifdef COMPUTE_SHADER

[numthreads(64,1,1)]
void main(uint3 ThreadId : SV_DispatchThreadID)
{
    int vertex_id = ThreadId.x;

    if (vertex_id >= VertexCount) {
        return;
    }

    // Remap matrices are stored as concatenated array where each map is 512 values long
    // So the whole magic has to be done via direct index-based addressing:
    int map_offset = RemapId * 512;

    // * RemappedBlendBuffer stores data as flat array of [VG0_ID, VG1_ID, VG2_ID, VG3_ID, VG0_WEIGHT, ...]
    //   - Note: Stored VG ids are 8-bit and cannot be used for remapping, so we use FullRangeVGBuffer instead
    int remapped_data_offset = vertex_id * WeightsPerVertexCount * 2;

    // * FullRangeVGBuffer stores data as flat array of [VG0_ID, VG1_ID, VG2_ID, VG3_ID]
    //   - Note: Stored VG ids are 16-bit
    int vg_data_offset = vertex_id * WeightsPerVertexCount;

    // Loop through all VGs of current vertex and remap each one
    for (int i = 0; i < WeightsPerVertexCount; i++)
    {
        RemappedBlendBuffer[remapped_data_offset+i] = ReverseMap[map_offset+FullRangeVGBuffer[vg_data_offset+i]];
    }
}

#endif
