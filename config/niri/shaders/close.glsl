// SUGGESTED TIMING: EaseOutCubic
// SUGGESTED DURATION: 400ms
// EFFECT: Slide slices horizontally, alternating directions
vec4 sliced_slide(vec3 coords_geo, vec3 size_geo) {
    const int num_slices = 20;
    float slice_height = 1.0 / float(num_slices);
    int slice = int(coords_geo.y / slice_height);
    float direction = mod(float(slice), 2.0) * 2.0 - 1.0; // -1.0 or 1.0
    float offset = direction * niri_clamped_progress * 0.3;
    vec3 displaced_coords = coords_geo;
    displaced_coords.x += offset;
    vec3 coords_tex = niri_geo_to_tex * displaced_coords;
    vec4 color = texture2D(niri_tex, coords_tex.st);
    color *= (1.0 - niri_clamped_progress);
    return color;
}

// SUGGESTED TIMING: EaseOutQuad
// SUGGESTED DURATION: 300ms
// EFFECT: Window shatters vertically in chunks
vec4 shattered_vert(vec3 coords_geo, vec3 size_geo) {
    const int num_slices = 25;
    float slice_width = 1.0 / float(num_slices);
    int slice = int(coords_geo.x / slice_width);
    float offset = (fract(float(slice) * 13.37 + niri_random_seed) - 0.5) * niri_clamped_progress * 1.0;
    vec3 displaced_coords = coords_geo;
    displaced_coords.y += offset;
    vec3 coords_tex = niri_geo_to_tex * displaced_coords;
    vec4 color = texture2D(niri_tex, coords_tex.st);
    color *= (1.0 - niri_clamped_progress);
    return color;
}

// SUGGESTED TIMING: EaseOutExpo
// SUGGESTED DURATION: 600ms
// EFFECT: Whirlpool swirl and fade
vec4 whirlpool(vec3 coords_geo, vec3 size_geo) {
    vec2 center = vec2(0.5);
    vec2 delta = coords_geo.xy - center;
    float angle = length(delta) * 8.0 * niri_clamped_progress;
    float s = sin(angle);
    float c = cos(angle);
    delta = mat2(c, -s, s, c) * delta;
    vec3 rotated_coords = vec3(center + delta, 1.0);
    vec3 coords_tex = niri_geo_to_tex * rotated_coords;
    vec4 color = texture2D(niri_tex, coords_tex.st);
    color *= (1.0 - niri_clamped_progress);
    return color;
}

// SUGGESTED TIMING: Linear
// SUGGESTED DURATION: 500ms
// EFFECT: Dissolve into noise
vec4 dissolve_noise(vec3 coords_geo, vec3 size_geo) {
    vec3 coords_tex = niri_geo_to_tex * coords_geo;
    vec4 color = texture2D(niri_tex, coords_tex.st);
    float noise = fract(sin(dot(coords_geo.xy + niri_random_seed, vec2(12.9898, 78.233))) * 43758.5453);
    float threshold = niri_clamped_progress;
    if (noise < threshold) {
        color.a = 0.0;
    }
    return color;
}

// SUGGESTED TIMING: EaseOutQuad
// SUGGESTED DURATION: 400ms
// EFFECT: Zigzag split and fade
vec4 zigzag_split(vec3 coords_geo, vec3 size_geo) {
    const int zigs = 10;
    float offset = sin(coords_geo.y * float(zigs) * 3.1415) * 0.1 * niri_clamped_progress;
    vec3 displaced_coords = coords_geo;
    displaced_coords.x += offset;
    vec3 coords_tex = niri_geo_to_tex * displaced_coords;
    vec4 color = texture2D(niri_tex, coords_tex.st);
    color *= (1.0 - niri_clamped_progress);
    return color;
}

// linear
vec4 fall_and_rotate(vec3 coords_geo, vec3 size_geo) {
    float progress = niri_clamped_progress * niri_clamped_progress;

    vec2 coords = (coords_geo.xy - vec2(0.5, 1.0)) * size_geo.xy;

    coords.y -= progress * 200.0;

    float random = (niri_random_seed - 0.5) / 2.0;
    random = sign(random) - random;
    float max_angle = 0.05 * random;

    float angle = progress * max_angle;
    mat2 rotate = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    coords = rotate * coords;

    coords_geo = vec3(coords / size_geo.xy + vec2(0.5, 1.0), 1.0);
    vec3 coords_tex = niri_geo_to_tex * coords_geo;
    vec4 color = texture2D(niri_tex, coords_tex.st);
    return color * (1.0 - niri_clamped_progress);
}

