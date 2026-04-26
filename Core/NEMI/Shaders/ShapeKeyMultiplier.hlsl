// Shader: NEMI Shape Key Multiplier
// Origin: WWMI-Package (https://github.com/SpectrumQT/WWMI-Package, GPLv3)
// Adaptation: Aether @ NEMI Project
// Comment: Applies dynamic unique per-character shape key multiplier to xyz offsets

Texture1D<float4> IniParams : register(t120);

cbuffer cb0 : register(b0)
{
    uint4 cb0[66];
}

RWBuffer<uint> u0 : register(u0);
RWBuffer<int>  u1 : register(u1);
// RWBuffer<float4> DebugRW : register(u7);

#define cmp -


[numthreads(2,32,1)]
void main(uint3 vThreadID : SV_DispatchThreadID, uint3 vThreadIDInGroup : SV_GroupThreadID)
{
    const float4 icb[] = {
        { 1.000000, 0, 0, 0},
        { 0, 1.000000, 0, 0},
        { 0, 0, 1.000000, 0},
        { 0, 0, 0, 1.000000}
    };

    float4 r0,r1;

    r0.x = u1[vThreadID.y];

    r0.y = float(r0.x);
    r0.y = asfloat(cb0[65].x) * r0.y;

    r0.z = cmp((int)vThreadIDInGroup.x != 0);

    r0.w = cmp(1 < r0.y);
    r0.z = r0.w ? r0.z : 0;
    r0.w = 0;

    while (true) {

        r1.x = cmp((uint)r0.w >= 3);

        if (r1.x != 0) {
            break;
        }

        r1.x = mad(3, (int)vThreadIDInGroup.x, (int)r0.w);
        r1.x = mad(6, (int)vThreadID.y, (int)r1.x);

        r1.y = dot(asfloat(cb0[64].xyzw), icb[r0.w+0].xyzw);
        r1.y = vThreadIDInGroup.x ? cb0[64].w : r1.y;

        r1.z = asint(u0[r1.x]);
        r1.z = (int)r1.z;
        r1.y = r1.z * r1.y;
        r1.z = r1.y / r0.y;
        r1.y = r0.z ? r1.z : r1.y;

        u0[r1.x] = asuint(r1.y);

        r0.w = (int)r0.w + 1;
    }

    return;
}
