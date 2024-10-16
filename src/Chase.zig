const std = @import("std");
const rl = @import("raylib");
const util = @import("./utilities.zig");

pub var radius: f32 = 20.0;
pub var collide_radius: f32 = 18.0;
var thickness: f32 = 2.0;

x: f32,
y: f32,
angle: f32,
speed: f32,
spinning_speed: f32 = 0.0,
spin: bool = false,
spin_angle: f32 = 0.0,
spin_speed: f32 = 6.0,
spin_time: f32 = 0.0,

pub fn calculateRadius() void {
    const render_min = util.getRenderMin();
    radius = render_min * 0.05;
    collide_radius = radius * 0.9;
    thickness = render_min * 0.005;
}

pub fn move(self: *@This(), x: f32, y: f32) void {
    const player_angle = @mod(util.atan2(y - self.y, x - self.x), 400);
    var speed = self.spinning_speed / (1.0 / 60.0 / rl.getFrameTime());
    if (!self.spin) {
        self.angle = player_angle;
        speed = self.speed / (1.0 / 60.0 / rl.getFrameTime());
    } else if (self.spin_time >= 5.0) {
        if (@mod(self.spin_angle - player_angle, 400) < 2.0 * self.spin_speed / (1.0 / 60.0 / rl.getFrameTime())) {
            self.spin = false;
            self.spin_time = 0.0;
            self.angle = player_angle;
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

    const first_line_first_angle = degrees - small_arc * 2.5;
    const first_line_second_angle = degrees - small_arc * 1.5;
    const second_line_first_angle = degrees - small_arc * 0.5;
    const second_line_second_angle = degrees + small_arc * 0.5;
    const third_line_first_angle = degrees + small_arc * 1.5;
    const third_line_second_angle = degrees + small_arc * 2.5;
    const fourth_line_first_angle = degrees + small_arc * 3.5;
    const fourth_line_second_angle = degrees + 360 - small_arc * 3.5;

    const inner_radius = radius - thickness / 2.0;
    const outer_radius = radius + thickness / 2.0;

    rl.drawRing(center_point, inner_radius, outer_radius, first_line_first_angle, first_line_second_angle, small_arc_segments, rl.Color.white);
    rl.drawRing(center_point, inner_radius, outer_radius, second_line_first_angle, second_line_second_angle, small_arc_segments, rl.Color.white);
    rl.drawRing(center_point, inner_radius, outer_radius, third_line_first_angle, third_line_second_angle, small_arc_segments, rl.Color.white);
    rl.drawRing(center_point, inner_radius, outer_radius, fourth_line_first_angle, fourth_line_second_angle, large_arc_segments, rl.Color.white);

    const first_point = rl.Vector2.init(self.x + radius * @cos(util.degreesToRadians(first_line_first_angle)), self.y + radius * @sin(util.degreesToRadians(first_line_first_angle)));
    const second_point = rl.Vector2.init(self.x + radius * @cos(util.degreesToRadians(first_line_second_angle)), self.y + radius * @sin(util.degreesToRadians(first_line_second_angle)));
    const third_point = rl.Vector2.init(self.x + radius * @cos(util.degreesToRadians(second_line_first_angle)), self.y + radius * @sin(util.degreesToRadians(second_line_first_angle)));
    const fourth_point = rl.Vector2.init(self.x + radius * @cos(util.degreesToRadians(second_line_second_angle)), self.y + radius * @sin(util.degreesToRadians(second_line_second_angle)));
    const fifth_point = rl.Vector2.init(self.x + radius * @cos(util.degreesToRadians(third_line_first_angle)), self.y + radius * @sin(util.degreesToRadians(third_line_first_angle)));
    const sixth_point = rl.Vector2.init(self.x + radius * @cos(util.degreesToRadians(third_line_second_angle)), self.y + radius * @sin(util.degreesToRadians(third_line_second_angle)));
    const seventh_point = rl.Vector2.init(self.x + radius * @cos(util.degreesToRadians(fourth_line_first_angle)), self.y + radius * @sin(util.degreesToRadians(fourth_line_first_angle)));
    const eighth_point = rl.Vector2.init(self.x + radius * @cos(util.degreesToRadians(fourth_line_second_angle)), self.y + radius * @sin(util.degreesToRadians(fourth_line_second_angle)));

    rl.drawLineEx(first_point, center_point, thickness, rl.Color.white);
    rl.drawLineEx(second_point, center_point, thickness, rl.Color.white);
    rl.drawLineEx(third_point, center_point, thickness, rl.Color.white);
    rl.drawLineEx(fourth_point, center_point, thickness, rl.Color.white);
    rl.drawLineEx(fifth_point, center_point, thickness, rl.Color.white);
    rl.drawLineEx(sixth_point, center_point, thickness, rl.Color.white);
    rl.drawLineEx(seventh_point, center_point, thickness, rl.Color.white);
    rl.drawLineEx(eighth_point, center_point, thickness, rl.Color.white);

    rl.drawCircleV(center_point, thickness / 2.0, rl.Color.white);
    rl.drawCircleV(first_point, thickness / 2.0, rl.Color.white);
    rl.drawCircleV(second_point, thickness / 2.0, rl.Color.white);
    rl.drawCircleV(third_point, thickness / 2.0, rl.Color.white);
    rl.drawCircleV(fourth_point, thickness / 2.0, rl.Color.white);
    rl.drawCircleV(fifth_point, thickness / 2.0, rl.Color.white);
    rl.drawCircleV(sixth_point, thickness / 2.0, rl.Color.white);
    rl.drawCircleV(seventh_point, thickness / 2.0, rl.Color.white);
    rl.drawCircleV(eighth_point, thickness / 2.0, rl.Color.white);
}