// SUGGESTED TIMING: EaseOutExpo
// DURATION: 800ms
// EFFECT: "One-Punch Exit" – CRUSH the window into a singularity
vec4 one_punch_exit(vec3 coords_geo, vec3 size_geo) {
    float shrink = pow(1.0 - niri_clamped_progress, 4.0);
    coords_geo.xy = (coords_geo.xy - vec2(0.5)) * shrink + vec2(0.5);
    vec3 coords_tex = niri_geo_to_tex * coords_geo;
    vec4 color = texture2D(niri_tex, coords_tex.st);
    color *= (1.0 - niri_clamped_progress);
    return color;
}

// SUGGESTED TIMING: EaseOutQuad
// DURATION: 600ms
// EFFECT: "Naruto Clone Poof" – burst of noise like smoke
vec4 naruto_poof(vec3 coords_geo, vec3 size_geo) {
    float noise = fract(sin(dot(coords_geo.xy + niri_random_seed, vec2(12.9898, 78.233))) * 43758.5453);
    float fade = smoothstep(0.0, 1.0, niri_clamped_progress);
    float cloud = exp(-20.0 * length(coords_geo.xy - vec2(0.5)));
    float mask = step(noise, 1.0 - fade + cloud * 0.5);
    vec3 coords_tex = niri_geo_to_tex * coords_geo;
    vec4 color = texture2D(niri_tex, coords_tex.st);
    return color * mask * (1.0 - niri_clamped_progress);
}

// SUGGESTED TIMING: Linear
// DURATION: 1000ms
// EFFECT: "Matrix Glitch" – green data falloff with glitches
vec4 matrix_exit(vec3 coords_geo, vec3 size_geo) {
    vec2 uv = coords_geo.xy;
    float col = fract(sin(dot(uv * size_geo.xy, vec2(91.345, 42.131))) * 12345.6789);
    vec2 glitch = vec2(0.0);
    if (mod(gl_FragCoord.y, 8.0) < 1.0) glitch.x = 0.02 * sin(niri_progress * 100.0);
    uv += glitch;

    vec3 coords_tex = niri_geo_to_tex * vec3(uv, 1.0);
    vec4 color = texture2D(niri_tex, coords_tex.st);
    color.rgb = vec3(0.0, col * 1.0, 0.0); // matrix green
    color *= (1.0 - niri_clamped_progress);
    return color;
}

// SUGGESTED TIMING: EaseOutCubic
// DURATION: 500ms
// EFFECT: "Itachi Crow Dissolve" – pixel scatter like flying crows
vec4 crow_dissolve(vec3 coords_geo, vec3 size_geo) {
    float angle = niri_progress * 20.0;
    float scatter = smoothstep(0.0, 1.0, niri_clamped_progress);
    vec2 dir = vec2(cos(angle), sin(angle)) * scatter * 0.3;
    coords_geo.xy += dir * fract(sin(dot(coords_geo.xy, vec2(45.12, 87.23))) * 4567.123);
    vec3 coords_tex = niri_geo_to_tex * coords_geo;
    vec4 color = texture2D(niri_tex, coords_tex.st);
    color *= (1.0 - niri_clamped_progress);
    return color;
}

// SUGGESTED TIMING: EaseOutExpo
// DURATION: 700ms
// EFFECT: "Zoro Lost Split" – multi-directional confusing slices
vec4 zoro_lost(vec3 coords_geo, vec3 size_geo) {
    float slice = floor(coords_geo.y * 20.0);
    float offset = sin(slice + niri_progress * 10.0) * 0.1 * (1.0 - niri_clamped_progress);
    coords_geo.x += offset;
    vec3 coords_tex = niri_geo_to_tex * coords_geo;
    vec4 color = texture2D(niri_tex, coords_tex.st);
    return color * (1.0 - niri_clamped_progress);
}


// SUGGESTED TIMING: EaseOutExpo
// DURATION: 700ms
// EFFECT: "Vergil SLASH" – a fast diagonal bisect with fading
vec4 vergil_slash(vec3 coords_geo, vec3 size_geo) {
    float cut_angle = 1.5; // Steeper than 45 degrees
    float slash_offset = coords_geo.x + coords_geo.y * cut_angle;
    float offset = smoothstep(0.0, 1.0, niri_clamped_progress) * 1.5;
    if (slash_offset < offset) {
        coords_geo.x += niri_clamped_progress * 0.3;
        coords_geo.y -= niri_clamped_progress * 0.3;
    }
    vec3 coords_tex = niri_geo_to_tex * coords_geo;
    vec4 color = texture2D(niri_tex, coords_tex.st);
    color *= 1.0 - niri_clamped_progress;
    return color;
}

