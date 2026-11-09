#!/usr/bin/env bash
set -euo pipefail

# Run with: nix shell nixpkgs#glslang --command bash check.sh
shader_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT

for version in 330 430; do
    for api in legacy current; do
        for shader in cursor_comet cursor_particles; do
            {
                printf '#version %s core\n' "$version"
                printf '%s\n' \
                    'uniform sampler2D iChannel0;' \
                    'uniform vec3 iResolution;' \
                    'uniform float iTime, iTimeCursorChange;' \
                    'uniform vec4 iCurrentCursor, iPreviousCursor, iCurrentCursorColor;'
                if [[ $api == current ]]; then
                    printf '%s\n' '#define CURSORSTYLE_BLOCK 0' 'uniform int iCursorVisible;'
                fi
                printf '%s\n' 'out vec4 outputColor;'
                # Bash read, rather than a dependency on a GLSL preprocessor.
                while IFS= read -r line || [[ -n $line ]]; do
                    printf '%s\n' "$line"
                done < "$shader_dir/$shader.glsl"
                printf '%s\n' 'void main() { mainImage(outputColor, gl_FragCoord.xy); }'
            } > "$tmp/$shader.frag"
            glslangValidator -S frag "$tmp/$shader.frag"
            printf 'PASS: %s, GLSL %s, %s uniforms\n' "$shader" "$version" "$api"
        done
    done
done

if command -v ghostty >/dev/null; then
    # Seed an old effect to ensure preset.conf really clears the shader stack.
    mkdir -p "$tmp/ghostty"
    printf 'custom-shader = %s/cursor_smear_fade.glsl\nconfig-file = %s/preset.conf\n' \
        "$shader_dir" "$shader_dir" > "$tmp/ghostty/config"
    XDG_CONFIG_HOME="$tmp" ghostty +validate-config
    # Independently test the three choices without modifying the active preset.
    for preset in comet particles off; do
        printf 'custom-shader = %s/cursor_smear_fade.glsl\nconfig-file = choice.conf\n' \
            "$shader_dir" > "$tmp/ghostty/config"
        printf 'custom-shader =\n' > "$tmp/ghostty/choice.conf"
        if [[ $preset != off ]]; then
            printf 'custom-shader = %s/cursor_%s.glsl\ncustom-shader-animation = true\n' \
                "$shader_dir" "$preset" >> "$tmp/ghostty/choice.conf"
        else
            printf 'custom-shader-animation = false\n' >> "$tmp/ghostty/choice.conf"
        fi
        XDG_CONFIG_HOME="$tmp" ghostty +validate-config
        resolved=$(XDG_CONFIG_HOME="$tmp" ghostty +show-config --no-pager)
        count=$(printf '%s\n' "$resolved" | grep -c '^custom-shader = ' || true)
        expected=1
        [[ $preset != off ]] || expected=0
        if [[ $count != "$expected" ]]; then
            printf 'FAIL: %s expected %s shaders, found %s\n' "$preset" "$expected" "$count" >&2
            exit 1
        fi
        if [[ $preset != off ]]; then
            printf '%s\n' "$resolved" | grep -F "custom-shader = $shader_dir/cursor_$preset.glsl"
        else
            printf '%s\n' "$resolved" | grep -F 'custom-shader-animation = false'
        fi
        printf 'PASS: %s preset clears the old shader stack\n' "$preset"
    done
fi
