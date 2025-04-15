local imgui_funcs = {}
imgui_funcs._VERSION = '0.1.3'
imgui_funcs.__index = imgui_funcs

local tempOffset = {x = 0, y = 0}
local currentlyDragging = nil

function imgui_funcs.handleWindowDragging(menuId, pos, size, pivot, dragging)
    if not dragging then
        return {x = pos.x, y = pos.y}, false
    end

    local mpos = imgui.GetMousePos()
    local offset = {x = size.x * pivot.x, y = size.y * pivot.y}
    local boxPos = {x = pos.x - offset.x, y = pos.y - offset.y}

    local screenWidth, screenHeight = imgui.GetIO().DisplaySize.x, imgui.GetIO().DisplaySize.y

    if mpos.x >= boxPos.x and mpos.x <= boxPos.x + size.x and mpos.y >= boxPos.y and mpos.y <= boxPos.y + size.y then
        if imgui.IsMouseClicked(0) and not imgui.IsAnyItemHovered() then
            currentlyDragging = menuId
            tempOffset = {x = mpos.x - boxPos.x, y = mpos.y - boxPos.y}
        end
    end

    if currentlyDragging == menuId then
        if imgui.IsMouseReleased(0) then
            currentlyDragging = nil
        else
            local newBoxPos = {x = mpos.x - tempOffset.x, y = mpos.y - tempOffset.y}

            local style = imgui.GetStyle()
            local borderSize = style.WindowBorderSize
            newBoxPos.x = math.max(borderSize, math.min(newBoxPos.x, screenWidth - size.x - borderSize / 2 + 1))
            newBoxPos.y = math.max(borderSize, math.min(newBoxPos.y, screenHeight - size.y - borderSize / 2 + 1))

            return {x = newBoxPos.x + offset.x, y = newBoxPos.y + offset.y}, true
        end
    end

    return {x = pos.x, y = pos.y}, false
end

function imgui_funcs.resetCurrentWindowDragging()
    currentlyDragging = nil
end

function imgui_funcs.calcTextSize(text)
    local processedText = text:gsub("{%x+}", "")
    return imgui.CalcTextSize(processedText)
end

function imgui_funcs.calculateWindowSize(lines, padding)
    local totalHeight = 0
    local maxWidth = 0
    local lineSpacing = imgui.GetTextLineHeightWithSpacing() - imgui.GetTextLineHeight()

    for _, text in ipairs(lines) do
        local textSize = imgui_funcs.calcTextSize(text)
        totalHeight = totalHeight + textSize.y + lineSpacing
        if textSize.x > maxWidth then
            maxWidth = textSize.x
        end
    end
    totalHeight = totalHeight - lineSpacing

    local windowSize = imgui.ImVec2(
        maxWidth + padding.x * 2,
        totalHeight + padding.y * 2
    )
    return windowSize
end

function imgui_funcs.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local col = imgui.Col

    local function designText(text__)
        local pos = imgui.GetCursorPos()
        if sampGetChatDisplayMode() == 2 then
            for i = 1, 1 --[[Shadow degree]] do
                imgui.SetCursorPos(imgui.ImVec2(pos.x + i, pos.y))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
                imgui.SetCursorPos(imgui.ImVec2(pos.x - i, pos.y))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
                imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y + i))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
                imgui.SetCursorPos(imgui.ImVec2(pos.x, pos.y - i))
                imgui.TextColored(imgui.ImVec4(0, 0, 0, 1), text__) -- shadow
            end
        end
        imgui.SetCursorPos(pos)
    end

    -- Ensure color codes are in the form of {RRGGBBAA}
    text = text:gsub('{(%x%x%x%x%x%x)}', '{%1FF}')

    local color = colors[col.Text]
    local start = 1
    local a, b = text:find('{........}', start)

    while a do
        local t = text:sub(start, a - 1)
        if #t > 0 then
            designText(t)
            imgui.TextColored(color, t)
            imgui.SameLine(nil, 0)
        end

        local clr = text:sub(a + 1, b - 1)
        if clr:upper() == 'STANDART' then
            color = colors[col.Text]
        else
            clr = tonumber(clr, 16)
            if clr then
                local r = bit.band(bit.rshift(clr, 24), 0xFF)
                local g = bit.band(bit.rshift(clr, 16), 0xFF)
                local b = bit.band(bit.rshift(clr, 8), 0xFF)
                local a = bit.band(clr, 0xFF)
                color = imgui.ImVec4(r / 255, g / 255, b / 255, a / 255)
            end
        end

        start = b + 1
        a, b = text:find('{........}', start)
    end

    imgui.NewLine()
    if #text >= start then
        imgui.SameLine(nil, 0)
        designText(text:sub(start))
        imgui.TextColored(color, text:sub(start))
    end
end

function imgui_funcs.CustomButton(name, color, colorHovered, colorActive, textColor, size)
    local clr = imgui.Col
    imgui.PushStyleColor(clr.Button, color)
    imgui.PushStyleColor(clr.ButtonHovered, colorHovered)
    imgui.PushStyleColor(clr.ButtonActive, colorActive)
    imgui.PushStyleColor(clr.Text, textColor)
    if not size then size = imgui.ImVec2(0, 0) end
    local result = imgui.Button(name, size)
    imgui.PopStyleColor(4)
    return result
end

function imgui_funcs.CustomTooltip(tooltip)
    if imgui.IsItemHovered() and tooltip then
        imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(8, 8))
        imgui.BeginTooltip()
        imgui_funcs.TextColoredRGB(tooltip)
        imgui.EndTooltip()
        imgui.PopStyleVar()
    end
end

function imgui_funcs.loadFontIcons(fileOrMemory, fontSize, min, max, fontdata)
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    local iconRanges = imgui.new.ImWchar[3](min, max, 0)
	if fileOrMemory then
		imgui.GetIO().Fonts:AddFontFromFileTTF(fontdata, fontSize, config, iconRanges)
	else
		imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fontdata, fontSize, config, iconRanges)
	end
end

return imgui_funcs
