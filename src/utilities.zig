const std = @import("std");
const rl = @import("raylib");

var windowResized = true;

pub fn gradiansToRadians(gradians: f32) f32 {
    return gradians * std.math.tau / 400.0;
}

pub fn gradiansToDegrees(gradians: f32) f32 {
    return gradians * 360.0 / 400.0;
}

pub fn cos(gradians: f32) f32 {
    return @cos(gradiansToRadians(gradians));
}

pub fn sin(gradians: f32) f32 {
    return @sin(gradiansToRadians(gradians));
}

pub fn atan2(y: f32, x: f32) f32 {
    return std.math.atan2(y, x) / (std.math.tau / 400.0);
}

pub fn adjustForDeltaTime(value: f32) f32 {
    return value / (1.0 / 60.0 / rl.getFrameTime());
}

pub fn getRenderWidth() f32 {
    return @floatFromInt(rl.getRenderWidth());
}

pub fn getRenderHeight() f32 {
    return @floatFromInt(rl.getRenderHeight());
}
