const std = @import("std");
const rl = @import("raylib");
const util = @import("./utilities.zig");
const Chase = @import("./Chase.zig");
const Still = @import("./Still.zig");
const StillSmall = @import("./StillSmall.zig");

var engine = std.Random.DefaultPrng.init(0);

const Mines = struct {
    chases: std.ArrayList(Chase),
    stills: std.ArrayList(?Still),
    still_smalls: std.ArrayList([3]?StillSmall),
};

pub fn fieldGenerate(allocator: std.mem.Allocator, id: u8) Mines {
    var chases = std.ArrayList(Chase).init(allocator);
    var stills = std.ArrayList(?Still).init(allocator);
    var still_smalls = std.ArrayList([3]?StillSmall).init(allocator);

    engine.seed(id);

    const random = engine.random();

    switch (id) {
        0 => {
            still_smalls.append(.{
                StillSmall{
                    .x = 50.0,
                    .y = util.getRenderHeight() - 50.0,
                    .angle = 0.0,
                    .speed = 0.5,
                },
                StillSmall{
                    .x = 50.0,
                    .y = util.getRenderHeight() - 50.0,
                    .angle = 0.0,
                    .speed = 0.5,
                },
                StillSmall{
                    .x = 50.0,
                    .y = util.getRenderHeight() - 50.0,
                    .angle = 0.0,
                    .speed = 0.5,
                },
            }) catch {};
            stills.append(Still{
                .x = 50.0,
                .y = util.getRenderHeight() - 50.0,
                .angle = 0.0,
                .spin_speed = 0.5,
                .fire_rate = 5.0,
            }) catch {};
            chases.append(Chase{
                .x = util.getRenderWidth() - 50.0,
                .y = util.getRenderHeight() - 50.0,
                .angle = 0.0,
                .speed = 1.0,
            }) catch {};
        },
        else => {
            const chase_amount: u2 = std.Random.intRangeAtMost(random, u2, 1, 3);

            var i: u2 = 0;
            while (i < chase_amount) : (i += 1) {
                const random_x: u16 = std.Random.intRangeAtMost(random, u16, 0, @intFromFloat(util.getRenderWidth() - 100.0));
                const random_y: u16 = std.Random.intRangeAtMost(random, u16, 0, @intFromFloat(util.getRenderHeight() - 100.0));
                var x: f32 = 0.0;
                var y: f32 = 0.0;

                if (random_x > @as(u16, @intFromFloat((util.getRenderWidth() - 100.0) / 2.0))) {
                    x = @floatFromInt(random_x + 100);
                } else {
                    x = @floatFromInt(random_x);
                }
                if (random_y > @as(u16, @intFromFloat((util.getRenderHeight() - 100.0) / 2.0))) {
                    y = @floatFromInt(random_y + 100);
                } else {
                    y = @floatFromInt(random_y);
                }

                chases.append(Chase{
                    .x = x,
                    .y = y,
                    .angle = 0.0,
                    .speed = 1.0,
                }) catch {};
            }

            const still_amount: u2 = std.Random.intRangeAtMost(random, u2, 1, 3);

            i = 0;
            while (i < still_amount) : (i += 1) {
                const random_x: u16 = std.Random.intRangeAtMost(random, u16, 0, @intFromFloat(util.getRenderWidth() - 100.0));
                const random_y: u16 = std.Random.intRangeAtMost(random, u16, 0, @intFromFloat(util.getRenderHeight() - 100.0));
                const random_angle: u9 = std.Random.intRangeAtMost(random, u9, 0, 400);
                var x: f32 = 0.0;
                var y: f32 = 0.0;
                var angle: f32 = 0.0;

                if (random_x > @as(u16, @intFromFloat((util.getRenderWidth() - 100.0) / 2.0))) {
                    x = @floatFromInt(random_x + 100);
                } else {
                    x = @floatFromInt(random_x);
                }
                if (random_y > @as(u16, @intFromFloat((util.getRenderHeight() - 100.0) / 2.0))) {
                    y = @floatFromInt(random_y + 100);
                } else {
                    y = @floatFromInt(random_y);
                }
                angle = @floatFromInt(random_angle);

                still_smalls.append(.{
                    StillSmall{
                        .x = x,
                        .y = y,
                        .angle = angle,
                        .speed = 0.5,
                    },
                    StillSmall{
                        .x = x,
                        .y = y,
                        .angle = angle,
                        .speed = 0.5,
                    },
                    StillSmall{
                        .x = x,
                        .y = y,
                        .angle = angle,
                        .speed = 0.5,
                    },
                }) catch {};
                stills.append(Still{
                    .x = x,
                    .y = y,
                    .angle = angle,
                    .spin_speed = 0.5,
                    .fire_rate = 5.0,
                }) catch {};
            }
        },
    }
    return Mines{ .chases = chases, .stills = stills, .still_smalls = still_smalls };
}
