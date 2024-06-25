const std = @import("std");
const rl = @import("raylib");
const util = @import("./utilities.zig");

pub const radius = 20.0;
pub const collide_radius = radius * 0.9;

x: f32,
y: f32,
angle: f32,
speed: f32,
spin: bool = false,
spin_angle: f32 = 0.0,
spin_speed: f32 = 0.0,
spin_time: f32 = 0.0,

pub fn move(self: *@This(), x: f32, y: f32) void {
    const player_angle = @mod(util.atan2(y - self.y, x - self.x), 400);
    var speed = self.spin_speed / (1.0 / 60.0 / rl.getFrameTime());
    if (!self.spin) {
        self.angle = player_angle;
        speed = self.speed / (1.0 / 60.0 / rl.getFrameTime());
    } else if (self.spin_time >= 5.0) {
        if (@mod(self.spin_angle - player_angle, 400) < 2.0 * self.spin_speed / (1.0 / 60.0 / rl.getFrameTime())) {
            self.spin = false;
            self.spin_time = 0.0;
        } else return;
    }

    self.x = @mod(self.x + speed * util.cos(self.angle), util.getRenderWidth());
    self.y = @mod(self.y + speed * util.sin(self.angle), util.getRenderHeight());
}

pub fn draw(self: *@This()) void {
    var degrees: f32 = 0.0;
    if (self.spin) {
        self.spin_time += rl.getFrameTime();
        self.spin_angle = @mod(self.spin_angle + self.spin_speed / (1.0 / 60.0 / rl.getFrameTime()), 400.0);
        degrees = util.gradiansToDegrees(self.spin_angle) - 180;
    } else {
        degrees = util.gradiansToDegrees(self.angle) - 180;
    }

    const center_point = rl.Vector2.init(self.x, self.y);

    // raylib seems to draw 36 segments for 360 degrees; i am, as such, drawing 1 segment every 10 degrees ceil
    const small_arc: f32 = 0.04 * 360.0;
    const large_arc: f32 = 360.0 - small_arc * 5.0;
    const small_arc_segments: u6 = @ceil(small_arc / 10.0);
    const large_arc_segments: u6 = @ceil(large_arc / 10.0);
    rl.drawCircleSectorLines(center_point, radius, degrees - small_arc * 1.5, degrees - small_arc * 2.5, small_arc_segments, rl.Color.white);
    rl.drawCircleSectorLines(center_point, radius, degrees - small_arc * 0.5, degrees + small_arc * 0.5, small_arc_segments, rl.Color.white);
    rl.drawCircleSectorLines(center_point, radius, degrees + small_arc * 1.5, degrees + small_arc * 2.5, small_arc_segments, rl.Color.white);
    rl.drawCircleSectorLines(center_point, radius, degrees + small_arc * 3.5, degrees + 360 - small_arc * 3.5, large_arc_segments, rl.Color.white);

    //rl.drawCircleLinesV(rl.Vector2.init(self.x, self.y), collide_radius, rl.Color.red);
}
