const std = @import("std");
const rl = @import("raylib");
const util = @import("./utilities.zig");
const StillSmall = @import("./StillSmall.zig");

pub var radius: f32 = 20.0;
pub var collide_radius: f32 = 18.0;
var thickness: f32 = 2.0;

x: f32,
y: f32,
angle: f32,
spin_speed: f32,
fire_rate: f32,
time_since_fire: f32 = 0.0,

pub fn calculateRadius() void {
    const render_min = util.getRenderMin();
    radius = render_min * 0.05;
    collide_radius = radius * 0.9;
    thickness = render_min * 0.005;
}

pub fn release(self: *@This(), still_smalls: *[3]?StillSmall) void {
    for (still_smalls) |*still_small_optional| {
        if (still_small_optional.*) |*still_small| {
            still_small.speed = util.gradiansToRadians(self.spin_speed) * radius;
            still_small.split = true;
        }
    }
}

pub fn fire(self: *@This(), still_smalls: [3]?StillSmall) ?[3]?[4]f32 {
    if (self.time_since_fire < self.fire_rate) {
        self.time_since_fire += rl.getFrameTime();
        return null;
    }
    var bullet_info: [3]?[4]f32 = .{ .{ 0.0, 0.0, 0.0, 0.0 }, .{ 0.0, 0.0, 0.0, 0.0 }, .{ 0.0, 0.0, 0.0, 0.0 } };
    for (still_smalls, 0..) |still_small_optional, i| {
        if (still_small_optional) |_| {
            bullet_info[i] = null;
            continue;
        }
        switch (i) {
            0 => if (bullet_info[0]) |*bullet| {
                bullet[0] = @mod(self.angle - 200.0 / 3.0, 400.0);
                bullet[1] = self.fire_rate / 2.0;
                bullet[2] = self.x - 1.5 * radius * util.cos(self.angle + 400.0 / 3.0);
                bullet[3] = self.y - 1.5 * radius * util.sin(self.angle + 400.0 / 3.0);
            },
            1 => if (bullet_info[1]) |*bullet| {
                bullet[0] = @mod(self.angle - 200, 400.0);
                bullet[1] = self.fire_rate / 2.0;
                bullet[2] = self.x - 1.5 * radius * util.cos(self.angle);
                bullet[3] = self.y - 1.5 * radius * util.sin(self.angle);
            },
            2 => if (bullet_info[2]) |*bullet| {
                bullet[0] = @mod(self.angle + 200.0 / 3.0, 400.0);
                bullet[1] = self.fire_rate / 2.0;
                bullet[2] = self.x - 1.5 * radius * util.cos(self.angle - 400.0 / 3.0);
                bullet[3] = self.y - 1.5 * radius * util.sin(self.angle - 400.0 / 3.0);
            },
            else => {},
        }
    }

    self.time_since_fire = 0.0;

    return bullet_info;
}

