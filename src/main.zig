const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = gpa.allocator();

fn input(msg: ?[]const u8) ![]u8 {
    if (msg) |m| {
        std.debug.print("{s}", .{m});
    }
    const stdin = std.io.getStdIn();
    var buff: [1024]u8 = undefined;
    const len = stdin.read(&buff);
    const ln = len catch |err| {
        return err;
    };
    var line = buff[0..ln];
    if (ln > 1 and line[ln - 1] == '\n') {
        line = line[0 .. ln - 1];
    }
    return line;
}
fn get_n() u8 {
    var line = input("%n -> ");
    var n: u8 = undefined;
    while (true) {
        const ex_line = line catch |err| {
            std.debug.print("Read error: {}\n", .{err});
            continue;
        };
        const ex_n = std.fmt.parseInt(u8, ex_line, 10) catch {
            std.debug.print("n must be u8\n", .{});
            line = input("%n -> ");
            continue;
        };
        n = ex_n;
        break;
    }
    return n;
}

fn circle(n: u8, m: *std.ArrayList(std.ArrayList(u8)), cx: i9, cy: i9, r: i9) void {
    std.debug.print("n: {}, cx: {}, cy: {}, r: {}\n", .{ n, cx, cy, r });
    var x: i9 = 0;
    var y: i9 = -r;
    var p: i9 = -r;
    while (x < -y) {
        if (p > 0) {
            y += 1;
            p += 2 * (x + y) + 1;
        } else {
            p += 2 * x + 1;
        }
        m.*.items[@abs(cx + x)].items[@abs(cy + y)] = 1;
        m.*.items[@abs(cx - x)].items[@abs(cy + y)] = 1;
        m.*.items[@abs(cx + x)].items[@abs(cy - y)] = 1;
        m.*.items[@abs(cx + x)].items[@abs(cy - y)] = 1;
        m.*.items[@abs(cx - x)].items[@abs(cy - y)] = 1;
        m.*.items[@abs(cx + y)].items[@abs(cy + x)] = 1;
        m.*.items[@abs(cx - y)].items[@abs(cy + x)] = 1;
        m.*.items[@abs(cx + y)].items[@abs(cy - x)] = 1;
        m.*.items[@abs(cx - y)].items[@abs(cy - x)] = 1;

        x += 1;
    }
}

fn matrix(allocator: std.mem.Allocator, n: u8) !std.ArrayList(std.ArrayList(u8)) {
    var m = std.ArrayList(std.ArrayList(u8)).init(allocator);
    try m.ensureTotalCapacity(n); // Резервируем место заранее

    for (0..n) |_| {
        var temp = std.ArrayList(u8).init(allocator);
        errdefer temp.deinit(); // Важно: очищаем temp в случае ошибки

        try temp.ensureTotalCapacity(n); // Резервируем место заранее
        for (0..n) |_| {
            try temp.append(0);
        }
        try m.append(temp); // Создаем КОПИЮ temp!
    }

    return m;
}

pub fn main() !void {
    const n = get_n();
    var m = try matrix(alloc, n);
    circle(n, &m, @divFloor(n, 2), @divFloor(n, 2), @divFloor(n, 2));
    for (0..n, m.items) |_, line| {
        for (0..n, line.items) |_, elem| {
            switch (elem) {
                0 => {
                    std.debug.print("\x1b[0;30m{} \x1b[0;m", .{elem});
                },
                else => {
                    std.debug.print("\x1b[0;m{} \x1b[0;m", .{elem});
                },
            }
        }
        std.debug.print("\n", .{});
    }
}
