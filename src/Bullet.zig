const std = @import("std");
const rl = @import("raylib");
const util = @import("./utilities.zig");

pub var radius: f32 = 10.0;
pub var collide_radius: f32 = 8.0;
var thickness: f32 = 2.0;

x: f32,
y: f32,
angle: f32,
speed: f32,
player_made: bool,
frame: u8 = 0,
time_since_frame: f32 = 0,

pub fn calculateRadius() void {
    const render_min = util.getRenderMin();
    radius = render_min * 0.025;
    collide_radius = radius * 0.8;
    thickness = render_min * 0.005;
}

pub fn move(self: *@This()) void {
    const speed = self.speed / (1.0 / 60.0 / rl.getFrameTime());
    self.x = @mod(self.x + speed * util.cos(self.angle), util.getRenderWidth());
    self.y = @mod(self.y + speed * util.sin(self.angle), util.getRenderHeight());
}

pub fn draw(self: *@This()) void {
    const radians: f32 = if (self.frame == 0) 0 else std.math.pi / 4.0;

    const right_point_x = self.x + radius * @cos(radians);
    const right_point_y = self.y - radius * @sin(radians);
    const top_point_x = self.x - radius * @sin(radians);
    const top_point_y = self.y - radius * @cos(radians);
    const left_point_x = self.x - radius * @cos(radians);
    const left_point_y = self.y + radius * @sin(radians);
    const bottom_point_x = self.x + radius * @sin(radians);
    const bottom_point_y = self.y + radius * @cos(radians);

    const right_point = rl.Vector2.init(right_point_x, right_point_y);
    const top_point = rl.Vector2.init(top_point_x, top_point_y);
    const left_point = rl.Vector2.init(left_point_x, left_point_y);
    const bottom_point = rl.Vector2.init(bottom_point_x, bottom_point_y);

    if (self.player_made) {
        rl.drawLineEx(right_point, left_point, thickness, rl.Color.white);
        rl.drawLineEx(top_point, bottom_point, thickness, rl.Color.white);
    } else {
        rl.drawLineEx(right_point, top_point, thickness, rl.Color.white);
        rl.drawLineEx(top_point, left_point, thickness, rl.Color.white);
        rl.drawLineEx(left_point, bottom_point, thickness, rl.Color.white);
        rl.drawLineEx(bottom_point, right_point, thickness, rl.Color.white);
    }

    rl.drawCircleV(right_point, thickness / 2.0, rl.Color.white);
    rl.drawCircleV(top_point, thickness / 2.0, rl.Color.white);
    rl.drawCircleV(left_point, thickness / 2.0, rl.Color.white);
    rl.drawCircleV(bottom_point, thickness / 2.0, rl.Color.white);

    //rl.drawCircleLinesV(rl.Vector2.init(self.x, self.y), collide_radius, rl.Color.red);

    self.time_since_frame += rl.getFrameTime();
    if (self.time_since_frame > 0.05) {
        self.frame = @mod(self.frame + 1, 2);
        self.time_since_frame = 0;
    }
}
