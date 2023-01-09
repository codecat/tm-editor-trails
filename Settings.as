[Setting hidden]
bool Setting_EnableTrails = true;

//[Setting hidden]
bool Setting_CaptureSamples = true;

[Setting hidden]
bool Setting_Loop = false;

[Setting hidden]
bool Setting_Follow = false;



[Setting category="General" name="Minimum duration" min=1.0 max=60.0 description="The minimum time in seconds for a trail's instance to be considered valid."]
double Setting_MinimumDuration = 1.0;

[Setting category="General" name="Samples per second" description="How many samples per second will be recorded for a trail. Note that if your framerate can't keep up, less samples are stored per frame." min="1" max="60"]
int Setting_SamplesPerSecond = 10;

[Setting category="General" name="Clear trails on editor play start"]
bool Setting_ClearOnStart = true;

[Setting category="General" name="Display velocity vector"]
bool Setting_DisplayVelocity = true;

[Setting category="General" name="Velocity over time" min=0.1 max=2 description="The amount of seconds to use when displaying the velocity over time."]
float Setting_VelocityOverTime = 1.0f;

[Setting category="General" name="Show debug window" description="The debug window can be useful to debug issues with the plugin."]
bool Setting_ShowDebugWindow = false;



[Setting category="Appearance" name="Trail line width" min=1 max=10]
int Setting_TrailWidth = 2;

[Setting category="Appearance" name="Velocity vector line width" min=1 max=10]
int Setting_VelocityTrailWidth = 1;

[Setting category="Appearance" name="Trail color" color]
vec4 Setting_TrailColor = vec4(1, 1, 1, 1);

[Setting category="Appearance" name="Car position color" color]
vec4 Setting_CarPositionColor = vec4(1, 0, 0, 1);

[Setting category="Appearance" name="Velocity vector color" color]
vec4 Setting_CarVelocityColor = vec4(1, 1, 0, 1);
