const std = @import("std");
const rl = @import("raylib");
const util = @import("./utilities.zig");

pub const radius = 10.0;
pub const collide_radius = radius * 0.9;
pub const player_collide_radius = radius * 0.5;

x: f32,
y: f32,
angle: f32,
speed: f32,
split: bool = false,
split_time: f32 = 0.0,

pub fn move(self: *@This()) void {
    if (!self.split) return;
    const speed = self.speed / (1.0 / 60.0 / rl.getFrameTime());
    self.x = @mod(self.x + speed * util.cos(self.angle + 300), util.getRenderWidth());
    self.y = @mod(self.y + speed * util.sin(self.angle + 300), util.getRenderHeight());

    self.split_time += rl.getFrameTime();
}

pub fn draw(self: @This()) void {
    const radians = util.gradiansToRadians(self.angle);

    const top_right_x = self.x - radius * @cos(radians + std.math.tau / 3.0);
    const top_right_y = self.y - radius * @sin(radians + std.math.tau / 3.0);
    const left_x = self.x - radius * @cos(radians);
    const left_y = self.y - radius * @sin(radians);
    const bottom_right_x = self.x - radius * @cos(radians - std.math.tau / 3.0);
    const bottom_right_y = self.y - radius * @sin(radians - std.math.tau / 3.0);

    //const center_point = rl.Vector2.init(self.x, self.y);
    const top_right_point = rl.Vector2.init(top_right_x, top_right_y);
    const left_point = rl.Vector2.init(left_x, left_y);
    const bottom_right_point = rl.Vector2.init(bottom_right_x, bottom_right_y);

    rl.drawTriangleLines(top_right_point, left_point, bottom_right_point, rl.Color.white);

    //rl.drawCircleLinesV(rl.Vector2.init(self.x, self.y), collide_radius, rl.Color.red);
    //rl.drawCircleLinesV(rl.Vector2.init(self.x, self.y), player_collide_radius, rl.Color.green);
}
