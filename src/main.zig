const std = @import("std");
const rl = @import("raylib");
const field = @import("./field_utilities.zig");
const util = @import("./utilities.zig");
const Bullet = @import("./Bullet.zig");
const Chase = @import("./Chase.zig");
const Player = @import("./Player.zig");
const Still = @import("./Still.zig");
const StillSmall = @import("./StillSmall.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    rl.setConfigFlags(rl.ConfigFlags{
        .msaa_4x_hint = true,
        .window_resizable = true,
    });
    rl.initWindow(400, 400, "raylib");
    defer rl.closeWindow();
    rl.setWindowSize(400, 400);
    rl.setWindowMinSize(300, 300);
    rl.setWindowTitle("Chases and Stills");

    var level: u8 = 0;
    var lives: u8 = 100;
    var player = Player{
        .x = util.getRenderWidth() / 2.0,
        .y = util.getRenderHeight() / 2.0,
        .angle = 0.0,
        .speed = 5.0,
        .rotate_speed = 5.0,
        .fire_delay = 1.0,
        .time_since_fire = 100.0,
    };

    level: while (true) {
        var arena = std.heap.ArenaAllocator.init(gpa.allocator());
        defer arena.deinit();
        const allocator = arena.allocator();

        const level_string: [:0]const u8 = std.fmt.allocPrintZ(allocator, "Level: {d}", .{level}) catch "";
        const lives_string: [:0]const u8 = std.fmt.allocPrintZ(allocator, "Lives: {d}", .{lives}) catch "";

        var bullets = std.ArrayList(Bullet).init(allocator);
        var mines = field.fieldGenerate(allocator, level);

        if (!field: while (true) {
            if (rl.isKeyDown(rl.KeyboardKey.key_left)) {
                player.rotateLeft();
            } else if (rl.isKeyDown(rl.KeyboardKey.key_right)) {
                player.rotateRight();
            }

            if (rl.isKeyDown(rl.KeyboardKey.key_up)) {
                player.move();
            } else if (rl.isKeyDown(rl.KeyboardKey.key_down)) {
                player.moveBackward();
            }

            if (rl.isKeyPressed(rl.KeyboardKey.key_z) and player.time_since_fire > player.fire_delay) {
                bullets.append(Bullet{
                    .x = player.x + (Player.radius + Bullet.radius) * @mod(util.cos(player.angle), util.getRenderWidth()),
                    .y = player.y + (Player.radius + Bullet.radius) * @mod(util.sin(player.angle), util.getRenderHeight()),
                    .angle = player.angle,
                    .speed = player.speed * 1.2,
                    .player_made = true,
                }) catch {};
                player.time_since_fire = 0.0;
            }

            for (mines.chases.items) |*chase| {
                chase.move(player.x, player.y);
            }

            for (mines.still_smalls.items) |*still_small_array| {
                for (still_small_array) |*still_small_optional| {
                    if (still_small_optional.*) |*still_small| {
                        still_small.move();
                    }
                }
            }

            for (mines.stills.items, 0..) |*still_optional, i| {
                if (still_optional.*) |*still| {
                    const bullet_info_optional: ?[3]?[4]f32 = still.fire(mines.still_smalls.items[i]);
                    if (bullet_info_optional) |bullet_info| {
                        for (bullet_info) |bullet_optional| {
                            if (bullet_optional) |bullet| {
                                bullets.append(Bullet{
                                    .x = bullet[2],
                                    .y = bullet[3],
                                    .angle = bullet[0],
                                    .speed = bullet[1],
                                    .player_made = false,
                                }) catch {};
                            }
                        }
                    }
                }
            }

            for (bullets.items) |*bullet| {
                bullet.move();
            }

            {
                rl.beginDrawing();
                defer rl.endDrawing();
                rl.clearBackground(rl.Color.black);

                player.draw();
                for (mines.chases.items) |*chase| {
                    chase.draw();
                }
                for (mines.stills.items, 0..) |*still_optional, i| {
                    if (still_optional.*) |*still| {
                        still.draw(&mines.still_smalls.items[i]);
                    }
                }
                for (mines.still_smalls.items) |still_small_array| {
                    for (still_small_array) |still_small_optional| {
                        if (still_small_optional) |still_small| {
                            still_small.draw();
                        }
                    }
                }
                for (bullets.items) |*bullet| {
                    bullet.draw();
                }

                rl.drawText(level_string, 10, 10, 20, rl.Color.white);
                rl.drawText(lives_string, 10, 30, 20, rl.Color.white);
                //rl.drawFPS(10, 50);
            }

            for (bullets.items, 0..) |bullet, i| {
                const player_vector = rl.Vector2.init(player.x, player.y);
                const bullet_vector = rl.Vector2.init(bullet.x, bullet.y);

                if (rl.checkCollisionCircles(player_vector, Player.collide_radius, bullet_vector, Bullet.collide_radius)) {
                    break :field false;
                }

                for (bullets.items, 0..) |second_bullet, j| {
                    if (i == j) continue;

                    const second_bullet_vector = rl.Vector2.init(second_bullet.x, second_bullet.y);

                    if (rl.checkCollisionCircles(bullet_vector, Bullet.collide_radius, second_bullet_vector, Bullet.collide_radius)) {
                        if (j > i) {
                            _ = bullets.swapRemove(j);
                            _ = bullets.swapRemove(i);
                        }
                    }
                }
            }

            for (mines.chases.items, 0..) |*chase, i| {
                const player_vector = rl.Vector2.init(player.x, player.y);
                const chase_vector = rl.Vector2.init(chase.x, chase.y);

                if (rl.checkCollisionCircles(player_vector, Player.collide_radius, chase_vector, Chase.collide_radius)) {
                    break :field false;
                }

                for (bullets.items, 0..) |bullet, j| {
                    const bullet_vector = rl.Vector2.init(bullet.x, bullet.y);

                    if (rl.checkCollisionCircles(bullet_vector, Bullet.collide_radius, chase_vector, Chase.collide_radius)) {
                        if (!chase.spin) {
                            chase.spin_angle = chase.angle;
                            chase.angle = bullet.angle;
                            chase.spin_speed = bullet.speed;
                            chase.spin = true;
                        } else {
                            _ = mines.chases.swapRemove(i);
                        }
                        _ = bullets.swapRemove(j);
                    }
                }
            }

            for (mines.still_smalls.items, 0..) |*still_small_array, i| {
                for (still_small_array, 0..) |*still_small_optional, j| {
                    if (still_small_optional.*) |*still_small| {
                        const still_small_vector = rl.Vector2.init(still_small.x, still_small.y);
                        if (still_small.split) {
                            const player_vector = rl.Vector2.init(player.x, player.y);

                            if (rl.checkCollisionCircles(player_vector, Player.collide_radius, still_small_vector, StillSmall.player_collide_radius)) {
                                break :field false;
                            }
                        }

                        for (bullets.items, 0..) |bullet, k| {
                            const bullet_vector = rl.Vector2.init(bullet.x, bullet.y);

                            if (rl.checkCollisionCircles(still_small_vector, StillSmall.collide_radius, bullet_vector, Bullet.collide_radius)) {
                                mines.still_smalls.items[i][j] = null;
                                _ = bullets.swapRemove(k);
                            }
                        }
                        if (still_small.split_time >= 10.0) {
                            const x = still_small.x;
                            const y = still_small.y;
                            const angle = still_small.angle;
                            const speed = still_small.speed;
                            mines.still_smalls.append(.{
                                StillSmall{
                                    .x = 0.0,
                                    .y = 0.0,
                                    .angle = 0.0,
                                    .speed = 0.0,
                                },
                                StillSmall{
                                    .x = 0.0,
                                    .y = 0.0,
                                    .angle = 0.0,
                                    .speed = 0.0,
                                },
                                StillSmall{
                                    .x = 0.0,
                                    .y = 0.0,
                                    .angle = 0.0,
                                    .speed = 0.0,
                                },
                            }) catch {};
                            mines.stills.append(Still{
                                .x = x,
                                .y = y,
                                .angle = angle,
                                .spin_speed = speed,
                                .fire_rate = 5.0,
                            }) catch {};
                            mines.still_smalls.items[i][j] = null;
                        }
                    }
                }
            }

            for (mines.stills.items, 0..) |*still_optional, i| {
                if (still_optional.*) |*still| {
                    const player_vector = rl.Vector2.init(player.x, player.y);
                    const still_vector = rl.Vector2.init(still.x, still.y);

                    if (rl.checkCollisionCircles(player_vector, Player.collide_radius, still_vector, Still.collide_radius)) {
                        break :field false;
                    }

                    for (bullets.items, 0..) |bullet, j| {
                        const bullet_vector = rl.Vector2.init(bullet.x, bullet.y);

                        if (rl.checkCollisionCircles(bullet_vector, Bullet.collide_radius, still_vector, Still.collide_radius)) {
                            still.release(&mines.still_smalls.items[i]);
                            mines.stills.items[i] = null;
                            _ = bullets.swapRemove(j);
                        }
                    }
                }
            }
            if (mines.chases.items.len <= 0) {
                still_small_array_loop: for (mines.still_smalls.items) |still_small_array| {
                    for (still_small_array) |still_small| {
                        if (still_small) |_| break :still_small_array_loop;
                    }
                } else still_array_loop: for (mines.stills.items) |still| {
                    if (still) |_| break :still_array_loop;
                } else break :field true;
            }

            player.time_since_fire += rl.getFrameTime();

            if (rl.isKeyPressed(rl.KeyboardKey.key_f)) {
                rl.toggleFullscreen();
            }
            if (rl.windowShouldClose() and !rl.isKeyPressed(rl.KeyboardKey.key_escape)) {
                break :level;
            }
        }) {
            if (lives == 0) {
                break;
            }
            player.x = util.getRenderWidth() / 2;
            player.y = util.getRenderHeight() / 2;
            player.angle = 0.0;
            player.time_since_fire = 100.0;
            lives -= 1;
            continue;
        } else {
            player.x = util.getRenderWidth() / 2.0;
            player.y = util.getRenderHeight() / 2.0;
            player.angle = 0.0;
            player.time_since_fire = 100.0;
            level += 1;
        }
    }
}