// SUGGESTED TIMING: EaseOutCubic
// DURATION: 500ms
// EFFECT: Yasuo wind slice – horizontal distortion ripples
vec4 yasuo_wind(vec3 coords_geo, vec3 size_geo) {
    float ripple = sin(coords_geo.y * 60.0 + niri_progress * 50.0) * 0.01;
    coords_geo.x += ripple * (1.0 - niri_clamped_progress);
    vec3 coords_tex = niri_geo_to_tex * coords_geo;
    vec4 color = texture2D(niri_tex, coords_tex.st);
    color *= 1.0 - niri_clamped_progress;
    return color;
}

// SUGGESTED TIMING: EaseOutQuad
// DURATION: 500ms
// EFFECT: "Teleport Fade" – pixelates and disappears like an anime exit
vec4 anime_teleport(vec3 coords_geo, vec3 size_geo) {
    float granularity = 40.0;
    vec2 grid = floor(coords_geo.xy * granularity) / granularity;
    float flicker = fract(sin(dot(grid + niri_random_seed, vec2(12.9898, 78.233))) * 43758.5453);
    if (flicker < niri_clamped_progress) return vec4(0.0);
    vec3 coords_tex = niri_geo_to_tex * grid.xyxyx;
    vec4 color = texture2D(niri_tex, coords_tex.st);
    return color * (1.0 - niri_clamped_progress);
}

// SUGGESTED TIMING: Linear
// DURATION: 500ms
// EFFECT: Combine Whirlpool + Dissolve
vec4 swirl_dissolve(vec3 coords_geo, vec3 size_geo) {
    // Whirlpool
    vec2 center = vec2(0.5);
    vec2 delta = coords_geo.xy - center;
    float angle = length(delta) * 8.0 * niri_clamped_progress;
    float s = sin(angle), c = cos(angle);
    delta = mat2(c, -s, s, c) * delta;
    vec3 rotated_coords = vec3(center + delta, 1.0);

    // Dissolve
    float noise = fract(sin(dot(coords_geo.xy + niri_random_seed, vec2(12.9898, 78.233))) * 43758.5453);
    vec3 coords_tex = niri_geo_to_tex * rotated_coords;
    vec4 color = texture2D(niri_tex, coords_tex.st);
    if (noise < niri_clamped_progress) color.a = 0.0;
    return color * (1.0 - niri_clamped_progress);
}

// SUGGESTED TIMING: EaseOutCubic
// DURATION: 450ms
// EFFECT: Jojo menacing blur
vec4 jojo_menacing(vec3 coords_geo, vec3 size_geo) {
    float offset = sin(niri_progress * 10.0 + coords_geo.y * 40.0) * 0.01;
    coords_geo.x += offset;
    coords_geo.y += offset * 0.5;
    vec3 coords_tex = niri_geo_to_tex * coords_geo;
    vec4 color = texture2D(niri_tex, coords_tex.st);
    color.rgb *= vec3(0.6, 0.3, 0.7); // purple tint
    return color * (1.0 - niri_clamped_progress);
}

vec4 pick_random_shader(vec3 coords_geo, vec3 size_geo) {
    float r = niri_random_seed;

    if (r < 0.05) return vergil_slash(coords_geo, size_geo);
    else if (r < 0.10) return yasuo_wind(coords_geo, size_geo);
    else if (r < 0.15) return anime_teleport(coords_geo, size_geo);
    else if (r < 0.20) return jojo_menacing(coords_geo, size_geo);
    else if (r < 0.25) return naruto_poof(coords_geo, size_geo);
    else if (r < 0.30) return one_punch_exit(coords_geo, size_geo);
    else if (r < 0.35) return matrix_exit(coords_geo, size_geo);
    else if (r < 0.40) return crow_dissolve(coords_geo, size_geo);
    else if (r < 0.45) return zoro_lost(coords_geo, size_geo);
    else if (r < 0.50) return sliced_slide(coords_geo, size_geo);
    else if (r < 0.55) return shattered_vert(coords_geo, size_geo);
    else if (r < 0.60) return whirlpool(coords_geo, size_geo);
    else if (r < 0.65) return dissolve_noise(coords_geo, size_geo);
    else if (r < 0.70) return zigzag_split(coords_geo, size_geo);
    else if (r < 0.75) return swirl_dissolve(coords_geo, size_geo);
    else if (r < 0.80) return fall_and_rotate(coords_geo, size_geo);
    else if (r < 0.85) return shattered_vert(coords_geo, size_geo);
    else if (r < 0.90) return whirlpool(coords_geo, size_geo);
    else return dissolve_noise(coords_geo, size_geo);
}

vec4 close_color(vec3 coords_geo, vec3 size_geo) {
    return pick_random_shader(coords_geo, size_geo);
}
