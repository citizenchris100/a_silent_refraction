# Development Environment Setup - Simulating Target Hardware

## Overview

A Silent Refraction is designed to run on Raspberry Pi 5 hardware as a dedicated gaming appliance. During development on desktop Linux systems (especially with Intel graphics), you may experience rendering differences from the target platform. This guide explains how to configure your development environment to better simulate the production hardware.

## Why This Matters

The Raspberry Pi 5 uses a VideoCore VII GPU with a completely different rendering pipeline than desktop Intel graphics. By using software rendering during development, we:

1. **Eliminate platform-specific rendering artifacts** (like screen tearing)
2. **Better simulate the target hardware's performance characteristics**
3. **Ensure visual consistency between development and production**
4. **Test with rendering constraints similar to the Pi's capabilities**

## The Solution: Software Rendering

Software rendering bypasses hardware-specific GPU behaviors and provides a more consistent, predictable rendering environment that better represents how the game will run on Raspberry Pi hardware.

## Implementation Methods

### Method 1: Permanent Alias (Recommended)

Add this alias to your shell configuration file (`~/.bashrc` for Bash, `~/.zshrc` for Zsh):

```bash
# Add to ~/.bashrc or ~/.zshrc
alias asr='cd /path/to/a_silent_refraction && LIBGL_ALWAYS_SOFTWARE=1 ./a_silent_refraction.sh'
```

After adding, reload your shell configuration:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

Now you can use `asr` instead of `./a_silent_refraction.sh`:
```bash
asr run          # Run the game
asr camera-system # Run camera test
asr debug        # Run debug tools
# etc.
```

### Method 2: Environment Variable

Set the environment variable for your current session:
```bash
export LIBGL_ALWAYS_SOFTWARE=1
./a_silent_refraction.sh camera-system
```

### Method 3: Per-Command

Apply software rendering for a single command:
```bash
LIBGL_ALWAYS_SOFTWARE=1 ./a_silent_refraction.sh camera-system
```

### Method 4: Wrapper Script

Create a development wrapper script in the project:

```bash
#!/bin/bash
# dev_run.sh - Development runner simulating target environment
echo "Running with software rendering (simulating Pi environment)"
LIBGL_ALWAYS_SOFTWARE=1 ./a_silent_refraction.sh "$@"
```

Make it executable:
```bash
chmod +x dev_run.sh
```

## Benefits of This Approach

### 1. Consistent Rendering Behavior
- Eliminates hardware-specific quirks (Intel screen tearing, NVIDIA frame pacing, etc.)
- Provides predictable frame timing
- Matches the deterministic rendering of embedded systems

### 2. Performance Testing
- Software rendering performance on modern desktop CPUs approximates Pi 5 performance
- Helps identify performance bottlenecks early
- Ensures the game runs smoothly on target hardware

### 3. Visual Accuracy
- No hardware-accelerated "enhancements" that won't exist on Pi
- Accurate color reproduction
- Consistent pixel-perfect rendering

## How It Works

- `LIBGL_ALWAYS_SOFTWARE=1` forces Mesa/OpenGL to use software rendering
- Rendering happens entirely on the CPU, similar to how the Pi's VideoCore handles 2D
- Provides consistent, deterministic output across different development machines

## Performance Expectations

For A Silent Refraction's technical profile:
- 2D graphics with 16-color palette
- No complex shaders or post-processing
- Simple sprite rendering and backgrounds
- Performance impact is minimal on modern CPUs

The software renderer easily handles these requirements while providing a more accurate development environment.

## Verifying the Setup

To verify software rendering is active:
```bash
LIBGL_ALWAYS_SOFTWARE=1 glxinfo | grep "renderer string"
# Should show: "llvmpipe" or similar software renderer
```

In-game verification:
1. Camera smoothing works without tearing
2. Consistent frame timing
3. No platform-specific visual artifacts

## Platform-Specific Notes

### Required On:
- Linux systems with Intel integrated graphics
- Linux systems with problematic GPU drivers
- Any system where hardware rendering causes issues

### Optional But Recommended On:
- Linux with NVIDIA/AMD graphics (for consistency)
- High-refresh displays (>60Hz) that might not match Pi output

### Not Needed On:
- Actual Raspberry Pi development boards
- Windows development (different rendering pipeline)
- macOS development (different rendering pipeline)

## Alternative Configurations

If software rendering is too slow for your development machine:

### Limit Frame Rate to Match Pi
```bash
# In project.godot under [application]
target_fps=30  # Pi 5 typical performance target
```

### Use Compositor Settings
Some Linux compositors can be configured to better match embedded display behavior.

## Troubleshooting

### Alias Not Working
1. Verify the project path in the alias is correct
2. Ensure you're editing the correct shell config (`.bashrc` vs `.zshrc`)
3. Reload the configuration or start a new terminal

### Performance Issues
1. Close other applications to free CPU resources
2. Ensure your CPU governor is set to "performance"
3. Consider upgrading to a newer CPU if consistently slow

### Rendering Differences
Some minor differences between software and Pi rendering are normal. Focus on:
- Overall performance characteristics
- Absence of platform-specific artifacts
- Consistent behavior across scenes

## Conclusion

This development environment setup ensures that what you see during development closely matches what players will experience on the target Raspberry Pi 5 hardware. It's not just a workaround for Intel graphics issues - it's a proper simulation of the production environment.