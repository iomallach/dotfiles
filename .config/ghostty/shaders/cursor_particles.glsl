// Ghostty / Shadertoy. Stateless Neovide-inspired sparks on the latest movement.
const float DURATION = 0.85;
const float MAX_LENGTH_CELLS = 12.0;
const float STRENGTH = 0.90;
const int PARTICLE_COUNT = 14;
const vec3 ACCENT = vec3(0.016, 0.820, 0.976); // theme cyan
const vec3 SPARK_ACCENT = vec3(0.949, 0.396, 0.710); // theme pink

float hash(float seed) {
    return fract(sin(seed * 127.1 + 311.7) * 43758.5453);
}

float boxDistance(vec2 point, vec2 center, vec2 halfSize) {
    vec2 d = abs(point - center) - halfSize;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);
    // Cursor visibility was added after Ghostty 1.2, alongside these macros.
#ifdef CURSORSTYLE_BLOCK
    if (iCursorVisible == 0) return;
#endif
    float age = max(iTime - iTimeCursorChange, 0.0);
    if (age >= DURATION ||
        min(iCurrentCursor.z, iCurrentCursor.w) <= 0.0 ||
        min(iPreviousCursor.z, iPreviousCursor.w) <= 0.0) return;

    vec2 halfSize = iCurrentCursor.zw * 0.5;
    vec2 head = iCurrentCursor.xy + vec2(halfSize.x, -halfSize.y);
    vec2 previous = iPreviousCursor.xy + iPreviousCursor.zw * vec2(0.5, -0.5);
    vec2 movement = head - previous;
    float movementLength = length(movement);
    if (movementLength < 0.5) return;

    vec2 direction = movement / movementLength;
    vec2 normal = vec2(-direction.y, direction.x);
    float cell = max(iCurrentCursor.w, 2.0);
    vec2 tail = head - direction * min(movementLength, MAX_LENGTH_CELLS * cell);
    float progress = clamp(age / DURATION, 0.0, 1.0);
    // All particles stay inside this padded box; avoid the loop elsewhere.
    vec2 margin = vec2(cell * 4.0);
    if (any(lessThan(fragCoord, min(tail, head) - margin)) ||
        any(greaterThan(fragCoord, max(tail, head) + margin))) return;

    vec3 light = vec3(0.0);
    float coverage = 0.0;
    float fade = pow(1.0 - progress, 1.2);
    for (int index = 0; index < PARTICLE_COUNT; index++) {
        // Stable for the entire movement: no frame-to-frame random flickering.
        float seed = float(index) + mod(iTimeCursorChange, 100.0) * 19.0;
        float scatter = hash(seed + 7.0) * 2.0 - 1.0;
        float along = (float(index) + hash(seed)) / float(PARTICLE_COUNT);
        vec2 position = mix(tail, head, along);
        // Scatter immediately outside the cursor row, even for one-cell moves.
        // Widely separated cores read as sparks instead of a continuous smear.
        position += normal * scatter * cell * (0.60 + progress * 1.60);
        position += direction * cell * (hash(seed + 5.0) - 0.5) * 0.5;
        position -= direction * cell * progress * (0.2 + hash(seed + 3.0) * 0.8);
        position.y += cell * progress * progress * 0.70;

        float radius = max(1.25, cell * mix(0.06, 0.13, hash(seed + 11.0)));
        radius *= mix(1.0, 0.5, progress);
        float d = length(fragCoord - position);
        float spark = 1.0 - smoothstep(radius * 0.45, radius + 0.8, d);
        spark += exp(-d / max(radius, 0.5)) * 0.10;
        spark *= fade * mix(0.65, 1.0, along);
        vec3 color = mix(ACCENT, SPARK_ACCENT, step(0.5, hash(seed + 17.0)));
        light += color * spark;
        coverage += spark;
    }

    float outsideCursor = smoothstep(0.0, 1.5, boxDistance(fragCoord, head, halfSize));
    float amount = min(coverage * STRENGTH, STRENGTH) * outsideCursor;
    vec3 color = light / max(coverage, 0.0001);
    fragColor.rgb = mix(fragColor.rgb, color * fragColor.a, amount);
}
