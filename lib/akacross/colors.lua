local Colors = {}
Colors._VERSION = '0.1.0'
Colors.__index = Colors

local function round(value)
    return math.floor(value + 0.5)
end

function Colors.convertColor(color, normalize, includeAlpha, outputHSVA)
    if type(color) ~= "number" then
        error("Invalid color value. Expected a number.")
    end

    local a = includeAlpha and bit.band(bit.rshift(color, 24), 0xFF) or 255
    local r = bit.band(bit.rshift(color, 16), 0xFF)
    local g = bit.band(bit.rshift(color, 8), 0xFF)
    local b = bit.band(color, 0xFF)

    if normalize then
        a, r, g, b = a / 255, r / 255, g / 255, b / 255
    end

    if outputHSVA then
        local h, s, v = RGBtoHSV(r, g, b)
        if includeAlpha then
            return {h = h, s = s, v = v, a = a}
        else
            return {h = h, s = s, v = v}
        end
    end

    if includeAlpha then
        return {r = r, g = g, b = b, a = a}
    else
        return {r = r, g = g, b = b}
    end
end

function Colors.joinARGB(a, r, g, b, normalized)
    if normalized then
        a, r, g, b = round(a * 255), round(r * 255), round(g * 255), round(b * 255)
    end

    local function clamp(value)
        return math.max(0, math.min(255, value))
    end

    a, r, g, b = clamp(a), clamp(r), clamp(g), clamp(b)

    local color = bit.bor(
        bit.lshift(a, 24), 
        bit.lshift(r, 16), 
        bit.lshift(g, 8), 
        b
    )

    return color
end

function Colors.changeAlpha(color, newAlpha, format)
    newAlpha = math.max(0, math.min(255, newAlpha))
    format = format or "ARGB"

    if format == "ARGB" then
        local rgb = bit.band(color, 0x00FFFFFF)
        return bit.bor(bit.lshift(newAlpha, 24), rgb)
    elseif format == "RGBA" then
        local rgb = bit.band(color, 0xFFFFFF00)
        return bit.bor(rgb, newAlpha)
    else
        error("Invalid format specified. Use 'ARGB' or 'RGBA'.")
    end
end

function Colors.toUnsignedColor(color)
    return color % (2^32)
end

-- Convert normalized RGB to HSV
function Colors.RGBtoHSV(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min

    local h, s, v = 0, 0, max

    if delta > 0 then
        if max == r then
            h = (g - b) / delta % 6
        elseif max == g then
            h = (b - r) / delta + 2
        else -- max == b
            h = (r - g) / delta + 4
        end
        h = h * 60
        if h < 0 then h = h + 360 end

        s = delta / max
    else
        h = 0
        s = 0
    end

    -- Handle edge cases for white and black
    if max == 0 then
        s = 0
    end

    return h, s, v
end

-- Convert HSV to normalized RGB
function Colors.HSVtoRGB(h, s, v)
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c

    local r1, g1, b1 = 0, 0, 0

    if h >= 0 and h < 60 then
        r1, g1, b1 = c, x, 0
    elseif h >= 60 and h < 120 then
        r1, g1, b1 = x, c, 0
    elseif h >= 120 and h < 180 then
        r1, g1, b1 = 0, c, x
    elseif h >= 180 and h < 240 then
        r1, g1, b1 = 0, x, c
    elseif h >= 240 and h < 300 then
        r1, g1, b1 = x, 0, c
    else -- h >= 300 and h < 360
        r1, g1, b1 = c, 0, x
    end

    local r = r1 + m
    local g = g1 + m
    local b = b1 + m

    return r, g, b
end

return Colors