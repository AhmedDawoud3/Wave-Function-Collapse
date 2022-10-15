local module = {
  _license = [[
    Copyright (c) 2022 Ahmed Dawoud
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
  ]],
}
local Tile = {}

Tile.__index = Tile

-- Initlize the tile with its properties.
local function new(imgData, rotation)
  w = imgData:getWidth()
  h = imgData:getHeight()
  image = love.graphics.newImage(imgData)

  -- Get an array of the upper row of pixels
  upPixels = {}
  for i = 0, imgData:getHeight() - 1 do
    local r, g, b, _ = imgData:getPixel(i, 0)
    table.insert(upPixels, r + g * 10 + b * 10 * 10)
  end

  rightPixels = {}
  for i = 0, imgData:getWidth() - 1 do
    local r, g, b, _ = imgData:getPixel(imgData:getWidth() - 1, i)
    table.insert(rightPixels, r + g * 10 + b * 10 * 10)
  end

  downPixels = {}
  for i = 0, imgData:getHeight() - 1 do
    local r, g, b, _ = imgData:getPixel(i, imgData:getHeight() - 1)
    table.insert(downPixels, r + g * 10 + b * 10 * 10)
  end

  leftPixels = {}
  for i = 0, imgData:getWidth() - 1 do
    local r, g, b, _ = imgData:getPixel(0, i)
    table.insert(leftPixels, r + g * 10 + b * 10 * 10)
  end

  -- Set the default value for rotation to be 0
  rotation = rotation or 0

  -- If rotated, shift the sides
  if rotation == 1 then
    upPixels, rightPixels, downPixels, leftPixels = leftPixels, upPixels, rightPixels, downPixels
  elseif rotation == 2 then
    upPixels, rightPixels, downPixels, leftPixels = downPixels, leftPixels, upPixels, rightPixels
  elseif rotation == 3 then
    upPixels, rightPixels, downPixels, leftPixels = rightPixels, downPixels, leftPixels, upPixels
  end
  return setmetatable({
    w = w,
    h = h,
    image = image,
    upPixels = upPixels,
    rightPixels = rightPixels,
    downPixels = downPixels,
    leftPixels = leftPixels,
    rotation = rotation,
  }, Tile)
end

function Tile:Draw(x, y)
  local xScaleFactor = WIDTH / DIM * 1 / self.w
  local yScaleFactor = HEIGHT / DIM * 1 / self.h

  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.scale(xScaleFactor, yScaleFactor)
  love.graphics.draw(self.image, self.w / 2, self.h / 2, self.rotation * math.pi / 2, 1, 1, self.w / 2, self.h / 2)
  love.graphics.pop()
end

--[[Functions to check if a tiles can go with another one]]
function Tile:CanGoBellow(tile) return IsTheSameTable(self.upPixels, tile.downPixels) or tile.downPixels == nil end
function Tile:CanGoAbove(tile) return IsTheSameTable(self.downPixels, tile.upPixels) or tile.upPixels == nil end
function Tile:CanGoOnRight(tile) return IsTheSameTable(self.leftPixels, tile.rightPixels) or tile.rightPixels == nil end
function Tile:CanGoOnLeft(tile) return IsTheSameTable(self.rightPixels, tile.leftPixels) or tile.leftPixels == nil end
-- General Case
function Tile:CanGoWith(tile)
  return self:CanGoBellow(tile) or self:CanGoAbove(tile) or self:CanGoOnRight(tile) or self:CanGoOnLeft(tile)
end

module.new = new
return setmetatable(module, {
  __call = function(_, ...) return new(...) end,
})
