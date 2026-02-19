import struct, zlib, math

def write_png(filename, size):
    W = H = size
    BG = [0x00, 0x80, 0x60, 0xFF]  # #008060 green
    FG = [0xFF, 0xFF, 0xFF, 0xFF]  # white
    TR = [0x00, 0x00, 0x00, 0x00]  # transparent

    pixels = [list(BG) for _ in range(W * H)]

    corner_r = size * 0.22

    for y in range(H):
        for x in range(W):
            cx0 = corner_r; cy0 = corner_r
            cx1 = W - corner_r; cy1 = H - corner_r
            in_rect = True
            if x < cx0 and y < cy0:
                in_rect = math.hypot(x - cx0, y - cy0) <= corner_r
            elif x > cx1 and y < cy0:
                in_rect = math.hypot(x - cx1, y - cy0) <= corner_r
            elif x < cx0 and y > cy1:
                in_rect = math.hypot(x - cx0, y - cy1) <= corner_r
            elif x > cx1 and y > cy1:
                in_rect = math.hypot(x - cx1, y - cy1) <= corner_r
            if not in_rect:
                pixels[y * W + x] = list(TR)

    def fill_rect(x0, y0, x1, y1):
        for y in range(max(0, y0), min(H, y1)):
            for x in range(max(0, x0), min(W, x1)):
                pixels[y * W + x] = list(FG)

    def fill_line(x0, y0, x1, y1, w):
        dx = abs(x1 - x0); dy = abs(y1 - y0)
        steps = max(dx, dy, 1)
        hw = w // 2
        for i in range(steps + 1):
            t = i / steps
            px = int(x0 + t * (x1 - x0))
            py = int(y0 + t * (y1 - y0))
            for oy in range(-hw, hw + 1):
                for ox in range(-hw, hw + 1):
                    if ox * ox + oy * oy <= (hw + 1) * (hw + 1):
                        nx, ny = px + ox, py + oy
                        if 0 <= nx < W and 0 <= ny < H:
                            pixels[ny * W + nx] = list(FG)

    s = size / 1024.0
    stroke = max(4, int(108 * s))
    top_y  = int(210 * s)
    bot_y  = int(810 * s)
    mid_y  = int(490 * s)
    left_x = int(190 * s)
    right_x = int(834 * s)
    mid_x  = int(512 * s)

    # Left vertical
    fill_rect(left_x, top_y, left_x + stroke, bot_y)
    # Right vertical
    fill_rect(right_x - stroke, top_y, right_x, bot_y)
    # Left diagonal (top-left → center)
    fill_line(left_x + stroke // 2, top_y, mid_x, mid_y, stroke)
    # Right diagonal (top-right → center)
    fill_line(right_x - stroke // 2, top_y, mid_x, mid_y, stroke)

    def make_chunk(name, data):
        c = name + data
        return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xFFFFFFFF)

    sig = b'\x89PNG\r\n\x1a\n'
    ihdr_data = struct.pack('>II', W, H) + bytes([8, 6, 0, 0, 0])
    ihdr = make_chunk(b'IHDR', ihdr_data)

    raw = b''
    for y in range(H):
        raw += b'\x00'
        for x in range(W):
            raw += bytes(pixels[y * W + x])

    idat = make_chunk(b'IDAT', zlib.compress(raw, 9))
    iend = make_chunk(b'IEND', b'')

    with open(filename, 'wb') as f:
        f.write(sig + ihdr + idat + iend)
    print(f"Written {filename} ({size}x{size})")

write_png('c:/Users/PC/Desktop/Projects/makhzani-app/mobile/assets/icon/icon.png', 1024)
