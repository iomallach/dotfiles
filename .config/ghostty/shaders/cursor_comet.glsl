// Ghostty / Shadertoy. Short Neovide-inspired smear; no feedback texture needed.
const float DURATION = 0.48;
const float MIN_LENGTH_CELLS = 1.5;
const float MAX_LENGTH_CELLS = 12.0;
const float STRENGTH = 0.85;
const vec3 ACCENT = vec3(0.016, 0.820, 0.976); // theme cyan

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

    // Ghostty gives the top-left corner in bottom-left-origin pixel space.
    vec2 halfSize = iCurrentCursor.zw * 0.5;
    vec2 head = iCurrentCursor.xy + vec2(halfSize.x, -halfSize.y);
    vec2 previous = iPreviousCursor.xy + iPreviousCursor.zw * vec2(0.5, -0.5);
    vec2 movement = head - previous;
    float movementLength = length(movement);
    if (movementLength < 0.5) return; // blinking/color changes are not movement

    float progress = clamp(age / DURATION, 0.0, 1.0);
    vec2 direction = movement / movementLength;
    // Extrapolate a short tail for one-cell moves so it isn't hidden by the cursor.
    float trailLength = clamp(movementLength,
        MIN_LENGTH_CELLS * iCurrentCursor.w,
        MAX_LENGTH_CELLS * iCurrentCursor.w);
    // Retract gradually instead of collapsing within the first few frames.
    trailLength *= pow(1.0 - progress, 1.5);
    if (trailLength < 0.5) return;
    // Start at the trailing rectangle edge, not its masked-out center.
    // The ray/box intersection also handles diagonal movement and bar cursors.
    vec2 safeDirection = max(abs(direction), vec2(0.0001));
    float edgeDistance = min(halfSize.x / safeDirection.x, halfSize.y / safeDirection.y);
    vec2 trailHead = head - direction * edgeDistance;
    vec2 tail = trailHead - direction * trailLength;
    vec2 normal = vec2(-direction.y, direction.x);
    // Tall/narrow terminal cursors must not make vertical trails hairline-thin.
    float width = max(dot(abs(normal), halfSize), max(iCurrentCursor.w * 0.45, 1.0));
    float glowRadius = max(iCurrentCursor.w * 0.12, 2.0);

    // Most screen pixels take this cheap path, including pixels on long jumps.
    vec2 margin = vec2(width * 1.15 + glowRadius * 4.0);
    if (any(lessThan(fragCoord, min(tail, trailHead) - margin)) ||
        any(greaterThan(fragCoord, max(tail, trailHead) + margin))) return;

    float along = clamp(dot(fragCoord - tail, direction) / trailLength, 0.0, 1.0);
    vec2 nearest = mix(tail, trailHead, along);
    float radius = width * mix(0.12, 1.15, along);
    float distanceToTrail = length(fragCoord - nearest) - radius;
    float core = 1.0 - smoothstep(-0.75, 1.0, distanceToTrail);
    float glow = exp(-max(distanceToTrail, 0.0) / glowRadius) * 0.32;
    float fade = pow(1.0 - progress, 0.8) * mix(0.15, 1.0, smoothstep(0.0, 0.35, along));

    // Never repaint the real cursor or its glyph; don't change window opacity.
    float outsideCursor = smoothstep(0.0, 1.5, boxDistance(fragCoord, head, halfSize));
    float amount = clamp((core + glow) * fade * STRENGTH * outsideCursor, 0.0, STRENGTH);
    vec3 color = mix(ACCENT, iCurrentCursorColor.rgb, along);
    fragColor.rgb = mix(fragColor.rgb, color * fragColor.a, amount);
}
