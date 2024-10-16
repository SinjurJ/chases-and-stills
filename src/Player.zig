const std = @import("std");
const rl = @import("raylib");
const util = @import("./utilities.zig");

pub var radius: f32 = 20.0;
pub var collide_radius: f32 = 4.0;
var thickness: f32 = 2.0;

x: f32,
y: f32,
angle: f32,
speed: f32,
rotate_speed: f32,
fire_delay: f32,
time_since_fire: f32,

pub fn calculateRadius() void {
    const render_min = util.getRenderMin();
    radius = render_min * 0.05;
    collide_radius = radius * 0.2;
    thickness = render_min * 0.005;
}

pub fn move(self: *@This()) void {
    const speed = util.adjustForDeltaTime(self.speed);
    self.x = @mod(self.x + speed * util.cos(self.angle), util.getRenderWidth());
    self.y = @mod(self.y + speed * util.sin(self.angle), util.getRenderHeight());
}

pub fn moveBackward(self: *@This()) void {
    const speed = util.adjustForDeltaTime(self.speed);
    self.x = @mod(self.x - speed / 10.0 * util.cos(self.angle), util.getRenderWidth());
    self.y = @mod(self.y - speed / 10.0 * util.sin(self.angle), util.getRenderHeight());
}

pub fn rotateLeft(self: *@This()) void {
    const rotate_speed = util.adjustForDeltaTime(self.rotate_speed);
    self.angle = @mod(self.angle - rotate_speed, 400);
}

pub fn rotateRight(self: *@This()) void {
    const rotate_speed = util.adjustForDeltaTime(self.rotate_speed);
    self.angle = @mod(self.angle + rotate_speed, 400);
}

pub fn draw(self: *@This()) void {
    const radians = util.gradiansToRadians(self.angle);

    const right_point_x = self.x + radius * @cos(radians);
    const right_point_y = self.y + radius * @sin(radians);
    const top_left_point_x = self.x + radius * @cos(radians + 0.9 * std.math.pi);
    const top_left_point_y = self.y + radius * @sin(radians + 0.9 * std.math.pi);
    const left_point_x = self.x + radius * 0.6 * @cos(radians + std.math.pi);
    const left_point_y = self.y + radius * 0.6 * @sin(radians + std.math.pi);
    const bottom_left_point_x = self.x + radius * @cos(radians + 1.1 * std.math.pi);
    const bottom_left_point_y = self.y + radius * @sin(radians + 1.1 * std.math.pi);

    const right_point = rl.Vector2.init(right_point_x, right_point_y);
    const top_left_point = rl.Vector2.init(top_left_point_x, top_left_point_y);
    const left_point = rl.Vector2.init(left_point_x, left_point_y);
    const bottom_left_point = rl.Vector2.init(bottom_left_point_x, bottom_left_point_y);

    rl.drawLineEx(right_point, top_left_point, thickness, rl.Color.white);
    rl.drawLineEx(top_left_point, left_point, thickness, rl.Color.white);
    rl.drawLineEx(left_point, bottom_left_point, thickness, rl.Color.white);
    rl.drawLineEx(bottom_left_point, right_point, thickness, rl.Color.white);

    rl.drawCircleV(right_point, thickness / 2.0, rl.Color.white);
    rl.drawCircleV(top_left_point, thickness / 2.0, rl.Color.white);
    rl.drawCircleV(left_point, thickness / 2.0, rl.Color.white);
    rl.drawCircleV(bottom_left_point, thickness / 2.0, rl.Color.white);

    //rl.drawCircleLinesV(rl.Vector2.init(self.x, self.y), collide_radius, rl.Color.red);
}
