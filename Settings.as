[Setting]
bool Setting_EnableTrails = true;

[Setting]
bool Setting_ShowDebugWindow = true;

[Setting]
double Setting_MinimumDuration = 1.0;

[Setting]
int Setting_SamplesPerSecond = 30;

[Setting]
bool Setting_CaptureSamples = true;

[Setting]
bool Setting_ClearOnStart = true;

[Setting]
bool Setting_Loop = false;

[Setting]
bool Setting_Follow = false;

[Setting min=1 max=10]
int Setting_TrailWidth = 2;

[Setting]
bool Setting_DisplayVelocity = true;

[Setting]
int Setting_VelocityTrailWidth = 1;

[Setting min=0.1 max=1]
float Setting_VelocityOverTime = 1.0f;

[Setting color]
vec4 Setting_TrailColor = vec4(1, 1, 1, 1);

[Setting color]
vec4 Setting_CarPositionColor = vec4(1, 0, 0, 1);

[Setting color]
vec4 Setting_CarVelocityColor = vec4(1, 1, 0, 1);
