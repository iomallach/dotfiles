float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float getSdfCircle(in vec2 p, in vec2 center, float radius) {
    return length(p - center) - radius;
}

// Based on Inigo Quilez's 2D distance functions article: https://iquilezles.org/articles/distfunctions2d/
// Potencially optimized by eliminating conditionals and loops to enhance performance and reduce branching

float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance) {
    return 1. - smoothstep(0., normalize(vec2(2., 2.), 0.).x, distance);
}

float determineStartVertexFactor(vec2 a, vec2 b) {
    // Conditions using step
    float condition1 = step(b.x, a.x) * step(a.y, b.y); // a.x < b.x && a.y > b.y
    float condition2 = step(a.x, b.x) * step(b.y, a.y); // a.x > b.x && a.y < b.y

    // If neither condition is met, return 1 (else case)
    return 1.0 - max(condition1, condition2);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}
float ease(float x) {
    return pow(1.0 - x, 3.0);
}

const vec4 TRAIL_COLOR = vec4(1., 0., 0., 1.0);
const float DURATION = 0.5; //IN SECONDS

const vec4 BUBBLE_COLOR = vec4(0.3, 0.7, 1.0, 1.0); // Cyan bubbles
const float BUBBLE_DURATION = 0.8; // Bubble lifetime in seconds
const float BUBBLE_MAX_SIZE = 0.015; // Maximum bubble radius
const int BUBBLE_COUNT = 8; // Number of bubbles in trail

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif
    
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);
    
    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));
    
    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    float lineLength = distance(centerCC, centerCP);
    
    float totalProgress = clamp((iTime - iTimeCursorChange) / BUBBLE_DURATION, 0.0, 1.0);
    
    vec4 newColor = fragColor;
    
    // Generate bubble trail
    for (int i = 0; i < BUBBLE_COUNT; i++) {
        float t = float(i) / float(BUBBLE_COUNT - 1);
        
        // Position along the trail
        vec2 bubblePos = mix(centerCP, centerCC, t);
        
        // Each bubble starts appearing at different times
        float bubbleStartTime = t * 0.3; // Stagger bubble appearance
        float bubbleProgress = clamp((totalProgress - bubbleStartTime) / (1.0 - bubbleStartTime), 0.0, 1.0);
        
        if (bubbleProgress > 0.0) {
            // Bubble size animation: grow then shrink
            float sizePhase = bubbleProgress * 2.0;
            float bubbleSize;
            if (sizePhase < 1.0) {
                // Growing phase
                bubbleSize = BUBBLE_MAX_SIZE * sizePhase;
            } else {
                // Shrinking phase
                bubbleSize = BUBBLE_MAX_SIZE * (2.0 - sizePhase);
            }
            
            // Bubble opacity: fade out over time
            float bubbleOpacity = 1.0 - ease(bubbleProgress);
            
            // Add some randomness to bubble positions (pseudo-random based on index)
            vec2 offset = vec2(
                sin(float(i) * 12.9898) * 0.005,
                cos(float(i) * 78.233) * 0.005
            );
            bubblePos += offset;
            
            float sdfBubble = getSdfCircle(vu, bubblePos, bubbleSize);
            vec4 bubbleColor = BUBBLE_COLOR * bubbleOpacity;
            
            newColor = mix(newColor, bubbleColor, antialising(sdfBubble) * bubbleOpacity);
        }
    }
    
    // Draw current cursor
    float sdfCurrentCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
    newColor = mix(newColor, TRAIL_COLOR, antialising(sdfCurrentCursor));
    newColor = mix(newColor, fragColor, step(sdfCurrentCursor, 0.));
    fragColor = mix(fragColor, newColor, 1.0);
}