pub fn draw(self: *@This(), still_smalls: *[3]?StillSmall) void {
    self.angle = @mod(self.angle - self.spin_speed / (1.0 / 60.0 / rl.getFrameTime()), 400.0);

    const radians = util.gradiansToRadians(self.angle);
    const small_radius = radius * 0.5;

    const top_right_center_x = self.x - radius * @cos(radians + std.math.tau / 3.0);
    const top_right_center_y = self.y - radius * @sin(radians + std.math.tau / 3.0);
    const top_right_bottom_x = top_right_center_x + small_radius * @sin(radians + std.math.tau / 3.0);
    const top_right_bottom_y = top_right_center_y - small_radius * @cos(radians + std.math.tau / 3.0);
    const top_right_top_x = top_right_center_x - small_radius * @sin(radians + std.math.tau / 3.0);
    const top_right_top_y = top_right_center_y + small_radius * @cos(radians + std.math.tau / 3.0);
    const top_right_inner_x = top_right_center_x + 1.5 * small_radius * @cos(radians + std.math.tau / 3.0);
    const top_right_inner_y = top_right_center_y + 1.5 * small_radius * @sin(radians + std.math.tau / 3.0);
    const left_center_x = self.x - radius * @cos(radians);
    const left_center_y = self.y - radius * @sin(radians);
    const left_top_x = left_center_x + small_radius * @sin(radians);
    const left_top_y = left_center_y - small_radius * @cos(radians);
    const left_bottom_x = left_center_x - small_radius * @sin(radians);
    const left_bottom_y = left_center_y + small_radius * @cos(radians);
    const left_inner_x = left_center_x + 1.5 * small_radius * @cos(radians);
    const left_inner_y = left_center_y + 1.5 * small_radius * @sin(radians);
    const bottom_right_center_x = self.x - radius * @cos(radians - std.math.tau / 3.0);
    const bottom_right_center_y = self.y - radius * @sin(radians - std.math.tau / 3.0);
    const bottom_right_bottom_x = bottom_right_center_x + small_radius * @sin(radians - std.math.tau / 3.0);
    const bottom_right_bottom_y = bottom_right_center_y - small_radius * @cos(radians - std.math.tau / 3.0);
    const bottom_right_top_x = bottom_right_center_x - small_radius * @sin(radians - std.math.tau / 3.0);
    const bottom_right_top_y = bottom_right_center_y + small_radius * @cos(radians - std.math.tau / 3.0);
    const bottom_right_inner_x = bottom_right_center_x + 1.5 * small_radius * @cos(radians - std.math.tau / 3.0);
    const bottom_right_inner_y = bottom_right_center_y + 1.5 * small_radius * @sin(radians - std.math.tau / 3.0);

    //const top_right_center_point = rl.Vector2.init(top_right_center_x, top_right_center_y);
    const top_right_bottom_point = rl.Vector2.init(top_right_bottom_x, top_right_bottom_y);
    const top_right_top_point = rl.Vector2.init(top_right_top_x, top_right_top_y);
    const top_right_inner_point = rl.Vector2.init(top_right_inner_x, top_right_inner_y);
    //const left_center_point = rl.Vector2.init(left_center_x, left_center_y);
    const left_top_point = rl.Vector2.init(left_top_x, left_top_y);
    const left_bottom_point = rl.Vector2.init(left_bottom_x, left_bottom_y);
    const left_inner_point = rl.Vector2.init(left_inner_x, left_inner_y);
    //const bottom_right_center_point = rl.Vector2.init(bottom_right_center_x, bottom_right_center_y);
    const bottom_right_bottom_point = rl.Vector2.init(bottom_right_bottom_x, bottom_right_bottom_y);
    const bottom_right_top_point = rl.Vector2.init(bottom_right_top_x, bottom_right_top_y);
    const bottom_right_inner_point = rl.Vector2.init(bottom_right_inner_x, bottom_right_inner_y);

    rl.drawLineEx(top_right_top_point, left_top_point, thickness, rl.Color.white);
    rl.drawLineEx(left_bottom_point, bottom_right_bottom_point, thickness, rl.Color.white);
    rl.drawLineEx(bottom_right_top_point, top_right_bottom_point, thickness, rl.Color.white);

    rl.drawLineEx(top_right_bottom_point, top_right_inner_point, thickness, rl.Color.white);
    rl.drawLineEx(top_right_inner_point, top_right_top_point, thickness, rl.Color.white);
    rl.drawLineEx(left_top_point, left_inner_point, thickness, rl.Color.white);
    rl.drawLineEx(left_inner_point, left_bottom_point, thickness, rl.Color.white);
    rl.drawLineEx(bottom_right_bottom_point, bottom_right_inner_point, thickness, rl.Color.white);
    rl.drawLineEx(bottom_right_inner_point, bottom_right_top_point, thickness, rl.Color.white);

    rl.drawLineEx(top_right_inner_point, left_inner_point, thickness, rl.Color.white);
    rl.drawLineEx(left_inner_point, bottom_right_inner_point, thickness, rl.Color.white);
    rl.drawLineEx(bottom_right_inner_point, top_right_inner_point, thickness, rl.Color.white);

    for (still_smalls, 0..) |*still_small_optional, i| {
        if (still_small_optional.*) |*still_small| {
            switch (i) {
                0 => {
                    still_small.x = top_right_center_x;
                    still_small.y = top_right_center_y;
                    still_small.angle = @mod(self.angle + 200.0 + 400.0 / 3.0, 400.0);
                },
                1 => {
                    still_small.x = left_center_x;
                    still_small.y = left_center_y;
                    still_small.angle = @mod(self.angle + 200.0, 400.0);
                },
                2 => {
                    still_small.x = bottom_right_center_x;
                    still_small.y = bottom_right_center_y;
                    still_small.angle = @mod(self.angle + 200.0 - 400.0 / 3.0, 400.0);
                },
                else => {},
            }
        }
    }
}
