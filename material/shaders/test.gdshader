shader_type spatial;
render_mode specular_toon;

// ########## SETUP ########### 
// Keep only the first noise map from the previous shader.
// Remove all other properties and clear the vertex() and fragment() shaders.

// Noise Map = NoiseTexture2d
// Noise Type = Simplex Smooth
// Seamless = true
// As Normal Map = false

// Primitive = Plane
// Size = (10m x 10m)
// Subdivisions = (640 x 640)
	
// Lighting = OmniLight3D
// Range = 25.0
// Energy = 2.0
// Transform = (0, 3, -5) // Adjust height for some quick variations.
// Disable preview sunlight.

// Base wave settings
uniform sampler2D noise;
uniform float waveHeight = 1.0; // Zero makes a flat plane.
uniform float displacementScale = 0.75; // Only affects vertex displacement.
uniform float normalMapIntensity = 1.0; // As a contrast to the vertex displacement. Should be 1.0
uniform float waveTile = 0.5;
uniform float waveSpeed = 0.5;

// Toggle waves
uniform bool waveA = true;
uniform bool waveB = true;
uniform bool waveC = true;
uniform bool waveD = true;

// Stylize the waves
uniform float contrast = 1.0; // Sort of a contrast, sort of a complexity/octave.
uniform float ridgePucker = 1.0; // Demonstrates how the Pow() method behaves.

// Explore lighting layers
uniform float ambientIntensity = 1.0; // Basically the overall light as implemented. Scales fresnel, but not color.
uniform float fresnelIntensity = 0.1;
uniform float colorIntensity = 1.0;

float wave(vec2 position) {
	position += texture(noise, position / (10.0/waveTile)).x * (2.0 * contrast); // No clear reason for the (-1) offset.
	vec2 wv = 1.0 - abs(sin(position));
	return pow(1.0 - pow(wv.x * wv.y, 0.65 * ridgePucker), 4.0) * waveHeight;
}

// Add several wave patterns on top of each other to form a single offset mask.
// Toggle them using the exposed bool parameters.
float height(vec2 position, float time) {
	time = time * waveSpeed;
	float h = 0.0;
	if(waveA){ h = wave((position + time) * 0.4) * 0.3; }
	if(waveB){ h += wave((position - time) * 0.3) * 0.3; }
	if(waveC){ h += wave((position + time) * 0.5) * 0.2; }
	if(waveD){ h += wave((position - time) * 0.6) * 0.2; }
	return h;
}

void vertex() {
	vec2 pos = VERTEX.xz;
	float k = height(pos, TIME);
	VERTEX.y = k * displacementScale;
	vec3 waveNormals = normalize(vec3(k - height(pos + vec2(0.1, 0.0), TIME), 0.1, k - height(pos + vec2(0.0, 0.1), TIME)));
	// This lerps from NORMAL to waveNormals based on the intensity value.
	NORMAL = (NORMAL * (1.0 - normalMapIntensity)) + (waveNormals * normalMapIntensity);
}

void fragment() {
	// A fresnel angle is a mask describing how perpendicular a surface angle is to your viewing angle.
	// It can be used to create a rim light, as we do here, or cheap SSS effects.
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW)) * fresnelIntensity;// * ambientIntensity;
	RIM = 0.2;
	METALLIC = 0.0;
	ROUGHNESS = 0.01 * (1.0 - fresnel);
	ALBEDO = (vec3(0.01, 0.03, 0.1) * colorIntensity) + fresnel;
	AO = ambientIntensity; // Set to zero to block all ambient lighting.
}

// Parameters are set with safe defaults. Try changing a few at a time, then reset them.

// Try WaveHeight(0.2), Displacement(0.1), Contrast(5) for a windy river-like effect.
// Try Ambient(0.05), Fresnel(0.02) and lower the omni light to Y(1.75) for a night sky with just the moon's reflection.
// Try Ambient(1), Fresnel(-0.1), Color(0.2) for an oily black water (artificial).